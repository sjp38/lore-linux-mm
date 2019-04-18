Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24D23C10F0B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 06:04:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DE844204FD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 06:04:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DE844204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DD726B0005; Thu, 18 Apr 2019 02:04:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78A986B0006; Thu, 18 Apr 2019 02:04:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 679F06B0007; Thu, 18 Apr 2019 02:04:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 164046B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 02:04:16 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f42so681756edd.0
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 23:04:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=NMZGZi7E/k1uxDFQhdlQAQLAcvZsm/HUaZEipShSxfo=;
        b=dWR0x+V1tQWYCS9sFOrRujqauG3oLsZYaNEzfWVoNAjlWF/RjaPB1of4XwBppNr0O3
         lSi/dd4Yt1il86q7Ia3FsN7QaYSouFzfuCf7vKBzf6X6JrCkahMPFI6CisQKb20Mv+vI
         4uyJlupZ169AE8NC0A+FkGhRG9tdNCiPtyWfOWhXhClM+NZyGNdbk6UMuk5D+u/b6ydi
         IIH8zIP4uU57t4YNgKBDo0g28HaafpaRGfvxAo40oKsB8wq1FjT/MNNmKblN7Av4KAT3
         gP38iiX+yBkjDxeUDPh1OH2mbz7JRkuLqEbbPaL/uqSdcBaSVG39WmW1JX9DjT25u+7Y
         p6/A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXwNAbrfvCbqHpvfqjeZcdGmgaoqIwuGnXuyar5a6aNsAMH0oPn
	UjTpg1eBVnSvEKF8xVIAWi02Rl/lt3X0zIvsz5rTJAw6nQmFpB1XgTbAhDQepKFOxBh+hFr5I9g
	q/j9968SEIVIOLlgKvIORPj0zAxE4sVNuh+VcbRrxv/3Oxb9OxTQ7/gUz/S+E/NI=
X-Received: by 2002:a17:906:34ce:: with SMTP id h14mr2448447ejb.293.1555567455625;
        Wed, 17 Apr 2019 23:04:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrNIXuC2xeyAeZNYugZpJ7JTX8H2lJccKafD4jTi7EWONfJoJHWCQzBdsUqfbZus2NV0/z
X-Received: by 2002:a17:906:34ce:: with SMTP id h14mr2448410ejb.293.1555567454862;
        Wed, 17 Apr 2019 23:04:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555567454; cv=none;
        d=google.com; s=arc-20160816;
        b=XIcGTWrG1GxPr+4zp2ZK953vH+lhC0ltEh6ORkyzXwwt8dfZis3pvpgvq0RpgNZpc5
         x2t0dq++6Xg/dyB1XpC3MBOBnXVZJcKCbxWcO7kboYxHbXloZPcnkdDCH4Vkb+40nxM7
         vKC0TFsOBLeiFkC8WnNJfm2sZH11+Qpn1Brd7Suxoaiwz8nTKtrep0JPoBDGuOFAAAEb
         mNGbgdWxAPv/vnMP8w9nm9/qCKWENhSvZ2YpCPu4EoomAyO1MAuSQ6WLvEje+zhLiA0v
         er1XSSQiJDSZdikcRUeWR4rWNYHGwQcYS31L44ekO6jC81xOhk7NZfhg1p8HsWyLCadr
         jdtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=NMZGZi7E/k1uxDFQhdlQAQLAcvZsm/HUaZEipShSxfo=;
        b=cNmNstDjmYJKSySl8uBBJoeyKLgXHX6ij1eOf4Hf+CTG0YjMZ/Qfs6Rj6Qdj+sw1sn
         iMzYLNPo+oUkKnU80xW12VrSioebhZUFjHZ3pQG1pTo0rXiEh0BI6qNC3+LXjYm2P/OE
         iemY4zE7owKhgRA4g0BoK8NV7Edu/coaFBU/Vt5MnHmzOrEawrMJIpXTF9+oOPrTjsxw
         OAEVIRht1ktH5BkK5TNJxBtgxcKQHRYBvX5Rlkk/+wbVCmwQk0kM7KPq6udXLMspHLzH
         S7FQeCYtQJfKwAm7k0iC+uP7oaXaqnRSfVDKvB687a4YKC6/mymYbMkpOvwV6LCowYSq
         fE3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay1-d.mail.gandi.net (relay1-d.mail.gandi.net. [217.70.183.193])
        by mx.google.com with ESMTPS id gs1si653640ejb.18.2019.04.17.23.04.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 23:04:14 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.193;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from [192.168.0.11] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay1-d.mail.gandi.net (Postfix) with ESMTPSA id DC0F4240004;
	Thu, 18 Apr 2019 06:04:08 +0000 (UTC)
Subject: Re: [PATCH v3 06/11] arm: Use STACK_TOP when computing mmap base
 address
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
 <20190417052247.17809-7-alex@ghiti.fr>
 <CAGXu5jLFtaiRqvd_Lw2B688bzUyti2O8o_iZVmQhb7rmnEKzBQ@mail.gmail.com>
From: Alex Ghiti <alex@ghiti.fr>
Message-ID: <9fdc1de9-8552-da1b-7d05-0596969ddad2@ghiti.fr>
Date: Thu, 18 Apr 2019 02:04:08 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAGXu5jLFtaiRqvd_Lw2B688bzUyti2O8o_iZVmQhb7rmnEKzBQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: sv-FI
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/18/19 1:27 AM, Kees Cook wrote:
> On Wed, Apr 17, 2019 at 12:29 AM Alexandre Ghiti <alex@ghiti.fr> wrote:
>> mmap base address must be computed wrt stack top address, using TASK_SIZE
>> is wrong since STACK_TOP and TASK_SIZE are not equivalent.
>>
>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
>> ---
>>   arch/arm/mm/mmap.c | 4 ++--
>>   1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/arch/arm/mm/mmap.c b/arch/arm/mm/mmap.c
>> index bff3d00bda5b..0b94b674aa91 100644
>> --- a/arch/arm/mm/mmap.c
>> +++ b/arch/arm/mm/mmap.c
>> @@ -19,7 +19,7 @@
>>
>>   /* gap between mmap and stack */
>>   #define MIN_GAP                (128*1024*1024UL)
>> -#define MAX_GAP                ((TASK_SIZE)/6*5)
>> +#define MAX_GAP                ((STACK_TOP)/6*5)
> Parens around STACK_TOP aren't needed, but you'll be removing it
> entirely, so I can't complain. ;)
>
>>   #define STACK_RND_MASK (0x7ff >> (PAGE_SHIFT - 12))
>>
>>   static int mmap_is_legacy(struct rlimit *rlim_stack)
>> @@ -51,7 +51,7 @@ static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
>>          else if (gap > MAX_GAP)
>>                  gap = MAX_GAP;
>>
>> -       return PAGE_ALIGN(TASK_SIZE - gap - rnd);
>> +       return PAGE_ALIGN(STACK_TOP - gap - rnd);
>>   }
>>
>>   /*
>> --
>> 2.20.1
>>
> Acked-by: Kees Cook <keescook@chromium.org>


Thanks !

>

