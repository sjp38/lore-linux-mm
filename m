Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id DD7CE6B0006
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 13:04:56 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id t83so4349612oij.14
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 10:04:56 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v62si865417oie.393.2018.02.23.10.04.55
        for <linux-mm@kvack.org>;
        Fri, 23 Feb 2018 10:04:55 -0800 (PST)
Message-ID: <5A90572D.9010704@arm.com>
Date: Fri, 23 Feb 2018 18:02:21 +0000
From: James Morse <james.morse@arm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/11] ACPI / APEI: Move the estatus queue code up, and
 under its own ifdef
References: <20180215185606.26736-1-james.morse@arm.com> <20180215185606.26736-2-james.morse@arm.com> <20180220192852.GB24320@pd.tnic>
In-Reply-To: <20180220192852.GB24320@pd.tnic>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>

Hi Borislav,

On 20/02/18 19:28, Borislav Petkov wrote:
> On Thu, Feb 15, 2018 at 06:55:56PM +0000, James Morse wrote:
>> +#ifdef CONFIG_HAVE_ACPI_APEI_NMI
>> +/*
>> + * While printk() now has an in_nmi() path, the handling for CPER records
>> + * does not. For example, memory_failure_queue() takes spinlocks and calls
>> + * schedule_work_on().
>> + *
>> + * So in any NMI-like handler, we allocate required memory from lock-less
>> + * memory allocator (ghes_estatus_pool), save estatus into it, put them into
>> + * lock-less list (ghes_estatus_llist), then delay printk into IRQ context via
>> + * irq_work (ghes_proc_irq_work).  ghes_estatus_size_request record
>> + * required pool size by all NMI error source.
> 
> Since you're touching this, pls correct the grammar too, while at it,
> and correct them into proper sentences.
> Also, end function names with "()".
> Also the "we" pronoun and tense sounds funny - let's make it passive.

Sure. I reckon your English grammar is better than mine, is this better?:

| In any NMI-like handler, memory from ghes_estatus_pool is used to save
| estatus, and added to the ghes_estatus_llist. irq_work_queue() causes
| ghes_proc_in_irq() to run in IRQ context where each estatus in
| ghes_estatus_llist are processed. Each NMI-like error source must grow
| the ghes_estatus_pool to ensure memory is available.



Thanks,

James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
