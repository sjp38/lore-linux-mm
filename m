Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 83FA26B0279
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 19:26:47 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s74so247392pfe.10
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 16:26:47 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id x20si13842055pfi.138.2017.06.21.16.26.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 16:26:46 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id s66so61488pfs.2
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 16:26:46 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v3 01/11] x86/mm: Don't reenter flush_tlb_func_common()
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <b13eee98a0e5322fbdc450f234a01006ec374e2c.1498022414.git.luto@kernel.org>
Date: Wed, 21 Jun 2017 16:26:43 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <207CCA52-C1A0-4AEF-BABF-FA6552CFB71F@gmail.com>
References: <cover.1498022414.git.luto@kernel.org>
 <cover.1498022414.git.luto@kernel.org>
 <b13eee98a0e5322fbdc450f234a01006ec374e2c.1498022414.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

Andy Lutomirski <luto@kernel.org> wrote:

> index 2a5e851f2035..f06239c6919f 100644
> --- a/arch/x86/mm/tlb.c
> +++ b/arch/x86/mm/tlb.c
> @@ -208,6 +208,9 @@ void switch_mm_irqs_off(struct mm_struct *prev, =
struct mm_struct *next,
> static void flush_tlb_func_common(const struct flush_tlb_info *f,
> 				  bool local, enum tlb_flush_reason =
reason)
> {
> +	/* This code cannot presently handle being reentered. */
> +	VM_WARN_ON(!irqs_disabled());
> +
> 	if (this_cpu_read(cpu_tlbstate.state) !=3D TLBSTATE_OK) {
> 		leave_mm(smp_processor_id());
> 		return;
> @@ -313,8 +316,12 @@ void flush_tlb_mm_range(struct mm_struct *mm, =
unsigned long start,
> 		info.end =3D TLB_FLUSH_ALL;
> 	}
>=20
> -	if (mm =3D=3D this_cpu_read(cpu_tlbstate.loaded_mm))
> +	if (mm =3D=3D this_cpu_read(cpu_tlbstate.loaded_mm)) {

Perhaps you want to add:

	VM_WARN_ON(irqs_disabled());

here

> +		local_irq_disable();
> 		flush_tlb_func_local(&info, TLB_LOCAL_MM_SHOOTDOWN);
> +		local_irq_enable();
> +	}
> +
> 	if (cpumask_any_but(mm_cpumask(mm), cpu) < nr_cpu_ids)
> 		flush_tlb_others(mm_cpumask(mm), &info);
> 	put_cpu();
> @@ -370,8 +377,12 @@ void arch_tlbbatch_flush(struct =
arch_tlbflush_unmap_batch *batch)
>=20
> 	int cpu =3D get_cpu();
>=20
> -	if (cpumask_test_cpu(cpu, &batch->cpumask))
> +	if (cpumask_test_cpu(cpu, &batch->cpumask)) {

and here?

> +		local_irq_disable();
> 		flush_tlb_func_local(&info, TLB_LOCAL_SHOOTDOWN);
> +		local_irq_enable();
> +	}
> +
> 	if (cpumask_any_but(&batch->cpumask, cpu) < nr_cpu_ids)
> 		flush_tlb_others(&batch->cpumask, &info);
> 	cpumask_clear(&batch->cpumask);
> --=20
> 2.9.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
