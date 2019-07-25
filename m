Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1059C41517
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 06:09:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0E9221850
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 06:09:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0E9221850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 613BD8E0039; Thu, 25 Jul 2019 02:09:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C4768E0031; Thu, 25 Jul 2019 02:09:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DB208E0039; Thu, 25 Jul 2019 02:09:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F32EB8E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 02:09:19 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r21so31517979edc.6
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 23:09:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=XrWh+rmPVAFrRcmqorS5a5ycL9qqh9BHPu7/J2lO+Zs=;
        b=ewfJonqvCIvyCxpTcoYwoCys/tDkszdGwYujptnYToBxOKlCNJjsCQS7ffCgPJLpHa
         4KdC6lGTubBj+6nwIFq3heyITmlkFnS3Jz4YUFYL3ETVSLWbFK9unYMotayXXOHqJhJ+
         ehR7QMKj6KzNEbeuONUYAL/piuZcnFg+hi8lLkWSAJm1YGsfcn3vscGMTfNiNBoDXokx
         rpIqk2ZRD8zTRyv1jyUTrS7bWqGgR1xKjE2tPUCQGQSh3tEsy6azkStXEwCu0UI93+E2
         4e8jyTliRROX5iE2KIRrERGd0kj/rTDIb4XN5APgUo/fBKspAJctBGjQOSMqRbGUYYh3
         m3fQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUzkFeOhkiMfiNYnT6p8t3OE7AZzNFRlDsVf0vaO0aob6eS4SFC
	U21sHfvviov2YSvwkHquB3v8l8wAPVE+fiRg23qbC+JwfiWm/wjvFj0JGTnEGwfZ1Q2PMeq2KxT
	LIZliJ0hgLr2tbuZEeexJC6BWctf7lY0BPTwhtdmle22D1ItMeb8b47ZJzvk0rGU=
X-Received: by 2002:a50:92a5:: with SMTP id k34mr74990384eda.90.1564034959549;
        Wed, 24 Jul 2019 23:09:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqykY/V2+99izeXZ1i5o9k3GcOSXQrlQmiALBBwsUCudzn2EbE18lMHfYbP3qxlZt3c7X2al
X-Received: by 2002:a50:92a5:: with SMTP id k34mr74990348eda.90.1564034958902;
        Wed, 24 Jul 2019 23:09:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564034958; cv=none;
        d=google.com; s=arc-20160816;
        b=RbsojrK1PmdZYu8rNY2ATOXAjgL0M9JYPbb+G7OBApKEKohNMyyRpTZ/R89gM5yKx8
         NocVw9Udim5DwaUiwMZjv3peRzIZA9iYoygW+oo9EmYTNw6ncsMA++8E6Wl4wlX/Y3FJ
         yhRnsPDFXAkeRuDn4YK3oyjgaM26sN47bnsGgE2HQ1gqZWHl76G8aZW+9HzmNar1ulGv
         lCGXNKxuPAWi9sg8KzOAf0fBP7EhntmYpcBq6XTssdjWkrvnFMh0/LLWHyVKD7wG+UVs
         YI4fpR266m7Q+p+CadM8uKYNua/Qt155rsYkwqpufFY/LMFfgfxS7gynwiqLmJz38jHN
         rSRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=XrWh+rmPVAFrRcmqorS5a5ycL9qqh9BHPu7/J2lO+Zs=;
        b=nElrQ2gIV4ReU36EraRYzQ857dKW6uPK8donQIlTel2ebPQuadCYPd75Wzn1/kvL5W
         QUM0XwN3+AG2buwAkRmp4UijIdStCAlzali97azo/9QSe2cEqoYVTzeRWDkF0zEGLTh1
         IBOTS3IMW9SXrHmMxv0Eou8rWFMEb8M0feIozJuzcXQMWTRIGn1GPIogJQsjBRQn5UHC
         iNTt+QiH5hRlU9kmfGx/qJQKpfjPr+Si7c+VyaMk8gomptxKkT9EnVdfj8gG+FjZM9te
         GXg72qHTXI1/TB0ZNJfkUge+8k7APm640Io5Lc1MQdRVPgIt8psCqx0Z14u/piXUiTXj
         BBWA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net. [217.70.183.196])
        by mx.google.com with ESMTPS id v8si8341831eja.245.2019.07.24.23.09.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Jul 2019 23:09:18 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.196;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 81.250.144.103
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 761F0E0008;
	Thu, 25 Jul 2019 06:09:11 +0000 (UTC)
