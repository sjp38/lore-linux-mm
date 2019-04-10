Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 970B2C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 07:33:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D1BD2183E
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 07:33:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D1BD2183E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C81076B026B; Wed, 10 Apr 2019 03:33:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C30726B026C; Wed, 10 Apr 2019 03:33:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4F9C6B026D; Wed, 10 Apr 2019 03:33:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 667FD6B026B
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 03:33:27 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id g1so752104edm.16
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 00:33:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=Q6IKcts9K6jG5BnhXi+W/xQfDM0V2xlEsrUrw5ztWk0=;
        b=oX6yyTUvewuKH8JD2Ixtd4uiTkqopOnuZNTmJ5NUJLsH87BC28YBAZsFUVnpZhrF8n
         qVoMnwSTaTNJdRsqmnDDXfGsNnfVY0HLZc8EAnnkijcETqMZwSeb/YGUMVhZ3d3vYsQW
         X8FiguivqGPsm7mEkvxC57l8NYZcFJo7+mK4m8vTVMmEq0vHVTQtRXgRykqA2IoA/VDB
         4uSZTlNoyGCa9CMwUqHr7pvqfqW0Gg4TJXzBI31LGPkXrvhCLEjbwHajlJw6bf9z22rO
         geuMc4O5DaT6Wpj7nehO07uJzZg3aihTn7tW81kCFLvAsq+em6X4nOVbrv70s5gu8y4n
         r0hQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXiZ+yHpWxMwioG8Onvd/17VjLn+SnHyTV0eQXJmcEB/AcoJUwh
	6qPhnCvd2RSkdJj3Cfb5HzHIS2GD8/3RyDzkkBWzkyTnBLAR3C5/5PTQHT9TAGYsc1uCfVxka37
	lJ9FKmHTXGNPMfldyYVyvrn95PfHWj0MBIXn9iw7JLLnvl8sk0IwT0r50vh6+QSc=
X-Received: by 2002:a17:906:e285:: with SMTP id gg5mr22275760ejb.229.1554881606868;
        Wed, 10 Apr 2019 00:33:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx9zVdZlFjybTxDkhU5oIhqz7heUt9GX8RDm98knAFpSTvCDAyAft3mC9Tq13iMli1xmbvM
X-Received: by 2002:a17:906:e285:: with SMTP id gg5mr22275722ejb.229.1554881606080;
        Wed, 10 Apr 2019 00:33:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554881606; cv=none;
        d=google.com; s=arc-20160816;
        b=TA34L2wauAiKlCMuxEfgdq1e4WgcNGErMl41DS0U5+mC3/0de9sU8UocM3xQSQYKSp
         GQlIBds++tHFM0aoBntkMyBc9uk/IyP+EukPWAJPUTV5T2jqFPGZWMGf7sviShsxiH9E
         QZIm8CWTS0kmXW8W+GMrYV7DWBNcHdZAwREgCRKlToJfN9TtUJuy+ANLeSJPHPfLlgfV
         SsgwsraT7xVZ99rVVB+A4lzyg/hfM6YuawhNRXMuge+yS8E/O66lbdR/FVih2e0kbmfY
         J2kAX7zYA7j1GkEy3CqRmKFAGiE4E4Q7h4bbq9ncrZnl33SjgxYEx9XBX0LfKIwirnK7
         mrAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Q6IKcts9K6jG5BnhXi+W/xQfDM0V2xlEsrUrw5ztWk0=;
        b=D4lXQ0rUwE5Z6W1KWhKIc4wbDzYLOXOSEpBebK0rBFMMPMWEFdsPnZa2SmbNrYniqq
         emzWF4qRB9h4eNDat5qWXbQSID5owu5IJhBLNBrw1lccRb3T4Lreah/WIk+Pg+uWbQoX
         bRXCFM9eDa2v5HMWvCXVuD9d4TF0eNae7TjOPtSUXClj6FAl793kRbWqic6QJPJ1uwVA
         1M11rHAUUW9GC8YJ7jOdhr68jtIJS6JMHgSiiXyzfIh/gvVbdkWP2Wt65wHFhU317ibL
         5bjldsgePtwbQKI+e7blJPaGKmj82utwX5S5qo4GgIoCh2BWImTDIe+SwcbcLFTH+iGZ
         cUvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id f5si2939398edy.201.2019.04.10.00.33.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 10 Apr 2019 00:33:26 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 81.250.144.103
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id BF3AAFF80C;
	Wed, 10 Apr 2019 07:33:21 +0000 (UTC)
Subject: Re: [PATCH v2 2/5] arm64, mm: Move generic mmap layout functions to
 mm
To: Christoph Hellwig <hch@infradead.org>
Cc: Albert Ou <aou@eecs.berkeley.edu>, Kees Cook <keescook@chromium.org>,
 Catalin Marinas <catalin.marinas@arm.com>, Palmer Dabbelt
 <palmer@sifive.com>, Will Deacon <will.deacon@arm.com>,
 Russell King <linux@armlinux.org.uk>, Ralf Baechle <ralf@linux-mips.org>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Paul Burton <paul.burton@mips.com>, Alexander Viro
 <viro@zeniv.linux.org.uk>, James Hogan <jhogan@kernel.org>,
 linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-mips@vger.kernel.org, linux-riscv@lists.infradead.org,
 linux-arm-kernel@lists.infradead.org, Luis Chamberlain <mcgrof@kernel.org>
References: <20190404055128.24330-1-alex@ghiti.fr>
 <20190404055128.24330-3-alex@ghiti.fr> <20190410065908.GC2942@infradead.org>
From: Alexandre Ghiti <alex@ghiti.fr>
Message-ID: <8d482fd0-b926-6d11-0554-a0f9001d19aa@ghiti.fr>
Date: Wed, 10 Apr 2019 09:32:28 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.5.2
MIME-Version: 1.0
In-Reply-To: <20190410065908.GC2942@infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: fr
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04/10/2019 08:59 AM, Christoph Hellwig wrote:
> On Thu, Apr 04, 2019 at 01:51:25AM -0400, Alexandre Ghiti wrote:
>> - fix the case where stack randomization should not be taken into
>>    account.
> Hmm.  This sounds a bit vague.  It might be better if something
> considered a fix is split out to a separate patch with a good
> description.

Ok, I will move this fix in another patch.

>
>> +config ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
>> +	bool
>> +	help
>> +	  This allows to use a set of generic functions to determine mmap base
>> +	  address by giving priority to top-down scheme only if the process
>> +	  is not in legacy mode (compat task, unlimited stack size or
>> +	  sysctl_legacy_va_layout).
> Given that this is an option that is just selected by other Kconfig
> options the help text won't ever be shown.  I'd just move it into a
> comment bove the definition.

Oh yes, it does not appear, thanks, I'll move it above the definition.

>
>> +#ifdef CONFIG_MMU
>> +#ifdef CONFIG_ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
> I don't think we need the #ifdef CONFIG_MMU here,
> CONFIG_ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT should only be selected
> if the MMU is enabled to start with.

Ok, thanks.

>> +#ifdef CONFIG_ARCH_HAS_ELF_RANDOMIZE
>> +unsigned long arch_mmap_rnd(void)
> Now that a bunch of architectures use a version in common code
> the arch_ prefix is a bit mislead.  Probably not worth changing
> here, but some time in the future it could use a new name.

Ok I'll keep it in mind for later,

Thanks for your time,

Alex

