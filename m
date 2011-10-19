Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CA66A6B002C
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 15:50:59 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p9JJoqfh008480
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 12:50:52 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by hpaq14.eem.corp.google.com with ESMTP id p9JJlIaM022975
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 12:50:50 -0700
Received: by pzk2 with SMTP id 2so7181311pzk.4
        for <linux-mm@kvack.org>; Wed, 19 Oct 2011 12:50:50 -0700 (PDT)
Date: Wed, 19 Oct 2011 12:50:35 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: fix race between mremap and removing migration entry
Message-ID: <alpine.LSU.2.00.1110191243300.6980@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, Justin Piszcz <jpiszcz@lucidpixels.com>, arekm@pid-linux.org, Anders Ossowicki <aowi@novozymes.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

I don't usually pay much attention to the stale "? " addresses in
stack backtraces, but this lucky report from Pawel Sikora hints that
mremap's move_ptes() has inadequate locking against page migration.

 3.0 BUG_ON(!PageLocked(p)) in migration_entry_to_page():
 kernel BUG at include/linux/swapops.h:105!
 RIP: 0010:[<ffffffff81127b76>]  [<ffffffff81127b76>]
                       migration_entry_wait+0x156/0x160
  [<ffffffff811016a1>] handle_pte_fault+0xae1/0xaf0
  [<ffffffff810feee2>] ? __pte_alloc+0x42/0x120
  [<ffffffff8112c26b>] ? do_huge_pmd_anonymous_page+0xab/0x310
  [<ffffffff81102a31>] handle_mm_fault+0x181/0x310
  [<ffffffff81106097>] ? vma_adjust+0x537/0x570
  [<ffffffff81424bed>] do_page_fault+0x11d/0x4e0
  [<ffffffff81109a05>] ? do_mremap+0x2d5/0x570
  [<ffffffff81421d5f>] page_fault+0x1f/0x30

mremap's down_write of mmap_sem, together with i_mmap_mutex or lock,
and pagetable locks, were good enough before page migration (with its
requirement that every migration entry be found) came in, and enough
while migration always held mmap_sem; but not enough nowadays, when
there's memory hotremove and compaction.

The danger is that move_ptes() lets a migration entry dodge around
behind remove_migration_pte()'s back, so it's in the old location when
looking at the new, then in the new location when looking at the old.

Either mremap's move_ptes() must additionally take anon_vma lock(), or
migration's remove_migration_pte() must stop peeking for is_swap_entry()
before it takes pagetable lock.

Consensus chooses the latter: we prefer to add overhead to migration
than to mremapping, which gets used by JVMs and by exec stack setup.

Reported-by: Pawel Sikora <pluto@agmk.net>
Signed-off-by: Hugh Dickins <hughd@google.com>
Acked-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Cc: stable@vger.kernel.org
---

 mm/migrate.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

--- 3.1-rc10/mm/migrate.c	2011-07-21 19:17:23.000000000 -0700
+++ linux/mm/migrate.c	2011-10-19 11:48:51.243961016 -0700
@@ -120,10 +120,10 @@ static int remove_migration_pte(struct p
 
 		ptep = pte_offset_map(pmd, addr);
 
-		if (!is_swap_pte(*ptep)) {
-			pte_unmap(ptep);
-			goto out;
-		}
+		/*
+		 * Peek to check is_swap_pte() before taking ptlock?  No, we
+		 * can race mremap's move_ptes(), which skips anon_vma lock.
+		 */
 
 		ptl = pte_lockptr(mm, pmd);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
