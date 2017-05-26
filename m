Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id BC3EC6B0292
	for <linux-mm@kvack.org>; Thu, 25 May 2017 21:39:12 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id 36so87260957qkz.10
        for <linux-mm@kvack.org>; Thu, 25 May 2017 18:39:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e58si4822608qta.179.2017.05.25.18.39.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 18:39:12 -0700 (PDT)
Message-ID: <1495762747.29205.63.camel@redhat.com>
Subject: Re: [PATCH v3 2/8] x86/mm: Change the leave_mm() condition for
 local TLB flushes
From: Rik van Riel <riel@redhat.com>
Date: Thu, 25 May 2017 21:39:07 -0400
In-Reply-To: <61de238db6d9c9018db020c41047ce32dac64488.1495759610.git.luto@kernel.org>
References: <cover.1495759610.git.luto@kernel.org>
	 <61de238db6d9c9018db020c41047ce32dac64488.1495759610.git.luto@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

On Thu, 2017-05-25 at 17:47 -0700, Andy Lutomirski wrote:
> 
> +++ b/arch/x86/mm/tlb.c
> @@ -311,7 +311,7 @@ void flush_tlb_mm_range(struct mm_struct *mm,
> unsigned long start,
> A 		goto out;
> A 	}
> A 
> -	if (!current->mm) {
> +	if (this_cpu_read(cpu_tlbstate.state) != TLBSTATE_OK) {
> A 		leave_mm(smp_processor_id());

Unless -mm changed leave_mm (I did not check), this
is not quite correct yet.

The reason is leave_mm (at least in the latest Linus
tree) ignores the cpu argument for one of its checks.

You should probably fix that in an earlier patch,
assuming you haven't already done so in -mm.

void leave_mm(int cpu)
{
A A A A A A A A struct mm_struct *active_mm =
this_cpu_read(cpu_tlbstate.active_mm);
A A A A A A A A if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK)
A A A A A A A A A A A A A A A A BUG();
A A A A A A A A if (cpumask_test_cpu(cpu, mm_cpumask(active_mm))) {
A A A A A A A A A A A A A A A A cpumask_clear_cpu(cpu, mm_cpumask(active_mm));
A A A A A A A A A A A A A A A A load_cr3(swapper_pg_dir);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
