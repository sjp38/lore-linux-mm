Return-Path: <SRS0=RE7g=PQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C22BC43387
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 09:57:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 666DA2087E
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 09:57:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="mQ2L/56S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 666DA2087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=russell.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA6168E006A; Tue,  8 Jan 2019 04:57:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2BB48E0038; Tue,  8 Jan 2019 04:57:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA5D68E006A; Tue,  8 Jan 2019 04:57:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9B1528E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 04:57:36 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id d196so2717164qkb.6
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 01:57:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=8NgReACofGr4pfsVek1KnbG548/6VAg+JiRF3ljMJik=;
        b=B4m0cPNX4Yb6Gw56sRmCjn2HjfTJooHKQBFIJ3ZiTJuXL2M3swk8uhSCTjXFvtCCxe
         1rzmeSNa9cDYneiF+rEH1MO1DC60ZSVX0NBGUNSWLVT98xU/wiqkz+NZmX1jxhIb3I6Y
         Mol4P6yerbhuo4VaDdCoH6+yU0t7pfup0NMHUZS6tsApkYvefA0NqyiHSrxVLUFx6zu8
         NUNKTfJlSH9F6OVCg8dp0T5rRROBsQk3v54xhEb+U5/agorXpcs5rQ9RxEwzIk41LmWN
         jo3D9eiyE/6tDZPleOJJhT9JbcM9EkjaHem9+AHM9tLLW9py/nsu9YJv0O800Rn0InB7
         tRTw==
X-Gm-Message-State: AJcUukdbTFM0lncFWDSDx+fd/aBCt+SXwTR/RpoajwYdO+pCIbtsRBip
	d2fvEScUoYJF0ZVj9mSkL9kxflNVIt8MZ8qUzjetszd7IRO+56zXV/L7BOTyPah7BSLk86CP1nm
	+RF7Aa4XA3jwo4UxH+rHdoKFzmz7WRUCl8gSZ0v6eQ6EsUazgek8HMGK02OIBZMY=
X-Received: by 2002:a05:620a:132b:: with SMTP id p11mr885854qkj.327.1546941456346;
        Tue, 08 Jan 2019 01:57:36 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6wZNZesacZYYIFAXQ8W+l9tYJY1iWAFuk1ACFvIdGSdRvrb7jm4ME6Rv6C3KRQD4BSixq1
X-Received: by 2002:a05:620a:132b:: with SMTP id p11mr885820qkj.327.1546941455597;
        Tue, 08 Jan 2019 01:57:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546941455; cv=none;
        d=google.com; s=arc-20160816;
        b=qRbvS07Q5u9WmIPH19a1smNC7AK1sG8ir18gH4N3XJuziPCsndt/X+B7ZE3YB8P0HM
         JGwhxrqUqrG1GyhM/kf1qgt/9aK0GEbpnxTY2FfaaWaesyw1jdlNQCqe8EgMbWRxDVRj
         51TuK9mdTn/g8Xkb6MDNQ8X6QOwCoK2UJ3C4c9eHQwOkrKli42KxoPrmT7PoLYAdvuSe
         AyJ3LUTVLrCHrsVpuxDViAj8PeDxnugj8ZYbHNoRz7augElfKmCWKXV0J+ZTDbZ7TwZO
         QwtjpfOB+4Uxv3oKxVoC4elsmQuUnS2sbP6A4QrmkE/MkvUvMtd6ADe4GNEVroA+d1NP
         oQZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id:dkim-signature;
        bh=8NgReACofGr4pfsVek1KnbG548/6VAg+JiRF3ljMJik=;
        b=nozFTQFKCk6gDaMxZSEdNuxSy1z2YWgSf98goTVQT6/UxO56pC/92iqAX+CWWbZm0O
         j9/SS60MsqTcD4n4C9EsLuFb9lcbrJHWWHnPk7T+23UfrreyJMUFN2kMFVBbqxOP2YRC
         p4KXXlKJfvB1WXxJ18saptBeCT3jgJzZ1AwR1vgidMEbELkaXVPHaUz8RTbMCUhOjPra
         O4GAnQVWZbRbr0OqRPtYAo7tAJylU2S1txg0p+S8Kl9FMQaZtvV8JO4p1WUGsUesTF+P
         N4F+xyN2GT5k+y1pXhxTK6h+nv7FRI6NYwS4BuQqc79vnK5nkSgF22wDep1846PsGHFi
         sZKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b="mQ2L/56S";
       spf=neutral (google.com: 64.147.123.25 is neither permitted nor denied by best guess record for domain of ruscur@russell.cc) smtp.mailfrom=ruscur@russell.cc
