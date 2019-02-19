Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AA9FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 18:03:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F7AB208E4
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 18:03:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="b2GCTC3x"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F7AB208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABD8F8E0003; Tue, 19 Feb 2019 13:03:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A6B138E0002; Tue, 19 Feb 2019 13:03:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 934D88E0003; Tue, 19 Feb 2019 13:03:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3DE358E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 13:03:42 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id m7so9441329wrn.15
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 10:03:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=LNCXwSviXkWBvTddFJgcavOW7yBNAyJmLfKdg/qHe68=;
        b=oZ+5bH5oiG+0N+faYa220EhwHVzlV+71N8Lkxch6eBRQm/WcX40bO1sc/12pBCDt0M
         FRcnOpc0ItjPPmMJAZgs9ZlzLQO2w0dfssbqZL+B/sdkemCSECUMLXpoiwVlIbQONxak
         ufeHFSlSNBreVOcBG/mib/x32sFdhEQUEB3wMO5VsAfGal3a+1Fk5hS6GQ2Wr7Nw8vlO
         9tt0s6mXm/va0c3GeV1++ZsvHot+nUmsCIs/N+IpObTQqQ2ZE0+71SfnXJ1WEEgdT+UY
         +/6IOhoJAmn11Ut/A8u7X7LQlX//W+bmQ2PHBBvUMEKRJwMEYgeGT79t4SpIwBCEPW/x
         oNdg==
X-Gm-Message-State: AHQUAubAltJ+qL9wTHZ3bgRrjAEEHjs9GijOmXO/BMTyGPZHiiYKNECj
	pwuU+wGKmSEJgsejgeoTGOz7dyS7oVMh58cslSxRjiOKrBnynsZvzwKDQVuJj+gBbW988ok060F
	RMDwKa9FA4utVKyZOw34qywS1atGjaFK+Osnr3xHj4vWt7ckqeaOExgUeC2BOFJRtbA==
X-Received: by 2002:a7b:c115:: with SMTP id w21mr158384wmi.104.1550599421677;
        Tue, 19 Feb 2019 10:03:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iaa2mqJ+ZE48DP5rdiznmtCg+UDslGMPbeWdZTk1h9Fjo0d/aGoElUkTLJLkmbmza/xKnnn
X-Received: by 2002:a7b:c115:: with SMTP id w21mr158323wmi.104.1550599420557;
        Tue, 19 Feb 2019 10:03:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550599420; cv=none;
        d=google.com; s=arc-20160816;
        b=YA6zmOEypRNV4RLVCv2YyezU3dQB7oGczPziagBPf6ZEmC64I8GuCwOfQ3aZg9eUso
         l41SXjNNRckA7hnTRfTHGmmvH5dEYEiSQkTZtOUV6IQKEJSucTtv5SntmOZXZEqrDlq7
         6c8Qy+IMhElbL4+2aBs7N79PjYXO3XDrtOlMkcsGvLQ6XgXtKK9zvHCfcuAcGg0zcfLg
         VsPZHertK7QUm/NRrpZzXv6LTMef9amBL/2FfKoKqw8yQ+v1emqJ3F8RrEiUNZoDv653
         UsXWx0kr3eHpC9ikanoX2UMcmJo4HC37AGJKe36zokyT39nw+SR4ePeWAR914sZPBwT/
         D/hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=LNCXwSviXkWBvTddFJgcavOW7yBNAyJmLfKdg/qHe68=;
        b=d7unVdXjNWRsMVJWkIc4aNhbcuhnyx0ivW/Y8NjAwix5gc638lYHj0jT2MyA60tSka
         lTPdD0q8DDw251iKLdTYp8zDDBmJHzSVEtCmVwEu55mTshsbzg+viS5Ij7VgPVbgQnkQ
         fEmJGKiM/GveFg7xzSjoxmtagPh5DxbnbF3W4YDrUD4m2EM19bXoWAmRt1IwbKw1lzjH
         xz5zGJdiCiZcD3CxVM4nlXoO6OH012KrnLMPF5SoMS+VQbNIFUMK8QDeyhgY90nCvNq7
         z+ZAFfcfGHMWAkhl+rReZRKDGfBeOmQmr6fJaSn5YOqsuURCt3gMqEd3vbGIZGc7bSJb
         iAMg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=b2GCTC3x;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id f10si1872657wmf.34.2019.02.19.10.03.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 10:03:40 -0800 (PST)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=b2GCTC3x;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 443pWZ2F8mz9v4wf;
	Tue, 19 Feb 2019 19:03:38 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=b2GCTC3x; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id eQrEmwqWTBU2; Tue, 19 Feb 2019 19:03:38 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 443pWZ0rg0z9v4wc;
	Tue, 19 Feb 2019 19:03:38 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1550599418; bh=LNCXwSviXkWBvTddFJgcavOW7yBNAyJmLfKdg/qHe68=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=b2GCTC3x+1ebV4kjmNBe4K2VSwG9YLP9usH79S0UkAn7UGWF/y176Exd0PiDDf6On
	 LC/NVSccjWdc1nyRfliH2uwaIFZ6fRkXXohRjhEh2JRMWF71YFqWI96w2JcO5Vona3
	 XTV1cSws4JrvGLs/oYJnlmdaoWq/AKqVCBholtlE=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id C84A38B7FE;
	Tue, 19 Feb 2019 19:03:39 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id kUrM2n6LmiuF; Tue, 19 Feb 2019 19:03:39 +0100 (CET)
