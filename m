Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id ADF58828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 00:03:46 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ts6so436361103pac.1
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 21:03:46 -0700 (PDT)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTP id gl5si1929154pac.8.2016.07.05.21.03.44
        for <linux-mm@kvack.org>;
        Tue, 05 Jul 2016 21:03:45 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <014201d1d738$744c8f90$5ce5aeb0$@alibaba-inc.com>
In-Reply-To: <014201d1d738$744c8f90$5ce5aeb0$@alibaba-inc.com>
Subject: Re: [PATCH 2/2] s390/mm: use ipte range to invalidate multiple page table entries
Date: Wed, 06 Jul 2016 12:03:28 +0800
Message-ID: <014601d1d73b$5a3c0420$0eb40c60$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Martin Schwidefsky' <schwidefsky@de.ibm.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> 
> +void ptep_invalidate_range(struct mm_struct *mm, unsigned long start,
> +			   unsigned long end, pte_t *ptep)
> +{
> +	unsigned long nr;
> +
> +	if (!MACHINE_HAS_IPTE_RANGE || mm_has_pgste(mm))
> +		return;
> +	preempt_disable();
> +	nr = (end - start) >> PAGE_SHIFT;
> +	/* If the flush is likely to be local skip the ipte range */
> +	if (nr && !cpumask_equal(mm_cpumask(mm),
> +				 cpumask_of(smp_processor_id())))

s/smp/raw_smp/ to avoid adding schedule entry with page table
lock held?

> +		__ptep_ipte_range(start, nr - 1, ptep);
> +	preempt_enable();
> +}
> +EXPORT_SYMBOL(ptep_invalidate_range);
> +

thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
