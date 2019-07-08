Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6110C48BE7
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 08:26:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A44320665
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 08:26:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A44320665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sifive.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 030038E000C; Mon,  8 Jul 2019 04:26:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F21CB8E0002; Mon,  8 Jul 2019 04:26:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E11698E000C; Mon,  8 Jul 2019 04:26:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7618E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 04:26:36 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id m2so1092550ljj.0
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 01:26:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:subject
         :in-reply-to:cc:from:to:message-id:mime-version
         :content-transfer-encoding;
        bh=H9Jhir71IPIyzQGq+vtRBmdG8XRrnz6d01HWPy/tDXY=;
        b=szTshzAG9YCZK8bLRcSWbeMDEVOudLd3nL0bxBgAZHUuGcva3rKG8CiMKqNP0HtLFh
         9YRLgSeA2uqYDQYLuWJ5a4GNgmIeUo8tQ2ySDwofmnLhiuhowdFsWOTcQNfm2+DNa+7+
         XuH4UH1BOe0zyQAUKMdaJT59/S3XYlAj/6N16VwfnHXg/0iOQ9tddcySeKe8bA5mQkeD
         k99uKU2QUnG+6hpS4J+cz8Fw96ivh5dVNJ5s6Lh1DIlI9kq5i0cwW5S1kLgfsrtxEIrr
         Gaf3Mf81xFw/aLTpLk6LaIVYddF5DHHi4Ei52SSjnTWNTNFYLhGVhr2JdAP91IKgDSj4
         U7gg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of palmer@dabbelt.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=palmer@dabbelt.com
X-Gm-Message-State: APjAAAUwm74PYLJ3kICTrpgFJ/Nq+LX1+KebYy6RHLOdBfnZY9dfd55F
	Lakxb0bRNHq0Y9NLGdsh4/Qhv25B3mFbyowAs/AI0v73cDtWZA/jhuBf2zveFYlrLMOy9/261dY
	d1AFyO0NZmSJvhYIXaAzZ4U2nClEUZZEimCKidHSrlVZzD2xtnthEyrAaWvtN1l1q7w==
X-Received: by 2002:a2e:9155:: with SMTP id q21mr9439100ljg.198.1562574395913;
        Mon, 08 Jul 2019 01:26:35 -0700 (PDT)
X-Received: by 2002:a2e:9155:: with SMTP id q21mr9439071ljg.198.1562574395025;
        Mon, 08 Jul 2019 01:26:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562574395; cv=none;
        d=google.com; s=arc-20160816;
        b=PiI7rjmzYkUS1BxLGNX2pkI3ASOZUuTo0+PYFPF/+Rv9wHnltio0fPfc/LBTzLtI7A
         z/ajHZSKKjq8Y1t0q9s9QQyz8AEylavZYMPkAQGTDNnWGA0DK0H6U3ekPKS5AwObaC94
         GzPS89Hy7zLTs5NOSJk8RuZy8InTmhuObGBlaE6GVLCEN3NTL5Wnw4rmIV/ch+gWQtu9
         xWGqQF/NgF87NSBgjZDMBlRR9/xKUO02PSptGks3dcnCrmsb4FdOTEq7Q+7uHvzCGUwT
         axR9JeB7ZialWCiDDrEvGVLkg+ncu8NjaX7k3kdMNAkVJcxAh0a+wjCxQ1nsOvKxWt/J
         gSYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:to:from:cc
         :in-reply-to:subject:date;
        bh=H9Jhir71IPIyzQGq+vtRBmdG8XRrnz6d01HWPy/tDXY=;
        b=C/u+kqWuSN+TNRhJLFA8gEr22D2XX9wqkJ4OsqsGhGlUscSUJw0GO/66iya2+cFtmY
         FMwAWjOSNzIOHpIVIwdyhOfGiYlIka60J3WH3DDmTuHoRG6U5LtQcLt+025u9YDg/XwH
         UxQz1b3Rw0uNglD8ae5WdAP5rGYb5wjauK7vMF5QqLjt8uhYU3JJVwKiLKg5cRki0WR6
         W2NuTTmfHH1GAUbQFDGFEbrt3uABNJasj70XbFpwPzOyMmFESQb1fKrohZ2dHBEq4MtI
         B8qxe7hyu5ojexkYCVcAdY7he4o7SWC7xzoKQAb+bKTAebO8wvtZ0vly+irzRPiiXNms
         OoZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of palmer@dabbelt.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=palmer@dabbelt.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m7sor8286018ljg.14.2019.07.08.01.26.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 01:26:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of palmer@dabbelt.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of palmer@dabbelt.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=palmer@dabbelt.com