Received: from wout2-smtp.messagingengine.com (wout2-smtp.messagingengine.com. [64.147.123.25])
        by mx.google.com with ESMTPS id e35si4229323qve.41.2019.01.08.01.57.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 01:57:34 -0800 (PST)
Received-SPF: neutral (google.com: 64.147.123.25 is neither permitted nor denied by best guess record for domain of ruscur@russell.cc) client-ip=64.147.123.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b="mQ2L/56S";
       spf=neutral (google.com: 64.147.123.25 is neither permitted nor denied by best guess record for domain of ruscur@russell.cc) smtp.mailfrom=ruscur@russell.cc
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.west.internal (Postfix) with ESMTP id 2AF1B1372;
	Tue,  8 Jan 2019 04:57:33 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
  by compute6.internal (MEProxy); Tue, 08 Jan 2019 04:57:33 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:content-type
	:date:from:in-reply-to:message-id:mime-version:references
	:subject:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender
	:x-sasl-enc; s=fm1; bh=8NgReACofGr4pfsVek1KnbG548/6VAg+JiRF3ljMJ
	ik=; b=mQ2L/56S+ov7BImttVK3klS4q7x3z3cfmxwjxB0oew76lugkXWSKxd301
	jhx3z2uBMhRyc8VYpUDl8I39v1dxiQPBESWlGKwvypRH80sXLpShjyi63ZTzokHW
	LplagP37FIZU/ZEJ4OhaIYWmNQruEFc3w8fbouwPTSfrpLe46VX2kakNC4FKQakq
	iNWvA0FHQajxJ/z2MO8Nks3KEe+mwoHGpfEWx1bH+WqpbXf/WhStegRE+7/5fZzp
	kFk6G4tHvFV+6A9vrU0Q7mM0mEneEI1N6wlZ5FRHH1+hhnbbqCPgm2vtpRlBrLYE
	Aos5x9n7zVOj3rybFGBe/lfyS6ygg==
X-ME-Sender: <xms:C3Q0XASfp-usMgrhx_WGTdAASULcT52_PDPMj5Fo5PtBuvuMl_ECAQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrvdelgddtkeculddtuddrgedtkedrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    gfrhhlucfvnfffucdlfedtmdenucfjughrpefkuffhvfffjghftggfggfgsehtkeertddt
    reejnecuhfhrohhmpeftuhhsshgvlhhlucevuhhrrhgvhicuoehruhhstghurhesrhhush
    hsvghllhdrtggtqeenucfkphepuddrudehjedrudelgedrudelkeenucfrrghrrghmpehm
    rghilhhfrhhomheprhhushgtuhhrsehruhhsshgvlhhlrdgttgenucevlhhushhtvghruf
    hiiigvpedt
X-ME-Proxy: <xmx:C3Q0XItAmkhGC32P9BWVvKIneWF6ItIwYel34OmCDto9z5E3EZL4ZA>
    <xmx:C3Q0XMwtlGuiBWJ69siaYGiWEGUWPUgN2c3UVCsJdfccTkUe1TVg5g>
    <xmx:C3Q0XIeE_OlUJVYyCa7EKe58lk3mF1GDyaHRfsuAJ2GitCHWzkknFw>
    <xmx:DHQ0XF5G1WQhdoXRMjmaqMlPrnpqCbb8ql3OuJNf52dmuGpWNujTRA>
Received: from crackle.ozlabs.ibm.com (unknown [1.157.194.198])
	by mail.messagingengine.com (Postfix) with ESMTPA id BFF3D10087;
	Tue,  8 Jan 2019 04:57:27 -0500 (EST)
Message-ID: <9c1097982d424c0c96459899e36f7f4c9345be73.camel@russell.cc>
Subject: Re: [PATCH v2 2/2] powerpc: use probe_user_read()
From: Russell Currey <ruscur@russell.cc>
To: Christophe Leroy <christophe.leroy@c-s.fr>, Michael Ellerman
	 <mpe@ellerman.id.au>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton
 <akpm@linux-foundation.org>,  Benjamin Herrenschmidt
 <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Mike
 Rapoport <rppt@linux.ibm.com>,  linux-mm@kvack.org,
 linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
