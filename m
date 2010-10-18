Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4B50C6B00D5
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 15:10:36 -0400 (EDT)
Message-ID: <20101018191034.21165.qmail@kosh.dhis.org>
From: pacman@kosh.dhis.org
Subject: Re: PROBLEM: memory corrupting bug, bisected to 6dda9d55
Date: Mon, 18 Oct 2010 14:10:33 -0500 (GMT+5)
In-Reply-To: <20101018113331.GB30667@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
List-ID: <linux-mm.kvack.org>

Mel Gorman writes:
> 
> A bit but I still don't know why it would cause corruption. Maybe this is still
> a caching issue but the difference in timing between list_add and list_add_tail
> is enough to hide the bug. It's also possible there are some registers
> ioremapped after the memmap array and reading them is causing some
> problem.

I've been doing a lot more tests and I'm sure that 6dda9d55 is not really
responsible. It just happens to provoke the bug in my particular setup.
Whatever it is, it's very sensitive to small changes.

At the end of free_all_bootmem, the free list for order 9 has 4 entries.
Which one is at the head of the list depends on whether 6dda9d55 is applied
or not. If page number 130048 is at the head of the list, it gets used fairly
soon, and everything's fine. The alternative is that page number 64512 is at
the head of the list, so it gets used fairly soon, and corruption occurs.

> 
> Andrew, what is the right thing to do here? We could flail around looking
> for explanations as to why the bug causes a user buffer corruption but never
> get an answer or do we go with this patch, preferably before 2.6.36 releases?

I've been flailing around quite a bit. Here's my latest result:

Since I can view the corruption with md5sum /sbin/e2fsck, I know it's in a
clean cached page. So I made an extra copy of /sbin/e2fsck, which won't be
loaded into memory during boot. So now after the corruption happens, I can
  cmp -l /sbin/e2fsck good-e2fsck
for a quick look at the changed bytes. Much easier than provoking a segfault
under gdb.

Then I got really creative and wrote a cmp replacement which mmaps the files
and reports the physical addresses from /proc/self/pagemap of the pages that
don't match. And the consistent result is that physical pages 64604 and 64609
(both in the range of the order=9 64512) have wrong contents. And the
corruption is always a single word 128 bytes after the start of the page.
Physical addresses 0x0fc5c080 and 0x0fc61080 are hit every time.

The values of the corrupted words, observed in 5 consecutive boots, were:
  at 0fc5c080   at 0fc61080
  -----------   -----------
  c3540000      92510000
  565c0000      23590000
  c85b0000      97580000
  d15f0000      9e5c0000
  d95b0000      a8580000

The low 16 bits are all 0 and the upper 16 bits seem randomly distributed.
But look at the differences:

  c3540000 - 92510000 = 31030000
  565c0000 - 23590000 = 33030000
  c85b0000 - 97580000 = 31030000
  d15f0000 - 9e5c0000 = 33030000
  d95b0000 - a8580000 = 31030000

This means something... but I don't know what.

In a completely different method of investigation, I went back a few stable
kernels, got 2.6.33.7 and applied 6dda9d55 to it, thinking that if 6dda9d55
only reveals a pre-existing bug, I could bisect it using 6dda9d55 as a
bug-revealing assistant. The bug appeared when running 2.6.33.7 with 6dda9d55
applied. That was discouraging.

>This patch fixes the problem by ensuring we are not reading a possibly
>invalid location of memory. It's not clear why the read causes
>corruption but one way or the other it is a buggy read.

At least that part of the explanation is wrong. Where's the buggy read?
The action taken by the 6dda9d55 version of __free_one_page looks perfectly
legitimate to me. Page numbers:

[129024       ] [130048       ]   order=10
[129024 129536] [130048 130560]   order=9

130048 is being freed. 130560 is not free. 129024 (the higher_buddy) is
already free at order=10. So 130048 is being pushed to the tail of the free
list, on the speculation that 130560 might soon be free and then the whole
thing will form an order=11 free page, the only problem being that order=11
is too high so that later merge will never happen. It's not useful, and maybe
not conceptually valid to say that 129024 is the buddy of 130048, but it is
an existing page, and the only way it wouldn't be is if the total memory size
was not a multiple of 1<<(MAX_ORDER-1) pages

-- 
Alan Curry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
