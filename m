Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D0C5A6B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 19:37:32 -0500 (EST)
Received: by ti-out-0910.google.com with SMTP id u3so257270tia.8
        for <linux-mm@kvack.org>; Wed, 04 Feb 2009 16:37:30 -0800 (PST)
Date: Thu, 5 Feb 2009 09:37:00 +0900
From: MinChan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2][RESEND] fix mlocked page counter mismatch
Message-ID: <20090205003700.GA26618@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux kernel <linux-kernel@vger.kernel.org>, linux mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I will resend this patch with Kosaki-san's ACK.

-- 

When I tested following program, I found that mlocked counter
is strange.
It couldn't free some mlocked pages of test program.
It is caused that try_to_unmap_file don't check real
page mapping in vmas.

That's because goal of address_space for file is to find all processes
into which the file's specific interval is mapped.
What I mean is that it's not related page but file's interval.

Even if the page isn't really mapping at the vma, it returns
SWAP_MLOCK since the vma have VM_LOCKED, then calls
try_to_mlock_page. After all, mlocked counter is increased again.

COWed anon page in a file-backed vma could be a such case.
This patch resolves it.

This patch is based on 2.6.28-rc2-mm1.

-- my test program --

int main()
{
       mlockall(MCL_CURRENT);
       return 0;
}

-- before --

root@barrios-target-linux:~# cat /proc/meminfo | egrep 'Mlo|Unev'
Unevictable:           0 kB
Mlocked:               0 kB

-- after --

root@barrios-target-linux:~# cat /proc/meminfo | egrep 'Mlo|Unev'
Unevictable:           8 kB
Mlocked:               8 kB


Signed-off-by: MinChan Kim <minchan.kim@gmail.com>
Acked-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Tested-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

---
 mm/rmap.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 1099394..bd24b55 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1080,7 +1080,8 @@ static int try_to_unmap_file(struct page *page, int unlock, int migration)
 	spin_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		if (MLOCK_PAGES && unlikely(unlock)) {
-			if (!(vma->vm_flags & VM_LOCKED))
+			if (!((vma->vm_flags & VM_LOCKED) &&
+						page_mapped_in_vma(page, vma)))
 				continue;	/* must visit all vmas */
 			ret = SWAP_MLOCK;
 		} else {
-- 
1.5.4.3

-- 
Kinds Regards
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