X-Google-Smtp-Source: APXvYqxXI/Ygue1Ac50jCKVSmx6Cuo5Nc2NT6pzqbq/Iw8sN98mexSHmndyMkZYR9vs57B/cyO2EhQ==
X-Received: by 2002:a2e:80c8:: with SMTP id r8mr9586901ljg.168.1562574394354;
        Mon, 08 Jul 2019 01:26:34 -0700 (PDT)
Received: from localhost ([134.17.27.127])
        by smtp.gmail.com with ESMTPSA id b27sm1558817ljb.11.2019.07.08.01.26.33
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 08 Jul 2019 01:26:33 -0700 (PDT)
Date: Mon, 08 Jul 2019 01:26:33 -0700 (PDT)
X-Google-Original-Date: Mon, 08 Jul 2019 01:23:27 PDT (-0700)
Subject:     Re: [PATCH 16/17] riscv: clear the instruction cache and all registers when booting
In-Reply-To: <78919862d11f6d56446f8fffd8a1a8c601ea5c32.camel@wdc.com>
CC: Christoph Hellwig <hch@lst.de>, Paul Walmsley <paul.walmsley@sifive.com>,
  linux-mm@kvack.org, Damien Le Moal <Damien.LeMoal@wdc.com>, linux-riscv@lists.infradead.org,
  linux-kernel@vger.kernel.org
