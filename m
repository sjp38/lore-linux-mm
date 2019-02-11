Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10E67C282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:45:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1A4521B68
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:45:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FS09PW47"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1A4521B68
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B59C8E012E; Mon, 11 Feb 2019 13:45:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 465608E012D; Mon, 11 Feb 2019 13:45:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32E488E012E; Mon, 11 Feb 2019 13:45:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id DE6F48E012D
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:45:31 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id 12so10036016plb.18
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:45:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=f8WuludV5DY6JBEAA4mWS3Heq1YO9mHamIhfdA1NQEs=;
        b=EwyW0uITrPXd1sSGiIYYutKP4qrctoxw51nIc4m1XLYiW1Ok8zrqSp7bnXKlbDAE6k
         NFH3AWCC41Rz9QM47qIBvMi8UklK/Zyu4Yu3x0or+EzSixJV4F9LVln6GJaun8T/huQ0
         zWZ0nAeRNJVdL2DTnQwI8ohAmKGxawQEZjH8cMGkYbU8BX26Oxzyk5Zl/rXUvEqz+cz4
         rT+kjg7OSlVJA3hMDU0MhLECYNQ1oQRZQAJVHvcnpmJik1AftWb/5eB+fiM4Z29amg9x
         wuy0DWS+sFuQ65bJMlbFnkjzBo329DejmznHkadhusLNmVvpg4xBIBwN6QFaYo1X805H
         cXhg==
X-Gm-Message-State: AHQUAuY53wnZQ5X8GfDExKTlFQHSG/y8FEQ1srdkrUl1xMyx//1FerDb
	DBtp9TTXgJUuFXq9yrKebVvCutxOeWrYyD8Rk+HPnImi+g+ycnTpolIzNsCL5m/N5vRGTFIxEDS
	0u3VDcR/KxdmgLdBVvVvoVdBg205eqp2DjL9VceMHIHEZLkYJDwtVK+6NVoP3nZupG3K55b1k0C
	eF3wjoVi3YAiT5T+8LjmhGDkb9Bq97WHIlCdMlSc4aHH90ACqlxtHUmhm6tErc4ZRawupLdCzOL
	iGNH4gRkqIKLqt+YYOSYy35h7mtutX7O+o2dyCs+NUe2cJTkOQA+Kv08PNNLLScGfQXrrCAOUbA
	RKe21H+SlMQwouoFKAirN5FBN/5gJN2dBc/8447ADwxEGy6w7+Y/7Y/am3O/SXGZ5uUsqHSt3ZO
	r
X-Received: by 2002:a63:26c1:: with SMTP id m184mr32659799pgm.367.1549910731512;
        Mon, 11 Feb 2019 10:45:31 -0800 (PST)
X-Received: by 2002:a63:26c1:: with SMTP id m184mr32659755pgm.367.1549910730853;
        Mon, 11 Feb 2019 10:45:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549910730; cv=none;
        d=google.com; s=arc-20160816;
        b=toP07mSi7GdtSJSm1c7cHo64yGDXKpDkQy/vx06aLwzzbBqU1crSaIFaRuXZeCpFgV
         7iE3BXpduNH83xTf8Qqnt4hPbYAFkBRlfaVwH/iAAomxGDlMrBZxitOmBWxzkN8LvDhB
         SMVOw+4+UEtCXGXM2t1YKbtpXmCnUYT6X2O8hBdcQnqlcxJ7uu0WfokoZllBRnBAcEcy
         ldqCkV4Lg/cl+WNWhs7wz4NDK70OAkM7aHom8k39wUtqHmaKZclR4E2SCcJSeAYprQW9
         TjtLwE2vYn+e2YalW4xuuph21jeMXTqHYebDxRjdnmoIviGjw7Q/flhAuUFmo9N1pCRr
         xebQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=f8WuludV5DY6JBEAA4mWS3Heq1YO9mHamIhfdA1NQEs=;
        b=eGeR727tZ4jor6TxealOWsk12JbjaqgiFDqWoDYY2g2D/T+BpBzoam2f6jhwHOqc9/
         PAWU5gz9Lu+mpoQ4603xXqOz6oArlV0e2DnPEiRqNCLV3k2ZaUZ8NFWuNI1wTKGiCwoE
         MfqED7HGZPec9L/ubB9W5T/HQFTMze7H59MX5TkjlsATNhNSYdj+dsggnjOr4Kbh3xIa
         gEXJEbsVAZ8QIdaLmBliKGwomGdcp4LcAM9VUUXkVQr4bB6JW9FaSFRZGswgBshxxhLE
         51eiB8CYGKVZIXKbmYVj/RMi6zoYQ930XAiggpIbnrnVMdnFJ4OvjCPTEjYGwPjgnjJY
         mC9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FS09PW47;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j8sor15507312plk.53.2019.02.11.10.45.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 10:45:30 -0800 (PST)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FS09PW47;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=f8WuludV5DY6JBEAA4mWS3Heq1YO9mHamIhfdA1NQEs=;
        b=FS09PW47SWT9WTic+WSr4mCH38g+qNcP9wITmHqh1HKcG+6ItutSVxZ8RMdu72vk9u
         uacrON/m559Ip5F4/g42Q7TtJRX4SUXct6JDayEzbbp9MC05ZnjzwDXO0d6AGhCaPxUp
         Lbp2sJtNUojU89w+NaA/PmtJKM5Benzz8PNTwdQK/yj65Li4BG/GPWHFvXtKTXacrogd
         lGk7EmAQaVOiIHfOSP5SSFJ9e2daLCSxRgjarO/CX35uAs8kC8/IAzkZ7iXafrtdqnhs
         g3T2+zg3Sx/JiCCDEUC9EATv3oa4LFwhcIKi/oHQCFW48J8GUel/2fG2eWr2d3TPLVp8
         R0Kg==
