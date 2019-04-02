Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3809BC4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 20:36:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D87992075E
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 20:36:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="XwSO9UiH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D87992075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 77C236B0275; Tue,  2 Apr 2019 16:36:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7046D6B0276; Tue,  2 Apr 2019 16:36:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A4776B0277; Tue,  2 Apr 2019 16:36:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0BA956B0275
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 16:36:47 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id y7so11536298wrq.4
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 13:36:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=BwooMA22qN5MVKhV+b35SP+1LDZWopZGd8mOz82SGGY=;
        b=f82OAy66WiYCDAUWmNwAtu+H6lrZVCppNGux+A7VzaYpC07l48a41woblBMjjWCvIt
         E+eJl7neJU/FyYKVEpIWF0spwPSGEXOrRIHT+dMkiaLTHtE+jl9i01rgJ9j2gjSNfLe8
         VhjMX3MtlinFsNiEj6oeiKc/8SeTx5I9bbeftf+Yf4D2Qgk2yn8xpwUF4bPUdkh98zXU
         Rw2AVaBb/k4ECHH+0CLYCqCz763rcsRe4rOVUOc92OeJ/yDcqzwLICru/h2daHvN8iUI
         jAtNZADFM5qqRHWpSW6v3PsCqLlN+r7AjVJ1OuVH8AvH7kdpzxhFBR+c3Avem11rA9k0
         S8Xg==
X-Gm-Message-State: APjAAAVjIxlrHt1NKYZanf+yCPZQLIJjmRSOBfDrTcnyLjWKND/8Bt6L
	ErpOEM0cixW159yRzemen4uHg71yQe1lJ9ZsWyaw8p+BNbAkIXdJCcaYDPoWkryB11jFQmlm33g
	xImfLtkOub7S7fYdDKIn6YgDNXjKx/135Tzc4eBPMIukLD2ZofiKzh1EkGbtapXkuxg==
X-Received: by 2002:adf:f984:: with SMTP id f4mr43363733wrr.97.1554237406569;
        Tue, 02 Apr 2019 13:36:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTb0yGzlcMTvyAlvzK83Y9Oqyhxa9BPAtlrPXYK6urTmubXIpfxeQG+9W9JsWvtSX8nHyq
X-Received: by 2002:adf:f984:: with SMTP id f4mr43363695wrr.97.1554237405698;
        Tue, 02 Apr 2019 13:36:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554237405; cv=none;
        d=google.com; s=arc-20160816;
        b=OyrPmla5y8YS+e2ikWZC5E8V2EnSRdK1ZVzIFg+4Jdrq8qXS19afWQNC/c0JTb43Us
         3Sfr3OozL6akyzPXyOpNWmq1itpLPbKYKmSHtytsvy6QxyXumAmtT9vpNEDdYtng4hNf
         aeQbApjDKNmKALqE/qzYZPSO2UB3eLAkXm2n/TP0wOweAwMJaPfbPGvTVfadRDyP46kk
         IMuA5248C+rMHiT4LHeuRKDpC4JjKKoRG/quQ+IHsJaa9WIVcnuzcAFjNxVOk9wVb+EZ
         SH+qG2lJC2cUNOxtdoNG2tl8A5kUuekK7D8UkT/K+1HFtsZ2LpqluNplH4lp4KwrAb1m
         Qz8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=BwooMA22qN5MVKhV+b35SP+1LDZWopZGd8mOz82SGGY=;
        b=zQFUBH/pvV6uCibfHJn+MEsXSqrVNdhoAykBU4SIRvjDFvtV5wZcwNhig9X4lIB+Ob
         R64BHrcTKRHTKeL4xWOFNSSpuGOgjy13hmKGu7ntvb9JGZHYLhl1Y9vDU+mbjpo58NiT
         oFjweAnqubzSbo9/HdiwRrNf8GIKt8TCPyCBTRA2uDzg38G9E6fNA+RcYxRvzrO49gk8
         nRogP/X/XvuBcQ2RPy+exrIJEeKjBZa+JI5p1PR/7jDwVGzmWGafx/Jrld7WxzzzhQUb
         Uo4ywkVB5JAHHBRArBo19VjPqLY1FOEWfMKSCBMSCYKxLw4fnz6cQc1xCmG4Nqrjimgw
         Ez1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=XwSO9UiH;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id y2si8853207wrs.332.2019.04.02.13.36.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 13:36:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=XwSO9UiH;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44Ygwr5PLKz9v0Vr;
	Tue,  2 Apr 2019 22:36:44 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=XwSO9UiH; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id yyUnmaIc8DNn; Tue,  2 Apr 2019 22:36:44 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44Ygwr3nJYz9v0Vq;
	Tue,  2 Apr 2019 22:36:44 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1554237404; bh=BwooMA22qN5MVKhV+b35SP+1LDZWopZGd8mOz82SGGY=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=XwSO9UiHs7eDKhbgCafzeJv3wWzgWvMT2DlYlpZEUflcR82p5RjBXhqv1B+ZBZ/qz
	 PoHCRyburOnl9/TcAZbdfUDX10m3l+OZInCgSAJ3kqvNEXuvVWndlKUIWdEw59AzAH
	 3Tipq4va5XI4jqdbpACigBrudGGvi4yNapNBGy+4=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id ACB2C8B8D2;
	Tue,  2 Apr 2019 22:36:44 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id x1CuPvs9w0Vs; Tue,  2 Apr 2019 22:36:44 +0200 (CEST)
