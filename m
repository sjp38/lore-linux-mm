Date: Sun, 19 Aug 2001 02:35:48 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: resend Re: [PATCH] final merging patch -- significant mozilla speedup.
Message-ID: <20010819023548.P1719@athlon.random>
References: <20010819012713.N1719@athlon.random> <Pine.LNX.4.33.0108182005590.3026-100000@touchme.toronto.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33.0108182005590.3026-100000@touchme.toronto.redhat.com>; from bcrl@redhat.com on Sat, Aug 18, 2001 at 08:10:50PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: torvalds@transmeta.com, alan@redhat.com, linux-mm@kvack.org, Chris Blizzard <blizzard@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sat, Aug 18, 2001 at 08:10:50PM -0400, Ben LaHaise wrote:
> On Sun, 19 Aug 2001, Andrea Arcangeli wrote:
> 
> > This below patch besides rewriting the vma lookup engine also covers the
> > cases addressed by your patch:
> 
> Your patch performs a few odd things like:
> 
> +       vma->vm_raend = 0;
> +       vma->vm_pgoff += (start - vma->vm_start) >> PAGE_SHIFT;
>         lock_vma_mappings(vma);
>         spin_lock(&vma->vm_mm->page_table_lock);
> -       vma->vm_pgoff += (start - vma->vm_start) >> PAGE_SHIFT;
> 
> which I would argue are incorrect.  Remember that page faults rely on

vm_raend is obviously correct.

For the vm_pgoff I need to think more about it (quite frankly I never
thought about expand_stack(), I only thought about the swapper locking
while doing the "odd" change), if it's a bug I will release a corrected
mmap-rb-5 in a few hours.  Thanks for raising this issue.

> page_table_lock to protect against the case where the stack is grown and
> vm_start is modified.  Aside from that, your patch is a sufficiently large
> change so as to be material for 2.5.  Also, have you instrumented the rb

I'm not caring about 2.whatever here. However I will certainly try at
max to avoid any hack at this point even in 2.4 now that the rb works
apparently solid (AFIK as worse with a SMP race in vm_pgoff :).

> trees to see what kind of an effect it has on performance compared to the
> avl tree?

I posted some benchmark result a few minutes ago (the numbers says there
were no implementation bugs).

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
