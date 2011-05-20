Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D9A88900114
	for <linux-mm@kvack.org>; Fri, 20 May 2011 18:47:46 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p4KMlaEM003481
	for <linux-mm@kvack.org>; Fri, 20 May 2011 15:47:41 -0700
Received: from pxi9 (pxi9.prod.google.com [10.243.27.9])
	by kpbe14.cbf.corp.google.com with ESMTP id p4KMlYrB011948
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 20 May 2011 15:47:35 -0700
Received: by pxi9 with SMTP id 9so4809789pxi.28
        for <linux-mm@kvack.org>; Fri, 20 May 2011 15:47:34 -0700 (PDT)
Date: Fri, 20 May 2011 15:47:33 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] tmpfs: fix highmem swapoff crash regression
Message-ID: <alpine.LSU.2.00.1105201535530.1899@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Witold Baryluk <baryluk@smp.if.uj.edu.pl>, Nitin Gupta <ngupta@vflare.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Commit 778dd893ae78 "tmpfs: fix race between umount and swapoff"
forgot the new rules for strict atomic kmap nesting, causing
WARNING: at arch/x86/mm/highmem_32.c:81 from __kunmap_atomic(), then
BUG: unable to handle kernel paging request at fffb9000 from shmem_swp_set()
when shmem_unuse_inode() is handling swapoff with highmem in use.
My disgrace again.  See https://bugzilla.kernel.org/show_bug.cgi?id=35352

Reported-by: Witold Baryluk <baryluk@smp.if.uj.edu.pl>
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@kernel.org
---

 mm/shmem.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- 2.6.39/mm/shmem.c	2011-05-18 21:06:34.000000000 -0700
+++ linux/mm/shmem.c	2011-05-20 13:57:20.778870967 -0700
@@ -916,11 +916,12 @@ static int shmem_unuse_inode(struct shme
 			if (size > ENTRIES_PER_PAGE)
 				size = ENTRIES_PER_PAGE;
 			offset = shmem_find_swp(entry, ptr, ptr+size);
+			shmem_swp_unmap(ptr);
 			if (offset >= 0) {
 				shmem_dir_unmap(dir);
+				ptr = shmem_swp_map(subdir);
 				goto found;
 			}
-			shmem_swp_unmap(ptr);
 		}
 	}
 lost1:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
