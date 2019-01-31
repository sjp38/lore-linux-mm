Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEF60C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 04:19:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7229E20833
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 04:19:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7229E20833
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 082F38E0002; Wed, 30 Jan 2019 23:19:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 032A38E0001; Wed, 30 Jan 2019 23:19:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8B968E0002; Wed, 30 Jan 2019 23:19:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A79E88E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 23:19:20 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id a2so1284215pgt.11
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 20:19:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=JJ2Z3gWqBnZA7p6m3crqgxo41wTTJmgblkbOTQD7DW0=;
        b=bFCL5wbJtMleo8vMVCfZbdibU3w+KUjD2s+AsX2d1LUxLL6LGjkgoHs63WXYpo8j8a
         sty7CmuSjZf9H9xVoe29y8bdhXvo6qWS3vaPJIuE0KNVCvBgPYof4xrU/ItjE3Kwby9H
         10xSGCDJ7WIwNFjmBCJayU7mvmJYFJYnB+pScJaDtIkHYSXKacfsTt85ZgUS9jkaP4b0
         tdG+YVILvf1kKtA4OLm+ErvWAcH/r2FJyELoX2wAGT+5VzsAYUDa9MFNoZUTGdE2X4Ct
         w0rVdN0ZzuCafzjMIJat2Hkhsnel+bibUpdpLDmZq/8eb08I7Gs/mPM8qrcG9UU4GjJc
         oo2A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AJcUukfjetOmvB2y8lBiOgWAvGgJ7OahzbpbCAEq5d1d9KKcI2RHKqBj
	oJCkRBBTt2FLymo7TFKXYPCYproiPJobHfPaZb/IVcmar91QViw88YPlQENEG45gnsPZ/nZvC6Y
	oAB1KOWYVrNABm6cGCBMYBSDW4S1NBS28rTVzTzqq9UfM21ONdYReSd94f7FWw6o=
X-Received: by 2002:a17:902:8d94:: with SMTP id v20mr32999336plo.194.1548908360349;
        Wed, 30 Jan 2019 20:19:20 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6zI5H56bYsCFhgWoXCnnD0YEiSPgo0tfRFma1xcmZfJw4SqYL+RTmY7b0EL5Q8yj6zKBKQ
X-Received: by 2002:a17:902:8d94:: with SMTP id v20mr32999313plo.194.1548908359481;
        Wed, 30 Jan 2019 20:19:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548908359; cv=none;
        d=google.com; s=arc-20160816;
        b=KMiEFilDd/KJSXJGU3k8pS1i2FD7l3tB3SEo69HV73Le5U6SZwNpBglK4OaAa6D35L
         ZUJK8T3CqGJWu26iZ9qFEWIlSF8rqLTWxG0Eql/svgqaHdOtPK4uGkYoqAJzQwHXzuZK
         3Bu68BZjGO7ulpDeaG/RBwuYpb6Iik8WMDTlN9fkj4fySoY+IxYdy5sdFp++CcDmvNm8
         dpd75ZJVJPQysEvb9fy8ATFi1gX0iRyBJh0ID5GP8PPx9RlfWvOa44wDFBNfs560y1tC
         1Z2akYpB//vtcrZX+ynowXsk/U9HjO9pWg+zRFD+05TAHtC5Q+K45PYaVN8yzZQUh9E5
         1a2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=JJ2Z3gWqBnZA7p6m3crqgxo41wTTJmgblkbOTQD7DW0=;
        b=hAn0rf81b7SuyknKEbdT+N7066kb0gVlxkhK1UkjHqbPPwKg8LtQZ88T8GIq2OrugT
         Oy57rgkCf+4lGud81WXgdY+KJweneisr3Q5j4Dxj5oYkk8TVMUgu5RV6gi3gRWlzP/DK
         H2kqVvQle7xh1LFjxLiQ0jLWzU2oxOvkU9jDM7E+ivobErIiiBqTI0GY/xjAaMhzndDm
         MLTp9aHPY9IFRfBk9zaJFnb9t7qD5lfa6RiwQp1X1hL1yamoweH0TB3jrJja24MDiBJR
         BN/SXdzxSECzCbDcoI/Ty8E14PpVXSAwmAHIurtS0JYFnsTHk9keVbwHWdGxjV3DedPn
         N39A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id k186si3398391pgc.576.2019.01.30.20.19.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 20:19:18 -0800 (PST)
