Received: from castle.nmd.msu.ru (castle.nmd.msu.ru [193.232.112.53])
	by kvack.org (8.8.7/8.8.7) with SMTP id EAA11222
	for <linux-mm@kvack.org>; Sat, 9 Jan 1999 04:43:30 -0500
Message-ID: <19990109124304.C26523@castle.nmd.msu.ru>
Date: Sat, 9 Jan 1999 12:43:04 +0300
From: Savochkin Andrey Vladimirovich <saw@msu.ru>
Subject: MM deadlock [was: Re: arca-vm-8...]
References: <Pine.LNX.3.95.990107093746.4270H-100000@penguin.transmeta.com> <Pine.LNX.3.95.990107144729.5025P-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.3.95.990107144729.5025P-100000@penguin.transmeta.com>; from "Linus Torvalds" on Thu, Jan 07, 1999 at 02:57:34PM
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, "Eric W. Biederman" <ebiederm+eric@ccr.net>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I've found an another deadlock.
Two processes were locked trying to grab an inode write semaphore.
Their call traces are (in diff format):

 Using `map-2.2.0pre5-1' to map addresses to symbols.
 
 Trace: c010f038 <__down+58/90>
 Trace: c018d080 <__down_failed+8/c>
 Trace: c011abaa <filemap_write_page+a6/15c>
 Trace: c011acad <filemap_swapout+4d/60>
 Trace: c011e2ae <try_to_swap_out+10a/1ac>
 Trace: c011e45a <swap_out_vma+10a/174>
 Trace: c011e521 <swap_out_process+5d/8c>
 Trace: c011e60b <swap_out+bb/e4>
 Trace: c011e75b <try_to_free_pages+4b/70>
 Trace: c011ef61 <__get_free_pages+b5/1dc>
-Trace: c0119cd7 <try_to_read_ahead+2f/124>
-Trace: c011a970 <filemap_nopage+170/304>
-Trace: c0118888 <do_no_page+54/e4>
-Trace: c01189e4 <handle_mm_fault+cc/168>
+Trace: c0118375 <do_wp_page+19/210>
+Trace: c0118a3a <handle_mm_fault+122/168>
 Trace: c010ce9f <do_page_fault+143/364>

I suspect that one of the processes grabbed the semaphore and then deadlocked
trying to do it again.  Probably the process invoked write()
with the data having been swapped out.  The page fault handler
tried to free some memory and try_to_free_pages decided to write
out dirty pages of a shared mapping.  By accident the dirty pages
happened to belong to the file the process had started to write to.

A simple solution will be to check if the inode semaphore is held
before trying to write pages out and skip the mapping if it is.
However it doesn't seem to be a very good solution because if the most
memory is occupied by dirty pages of a shared mapping then
writing the pages out is the most right thing to do.

Best wishes
					Andrey V.
					Savochkin

On Thu, Jan 07, 1999 at 02:57:34PM -0800, Linus Torvalds wrote:
[snip]
> Confirmed. Hpa was good enough to reproduce this, and my debugging code
> caught the (fairly deep) deadlock: 
> 
> 	system_call ->
> 	sys_write ->
> 	ext2_file_write ->
> 	ext2_getblk ->
> 	ext2_alloc_block ->	** gets superblock lock **
> 	ext2_new_block ->
> 	getblk ->
> 	refill_freelist ->
> 	grow_buffers ->
> 	__get_free_pages ->
> 	try_to_free_pages ->
> 	swap_out ->
> 	swap_out_process ->
> 	swap_out_vma ->
> 	try_to_swap_out ->
> 	filemap_swapout ->
> 	filemap_write_page ->
> 	ext2_file_write ->
> 	ext2_getblk ->
> 	ext2_alloc_block ->
> 	__wait_on_super		** BOOM - we want the superblock lock again **
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
