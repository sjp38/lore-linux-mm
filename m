Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 536296B0078
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 13:40:08 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so2218573eek.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 10:40:06 -0800 (PST)
Date: Fri, 16 Nov 2012 19:40:02 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/2] change_protection(): Count the number of pages
 affected
Message-ID: <20121116184002.GB4763@gmail.com>
References: <1352883029-7885-1-git-send-email-mingo@kernel.org>
 <CA+55aFz_JnoR73O46YWhZn2A4t_CSUkGzMMprCUpvR79TVMCEQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFz_JnoR73O46YWhZn2A4t_CSUkGzMMprCUpvR79TVMCEQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>, Hugh Dickins <hughd@google.com>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Wed, Nov 14, 2012 at 12:50 AM, Ingo Molnar <mingo@kernel.org> wrote:
> > What do you guys think about this mprotect() optimization?
> 
> Hmm..
> 
> If this is mainly about just avoiding the TLB flushing, I do 
> wonder if it might not be more interesting to try to be much 
> more aggressive.
> 
> As noted elsewhere, we should just notice when vm_page_prot 
> doesn't change at all - even if 'flags' change, it is possible 
> that the actual low-level page protection bits do not (due to 
> the X=R issue).
> 
> But even *more* aggressively, how about looking at
> 
>  - not flushing the TLB at all if the bits become  more permissive
> (taking the TLB micro-fault and letting the CPU just update it on its
> own)
> 
>  - even *more* aggressive: if the bits become strictly more 
> restrictive, how about not flushing the TLB at all, *and* not 
> even changing the page tables, and just teaching the page 
> fault code to do it lazily at fault time?
> 
> Now, the "change protections lazily" might actually be a huge 
> performance problem with the page fault overhead dwarfing any 
> TLB flush costs, but we don't really know, do we? It might be 
> worth trying out.

It might be a good idea when ptes get weaker protections - and 
maybe some CPU models see the pte modification in memory and are 
able to hash that to the TLB entry already and flush it? Even if 
they don't guarantee it architecturally they might have it as an 
optimization that works most of the time.

But I'd prefer to keep any such patch separate from these 
patches and maybe even keep them per arch and per CPU model?

I have instrumented and made sure that *these* patches do help 
visibly - but to determine whether not flushing TLBs when they 
are made more permissive is a lot harder to do ... there could 
be per arch differences, even per CPU model differences, 
depending on TLB size, CPU features, etc.

For unthreaded process environments mprotect() is pretty neat 
already.

For small/midsize mprotect()s in threaded environments there's 
two big costs:

  - the down_write(mm->sem)/up_write(mm->sem) serializes between 
    threads.

    Technically this could be improved, as the most expensive 
    parts of mprotect() are really safe via down_read() - the 
    only exception appears to be:

        vma->vm_flags = newflags;
        vma->vm_page_prot = pgprot_modify(vma->vm_page_prot,
                                          vm_get_page_prot(newflags));

    and that could be serialized using a spinlock, say the 
    pagetable lock. But it's a lot of footwork factoring out 
    vma->vm_page_prot users and we'd consider each such place 
    whether slowing them down is less of a problem than the 
    benefit of speeding up mprotect().

    So I wouldn't personally go there, dragons and all that.

  - the TLB flush, if done on some highly threaded workload like
    a JVM with threads live on many other CPUs is a global TLB 
    flush, with IPIs sent everywhere and the result has to be 
    waited for.

    This could be improved even if we don't do your
    very aggressive optimization, unless I'm missing something: 
    we could still flush locally and send the IPIs, but we don't
    have to *wait* for them when we weaken protections, right? 

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