Received-SPF: neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 43qn7810Tdz9sBb;
	Thu, 31 Jan 2019 15:19:16 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Christophe Leroy <christophe.leroy@c-s.fr>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org
Subject: Re: [PATCH v3 2/2] powerpc: use probe_user_read()
In-Reply-To: <afd95fa4747f1c1eb66677025c2c7c9055f43cce.1547652372.git.christophe.leroy@c-s.fr>
References: <39fb6c5a191025378676492e140dc012915ecaeb.1547652372.git.christophe.leroy@c-s.fr> <afd95fa4747f1c1eb66677025c2c7c9055f43cce.1547652372.git.christophe.leroy@c-s.fr>
Date: Thu, 31 Jan 2019 15:19:13 +1100
Message-ID: <878sz1pigu.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Christophe Leroy <christophe.leroy@c-s.fr> writes:

> Instead of opencoding, use probe_user_read() to failessly
> read a user location.
>
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> ---
>  v3: No change
>
>  v2: Using probe_user_read() instead of probe_user_address()
>
>  arch/powerpc/kernel/process.c   | 12 +-----------
>  arch/powerpc/mm/fault.c         |  6 +-----
>  arch/powerpc/perf/callchain.c   | 20 +++-----------------
>  arch/powerpc/perf/core-book3s.c |  8 +-------
>  arch/powerpc/sysdev/fsl_pci.c   | 10 ++++------
>  5 files changed, 10 insertions(+), 46 deletions(-)

Looks good.

Acked-by: Michael Ellerman <mpe@ellerman.id.au>

cheers

