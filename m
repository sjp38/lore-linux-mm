Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 133F46006F5
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 12:53:14 -0400 (EDT)
Date: Thu, 8 Jul 2010 13:17:11 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH v4 09/12] Retry fault before vmentry
Message-ID: <20100708161711.GB13855@amt.cnet>
References: <1278433500-29884-1-git-send-email-gleb@redhat.com>
 <1278433500-29884-10-git-send-email-gleb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1278433500-29884-10-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 06, 2010 at 07:24:57PM +0300, Gleb Natapov wrote:
> When page is swapped in it is mapped into guest memory only after guest
> tries to access it again and generate another fault. To save this fault
> we can map it immediately since we know that guest is going to access
> the page.
> 
> Signed-off-by: Gleb Natapov <gleb@redhat.com>
> ---
>  arch/x86/include/asm/kvm_host.h |    7 ++++++-
>  arch/x86/kvm/mmu.c              |   27 ++++++++++++++++++++-------
>  arch/x86/kvm/paging_tmpl.h      |   37 +++++++++++++++++++++++++++++++++----
>  arch/x86/kvm/x86.c              |    9 +++++++++
>  virt/kvm/kvm_main.c             |    2 ++
>  5 files changed, 70 insertions(+), 12 deletions(-)
> 

> +static int FNAME(page_fault_other_cr3)(struct kvm_vcpu *vcpu, gpa_t cr3,
> +				       gva_t addr, u32 error_code)
> +{
> +	int r = 0;
> +	gpa_t curr_cr3 = vcpu->arch.cr3;
> +
> +	if (curr_cr3 != cr3) {
> +		/*
> +		 * We do page fault on behalf of a process that is sleeping
> +		 * because of async PF. PV guest takes reference to mm that cr3
> +		 * belongs too, so it has to be valid here.
> +		 */
> +		kvm_set_cr3(vcpu, cr3);
> +		if (kvm_mmu_reload(vcpu))
> +			goto switch_cr3;
> +	}
> +
> +	r = FNAME(page_fault)(vcpu, addr, error_code, true);

KVM_REQ_MMU_SYNC request generated here must be processed before
switching to a different cr3 (otherwise vcpu_enter_guest will process it 
with the wrong cr3 in place).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
