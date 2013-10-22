Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id EA6536B00ED
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 11:48:11 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so8772860pbc.3
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 08:48:11 -0700 (PDT)
Received: from psmtp.com ([74.125.245.141])
        by mx.google.com with SMTP id yk3si12598177pac.186.2013.10.22.08.48.10
        for <linux-mm@kvack.org>;
        Tue, 22 Oct 2013 08:48:10 -0700 (PDT)
Received: by mail-wi0-f176.google.com with SMTP id l12so5929843wiv.3
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 08:48:08 -0700 (PDT)
Date: Tue, 22 Oct 2013 08:48:02 -0700
From: walken@google.com
Subject: Re: [PATCH 0/3] mm,vdso: preallocate new vmas
Message-ID: <20131022154802.GA25490@localhost>
References: <1382057438-3306-1-git-send-email-davidlohr@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1382057438-3306-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Michel Lespinasse <walken@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, aswin@hp.com, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Thu, Oct 17, 2013 at 05:50:35PM -0700, Davidlohr Bueso wrote:
> Linus recently pointed out[1] some of the amount of unnecessary work 
> being done with the mmap_sem held. This patchset is a very initial 
> approach on reducing some of the contention on this lock, and moving
> work outside of the critical region.
> 
> Patch 1 adds a simple helper function.
> 
> Patch 2 moves out some trivial setup logic in mlock related calls.
> 
> Patch 3 allows managing new vmas without requiring the mmap_sem for
> vdsos. While it's true that there are many other scenarios where
> this can be done, few are actually as straightforward as this in the
> sense that we *always* end up allocating memory anyways, so there's really
> no tradeoffs. For this reason I wanted to get this patch out in the open.
> 
> There are a few points to consider when preallocating vmas at the start
> of system calls, such as how many new vmas (ie: callers of split_vma can
> end up calling twice, depending on the mm state at that point) or the probability
> that we end up merging the vma instead of having to create a new one, like the 
> case of brk or copy_vma. In both cases the overhead of creating and freeing
> memory at every syscall's invocation might outweigh what we gain in not holding
> the sem.

Hi Davidlohr,

I had a quick look at the patches and I don't see anything wrong with them.
However, I must also say that I have 99 problems with mmap_sem and the one
you're solving doesn't seem to be one of them, so I would be interested to
see performance numbers showing how much difference these changes make.

Generally the problems I see with mmap_sem are related to long latency
operations. Specifically, the mmap_sem write side is currently held
during the entire munmap operation, which iterates over user pages to
free them, and can take hundreds of milliseconds for large VMAs. Also,
the mmap_sem read side is held during user page fauls - well, the
VM_FAULT_RETRY mechanism allows us to drop mmap_sem during major page
faults, but it is still held while allocating user pages or page tables,
and while going through FS code for asynchronous readahead, which turns
out not to be as asynchronous as you'd think as it can still block for
reading extends etc... So, generally the main issues I am seeing with
mmap_sem are latency related, while your changes only help for throughput
for workloads that don't hit the above latency issues. I think that's a
valid thing to do but I'm not sure if common workloads hit these throughput
issues today ?

> [1] https://lkml.org/lkml/2013/10/9/665 

Eh, that post really makes it look easy doesn't it :)

There are a few complications with mmap_sem as it turns out to protect
more than just the VMA structures. For example, mmap_sem plays a role
in preventing page tables from being unmapped while follow_page_mask()
reads through them (there are other arch specific ways to do that,
like disabling local interrupts on x86 to prevent TLB shootdown, but
none that are currently available in generic code). This isn't an
issue with your current proposed patches but is something you need to
be aware of if you're going to do more work around the mmap_sem issues
(which I would encourage you to BTW - there are a lot of issues around
mmap_sem, so it definitely helps to have more people looking at this :)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