> diff --git a/arch/powerpc/kernel/process.c b/arch/powerpc/kernel/process.c
> index ce393df243aa..6a4b59d574c2 100644
> --- a/arch/powerpc/kernel/process.c
> +++ b/arch/powerpc/kernel/process.c
> @@ -1298,16 +1298,6 @@ void show_user_instructions(struct pt_regs *regs)
>  
>  	pc = regs->nip - (NR_INSN_TO_PRINT * 3 / 4 * sizeof(int));
>  
> -	/*
> -	 * Make sure the NIP points at userspace, not kernel text/data or
> -	 * elsewhere.
> -	 */
> -	if (!__access_ok(pc, NR_INSN_TO_PRINT * sizeof(int), USER_DS)) {
> -		pr_info("%s[%d]: Bad NIP, not dumping instructions.\n",
> -			current->comm, current->pid);
> -		return;
> -	}
> -
>  	seq_buf_init(&s, buf, sizeof(buf));
>  
>  	while (n) {
> @@ -1318,7 +1308,7 @@ void show_user_instructions(struct pt_regs *regs)
>  		for (i = 0; i < 8 && n; i++, n--, pc += sizeof(int)) {
>  			int instr;
>  
> -			if (probe_kernel_address((const void *)pc, instr)) {
> +			if (probe_user_read(&instr, (void __user *)pc, sizeof(instr))) {
>  				seq_buf_printf(&s, "XXXXXXXX ");
>  				continue;
>  			}
> diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
> index 887f11bcf330..ec74305fa330 100644
> --- a/arch/powerpc/mm/fault.c
> +++ b/arch/powerpc/mm/fault.c
> @@ -276,12 +276,8 @@ static bool bad_stack_expansion(struct pt_regs *regs, unsigned long address,
>  		if ((flags & FAULT_FLAG_WRITE) && (flags & FAULT_FLAG_USER) &&
>  		    access_ok(nip, sizeof(*nip))) {
>  			unsigned int inst;
> -			int res;
>  
> -			pagefault_disable();
> -			res = __get_user_inatomic(inst, nip);
> -			pagefault_enable();
> -			if (!res)
> +			if (!probe_user_read(&inst, nip, sizeof(inst)))
>  				return !store_updates_sp(inst);
>  			*must_retry = true;
>  		}
> diff --git a/arch/powerpc/perf/callchain.c b/arch/powerpc/perf/callchain.c
> index 0af051a1974e..0680efb2237b 100644
> --- a/arch/powerpc/perf/callchain.c
> +++ b/arch/powerpc/perf/callchain.c
> @@ -159,12 +159,8 @@ static int read_user_stack_64(unsigned long __user *ptr, unsigned long *ret)
>  	    ((unsigned long)ptr & 7))
>  		return -EFAULT;
>  
> -	pagefault_disable();
> -	if (!__get_user_inatomic(*ret, ptr)) {
> -		pagefault_enable();
> +	if (!probe_user_read(ret, ptr, sizeof(*ret)))
>  		return 0;
> -	}
> -	pagefault_enable();
>  
>  	return read_user_stack_slow(ptr, ret, 8);
>  }
> @@ -175,12 +171,8 @@ static int read_user_stack_32(unsigned int __user *ptr, unsigned int *ret)
>  	    ((unsigned long)ptr & 3))
>  		return -EFAULT;
>  
> -	pagefault_disable();
> -	if (!__get_user_inatomic(*ret, ptr)) {
> -		pagefault_enable();
> +	if (!probe_user_read(ret, ptr, sizeof(*ret)))
>  		return 0;
> -	}
> -	pagefault_enable();
>  
>  	return read_user_stack_slow(ptr, ret, 4);
>  }
> @@ -307,17 +299,11 @@ static inline int current_is_64bit(void)
>   */
>  static int read_user_stack_32(unsigned int __user *ptr, unsigned int *ret)
>  {
> -	int rc;
> -
>  	if ((unsigned long)ptr > TASK_SIZE - sizeof(unsigned int) ||
>  	    ((unsigned long)ptr & 3))
>  		return -EFAULT;
>  
> -	pagefault_disable();
> -	rc = __get_user_inatomic(*ret, ptr);
> -	pagefault_enable();
> -
> -	return rc;
> +	return probe_user_read(ret, ptr, sizeof(*ret));
>  }
>  
>  static inline void perf_callchain_user_64(struct perf_callchain_entry_ctx *entry,
> diff --git a/arch/powerpc/perf/core-book3s.c b/arch/powerpc/perf/core-book3s.c
> index b0723002a396..4b64ddf0db68 100644
> --- a/arch/powerpc/perf/core-book3s.c
> +++ b/arch/powerpc/perf/core-book3s.c
> @@ -416,7 +416,6 @@ static void power_pmu_sched_task(struct perf_event_context *ctx, bool sched_in)
>  static __u64 power_pmu_bhrb_to(u64 addr)
>  {
>  	unsigned int instr;
> -	int ret;
>  	__u64 target;
>  
>  	if (is_kernel_addr(addr)) {
> @@ -427,13 +426,8 @@ static __u64 power_pmu_bhrb_to(u64 addr)
>  	}
>  
>  	/* Userspace: need copy instruction here then translate it */
> -	pagefault_disable();
> -	ret = __get_user_inatomic(instr, (unsigned int __user *)addr);
> -	if (ret) {
> -		pagefault_enable();
> +	if (probe_user_read(&instr, (unsigned int __user *)addr, sizeof(instr)))
>  		return 0;
> -	}
> -	pagefault_enable();
>  
>  	target = branch_target(&instr);
>  	if ((!target) || (instr & BRANCH_ABSOLUTE))
> diff --git a/arch/powerpc/sysdev/fsl_pci.c b/arch/powerpc/sysdev/fsl_pci.c
> index 918be816b097..c8a1b26489f5 100644
> --- a/arch/powerpc/sysdev/fsl_pci.c
> +++ b/arch/powerpc/sysdev/fsl_pci.c
> @@ -1068,13 +1068,11 @@ int fsl_pci_mcheck_exception(struct pt_regs *regs)
>  	addr += mfspr(SPRN_MCAR);
>  
>  	if (is_in_pci_mem_space(addr)) {
> -		if (user_mode(regs)) {
> -			pagefault_disable();
> -			ret = get_user(inst, (__u32 __user *)regs->nip);
> -			pagefault_enable();
> -		} else {
> +		if (user_mode(regs))
> +			ret = probe_user_read(&inst, (void __user *)regs->nip,
> +					      sizeof(inst));
> +		else
>  			ret = probe_kernel_address((void *)regs->nip, inst);
> -		}
>  
>  		if (!ret && mcheck_handle_load(regs, inst)) {
>  			regs->nip += 4;
> -- 
> 2.13.3

