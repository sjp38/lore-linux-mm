Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B46A96B00F0
	for <linux-mm@kvack.org>; Sun, 17 Oct 2010 06:34:17 -0400 (EDT)
Message-ID: <4CBAD111.3070406@redhat.com>
Date: Sun, 17 Oct 2010 12:33:53 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 03/12] Retry fault before vmentry
References: <1287048176-2563-1-git-send-email-gleb@redhat.com> <1287048176-2563-4-git-send-email-gleb@redhat.com>
In-Reply-To: <1287048176-2563-4-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 10/14/2010 11:22 AM, Gleb Natapov wrote:
> When page is swapped in it is mapped into guest memory only after guest
> tries to access it again and generate another fault. To save this fault
> we can map it immediately since we know that guest is going to access
> the page. Do it only when tdp is enabled for now. Shadow paging case is
> more complicated. CR[034] and EFER registers should be switched before
> doing mapping and then switched back.
>
> +void kvm_arch_async_page_ready(struct kvm_vcpu *vcpu, struct kvm_async_pf *work)
> +{
> +	if (!vcpu->arch.mmu.direct_map || is_error_page(work->page))
> +		return;
> +	vcpu->arch.mmu.page_fault(vcpu, work->gva, 0, true);
> +}

Missing mmu_topup_memory_caches().


-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