Received: from PO15451 (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 6B8D38B8CD;
	Tue,  2 Apr 2019 22:36:43 +0200 (CEST)
Subject: Re: [RFC PATCH v2 3/3] kasan: add interceptors for all string
 functions
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Nicholas Piggin <npiggin@gmail.com>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 Daniel Axtens <dja@axtens.net>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org,
 linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com
References: <f13944c4e99ec2cef6d93d762e6b526e0335877f.1553785019.git.christophe.leroy@c-s.fr>
 <51a6d9d7185de310f37ccbd7e4ebfdd6c7e9791f.1553785020.git.christophe.leroy@c-s.fr>
 <3211b0f8-7b52-01b7-8208-65d746969248@c-s.fr>
 <ae9262e5-0917-b7c9-52c7-fe21db2ecacb@virtuozzo.com>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <d5d2fa6f-c2ba-8234-e412-9c4ccd6cc4c6@c-s.fr>
Date: Tue, 2 Apr 2019 22:36:43 +0200
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <ae9262e5-0917-b7c9-52c7-fe21db2ecacb@virtuozzo.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 02/04/2019 à 18:14, Andrey Ryabinin a écrit :
> 
> 
> On 4/2/19 12:43 PM, Christophe Leroy wrote:
>> Hi Dmitry, Andrey and others,
>>
>> Do you have any comments to this series ?
>>
> 
> I don't see justification for adding all these non-instrumented functions. We need only some subset of these functions
> and only on powerpc so far. Arches that don't use str*() that early simply doesn't need not-instrumented __str*() variant.
> 
> Also I don't think that auto-replace str* to __str* for all not instrumented files is a good idea, as this will reduce KASAN coverage.
> E.g. we don't instrument slub.c but there is no reason to use non-instrumented __str*() functions there.

Ok, I didn't see it that way.

In fact I was seeing the opposite and was considering it as an 
opportunity to increase KASAN coverage. E.g.: at the time being things 
like the above (from arch/xtensa/include/asm/string.h) are not covered 
at all I believe:

#define __HAVE_ARCH_STRCPY
static inline char *strcpy(char *__dest, const char *__src)
{
	register char *__xdest = __dest;
	unsigned long __dummy;

	__asm__ __volatile__("1:\n\t"
		"l8ui	%2, %1, 0\n\t"
		"s8i	%2, %0, 0\n\t"
		"addi	%1, %1, 1\n\t"
		"addi	%0, %0, 1\n\t"
		"bnez	%2, 1b\n\t"
		: "=r" (__dest), "=r" (__src), "=&r" (__dummy)
		: "0" (__dest), "1" (__src)
		: "memory");

	return __xdest;
}

In my series, I have deactivated optimised string functions when KASAN 
is selected like arm64 do. See https://patchwork.ozlabs.org/patch/1055780/
But not every arch does that, meaning that some string functions remains 
not instrumented at all.

Also, I was seeing it as a way to reduce impact on performance with 
KASAN. Because instrumenting each byte access of the non-optimised 
string functions is a performance genocide.

> 
> And finally, this series make bug reporting slightly worse. E.g. let's look at strcpy():
> 
> +char *strcpy(char *dest, const char *src)
> +{
> +	size_t len = __strlen(src) + 1;
> +
> +	check_memory_region((unsigned long)src, len, false, _RET_IP_);
> +	check_memory_region((unsigned long)dest, len, true, _RET_IP_);
> +
> +	return __strcpy(dest, src);
> +}
> 
> If src is not-null terminated string we might not see proper out-of-bounds report from KASAN only a crash in __strlen().
> Which might make harder to identify where 'src' comes from, where it was allocated and what's the size of allocated area.
> 
> 
>> I'd like to know if this approach is ok or if it is better to keep doing as in https://patchwork.ozlabs.org/patch/1055788/
>>
> I think the patch from link is a better solution to the problem.
> 

Ok, I'll stick with it then. Thanks for your feedback

Christophe

