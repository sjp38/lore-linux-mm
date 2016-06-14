Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id B68676B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 12:47:46 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id b126so167570035ite.3
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 09:47:46 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id va9si25056887pac.186.2016.06.14.09.47.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 09:47:46 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id fg1so12974506pad.3
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 09:47:45 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] Linux VM workaround for Knights Landing A/D leak
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <1465919919-2093-1-git-send-email-lukasz.anaczkowski@intel.com>
Date: Tue, 14 Jun 2016 09:47:41 -0700
Content-Transfer-Encoding: 7bit
Message-Id: <7FB15233-B347-4A87-9506-A9E10D331292@gmail.com>
References: <1465919919-2093-1-git-send-email-lukasz.anaczkowski@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukasz Anaczkowski <lukasz.anaczkowski@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, harish.srinivasappa@intel.com, lukasz.odzioba@intel.com


Lukasz Anaczkowski <lukasz.anaczkowski@intel.com> wrote:

> From: Andi Kleen <ak@linux.intel.com>
> +void fix_pte_leak(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
> +{
Here there should be a call to smp_mb__after_atomic() to synchronize with
switch_mm. I submitted a similar patch, which is still pending (hint).

> +	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids) {
> +		trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
> +		flush_tlb_others(mm_cpumask(mm), mm, addr,
> +				 addr + PAGE_SIZE);
> +		mb();
> +		set_pte(ptep, __pte(0));
> +	}
> +}

Regards,
Nadav

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
