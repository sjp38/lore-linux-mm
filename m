Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E512CC10F0B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 06:06:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E957204FD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 06:06:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E957204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 409366B0006; Thu, 18 Apr 2019 02:06:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B7836B0007; Thu, 18 Apr 2019 02:06:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A7716B0008; Thu, 18 Apr 2019 02:06:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D4E886B0006
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:06:36 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f7so681483edi.3
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 23:06:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=li+ds4XAC510r4QyK5OlsQOybzk9sXps+syj2ca737Y=;
        b=dAbfetY34cyU+CUX6oMOrw3uNGlo1CxpQBT2gh+ii1Q0p6ov7aCDAXy8OmbkUG+SF/
         D/IgohOHjVnYvjbRb8n19y5Skx2ZfV/g1tE6ZirYG2uj9tdyF5COvF0j0M4u5VeYhwtP
         1fieFk9j7CcrInAW1eLL+6vGRU8Ep4Fy63hzIpeOTGGzwqHSQ8V3dJ89XExmx4onUa19
         Qc1NFLOwESMVyMzBSGtDOhEo4qbNAkkRFSNlIgWkMV4+ERTNCJ0CnFqrhgGl4ycIG+XR
         LkkB9iMytKjWeYNivZ7K4IUp27HgqbiZ6OCpVaBa444Js3sMJpqCVc+SwV6D48EueYyW
         wPTQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAV9hdMakY6ErVsN4mJxd5pq6bYrA9cqhn8zCY7qpq8QeHth+xKg
	fmhwEFpTm4rEUSs8kspelUPEY4IagCtm7GUnZyGbRpQiWbpG+hs1Sjm8PD5q9WOUIy7X9Q8xy4K
	5eQs/0cKVTd6HyGb6H2KGMn8XUrLZhWjiP6xoGvEFftkPCIxeM8ozaEcZckNho2g=
X-Received: by 2002:a50:94d1:: with SMTP id t17mr22399755eda.124.1555567596438;
        Wed, 17 Apr 2019 23:06:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrW5A5nFmfGOLTy+3o0Hr+RBoIJiUDS55CWj1E6w3iRqEzEuA9hXKGcMIUKaWdRdfeU9aq
X-Received: by 2002:a50:94d1:: with SMTP id t17mr22399720eda.124.1555567595677;
        Wed, 17 Apr 2019 23:06:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555567595; cv=none;
        d=google.com; s=arc-20160816;
        b=sGv11K6WWl/NaK+3aRGQa4lsET1Jhl0T/PHlJrtkZeUTMtO/B1KpRm0VtaDeSzAjaL
         hvbHGOaJvrxRie7VheJhQFw1NfqamerNEM12uX9BuyTm49zSpBM1apgHEC1XdaKsZMAa
         ne6TQRDj5SX1zv7KJcnT0vDCQRJGM+7q1Cef/mP+QkCSSi1vFaQhWGJ5JWpb0lFx7vv7
         zA8ACzZT4AfYyXW8PYQOC6AEu6QFYhF7GmT/ParE1Ill8J1dM8PYj76xlS5X4MGQfJow
         k140jkO+9X9jHSnDqmEth5IBLXxeJcFyAfEfQkR3hBwKLFxHuwZ3r/iIMFhU8+5yLy8g
         o/FQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=li+ds4XAC510r4QyK5OlsQOybzk9sXps+syj2ca737Y=;
        b=ZfJHHXIqHfuIl2CuKNyVv7HC23NlK9IuFsxYW7m/ixjfA4FE2cZSzeP+ydSwV03bLL
         69OhCO4L+ghphNCqjMcpHNy1Zabll0JF5j8VrnaJtxxnhSu65EgfTLIXPVjwihI6TqBn
         HLAAsXfDIwhd0oWcnxJHq512EJeQEBpV7l+KtFZbtvYqjPOJXlij/zUr46b7Ntgte4cJ
         89eLkqWFQQm8obdU3QU64oh3y/vV307aDaGdGtNTmMpQKOZ/uu4ObjRqsSdDHAYdZNIY
         VTFjmcQHNSN/ClxaWL5K/X/9QnMTj8wDczonsYlDizvDXu3dyEixNHvt54MYiXeULO47
         si/w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id jt10si664114ejb.292.2019.04.17.23.06.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 23:06:35 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from [192.168.0.11] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id 29000FF809;
	Thu, 18 Apr 2019 06:06:29 +0000 (UTC)
Subject: Re: [PATCH v3 08/11] mips: Properly account for stack randomization
 and stack guard gap
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
 <hch@lst.de>, Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>,
 Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
 Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Luis Chamberlain <mcgrof@kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
 linux-mips@vger.kernel.org, linux-riscv@lists.infradead.org,
 "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
 Linux-MM <linux-mm@kvack.org>
References: <20190417052247.17809-1-alex@ghiti.fr>
 <20190417052247.17809-9-alex@ghiti.fr>
 <CAGXu5j+-M5VGsPqZ6JyqH6w=HP9NLK2KEAQqen99ssUg5mC89A@mail.gmail.com>
From: Alex Ghiti <alex@ghiti.fr>
Message-ID: <df36815b-ace1-2cd6-d511-14b7e0df04a0@ghiti.fr>
Date: Thu, 18 Apr 2019 02:06:29 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+-M5VGsPqZ6JyqH6w=HP9NLK2KEAQqen99ssUg5mC89A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: sv-FI
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/18/19 1:30 AM, Kees Cook wrote:
> On Wed, Apr 17, 2019 at 12:31 AM Alexandre Ghiti <alex@ghiti.fr> wrote:
>> This commit takes care of stack randomization and stack guard gap when
>> computing mmap base address and checks if the task asked for randomization.
>> This fixes the problem uncovered and not fixed for mips here:
>> https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1429066.html
> same URL change here please...
>
>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Acked-by: Kees Cook <keescook@chromium.org>


Thanks !


>
> -Kees
>
>> ---
>>   arch/mips/mm/mmap.c | 14 ++++++++++++--
>>   1 file changed, 12 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
>> index 2f616ebeb7e0..3ff82c6f7e24 100644
>> --- a/arch/mips/mm/mmap.c
>> +++ b/arch/mips/mm/mmap.c
>> @@ -21,8 +21,9 @@ unsigned long shm_align_mask = PAGE_SIZE - 1; /* Sane caches */
>>   EXPORT_SYMBOL(shm_align_mask);
>>
>>   /* gap between mmap and stack */
>> -#define MIN_GAP (128*1024*1024UL)
>> -#define MAX_GAP ((TASK_SIZE)/6*5)
>> +#define MIN_GAP                (128*1024*1024UL)
>> +#define MAX_GAP                ((TASK_SIZE)/6*5)
>> +#define STACK_RND_MASK (0x7ff >> (PAGE_SHIFT - 12))
>>
>>   static int mmap_is_legacy(struct rlimit *rlim_stack)
>>   {
>> @@ -38,6 +39,15 @@ static int mmap_is_legacy(struct rlimit *rlim_stack)
>>   static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
>>   {
>>          unsigned long gap = rlim_stack->rlim_cur;
>> +       unsigned long pad = stack_guard_gap;
>> +
>> +       /* Account for stack randomization if necessary */
>> +       if (current->flags & PF_RANDOMIZE)
>> +               pad += (STACK_RND_MASK << PAGE_SHIFT);
>> +
>> +       /* Values close to RLIM_INFINITY can overflow. */
>> +       if (gap + pad > gap)
>> +               gap += pad;
>>
>>          if (gap < MIN_GAP)
>>                  gap = MIN_GAP;
>> --
>> 2.20.1
>>

