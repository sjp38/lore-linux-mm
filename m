Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 588686B004A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 13:22:09 -0400 (EDT)
Date: Thu, 7 Oct 2010 19:21:52 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v6 03/12] Retry fault before vmentry
Message-ID: <20101007172152.GB2397@redhat.com>
References: <1286207794-16120-1-git-send-email-gleb@redhat.com>
 <1286207794-16120-4-git-send-email-gleb@redhat.com>
 <4CADBD13.4040609@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4CADBD13.4040609@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, Oct 07, 2010 at 02:29:07PM +0200, Avi Kivity wrote:
>  On 10/04/2010 05:56 PM, Gleb Natapov wrote:
> >When page is swapped in it is mapped into guest memory only after guest
> >tries to access it again and generate another fault. To save this fault
> >we can map it immediately since we know that guest is going to access
> >the page. Do it only when tdp is enabled for now. Shadow paging case is
> >more complicated. CR[034] and EFER registers should be switched before
> >doing mapping and then switched back.
> 
> With non-pv apf, I don't think we can do shadow paging.  The guest
Yes, with non-pv this trick will not work without tdp. I haven't even
considered it for that case.

> isn't aware of the apf, so as far as it is concerned it is allowed
> to kill the process and replace it with something else:
> 
>   guest process x: apf
>   kvm: timer intr
>   guest kernel: context switch
>   very fast guest admin: pkill -9 x
>   guest kernel: destroy x's cr3
>   guest kernel: reuse x's cr3 for new process y
>   kvm: retry fault, instantiating x's page in y's page table
> 
> Even with tdp, we have the same case for nnpt (just
> s/kernel/hypervisor/ and s/process/guest/).  What we really need is
> to only instantiate the page for direct maps, which are independent
> of the guest.
> 
> Could be done like this:
> 
> - at apf time, walk shadow mmu
> - if !sp->role.direct, abort
> - take reference to sp
> - on apf completion, instantiate spte in sp
> 
> -- 
> I have a truly marvellous patch that fixes the bug which this
> signature is too narrow to contain.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