X-Google-Smtp-Source: AHgI3IYkqqWg3qLv11mJkantOVmSlD1yu0ktdetixdx7d8k099+SMnCkUVzvna814b0ufrtSyUZubQ==
X-Received: by 2002:a17:902:7148:: with SMTP id u8mr11197355plm.110.1549910730206;
        Mon, 11 Feb 2019 10:45:30 -0800 (PST)
Received: from [10.33.115.182] ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id e65sm16254804pfc.184.2019.02.11.10.45.28
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 10:45:29 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v2 10/20] x86: avoid W^X being broken during modules
 loading
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20190211182956.GN19618@zn.tnic>
Date: Mon, 11 Feb 2019 10:45:26 -0800
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>,
 Andy Lutomirski <luto@kernel.org>,
 Ingo Molnar <mingo@redhat.com>,
 LKML <linux-kernel@vger.kernel.org>,
 X86 ML <x86@kernel.org>,
 "H. Peter Anvin" <hpa@zytor.com>,
 Thomas Gleixner <tglx@linutronix.de>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Peter Zijlstra <peterz@infradead.org>,
 Damian Tometzki <linux_dti@icloud.com>,
 linux-integrity <linux-integrity@vger.kernel.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux-MM <linux-mm@kvack.org>,
 Will Deacon <will.deacon@arm.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Kristen Carlson Accardi <kristen@linux.intel.com>,
 "Dock, Deneen T" <deneen.t.dock@intel.com>,
 Kees Cook <keescook@chromium.org>,
 Dave Hansen <dave.hansen@intel.com>,
 Masami Hiramatsu <mhiramat@kernel.org>
Content-Transfer-Encoding: 7bit
Message-Id: <1533F2BB-2284-499B-9912-6D74D0B87BC1@gmail.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-11-rick.p.edgecombe@intel.com>
 <20190211182956.GN19618@zn.tnic>
To: Borislav Petkov <bp@alien8.de>
X-Mailer: Apple Mail (2.3445.102.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Feb 11, 2019, at 10:29 AM, Borislav Petkov <bp@alien8.de> wrote:
> 
>> diff --git a/arch/x86/kernel/alternative.c b/arch/x86/kernel/alternative.c
>> index 76d482a2b716..69f3e650ada8 100644
>> --- a/arch/x86/kernel/alternative.c
>> +++ b/arch/x86/kernel/alternative.c
>> @@ -667,15 +667,29 @@ void __init alternative_instructions(void)
>>  * handlers seeing an inconsistent instruction while you patch.
>>  */
>> void *__init_or_module text_poke_early(void *addr, const void *opcode,
>> -					      size_t len)
>> +				       size_t len)
>> {
>> 	unsigned long flags;
>> -	local_irq_save(flags);
>> -	memcpy(addr, opcode, len);
>> -	local_irq_restore(flags);
>> -	sync_core();
>> -	/* Could also do a CLFLUSH here to speed up CPU recovery; but
>> -	   that causes hangs on some VIA CPUs. */
>> +
>> +	if (static_cpu_has(X86_FEATURE_NX) &&
> 
> Not a fast path - boot_cpu_has() is fine here.

Are you sure about that? This path is still used when modules are loaded.

