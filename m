Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 59C4F6B0055
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 13:33:22 -0400 (EDT)
Date: Thu, 13 Aug 2009 18:33:06 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: vma_merge issue
In-Reply-To: <4A83694F.6090809@gmail.com>
Message-ID: <Pine.LNX.4.64.0908131820500.13350@sister.anvils>
References: <a1b36c3a0908101347t796dedbat2ecb0535c32f325b@mail.gmail.com>
 <Pine.LNX.4.64.0908121841550.14314@sister.anvils>
 <a1b36c3a0908121204q1b59df1fk86afec9d05ec16dc@mail.gmail.com>
 <Pine.LNX.4.64.0908122038360.18426@sister.anvils> <4A83694F.6090809@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: William R Speirs <bill.speirs@gmail.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 12 Aug 2009, William R Speirs wrote:
> Hugh Dickins wrote:
> > 
> > MADV_DONTNEED: brilliant idea, what a shame it doesn't work for you.
> > I'd been on the point of volunteering a bugfix to it to do what you
> > want, it would make sense; but there's a big but... we have sold
> > MADV_DONTNEED as an madvise that only needs non-exclusive access
> > to the mmap_sem, which means it can be used concurrently with faulting,
> > which has made it much more useful to glibc (I believe).  If we were
> > to fiddle with vmas and accounting and merging in there, it would go
> > back to needing exclusive mmap_sem, which would hurt important users.
> 
> For my own edification, hurt these users how? Performance? Serializing access
> during a MADV_DONTNEED? I wonder how big the "hurt" would be?

Performance, yes: serializing, yes.

I forget the details, others will have paid closer attention, I may
be making this up!  But it was something like garbage collection when
when freeing mallocs: it pays off if faults elsewhere in the address
space can occur concurrently, but bad news if exclusive mmap_sem
locks out those faults.  Big enough hurt to show up very badly in
some reallife multithreaded apps, and benchmarks hitting the issue.

> > A "refinement" to that suggestion is to put the file on tmpfs:
> > you will then get charged for RAM+swap as you use it, but you can
> > use madvise MADV_REMOVE to unmap pages, punching holes in the file,
> > freeing up those charges.  A little baroque, but I think it does
> > amount to a way of doing exactly what you wanted in the first place.
> 
> I like this (the refined) idea a lot. I coded it up and works as expected,
> and the way I initially want.
> 
> Thanks for taking the time and providing the solution... I appreciate it.

I'm very glad to hear that worked out: thanks for reporting back.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