Date: Tue, 08 Jan 2019 20:58:37 +1100
In-Reply-To: <293a653c-52aa-6326-4022-73fb25590354@c-s.fr>
References: 
	<0b0db24e18063076e9d9f4e376994af83da05456.1546932949.git.christophe.leroy@c-s.fr>
	 <e939991366b784ef13c7afcab51749e3b46327ac.1546932949.git.christophe.leroy@c-s.fr>
	 <293a653c-52aa-6326-4022-73fb25590354@c-s.fr>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.3 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190108095837.1WJWPj9kXKvQ-XlrUAej7D-MQT-alriruDB5aHZ2rVw@z>

On Tue, 2019-01-08 at 10:37 +0100, Christophe Leroy wrote:
> Hi Michael and Russell,
> 
> Any idea why:
> - checkpatch reports missing Signed-off-by:
> - Snowpatch build fails on PPC64 (it seems unrelated to the patch, 
> something wrong in lib/genalloc.c)

Upstream kernel broke for powerpc (snowpatch applies patches on top of
powerpc/next), it was fixed in commit
35004f2e55807a1a1491db24ab512dd2f770a130 which I believe is in
powerpc/next now.  I will look at rerunning tests for all the patches
that this impacted.

As for the S-o-b, no clue, I'll have a look.  Thanks for the report!

- Russell

