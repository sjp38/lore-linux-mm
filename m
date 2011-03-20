Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DCED08D0039
	for <linux-mm@kvack.org>; Sun, 20 Mar 2011 02:28:00 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p2K6RvNT003172
	for <linux-mm@kvack.org>; Sat, 19 Mar 2011 23:27:57 -0700
Received: from pwj3 (pwj3.prod.google.com [10.241.219.67])
	by hpaq14.eem.corp.google.com with ESMTP id p2K6RsW8008981
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 19 Mar 2011 23:27:56 -0700
Received: by pwj3 with SMTP id 3so983475pwj.15
        for <linux-mm@kvack.org>; Sat, 19 Mar 2011 23:27:54 -0700 (PDT)
Date: Sat, 19 Mar 2011 23:27:38 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: compaction beware writeback
Message-ID: <alpine.LSU.2.00.1103192318100.1877@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

I notice there's a Bug 31142 "Large write to USB stick freezes"
discussion happening (which I've not digested), for which Andrea
is proposing a patch which reminds me of this one.  Thought I'd
better throw this into the mix for consideration.

I'd not sent it in yet, because I only see the problem on one machine,
and then only with a shmem patch I'm working up; but can't see how
that patch would actually be necessary to create the problem.

It happens in my extfs-on-loop-on-tmpfs swapping tests, when copying
in the kernel tree.  I believe the relevant traces are these three:
I notice sync_supers there every time it hangs, but I guess it comes
along after, and gets stuck on the same page which cp is waiting for.

D  sync_supers:
schedule +0x670
io_schedule +0x50
sync_buffer +0x68
__wait_on_bit +0x90
out_of_line_wait_on_bit +0x98
__wait_on_buffer +0x30
__sync_dirty_buffer +0xc0
ext4_commit_super +0x2c4
ext4_write_super +0x28
sync_supers +0xdc
bdi_sync_supers +0x40
kthread +0xac
kernel_thread +0x54

D  loop0:
schedule +0x670
io_schedule +0x50
sync_page +0x84
__wait_on_bit +0x90
wait_on_page_bit +0xa4
unmap_and_move +0x180
migrate_pages +0xbc
compact_zone +0xbc
compact_zone_order +0xc8
try_to_compact_pages +0x104
__alloc_pages_direct_compact +0xc0
__alloc_pages_nodemask +0x68c
allocate_slab +0x84
new_slab +0x58
__slab_alloc +0x1ec
kmem_cache_alloc +0x7c
radix_tree_preload +0x94
add_to_page_cache_locked +0x78
shmem_getpage +0x208
pagecache_write_begin +0x2c
do_lo_send_aops +0xc0
do_bio_filebacked +0x11c
loop_thread +0x204
kthread +0xac
kernel_thread +0x54

D  cp:
schedule +0x670
io_schedule +0x50
sync_buffer +0x68
__wait_on_bit +0x90
out_of_line_wait_on_bit +0x98
__wait_on_buffer +0x30
ext4_find_entry +0x230
ext4_lookup +0x44
d_alloc_and_lookup +0x74
do_last +0xe0
do_filp_open +0x2b8
do_sys_open +0x8c
compat_sys_open +0x24
syscall_exit +0x0

I believe (but haven't verified for sure) that what happens is that
compaction (when trying to allocate a radix_tree node - SLUB asks
for order 2 - in the loop0 daemon trace) chooses the cp page under
writeback which is waiting for loop0 to write it.

So I've extended your earlier PF_MEMALLOC patch to prevent waiting for
writeback as well as waiting for pagelock.  And I've never seen the
hang again since putting this patch in.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/migrate.c |   38 +++++++++++++++++++++-----------------
 1 file changed, 21 insertions(+), 17 deletions(-)

--- 2.6.38/mm/migrate.c	2011-03-14 18:20:32.000000000 -0700
+++ linux/mm/migrate.c	2011-03-15 06:36:26.000000000 -0700
@@ -637,29 +637,33 @@ static int unmap_and_move(new_page_t get
 		if (unlikely(split_huge_page(page)))
 			goto move_newpage;
 
+	/*
+	 * It's not safe for direct compaction to call lock_page.
+	 * For example, during page readahead pages are added locked
+	 * to the LRU. Later, when the IO completes the pages are
+	 * marked uptodate and unlocked. However, the queueing
+	 * could be merging multiple pages for one bio (e.g.
+	 * mpage_readpages). If an allocation happens for the
+	 * second or third page, the process can end up locking
+	 * the same page twice and deadlocking. Rather than
+	 * trying to be clever about what pages can be locked,
+	 * avoid the use of lock_page for direct compaction
+	 * altogether.
+	 *
+	 * Nor is it safe for direct compaction to wait_on_page_writeback:
+	 * we might be trying to allocate on behalf of that writeback (e.g.
+	 * slub allocating an order-2 page for a radix_tree node for the
+	 * loop device below, might target that very page under writeback).
+	 */
+	if (current->flags & PF_MEMALLOC)
+		force = 0;
+
 	/* prepare cgroup just returns 0 or -ENOMEM */
 	rc = -EAGAIN;
 
 	if (!trylock_page(page)) {
 		if (!force)
 			goto move_newpage;
-
-		/*
-		 * It's not safe for direct compaction to call lock_page.
-		 * For example, during page readahead pages are added locked
-		 * to the LRU. Later, when the IO completes the pages are
-		 * marked uptodate and unlocked. However, the queueing
-		 * could be merging multiple pages for one bio (e.g.
-		 * mpage_readpages). If an allocation happens for the
-		 * second or third page, the process can end up locking
-		 * the same page twice and deadlocking. Rather than
-		 * trying to be clever about what pages can be locked,
-		 * avoid the use of lock_page for direct compaction
-		 * altogether.
-		 */
-		if (current->flags & PF_MEMALLOC)
-			goto move_newpage;
-
 		lock_page(page);
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
