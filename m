Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 75CF48E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 12:20:43 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id h10so1806890plk.12
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 09:20:43 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a20si19413720pfh.163.2018.12.20.09.20.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Dec 2018 09:20:42 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBKHEqIO044597
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 12:20:41 -0500
Received: from e14.ny.us.ibm.com (e14.ny.us.ibm.com [129.33.205.204])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pgdec5nm4-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 12:20:41 -0500
Received: from localhost
	by e14.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bauerman@linux.ibm.com>;
	Thu, 20 Dec 2018 17:20:39 -0000
References: <20181219213338.26619-1-igor.stoppa@huawei.com> <20181219213338.26619-5-igor.stoppa@huawei.com>
From: Thiago Jung Bauermann <bauerman@linux.ibm.com>
Subject: Re: [PATCH 04/12] __wr_after_init: x86_64: __wr_op
In-reply-to: <20181219213338.26619-5-igor.stoppa@huawei.com>
Date: Thu, 20 Dec 2018 15:20:29 -0200
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87r2ecunc2.fsf@morokweng.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Matthew Wilcox <willy@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


Hello Igor,

> +/*
> + * The following two variables are statically allocated by the linker
> + * script at the the boundaries of the memory region (rounded up to
> + * multiples of PAGE_SIZE) reserved for __wr_after_init.
> + */
> +extern long __start_wr_after_init;
> +extern long __end_wr_after_init;
> +
> +static inline bool is_wr_after_init(unsigned long ptr, __kernel_size_t size)
> +{
> +	unsigned long start = (unsigned long)&__start_wr_after_init;
> +	unsigned long end = (unsigned long)&__end_wr_after_init;
> +	unsigned long low = ptr;
> +	unsigned long high = ptr + size;
> +
> +	return likely(start <= low && low <= high && high <= end);
> +}
> +
> +void *__wr_op(unsigned long dst, unsigned long src, __kernel_size_t len,
> +	      enum wr_op_type op)
> +{
> +	temporary_mm_state_t prev;
> +	unsigned long offset;
> +	unsigned long wr_poking_addr;
> +
> +	/* Confirm that the writable mapping exists. */
> +	if (WARN_ONCE(!wr_ready, "No writable mapping available"))
> +		return (void *)dst;
> +
> +	if (WARN_ONCE(op >= WR_OPS_NUMBER, "Invalid WR operation.") ||
> +	    WARN_ONCE(!is_wr_after_init(dst, len), "Invalid WR range."))
> +		return (void *)dst;
> +
> +	offset = dst - (unsigned long)&__start_wr_after_init;
> +	wr_poking_addr = wr_poking_base + offset;
> +	local_irq_disable();
> +	prev = use_temporary_mm(wr_poking_mm);
> +
> +	if (op == WR_MEMCPY)
> +		copy_to_user((void __user *)wr_poking_addr, (void *)src, len);
> +	else if (op == WR_MEMSET)
> +		memset_user((void __user *)wr_poking_addr, (u8)src, len);
> +
> +	unuse_temporary_mm(prev);
> +	local_irq_enable();
> +	return (void *)dst;
> +}

There's a lot of casting back and forth between unsigned long and void *
(also in the previous patch). Is there a reason for that? My impression
is that there would be less casts if variables holding addresses were
declared as void * in the first place. In that case, it wouldn't hurt to
have an additional argument in __rw_op() to carry the byte value for the
WR_MEMSET operation.

> +
> +#define TB (1UL << 40)
> +
> +struct mm_struct *copy_init_mm(void);
> +void __init wr_poking_init(void)
> +{
> +	unsigned long start = (unsigned long)&__start_wr_after_init;
> +	unsigned long end = (unsigned long)&__end_wr_after_init;
> +	unsigned long i;
> +	unsigned long wr_range;
> +
> +	wr_poking_mm = copy_init_mm();
> +	if (WARN_ONCE(!wr_poking_mm, "No alternate mapping available."))
> +		return;
> +
> +	wr_range = round_up(end - start, PAGE_SIZE);
> +
> +	/* Randomize the poking address base*/
> +	wr_poking_base = TASK_UNMAPPED_BASE +
> +		(kaslr_get_random_long("Write Rare Poking") & PAGE_MASK) %
> +		(TASK_SIZE - (TASK_UNMAPPED_BASE + wr_range));
> +
> +	/*
> +	 * Place 64TB of kernel address space within 128TB of user address
> +	 * space, at a random page aligned offset.
> +	 */
> +	wr_poking_base = (((unsigned long)kaslr_get_random_long("WR Poke")) &
> +			  PAGE_MASK) % (64 * _BITUL(40));

You're setting wr_poking_base twice in a row? Is this an artifact from
rebase?

--
Thiago Jung Bauermann
IBM Linux Technology Center
