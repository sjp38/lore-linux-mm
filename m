Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1440BC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:44:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A32E321743
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 09:44:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A32E321743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52F6A6B0006; Fri,  9 Aug 2019 05:44:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DF686B0007; Fri,  9 Aug 2019 05:44:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F5016B0008; Fri,  9 Aug 2019 05:44:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E582D6B0006
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 05:44:44 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z2so990834ede.2
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 02:44:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=7Zz+dekQVz+t60cfPAWXHDt673zqelsbIxrG4v8rxXU=;
        b=PWUyyvPiWg43+178mY4Y0h+79yV7/v8rnEawctRQdDcBxAYCcZ3fIFESyrVIaefce5
         +u2ad20rxFpZkSIj9MBHSRiuwmqg2uOScDwZy395HE69tQ4srLtwTTDaMTdNTW8wqEQK
         TN9yDCUoVhe8kltX5zfJHa3QH7BFa66TMZe9bJOC8I3MvXhM5zNUuEI76hS5D+sdPkcS
         k1VAmKYjbWM/je2yVL+PD4aMxvqpVcFT6t8MY9WkQA+7oCtqZeZi9OdvLe5iyjPOQQLX
         9dBtTG9vE2y4iGvcUBL8IUYFQB22fZTV5ei4Ih0h8X1lkiQ7TNBG6Q/za0PC4vvlxY4T
         kaCw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWr7PLJFLnwvy3EJ20PcvLya4frtQ/M41Joq6X9e2UPRHI7TwE4
	pCyt+SJ+6nZbX5sSMcz6DGCaImcVOJ+l4FKdhWDGpQVBf2zDU/mawNmiim+pUUB4SnqABc/1HoK
	D2xUI0W7wWYNtLvvh/bS5ZkNS0Nd2q1aoXHysrN2CVxUzYxW9/u9/ZpS08aHhd4M=
X-Received: by 2002:a17:906:8409:: with SMTP id n9mr17274494ejx.128.1565343884486;
        Fri, 09 Aug 2019 02:44:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTABTVR1Z1J01O+vViFpoNPTKBuhkAGeQcfuVv1cNNAC0DL1SEAmr1prZ7wBIRBPx2EzPD
X-Received: by 2002:a17:906:8409:: with SMTP id n9mr17274452ejx.128.1565343883492;
        Fri, 09 Aug 2019 02:44:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565343883; cv=none;
        d=google.com; s=arc-20160816;
        b=hFeQkxAr9aPznB1/3ousJxRMqKg2GxplrjKDvwQCTVAK59f5QSx1n/Vf2XCOWsprdP
         YsWNLIHFW6HKQXAEHYjsxpONl8rHfdTCoNO68jS0L9K461f2w6mwdG7eyCr8wMKfVOxT
         AuI8xuRLKH2IbCOwK4+ZMqaz7ELEFRMnLObwS9l1wmM+qMgWWIOopp043yHsfnETFHPh
         fnUSiwCMQgF6rFh3VoUHEPAXUTv5H5JFKzAyJuc0rT6nR8MvZmeD4spQnTZjHIdYjUSX
         sH7hRv01ytfbYUUk5bB11z+lmu/VZ1kDozbfBWEFCpQ2l5eg6mOgL3Hl0DtOXvEwF3E+
         KR1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=7Zz+dekQVz+t60cfPAWXHDt673zqelsbIxrG4v8rxXU=;
        b=JZD1dKaB9yfaOmcUPqmam75Gn1qy0Urr1PF21VlRJPOueX22gbgR2Y3z9thqBKxrya
         AZEICW13SHz9RMYa5D6/HP3Cr6aFI313Z38cojn69KfVtXmcUHez2cPrmCImC7rCGKjK
         LeWZpgdtJhdVaXxhi5i51YviNB4wH5nZDnXFxS6D0xzglZeElpRBXZJhAgqpJCyGWsqc
         5L+0RAWY1YbMcb3LptU1AI2D3PNkSpm0zTa1/ba3MhFn0Po4z38uJ5IE4i3Y5UP+d6kZ
         QANETBIHheSJlbyQv5DhBh7/B/mPGQ+Lc7YmfjBpClQyf1iumufLUEf71ivL1MMb4PCB
         EB8g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id e42si38087869edd.289.2019.08.09.02.44.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 09 Aug 2019 02:44:43 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 81.250.144.103
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 5865C6000D;
	Fri,  9 Aug 2019 09:44:39 +0000 (UTC)
