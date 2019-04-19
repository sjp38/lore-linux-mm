Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E7B4C282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 07:21:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E11802183F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 07:21:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E11802183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B2896B0269; Fri, 19 Apr 2019 03:21:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5633A6B026A; Fri, 19 Apr 2019 03:21:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42BFA6B026B; Fri, 19 Apr 2019 03:21:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E44F56B0269
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 03:21:24 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o8so2466838edh.12
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 00:21:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=bnQSy0WtCB7Cu0qsokQqvclK8aEJwCrIiNI51qlDWjY=;
        b=dZ1S8yi+9x0ZRJFW2BNZE7mv9X34CYhyloJpmyQMY3IdvZrlRpeQ4IU/iggeou3Tsi
         RZ4SQYIlEDX4+0sNSY7pXpvLeBM9Sb07+GIcJhJ+lUfhZh+D4j/syafSm0o1p7JmEbln
         axam2d42jzFkc1/1lLctNiVn2+vR3CLiLDH7MPh36ysKZFp5Wu3cKUHdW71Z1JGbuuIz
         rQvfQHA38Bp8iFMukMbcLJ3oh0gEJf31t3XKRhH/HxHuCpfnFQDZEaBlvDSIUfbvyKe6
         hvqqkXpd747w7IzGGpbICZErSRIi/s0njHq0Lp7Rul+OABO8Qk8e9ffE+PbyHV1Uj2av
         liQA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVhZquw63mFSNWksq5kWpGIoDfl/GepOnuLtimERuKC1d/EpE7p
	jDBO1GaXoh2zJwSm7Z1dC7rAccMXmtldBivZqBsz7Mv3V7pv2Pv79k2/KKvG+GUFtoUlFT8EYhH
	/92eeKYvBs0WLg39MLvqCUU5xYLybIoNehrNmCW2jSwMca/3DlDyA5bsn5thKICk=
X-Received: by 2002:a50:cc89:: with SMTP id q9mr1382853edi.257.1555658484505;
        Fri, 19 Apr 2019 00:21:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsAsjmzgjOQg0YaBq6UxXn9hAOmMEMYnMnWYwP1KJSVc/AMyFYqc3NL7NskiXWf1qZdUtn
X-Received: by 2002:a50:cc89:: with SMTP id q9mr1382809edi.257.1555658483551;
        Fri, 19 Apr 2019 00:21:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555658483; cv=none;
        d=google.com; s=arc-20160816;
        b=aDjuMughCquqr1Tsj2Nbq7Vfj8u0faNJyNZa22+2KgSQVwr6T4IY3FjZk+e12gKOtF
         L36SpsocD82PZp4ghpuWRSP5EvIj8dG5Tv7K8Ao6G1e/ermj791/XpyCEhCrxTaIVc59
         A9h0QrPJx5CwFu6PHKZQ1xRIVkVzS+PmeMDFpbCGd/gYEdPKznG9woJoMZE++Eb4gGKE
         BiCGUFy3sfp6ZO/s4KqLvAXiV1qRpg37RyGZAuyabNbizp00PBxtKrvBlr13x6YT+f69
         a1uN+mx7KFEN5fmoif1zYVNTon7AtqMUZC868Oiq9out9Pcb91y/dZXwfOyHY8sSmyl8
         XVyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=bnQSy0WtCB7Cu0qsokQqvclK8aEJwCrIiNI51qlDWjY=;
        b=XXilWec61hiPqZh5GbW7KlJgdgUNqHc1/fPRdyPr4U0QyUnN94/Tj6IF+k0BQnTNG8
         kroqUp1nFOx3gC1ifd3YgigwfzUfAvDayA4hYnluTB8UZPbQ5aas5KG8cNOfb11v+ZLP
         H++08NN0icPqofZJoYIoFqUrmjZRXhxio0jSUzrRNwkrMDAYP9KmuvQSX2MUAyyyZRHB
         BspLa0SScBQxCTmSOH3xsIBM7xUNaXLrzL8lA5Oc9A6yMm0SsnSkRMrXKGANmOYzy6zY
         I62mkQYxTWh6IR0Oj4Me/KRWEgUZSBLoaqAUH7blOQ6f1GeKbk1ydvhkBRKAmzIZD0hc
         j5tQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id c44si2033896ede.368.2019.04.19.00.21.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 19 Apr 2019 00:21:23 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 81.250.144.103
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 78D2F6000E;
	Fri, 19 Apr 2019 07:21:16 +0000 (UTC)