> 
> Thanks
> Christophe
> 
> Le 08/01/2019 à 08:37, Christophe Leroy a écrit :
> > Instead of opencoding, use probe_user_read() to failessly
> > read a user location.
> > 
> > Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> > ---
> >   v2: Using probe_user_read() instead of probe_user_address()
> > 
> >   arch/powerpc/kernel/process.c   | 12 +-----------
> >   arch/powerpc/mm/fault.c         |  6 +-----
> >   arch/powerpc/perf/callchain.c   | 20 +++-----------------
> >   arch/powerpc/perf/core-book3s.c |  8 +-------
> >   arch/powerpc/sysdev/fsl_pci.c   | 10 ++++------
> >   5 files changed, 10 insertions(+), 46 deletions(-)
> > 
> > diff --git a/arch/powerpc/kernel/process.c
> > b/arch/powerpc/kernel/process.c
> > index ce393df243aa..6a4b59d574c2 100644
> > --- a/arch/powerpc/kernel/process.c
> > +++ b/arch/powerpc/kernel/process.c
> > @@ -1298,16 +1298,6 @@ void show_user_instructions(struct pt_regs
> > *regs)
> >   
> >   	pc = regs->nip - (NR_INSN_TO_PRINT * 3 / 4 * sizeof(int));
> >   
> > -	/*
> > -	 * Make sure the NIP points at userspace, not kernel text/data
> > or
> > -	 * elsewhere.
> > -	 */
> > -	if (!__access_ok(pc, NR_INSN_TO_PRINT * sizeof(int), USER_DS))
> > {
> > -		pr_info("%s[%d]: Bad NIP, not dumping instructions.\n",
> > -			current->comm, current->pid);
> > -		return;
> > -	}
> > -
> >   	seq_buf_init(&s, buf, sizeof(buf));
> >   
> >   	while (n) {
> > @@ -1318,7 +1308,7 @@ void show_user_instructions(struct pt_regs
> > *regs)
> >   		for (i = 0; i < 8 && n; i++, n--, pc += sizeof(int)) {
> >   			int instr;
> >   
> > -			if (probe_kernel_address((const void *)pc,
> > instr)) {
> > +			if (probe_user_read(&instr, (void __user *)pc,
> > sizeof(instr))) {
> >   				seq_buf_printf(&s, "XXXXXXXX ");
> >   				continue;
> >   			}
> > diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
> > index 887f11bcf330..ec74305fa330 100644
> > --- a/arch/powerpc/mm/fault.c
> > +++ b/arch/powerpc/mm/fault.c
> > @@ -276,12 +276,8 @@ static bool bad_stack_expansion(struct pt_regs
> > *regs, unsigned long address,
> >   		if ((flags & FAULT_FLAG_WRITE) && (flags &
> > FAULT_FLAG_USER) &&
> >   		    access_ok(nip, sizeof(*nip))) {
> >   			unsigned int inst;
> > -			int res;
> >   
> > -			pagefault_disable();
> > -			res = __get_user_inatomic(inst, nip);
> > -			pagefault_enable();
> > -			if (!res)
> > +			if (!probe_user_read(&inst, nip, sizeof(inst)))
> >   				return !store_updates_sp(inst);
> >   			*must_retry = true;
> >   		}
> > diff --git a/arch/powerpc/perf/callchain.c
> > b/arch/powerpc/perf/callchain.c
> > index 0af051a1974e..0680efb2237b 100644
> > --- a/arch/powerpc/perf/callchain.c
> > +++ b/arch/powerpc/perf/callchain.c
> > @@ -159,12 +159,8 @@ static int read_user_stack_64(unsigned long
> > __user *ptr, unsigned long *ret)
> >   	    ((unsigned long)ptr & 7))
> >   		return -EFAULT;
> >   
> > -	pagefault_disable();
> > -	if (!__get_user_inatomic(*ret, ptr)) {
> > -		pagefault_enable();
> > +	if (!probe_user_read(ret, ptr, sizeof(*ret)))
> >   		return 0;
> > -	}
> > -	pagefault_enable();
> >   
> >   	return read_user_stack_slow(ptr, ret, 8);
> >   }
> > @@ -175,12 +171,8 @@ static int read_user_stack_32(unsigned int
> > __user *ptr, unsigned int *ret)
> >   	    ((unsigned long)ptr & 3))
> >   		return -EFAULT;
> >   
> > -	pagefault_disable();
> > -	if (!__get_user_inatomic(*ret, ptr)) {
> > -		pagefault_enable();
> > +	if (!probe_user_read(ret, ptr, sizeof(*ret)))
> >   		return 0;
> > -	}
> > -	pagefault_enable();
> >   
> >   	return read_user_stack_slow(ptr, ret, 4);
> >   }
> > @@ -307,17 +299,11 @@ static inline int current_is_64bit(void)
> >    */
> >   static int read_user_stack_32(unsigned int __user *ptr, unsigned
> > int *ret)
> >   {
> > -	int rc;
> > -
> >   	if ((unsigned long)ptr > TASK_SIZE - sizeof(unsigned int) ||
> >   	    ((unsigned long)ptr & 3))
> >   		return -EFAULT;
> >   
> > -	pagefault_disable();
> > -	rc = __get_user_inatomic(*ret, ptr);
> > -	pagefault_enable();
> > -
> > -	return rc;
> > +	return probe_user_read(ret, ptr, sizeof(*ret));
> >   }
> >   
> >   static inline void perf_callchain_user_64(struct
> > perf_callchain_entry_ctx *entry,
> > diff --git a/arch/powerpc/perf/core-book3s.c
> > b/arch/powerpc/perf/core-book3s.c
> > index b0723002a396..4b64ddf0db68 100644
> > --- a/arch/powerpc/perf/core-book3s.c
> > +++ b/arch/powerpc/perf/core-book3s.c
> > @@ -416,7 +416,6 @@ static void power_pmu_sched_task(struct
> > perf_event_context *ctx, bool sched_in)
> >   static __u64 power_pmu_bhrb_to(u64 addr)
> >   {
> >   	unsigned int instr;
> > -	int ret;
> >   	__u64 target;
> >   
> >   	if (is_kernel_addr(addr)) {
> > @@ -427,13 +426,8 @@ static __u64 power_pmu_bhrb_to(u64 addr)
> >   	}
> >   
> >   	/* Userspace: need copy instruction here then translate it */
> > -	pagefault_disable();
> > -	ret = __get_user_inatomic(instr, (unsigned int __user *)addr);
> > -	if (ret) {
> > -		pagefault_enable();
> > +	if (probe_user_read(&instr, (unsigned int __user *)addr,
> > sizeof(instr)))
> >   		return 0;
> > -	}
> > -	pagefault_enable();
> >   
> >   	target = branch_target(&instr);
> >   	if ((!target) || (instr & BRANCH_ABSOLUTE))
> > diff --git a/arch/powerpc/sysdev/fsl_pci.c
> > b/arch/powerpc/sysdev/fsl_pci.c
> > index 918be816b097..c8a1b26489f5 100644
> > --- a/arch/powerpc/sysdev/fsl_pci.c
> > +++ b/arch/powerpc/sysdev/fsl_pci.c
> > @@ -1068,13 +1068,11 @@ int fsl_pci_mcheck_exception(struct pt_regs
> > *regs)
> >   	addr += mfspr(SPRN_MCAR);
> >   
> >   	if (is_in_pci_mem_space(addr)) {
> > -		if (user_mode(regs)) {
> > -			pagefault_disable();
> > -			ret = get_user(inst, (__u32 __user *)regs-
> > >nip);
> > -			pagefault_enable();
> > -		} else {
> > +		if (user_mode(regs))
> > +			ret = probe_user_read(&inst, (void __user
> > *)regs->nip,
> > +					      sizeof(inst));
> > +		else
> >   			ret = probe_kernel_address((void *)regs->nip,
> > inst);
> > -		}
> >   
> >   		if (!ret && mcheck_handle_load(regs, inst)) {
> >   			regs->nip += 4;
> > 