Subject: Re: [PATCH v6 09/14] mips: Properly account for stack randomization
 and stack guard gap
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Albert Ou <aou@eecs.berkeley.edu>, Kees Cook <keescook@chromium.org>,
 linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>,
 Palmer Dabbelt <palmer@sifive.com>, Will Deacon <will.deacon@arm.com>,
 Russell King <linux@armlinux.org.uk>, Ralf Baechle <ralf@linux-mips.org>,
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 Luis Chamberlain <mcgrof@kernel.org>, Paul Burton <paul.burton@mips.com>,
 Paul Walmsley <paul.walmsley@sifive.com>, James Hogan <jhogan@kernel.org>,
 linux-riscv@lists.infradead.org, linux-mips@vger.kernel.org,
 Christoph Hellwig <hch@lst.de>, linux-arm-kernel@lists.infradead.org,
 Alexander Viro <viro@zeniv.linux.org.uk>
References: <20190808061756.19712-1-alex@ghiti.fr>
 <20190808061756.19712-10-alex@ghiti.fr>
 <bd67507e-8a5b-34b5-1a33-5500bbb724b2@cogentembedded.com>
From: Alexandre Ghiti <alex@ghiti.fr>
Message-ID: <91e31484-b268-2c90-1dd1-98cec349af6c@ghiti.fr>
Date: Fri, 9 Aug 2019 11:44:38 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <bd67507e-8a5b-34b5-1a33-5500bbb724b2@cogentembedded.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: fr
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/8/19 11:16 AM, Sergei Shtylyov wrote:
> Hello!
>
> On 08.08.2019 9:17, Alexandre Ghiti wrote:
>
>> This commit takes care of stack randomization and stack guard gap when
>> computing mmap base address and checks if the task asked for 
>> randomization.
>>
>> This fixes the problem uncovered and not fixed for arm here:
>> https://lkml.kernel.org/r/20170622200033.25714-1-riel@redhat.com
>>
>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
>> Acked-by: Kees Cook <keescook@chromium.org>
>> Acked-by: Paul Burton <paul.burton@mips.com>
>> Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
>> ---
>>   arch/mips/mm/mmap.c | 14 ++++++++++++--
>>   1 file changed, 12 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
>> index d79f2b432318..f5c778113384 100644
>> --- a/arch/mips/mm/mmap.c
>> +++ b/arch/mips/mm/mmap.c
>> @@ -21,8 +21,9 @@ unsigned long shm_align_mask = PAGE_SIZE - 1;    /* 
>> Sane caches */
>>   EXPORT_SYMBOL(shm_align_mask);
>>     /* gap between mmap and stack */
>> -#define MIN_GAP (128*1024*1024UL)
>> -#define MAX_GAP ((TASK_SIZE)/6*5)
>> +#define MIN_GAP        (128*1024*1024UL)
>> +#define MAX_GAP        ((TASK_SIZE)/6*5)
>
>    Could add spaces around *, while touching this anyway? And parens
> around TASK_SIZE shouldn't be needed...
>

I did not fix checkpatch warnings here since this code gets removed 
afterwards.


>> +#define STACK_RND_MASK    (0x7ff >> (PAGE_SHIFT - 12))
>>     static int mmap_is_legacy(struct rlimit *rlim_stack)
>>   {
>> @@ -38,6 +39,15 @@ static int mmap_is_legacy(struct rlimit *rlim_stack)
>>   static unsigned long mmap_base(unsigned long rnd, struct rlimit 
>> *rlim_stack)
>>   {
>>       unsigned long gap = rlim_stack->rlim_cur;
>> +    unsigned long pad = stack_guard_gap;
>> +
>> +    /* Account for stack randomization if necessary */
>> +    if (current->flags & PF_RANDOMIZE)
>> +        pad += (STACK_RND_MASK << PAGE_SHIFT);
>
>    Parens not needed here.


Belt and braces approach here as I'm never sure about priorities.

Thanks for your time,

Alex


>
>> +
>> +    /* Values close to RLIM_INFINITY can overflow. */
>> +    if (gap + pad > gap)
>> +        gap += pad;
>>         if (gap < MIN_GAP)
>>           gap = MIN_GAP;
>>
>
>
> _______________________________________________
> linux-riscv mailing list
> linux-riscv@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-riscv