From: Palmer Dabbelt <palmer@sifive.com>
To: Atish Patra <Atish.Patra@wdc.com>
Message-ID: <mhng-3f43f4b8-473d-429d-9a09-12d3542e33bc@palmer-si-x1e>
Mime-Version: 1.0 (MHng)
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 01 Jul 2019 14:26:18 PDT (-0700), Atish Patra wrote:
> On Mon, 2019-06-24 at 07:43 +0200, Christoph Hellwig wrote:
>> When we get booted we want a clear slate without any leaks from
>> previous
>> supervisors or the firmware.  Flush the instruction cache and then
>> clear
>> all registers to known good values.  This is really important for the
>> upcoming nommu support that runs on M-mode, but can't really harm
>> when
>> running in S-mode either.
> 
> That means it should be done for S-mode as well. Right ?
> I see the reset code is enabled only for M-mode only.
> 
>>   Vaguely based on the concepts from opensbi.
>> 
>> Signed-off-by: Christoph Hellwig <hch@lst.de>
>> ---
>>  arch/riscv/kernel/head.S | 85
>> ++++++++++++++++++++++++++++++++++++++++
>>  1 file changed, 85 insertions(+)
>> 
>> diff --git a/arch/riscv/kernel/head.S b/arch/riscv/kernel/head.S
>> index a4c170e41a34..74feb17737b4 100644
>> --- a/arch/riscv/kernel/head.S
>> +++ b/arch/riscv/kernel/head.S
>> @@ -11,6 +11,7 @@
>>  #include <asm/thread_info.h>
>>  #include <asm/page.h>
>>  #include <asm/csr.h>
>> +#include <asm/hwcap.h>
>>  
>>  __INIT
>>  ENTRY(_start)
>> @@ -19,6 +20,12 @@ ENTRY(_start)
>>  	csrw CSR_XIP, zero
>>  
>>  #ifdef CONFIG_M_MODE
>> +	/* flush the instruction cache */
>> +	fence.i
>> +
>> +	/* Reset all registers except ra, a0, a1 */
>> +	call reset_regs
>> +
>>  	/*
>>  	 * The hartid in a0 is expected later on, and we have no
>> firmware
>>  	 * to hand it to us.
>> @@ -168,6 +175,84 @@ relocate:
>>  	j .Lsecondary_park
>>  END(_start)
>>  
>> +#ifdef CONFIG_M_MODE
>> +ENTRY(reset_regs)
>> +	li	sp, 0
>> +	li	gp, 0
>> +	li	tp, 0
>> +	li	t0, 0
>> +	li	t1, 0
>> +	li	t2, 0
>> +	li	s0, 0
>> +	li	s1, 0
>> +	li	a2, 0
>> +	li	a3, 0
>> +	li	a4, 0
>> +	li	a5, 0
>> +	li	a6, 0
>> +	li	a7, 0
>> +	li	s2, 0
>> +	li	s3, 0
>> +	li	s4, 0
>> +	li	s5, 0
>> +	li	s6, 0
>> +	li	s7, 0
>> +	li	s8, 0
>> +	li	s9, 0
>> +	li	s10, 0
>> +	li	s11, 0
>> +	li	t3, 0
>> +	li	t4, 0
>> +	li	t5, 0
>> +	li	t6, 0
>> +	csrw	sscratch, 0
>> +
>> +#ifdef CONFIG_FPU
>> +	csrr	t0, misa
>> +	andi	t0, t0, (COMPAT_HWCAP_ISA_F | COMPAT_HWCAP_ISA_D)
>> +	bnez	t0, .Lreset_regs_done
>> +
>> +	li	t1, SR_FS
>> +	csrs	sstatus, t1

You need to check that the write stuck and branch around the FP instructions.
Specifically, CONFIG_FPU means there may be an FPU, not there's definately an
FPU.  You should also turn the FPU back off after zeroing the state.

>> +	fmv.s.x	f0, zero
>> +	fmv.s.x	f1, zero
>> +	fmv.s.x	f2, zero
>> +	fmv.s.x	f3, zero
>> +	fmv.s.x	f4, zero
>> +	fmv.s.x	f5, zero
>> +	fmv.s.x	f6, zero
>> +	fmv.s.x	f7, zero
>> +	fmv.s.x	f8, zero
>> +	fmv.s.x	f9, zero
>> +	fmv.s.x	f10, zero
>> +	fmv.s.x	f11, zero
>> +	fmv.s.x	f12, zero
>> +	fmv.s.x	f13, zero
>> +	fmv.s.x	f14, zero
>> +	fmv.s.x	f15, zero
>> +	fmv.s.x	f16, zero
>> +	fmv.s.x	f17, zero
>> +	fmv.s.x	f18, zero
>> +	fmv.s.x	f19, zero
>> +	fmv.s.x	f20, zero
>> +	fmv.s.x	f21, zero
>> +	fmv.s.x	f22, zero
>> +	fmv.s.x	f23, zero
>> +	fmv.s.x	f24, zero
>> +	fmv.s.x	f25, zero
>> +	fmv.s.x	f26, zero
>> +	fmv.s.x	f27, zero
>> +	fmv.s.x	f28, zero
>> +	fmv.s.x	f29, zero
>> +	fmv.s.x	f30, zero
>> +	fmv.s.x	f31, zero
>> +	csrw	fcsr, 0
>> +#endif /* CONFIG_FPU */
>> +.Lreset_regs_done:
>> +	ret
>> +END(reset_regs)
>> +#endif /* CONFIG_M_MODE */
>> +
>>  __PAGE_ALIGNED_BSS
>>  	/* Empty zero page */
>>  	.balign PAGE_SIZE
> 
> -- 
> Regards,
> Atish

