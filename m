Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA32316
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 17:59:19 -0500
Date: Thu, 7 Jan 1999 14:57:34 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: arca-vm-8 [Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm , improvement , [Re: 2.2.0 Bug summary]]]
In-Reply-To: <Pine.LNX.3.95.990107093746.4270H-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.95.990107144729.5025P-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Andrea Arcangeli <andrea@e-mind.com>, steve@netplus.net, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, bredelin@ucsd.edu, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, Rik van Riel <H.H.vanRiel@phys.uu.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Thu, 7 Jan 1999, Linus Torvalds wrote:
> 
> The deadlock I suspect is:
>  - we're low on memory
>  - we allocate or look up a new block on the filesystem. This involves
>    getting the ext2 superblock lock, and doing a "bread()" of the free
>    block bitmap block.
>  - this causes us to try to allocate a new buffer, and we are so low on
>    memory that we go into try_to_free_pages() to find some more memory.
>  - try_to_free_pages() finds a shared memory file to page out.
>  - trying to page that out, it looks up the buffers on the filesystem it
>    needs, but deadlocks on the superblock lock.

Confirmed. Hpa was good enough to reproduce this, and my debugging code
caught the (fairly deep) deadlock: 

	system_call ->
	sys_write ->
	ext2_file_write ->
	ext2_getblk ->
	ext2_alloc_block ->	** gets superblock lock **
	ext2_new_block ->
	getblk ->
	refill_freelist ->
	grow_buffers ->
	__get_free_pages ->
	try_to_free_pages ->
	swap_out ->
	swap_out_process ->
	swap_out_vma ->
	try_to_swap_out ->
	filemap_swapout ->
	filemap_write_page ->
	ext2_file_write ->
	ext2_getblk ->
	ext2_alloc_block ->
	__wait_on_super		** BOOM - we want the superblock lock again **

and I suspect the fix is fairly simple: I'll just add back the __GFP_IO
bit (we kind of used to have one that did something similar) which will
make the swap-out code not write out shared pages when it allocates
buffers. 

The better fix would actually be to make sure that filesystems do not hold
locks around these kinds of blocking operations, but that is harder to do
at this late stage.

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
