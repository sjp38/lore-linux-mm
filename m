Date: Thu, 4 May 2000 17:19:03 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: classzone-VM + mapped pages out of lru_cache
In-Reply-To: <yttu2gel6p3.fsf@vexeta.dc.fi.udc.es>
Message-ID: <Pine.LNX.4.21.0005041702560.2512-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On 4 May 2000, Juan J. Quintela wrote:

>suited to the memory of my system (Uniprocessor 96MB)

Do you have also an SMP to try it out too? On IA32-SMP and alpha-SMP I
definitely can't reproduce the pico lockup reported to me a few hours ago.

>The results are very good for your patch:
>
>Vanilla pre7-3            pre7-3+classzone-18
>real    3m29.926s         real    2m10.210s
>user    0m15.280s         real    2m10.210s
>sys     0m20.500s         real    2m10.210s

;)

>That is the description of the situation.  Andrea, why do you reverse
>the patch of filemap.c:truncate_inode_pages() of using TryLockPage()?

Because it's not necessary as far I can tell. Only one
truncate_inode_pages() can run at once and none read or write can run
under truncate_inode_pages(). This should be enforced by the VFS, and if
that doesn't happen the truncate_inode_pages changes that gone into pre6
(and following) hides the real bug.

>That change was proposed by Rik due to an Oops that I get here.  It

Can I see the Oops?

>was one of the non-easily reproducible ones that I get.

Maybe you can try to write/read under a truncate or something like
that. I've not yet checked if there are still races in the VFS between
read/write/truncate.

BTW, maybe if you was using NFS you got in troubles with
invalidate_inode_pages. New invalidate_inode_pages in classzone patch
won't race with the old truncate_inode_page. Also without classzone-VM-18
invalidate_inode_pages can crash the kerne because _nobody_ can unlink a
mapped page-cache from the cache without first clearing the pte (and
flushing the page to disk if the pte happened to be dirty). So if
invalidate_inode_pages() runs under an inode map-shared in memory you'll
get a lockup as soon as you try to sync the page to disk. I didn't tried
to reproduce but I only read the code. However if I am right about this
reproducing should be easy. You have to MAP_SHARED on the client a file,
touch the shared mapping so that some pte become dirty, now overwrite the
file on the server and then push the client low on memory so that swap_out
will try to unmap the page -> crash. This is a security issue also for
2.2.x, fix is in classzone-VM-18 where I don't unmap the page if the page
count is > 1 (so if the page have no chance to be mapped). Effect of the
fix is that you can't MAP_SHARED and change the file from more than one
client or you have to expect inchoerency between the cache copies.

This untested patch should fix the problem also in 2.2.15 (the same way I
fixed it in classzone patch):

--- 2.2.15/mm/filemap.c	Thu May  4 13:00:40 2000
+++ /tmp/filemap.c	Thu May  4 17:11:18 2000
@@ -68,7 +68,7 @@
 
 	p = &inode->i_pages;
 	while ((page = *p) != NULL) {
-		if (PageLocked(page)) {
+		if (PageLocked(page) || atomic_read(&page->count) > 1) {
 			p = &page->next;
 			continue;
 		}


Trond, what do you think about it?

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
