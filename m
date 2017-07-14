Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CBA57440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 16:06:36 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id d193so38430901pgc.0
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 13:06:36 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0135.outbound.protection.outlook.com. [104.47.0.135])
        by mx.google.com with ESMTPS id s5si7549524plj.430.2017.07.14.13.06.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 13:06:35 -0700 (PDT)
Date: Fri, 14 Jul 2017 23:06:25 +0300
From: Roman Kagan <rkagan@virtuozzo.com>
Subject: Re: [PATCH v4 8/8] x86,kvm: Teach KVM's VMX code that CR3 isn't a
 constant
Message-ID: <20170714200624.GA22585@rkaganb.sw.ru>
References: <cover.1495990440.git.luto@kernel.org>
 <7d369dab491071edc02d39e2fa2b218a3be401f2.1495990440.git.luto@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7d369dab491071edc02d39e2fa2b218a3be401f2.1495990440.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, kvm@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

On Sun, May 28, 2017 at 10:00:17AM -0700, Andy Lutomirski wrote:
> When PCID is enabled, CR3's PCID bits can change during context
> switches, so KVM won't be able to treat CR3 as a per-mm constant any
> more.
> 
> I structured this like the existing CR4 handling.  Under ordinary
> circumstances (PCID disabled or if the current PCID and the value
> that's already in the VMCS match), then we won't do an extra VMCS
> write, and we'll never do an extra direct CR3 read.  The overhead
> should be minimal.
> 
> I disallowed using the new helper in non-atomic context because
> PCID support will cause CR3 to stop being constant in non-atomic
> process context.
> 
> (Frankly, it also scares me a bit that KVM ever treated CR3 as
> constant, but it looks like it was okay before.)
> 
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Radim KrA?mA!A? <rkrcmar@redhat.com>
> Cc: kvm@vger.kernel.org
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Nadav Amit <namit@vmware.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Arjan van de Ven <arjan@linux.intel.com>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
>  arch/x86/include/asm/mmu_context.h | 19 +++++++++++++++++++
>  arch/x86/kvm/vmx.c                 | 21 ++++++++++++++++++---
>  2 files changed, 37 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
> index 187c39470a0b..f20d7ea47095 100644
> --- a/arch/x86/include/asm/mmu_context.h
> +++ b/arch/x86/include/asm/mmu_context.h
> @@ -266,4 +266,23 @@ static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
>  	return __pkru_allows_pkey(vma_pkey(vma), write);
>  }
>  
> +
> +/*
> + * This can be used from process context to figure out what the value of
> + * CR3 is without needing to do a (slow) read_cr3().
> + *
> + * It's intended to be used for code like KVM that sneakily changes CR3
> + * and needs to restore it.  It needs to be used very carefully.
> + */
> +static inline unsigned long __get_current_cr3_fast(void)
> +{
> +	unsigned long cr3 = __pa(this_cpu_read(cpu_tlbstate.loaded_mm)->pgd);
> +
> +	/* For now, be very restrictive about when this can be called. */
> +	VM_WARN_ON(in_nmi() || !in_atomic());

With the following config (from Fedora26 + olddefconfig)

  $ grep PREEMPT .config
  CONFIG_PREEMPT_NOTIFIERS=y
  # CONFIG_PREEMPT_NONE is not set
  CONFIG_PREEMPT_VOLUNTARY=y
  # CONFIG_PREEMPT is not set

I hit this warning on !in_atomic() on every vm entry.  Shouldn't this be
preemptible() instead?

Roman.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
