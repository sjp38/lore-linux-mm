Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3EDE06B004A
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 08:29:32 -0400 (EDT)
Message-ID: <4CADBD13.4040609@redhat.com>
Date: Thu, 07 Oct 2010 14:29:07 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 03/12] Retry fault before vmentry
References: <1286207794-16120-1-git-send-email-gleb@redhat.com> <1286207794-16120-4-git-send-email-gleb@redhat.com>
In-Reply-To: <1286207794-16120-4-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 10/04/2010 05:56 PM, Gleb Natapov wrote:
> When page is swapped in it is mapped into guest memory only after guest
> tries to access it again and generate another fault. To save this fault
> we can map it immediately since we know that guest is going to access
> the page. Do it only when tdp is enabled for now. Shadow paging case is
> more complicated. CR[034] and EFER registers should be switched before
> doing mapping and then switched back.

With non-pv apf, I don't think we can do shadow paging.  The guest isn't 
aware of the apf, so as far as it is concerned it is allowed to kill the 
process and replace it with something else:

   guest process x: apf
   kvm: timer intr
   guest kernel: context switch
   very fast guest admin: pkill -9 x
   guest kernel: destroy x's cr3
   guest kernel: reuse x's cr3 for new process y
   kvm: retry fault, instantiating x's page in y's page table

Even with tdp, we have the same case for nnpt (just s/kernel/hypervisor/ 
and s/process/guest/).  What we really need is to only instantiate the 
page for direct maps, which are independent of the guest.

Could be done like this:

- at apf time, walk shadow mmu
- if !sp->role.direct, abort
- take reference to sp
- on apf completion, instantiate spte in sp

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
