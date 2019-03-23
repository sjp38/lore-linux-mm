Return-Path: <SRS0=0AWy=R2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C672C43381
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 08:18:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4626E218E2
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 08:18:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4626E218E2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D08526B0005; Sat, 23 Mar 2019 04:18:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDFDB6B0006; Sat, 23 Mar 2019 04:18:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCE676B0007; Sat, 23 Mar 2019 04:18:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 64ACE6B0005
	for <linux-mm@kvack.org>; Sat, 23 Mar 2019 04:18:08 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x13so1855145edq.11
        for <linux-mm@kvack.org>; Sat, 23 Mar 2019 01:18:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=rmYWYh2u8sdH0+/BBr+kgYZSa7bB3woieUUd4MGeYmk=;
        b=A1D2YOpYPPP9bWzLitVLBK/0bwe4NGZg2DD+E7DU+iC4bpBGxn/cZEXQ+rKnhvcsxB
         6zQKgms6/NATRWSOwpyz+t0xiw9j5I2vS60mbyvEJLLeTpwZWd3mmnJRco2PKAfO2KDm
         ZtejhXewP41QmVtB3+S/wiDzNhgm0fTeqlIiKCRdhUJ773ogF9M45U9skBQYZ1NZejvt
         Rijz+Ud1ZBc8CEFz+VGUPTcAdpwp4nxlITLAZtmvSXv2m1WFulLoZ3I+09AkInnHBUzN
         kyhdGQfOrrjNoPDpOu+8shx/MTaqKbUGwmYHFP1Au1fRx00BLlOjcbmUpToT+Z8e69ol
         A8/Q==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXZ211555cp9aRQJXap0w6BNJIx90gKG9dBs3NBvr2ihO/Kinz1
	U/DRb/t1csGscrRk83v2UXZ7s/gMu1fIWI84krnmtyzBoWueAYJzs30SfnnPPMKg5fYcZQ+pQ22
	gUMXeHoJiDr8oWSzmUAghpTymX9Y8sTWF5vN6svay40R685MtNVQ1BggbXFJM1hA=
X-Received: by 2002:a50:ca8d:: with SMTP id x13mr9244215edh.56.1553329087932;
        Sat, 23 Mar 2019 01:18:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxcvDnK+Q6Y9FXdax237jW33nd242e1nC4b2fnLwJSAn9LxcsfR54on0ikUnpQF1QXO3RAA
X-Received: by 2002:a50:ca8d:: with SMTP id x13mr9244160edh.56.1553329086879;
        Sat, 23 Mar 2019 01:18:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553329086; cv=none;
        d=google.com; s=arc-20160816;
        b=mL8n9wkR7I24UUAV8W/bi4B/Chbwh9wAeBnIVE232l130c1lgD3Q1lXdSDZ2+ZnduH
         MvWEd6/ZAzcVXPUUfJFvNlNQOH7XLoIxehomRwbKCfztxh3FPSYMhEzlfbFe9l7M+7XG
         CmEz5prL+PkjyVEish+ZyO8Or8zOUhgCxqdYb57Zeh0UiYmRNKFzCBspZQLIbPkq6hHs
         P2MVkKqwByzraHpBZx/S/tNPJX/A+1OH+Xho2syN6wXQIW9VZlEWvbXUbndARVCq9KjG
         IGF+beCtfgf7jAwqrbQLvk7/ihjKHlMdufPvneaHDMkY+eazaMDTiMVnxI/e9JyduD5r
         3VCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=rmYWYh2u8sdH0+/BBr+kgYZSa7bB3woieUUd4MGeYmk=;
        b=jmNxvSCxOBZLkW7wnzqiwMtF+BIltVOhkLHAlSvK9SJxL8jp8Vd7+mpQxumoGaTrAj
         QpNN66DrODDu9kvN+bdPtMeLwoTWt5mAgXjGwYv1rB7Oe6tbUsbeQfofW8furNcpV/KH
         z/w6CP9My4fxLIw/QqaFCnUYxtmhGSUs3djm8yXoE3Qk4bbts2kdJUMbqbYwGg1p4yB1
         T6gpe8hDoL3flDLt2C1CYxKMne7utkb2ilACPb39hJmlQ8OzD6cTVftgy4MbrXZabh/k
         F4om64AbrQ0Yis9Ld4nW67ps3azSn4m+EwsL1aSdkblK9S3TzOgoXpMrISYw0hPXL5em
         XlSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay12.mail.gandi.net (relay12.mail.gandi.net. [217.70.178.232])
        by mx.google.com with ESMTPS id i14si332429ejy.50.2019.03.23.01.18.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 23 Mar 2019 01:18:06 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.232;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from [192.168.0.11] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay12.mail.gandi.net (Postfix) with ESMTPSA id 9811C200009;
	Sat, 23 Mar 2019 08:18:02 +0000 (UTC)
Subject: Re: [PATCH 1/4] arm64, mm: Move generic mmap layout functions to mm
To: Christoph Hellwig <hch@infradead.org>
Cc: Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>,
 Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
 Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linux-mips@vger.kernel.org, linux-riscv@lists.infradead.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
References: <20190322074225.22282-1-alex@ghiti.fr>
 <20190322074225.22282-2-alex@ghiti.fr> <20190322132127.GA18602@infradead.org>
From: Alex Ghiti <alex@ghiti.fr>
Message-ID: <72751399-3170-059b-b572-b9b9986ca0fd@ghiti.fr>
Date: Sat, 23 Mar 2019 04:18:02 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190322132127.GA18602@infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: sv-FI
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/22/19 9:21 AM, Christoph Hellwig wrote:
>> It then introduces a new define ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
>> that can be defined by other architectures to benefit from those functions.
> Can you make this a Kconfig option defined in arch/Kconfig or mm/Kconfig
> and selected by the architectures?


Yes, I will do.


>> -#ifndef STACK_RND_MASK
>> -#define STACK_RND_MASK (0x7ff >> (PAGE_SHIFT - 12))	/* 8MB of VA */
>> -#endif
>> -
>> -static unsigned long randomize_stack_top(unsigned long stack_top)
>> -{
>> -	unsigned long random_variable = 0;
>> -
>> -	if (current->flags & PF_RANDOMIZE) {
>> -		random_variable = get_random_long();
>> -		random_variable &= STACK_RND_MASK;
>> -		random_variable <<= PAGE_SHIFT;
>> -	}
>> -#ifdef CONFIG_STACK_GROWSUP
>> -	return PAGE_ALIGN(stack_top) + random_variable;
>> -#else
>> -	return PAGE_ALIGN(stack_top) - random_variable;
>> -#endif
>> -}
>> -
> Maybe the move of this function can be split into another prep patch,
> as it is only very lightly related?
>
>

Ok, that makes sense.

>> +#if defined(HAVE_ARCH_PICK_MMAP_LAYOUT) || \
>> +	defined(ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT)
> Not sure if it is wrіtten down somehwere or just convention, but I
> general see cpp defined statements aligned with spaces to the
> one on the previous line.


Ok, I will fix that.


> Except for these nitpicks this looks very nice to me, thanks for doing
> this work!


Thanks :)