Subject: Re: [PATCH REBASE v4 12/14] mips: Replace arch specific way to
 determine 32bit task with generic version
To: Luis Chamberlain <mcgrof@kernel.org>
Cc: Albert Ou <aou@eecs.berkeley.edu>, Kees Cook <keescook@chromium.org>,
 Catalin Marinas <catalin.marinas@arm.com>, Palmer Dabbelt
 <palmer@sifive.com>, Will Deacon <will.deacon@arm.com>,
 Russell King <linux@armlinux.org.uk>, Ralf Baechle <ralf@linux-mips.org>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Paul Burton <paul.burton@mips.com>, linux-riscv@lists.infradead.org,
 Alexander Viro <viro@zeniv.linux.org.uk>, James Hogan <jhogan@kernel.org>,
 linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
 linux-mips@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
 linux-arm-kernel@lists.infradead.org
References: <20190724055850.6232-1-alex@ghiti.fr>
 <20190724055850.6232-13-alex@ghiti.fr>
 <20190724171648.GW19023@42.do-not-panic.com>
From: Alexandre Ghiti <alex@ghiti.fr>
Message-ID: <17fa5d60-2417-70cb-36b0-203b30b27624@ghiti.fr>
Date: Thu, 25 Jul 2019 08:09:11 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190724171648.GW19023@42.do-not-panic.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: fr
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/24/19 7:16 PM, Luis Chamberlain wrote:
> On Wed, Jul 24, 2019 at 01:58:48AM -0400, Alexandre Ghiti wrote:
>> Mips uses TASK_IS_32BIT_ADDR to determine if a task is 32bit, but
>> this define is mips specific and other arches do not have it: instead,
>> use !IS_ENABLED(CONFIG_64BIT) || is_compat_task() condition.
>>
>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
>> Reviewed-by: Kees Cook <keescook@chromium.org>
>> ---
>>   arch/mips/mm/mmap.c | 3 ++-
>>   1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
>> index faa5aa615389..d4eafbb82789 100644
>> --- a/arch/mips/mm/mmap.c
>> +++ b/arch/mips/mm/mmap.c
>> @@ -17,6 +17,7 @@
>>   #include <linux/sched/signal.h>
>>   #include <linux/sched/mm.h>
>>   #include <linux/sizes.h>
>> +#include <linux/compat.h>
>>   
>>   unsigned long shm_align_mask = PAGE_SIZE - 1;	/* Sane caches */
>>   EXPORT_SYMBOL(shm_align_mask);
>> @@ -191,7 +192,7 @@ static inline unsigned long brk_rnd(void)
>>   
>>   	rnd = rnd << PAGE_SHIFT;
>>   	/* 32MB for 32bit, 1GB for 64bit */
>> -	if (TASK_IS_32BIT_ADDR)
>> +	if (!IS_ENABLED(CONFIG_64BIT) || is_compat_task())
>>   		rnd = rnd & SZ_32M;
>>   	else
>>   		rnd = rnd & SZ_1G;
>> -- 
> Since there are at least two users why not just create an inline for
> this which describes what we are looking for and remove the comments?


Actually this is a preparatory patch, this will get merged with the 
generic version in the next patch.

Alex


>
>    Luis
>
> _______________________________________________
> linux-riscv mailing list
> linux-riscv@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-riscv