Received: from PO15451 (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 010C88B7F9;
	Tue, 19 Feb 2019 19:03:38 +0100 (CET)
Subject: Re: [PATCH v5 3/3] powerpc/32: Add KASAN support
To: Michael Ellerman <mpe@ellerman.id.au>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Nicholas Piggin <npiggin@gmail.com>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 kasan-dev@googlegroups.com, linux-mm@kvack.org
References: <cover.1549935247.git.christophe.leroy@c-s.fr>
 <3429fe33b68206ecc2a725a740937bbaef2d1ac8.1549935251.git.christophe.leroy@c-s.fr>
 <87a7itqwdo.fsf@concordia.ellerman.id.au>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <8654376c-2c55-89b0-cd79-0bcf02338519@c-s.fr>
Date: Tue, 19 Feb 2019 19:03:38 +0100
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <87a7itqwdo.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 18/02/2019 à 10:27, Michael Ellerman a écrit :
> Christophe Leroy <christophe.leroy@c-s.fr> writes:
> 
>> diff --git a/arch/powerpc/include/asm/ppc_asm.h b/arch/powerpc/include/asm/ppc_asm.h
>> index e0637730a8e7..dba2c1038363 100644
>> --- a/arch/powerpc/include/asm/ppc_asm.h
>> +++ b/arch/powerpc/include/asm/ppc_asm.h
>> @@ -251,6 +251,10 @@ GLUE(.,name):
>>   
>>   #define _GLOBAL_TOC(name) _GLOBAL(name)
>>   
>> +#define KASAN_OVERRIDE(x, y) \
>> +	.weak x;	     \
>> +	.set x, y
>> +
> 
> Can you add a comment describing what that does and why?

It's gone. Hope the new approach is more clear. It's now in a dedicated 
patch.

> 
>> diff --git a/arch/powerpc/kernel/Makefile b/arch/powerpc/kernel/Makefile
>> index 879b36602748..fc4c42262694 100644
>> --- a/arch/powerpc/kernel/Makefile
>> +++ b/arch/powerpc/kernel/Makefile
>> @@ -16,8 +16,9 @@ CFLAGS_prom_init.o      += -fPIC
>>   CFLAGS_btext.o		+= -fPIC
>>   endif
>>   
>> -CFLAGS_cputable.o += $(DISABLE_LATENT_ENTROPY_PLUGIN)
>> -CFLAGS_prom_init.o += $(DISABLE_LATENT_ENTROPY_PLUGIN)
>> +CFLAGS_early_32.o += -DDISABLE_BRANCH_PROFILING
>> +CFLAGS_cputable.o += $(DISABLE_LATENT_ENTROPY_PLUGIN) -DDISABLE_BRANCH_PROFILING
>> +CFLAGS_prom_init.o += $(DISABLE_LATENT_ENTROPY_PLUGIN) -DDISABLE_BRANCH_PROFILING
> 
> Why do we need to disable branch profiling now?

Recommended by Andrey, see https://patchwork.ozlabs.org/patch/1023887/

Maybe it should be only when KASAN is active ? For prom_init it should 
probably be all the time, for the others I don't know. Can't remember 
why I did it that way.

> 
> I'd probably be happier if all the CFLAGS changes were done in a leadup
> patch to make them more obvious.

Oops, I forgot to read your mail entirely before sending out v6. Indeed 
I only read first part. Anyway, that's probably not the last run.

> 
>> diff --git a/arch/powerpc/kernel/prom_init_check.sh b/arch/powerpc/kernel/prom_init_check.sh
>> index 667df97d2595..da6bb16e0876 100644
>> --- a/arch/powerpc/kernel/prom_init_check.sh
>> +++ b/arch/powerpc/kernel/prom_init_check.sh
>> @@ -16,8 +16,16 @@
>>   # If you really need to reference something from prom_init.o add
>>   # it to the list below:
>>   
>> +grep CONFIG_KASAN=y .config >/dev/null
> 
> Just to be safe "^CONFIG_KASAN=y$" ?

ok

> 
>> +if [ $? -eq 0 ]
>> +then
>> +	MEMFCT="__memcpy __memset"
>> +else
>> +	MEMFCT="memcpy memset"
>> +fi
> 
> MEM_FUNCS ?

Yes, I change it now before I forget.

> 
>> diff --git a/arch/powerpc/lib/Makefile b/arch/powerpc/lib/Makefile
>> index 3bf9fc6fd36c..ce8d4a9f810a 100644
>> --- a/arch/powerpc/lib/Makefile
>> +++ b/arch/powerpc/lib/Makefile
>> @@ -8,6 +8,14 @@ ccflags-$(CONFIG_PPC64)	:= $(NO_MINIMAL_TOC)
>>   CFLAGS_REMOVE_code-patching.o = $(CC_FLAGS_FTRACE)
>>   CFLAGS_REMOVE_feature-fixups.o = $(CC_FLAGS_FTRACE)
>>   
>> +KASAN_SANITIZE_code-patching.o := n
>> +KASAN_SANITIZE_feature-fixups.o := n
>> +
>> +ifdef CONFIG_KASAN
>> +CFLAGS_code-patching.o += -DDISABLE_BRANCH_PROFILING
>> +CFLAGS_feature-fixups.o += -DDISABLE_BRANCH_PROFILING
>> +endif
> 
> There's that branch profiling again, though here it's only if KASAN is enabled.
> 
>> diff --git a/arch/powerpc/mm/kasan_init.c b/arch/powerpc/mm/kasan_init.c
>> new file mode 100644
>> index 000000000000..bd8e0a263e12
>> --- /dev/null
>> +++ b/arch/powerpc/mm/kasan_init.c
>> @@ -0,0 +1,114 @@
>> +// SPDX-License-Identifier: GPL-2.0
>> +
>> +#define DISABLE_BRANCH_PROFILING
>> +
>> +#include <linux/kasan.h>
>> +#include <linux/printk.h>
>> +#include <linux/memblock.h>
>> +#include <linux/sched/task.h>
>> +#include <asm/pgalloc.h>
>> +
>> +void __init kasan_early_init(void)
>> +{
>> +	unsigned long addr = KASAN_SHADOW_START;
>> +	unsigned long end = KASAN_SHADOW_END;
>> +	unsigned long next;
>> +	pmd_t *pmd = pmd_offset(pud_offset(pgd_offset_k(addr), addr), addr);
> 
> Can none of those fail?

map_kernel_page() in pgtable_32.c does exactly the same.

pud_offset() and pmd_offset() are no-ops and only serve as type 
modifiers, so pmd will get the value returned by pgd_offset_k() which 
should always be valid unless init_mm->pgd is bad.

Christophe

> 
> 
> cheers
> 