From: Alex Ghiti <alex@ghiti.fr>
Subject: Re: [PATCH v3 08/11] mips: Properly account for stack randomization
 and stack guard gap
To: Paul Burton <paul.burton@mips.com>
Cc: Albert Ou <aou@eecs.berkeley.edu>, Kees Cook <keescook@chromium.org>,
 Catalin Marinas <catalin.marinas@arm.com>, Palmer Dabbelt
 <palmer@sifive.com>, Will Deacon <will.deacon@arm.com>,
 Russell King <linux@armlinux.org.uk>, Ralf Baechle <ralf@linux-mips.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Luis Chamberlain <mcgrof@kernel.org>,
 "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>, James Hogan <jhogan@kernel.org>,
 "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>,
 Christoph Hellwig <hch@lst.de>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
References: <20190417052247.17809-1-alex@ghiti.fr>
 <20190417052247.17809-9-alex@ghiti.fr>
 <20190418212701.dpymnwuki3g7rox2@pburton-laptop>
Message-ID: <b971499a-ae49-bea5-d3ac-dc779d4817ef@ghiti.fr>
Date: Fri, 19 Apr 2019 09:20:01 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.5.2
MIME-Version: 1.0
In-Reply-To: <20190418212701.dpymnwuki3g7rox2@pburton-laptop>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/18/19 5:27 PM, Paul Burton wrote:
> Hi Alexandre,
>
> On Wed, Apr 17, 2019 at 01:22:44AM -0400, Alexandre Ghiti wrote:
>> This commit takes care of stack randomization and stack guard gap when
>> computing mmap base address and checks if the task asked for randomization.
>> This fixes the problem uncovered and not fixed for mips here:
>> https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1429066.html
>>
>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> For patches 8-10:
>
>      Acked-by: Paul Burton <paul.burton@mips.com>
>
> Thanks for improving this,


Thank you for your time,


Alex


>      Paul
>
>> ---
>>   arch/mips/mm/mmap.c | 14 ++++++++++++--
>>   1 file changed, 12 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
>> index 2f616ebeb7e0..3ff82c6f7e24 100644
>> --- a/arch/mips/mm/mmap.c
>> +++ b/arch/mips/mm/mmap.c
>> @@ -21,8 +21,9 @@ unsigned long shm_align_mask = PAGE_SIZE - 1;	/* Sane caches */
>>   EXPORT_SYMBOL(shm_align_mask);
>>   
>>   /* gap between mmap and stack */
>> -#define MIN_GAP (128*1024*1024UL)
>> -#define MAX_GAP ((TASK_SIZE)/6*5)
>> +#define MIN_GAP		(128*1024*1024UL)
>> +#define MAX_GAP		((TASK_SIZE)/6*5)
>> +#define STACK_RND_MASK	(0x7ff >> (PAGE_SHIFT - 12))
>>   
>>   static int mmap_is_legacy(struct rlimit *rlim_stack)
>>   {
>> @@ -38,6 +39,15 @@ static int mmap_is_legacy(struct rlimit *rlim_stack)
>>   static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
>>   {
>>   	unsigned long gap = rlim_stack->rlim_cur;
>> +	unsigned long pad = stack_guard_gap;
>> +
>> +	/* Account for stack randomization if necessary */
>> +	if (current->flags & PF_RANDOMIZE)
>> +		pad += (STACK_RND_MASK << PAGE_SHIFT);
>> +
>> +	/* Values close to RLIM_INFINITY can overflow. */
>> +	if (gap + pad > gap)
>> +		gap += pad;
>>   
>>   	if (gap < MIN_GAP)
>>   		gap = MIN_GAP;
>> -- 
>> 2.20.1
>>
> _______________________________________________
> linux-riscv mailing list
> linux-riscv@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-riscv

