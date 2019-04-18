Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EA7AC10F0B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:23:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F09D921479
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:23:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F09D921479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A41D36B0006; Thu, 18 Apr 2019 01:23:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F1516B0007; Thu, 18 Apr 2019 01:23:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E1626B0008; Thu, 18 Apr 2019 01:23:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 435F56B0006
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 01:23:46 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k56so639937edb.2
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 22:23:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=Y2OrEfAfUzMlipsZCoQ+KrURIeLhMn3AxuhA5y5txtM=;
        b=XvkfaV+iypAHgQsOQ/iAi7KvlXh8XFwSm9uB8mTYJv6unZVGIVitrkCr+KHuzXFf2G
         j9e+QXntNGFWF78yloDsr/Of/sXaUpgdqbOibZu+Qav6tX9Vi1eOm8SWSMbWjbLO4lnr
         fH60kyDZAD26EOqB/qYia4x3H61HZjFBD0+UUbnc4tPI6H1IUMBGQpCCTOUZRxnUoKDP
         /l5hCeGtZzSUAw3odEm8iduSiMmOrRnFbN1gTE7ISbMFISIrRdjArjJL/9Ff1shqLIPe
         qB5+PXrO53nj8BU7hK16wA9rkcBYWwFRpoFsOFIZrKxpPPzKaeZ2F3UrWfKzhLm3OIow
         MRhQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUHKSk/BZJqtmePqvuuFYUgIy6zAUL1gnwDtDTjv0pA+pCe/fe4
	tPZHMybBZ946LKmYtUQ6igynPHcCDLfcNEdqsEuMd4l9q4XperiqXAkmK0jpM0Yv24wg2yTbDUh
	ITantT7nxrlD2tZoRGUXwl5IRwz+NxniDabagZEO94VqnghsSCyRNUOlNUSTrnj4=
X-Received: by 2002:a50:89f4:: with SMTP id h49mr21897827edh.73.1555565025772;
        Wed, 17 Apr 2019 22:23:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzOnIyIwfE6hwqs8tRAXbukSeBTUd1WLB1iO8suVvTCHwRldTNMVw9oobQvrzdtbklc5WeM
X-Received: by 2002:a50:89f4:: with SMTP id h49mr21897799edh.73.1555565025094;
        Wed, 17 Apr 2019 22:23:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555565025; cv=none;
        d=google.com; s=arc-20160816;
        b=uG9HlpX8hoW2RiAEamdTKTtrVspUFXgVhk/EZJCUrw0ujlrLGPBa/SE0FLwKTAMxQj
         6I9VqHp6SyWHoY8U9Tdt/1smCEwD+/ZlYhaomSi4tZ1a9eBldLQBOtkalfChG0WLmIA/
         RogTYjJQOS/nJfUL9m5RGQFKrs30aKU6Zfc9MC98af3QGOZZRtBZGP3HhrMtFqyw1PfX
         Mn7DkLY/xQVsYgr56YVumZ+vt/i0bOk8trFpi4/GCE2d9U0BWnM0IdjnbNeWrngxNzxy
         C76NasPWFGHhjqCEbjyo0pk/e4Ylsv/2xDIwmkV/xnpz3rv6ZxMHT/DHFs0LM7ACQjVn
         tWpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=Y2OrEfAfUzMlipsZCoQ+KrURIeLhMn3AxuhA5y5txtM=;
        b=uoFf9CzPbh78avJUGcy06vq6vygo/ni9o9kgcT/9NCFx2XEG787pkBvRgW4olY/Def
         eMXxIrFaNP1SCesWsCmYUMN6SBoOlfjNq0Z5cEwNRZeNeUXxdVkrL/s5v7kss6gxQK88
         q3djwVrQR3I7Qf6QQQH+NgQMVHHk7ZHWAU9vyO8TwuIcQRlauo2HJowgHae0QfI7tpxv
         c//c/jL36m7Nq7sm0g8bw64FterbmOwGAEKeR22An4dZNFZ7fJdX5olFtBVgWwIle42O
         uG+PoJY8hyRxcYKvlUMHhFkygY5/q0LkITUw64Yja69MR0hGqE9zcBBgtnM8s3rkyK6c
         yO7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id i4si475280edg.311.2019.04.17.22.23.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 22:23:45 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from [192.168.0.11] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 2D76460003;
	Thu, 18 Apr 2019 05:23:38 +0000 (UTC)
Subject: Re: [PATCH v3 02/11] arm64: Make use of is_compat_task instead of
 hardcoding this test
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
 <20190417052247.17809-3-alex@ghiti.fr>
 <CAGXu5jKVa2YgAkWH1e26kxd2j6C4WsJ38+Z3K1z7JRvr_jDX6Q@mail.gmail.com>
From: Alex Ghiti <alex@ghiti.fr>
Message-ID: <1f63cf5a-6bbe-fa55-75c0-20322d8a7f36@ghiti.fr>
Date: Thu, 18 Apr 2019 01:23:38 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAGXu5jKVa2YgAkWH1e26kxd2j6C4WsJ38+Z3K1z7JRvr_jDX6Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: sv-FI
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000003, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/18/19 12:32 AM, Kees Cook wrote:
> On Wed, Apr 17, 2019 at 12:25 AM Alexandre Ghiti <alex@ghiti.fr> wrote:
>> Each architecture has its own way to determine if a task is a compat task,
>> by using is_compat_task in arch_mmap_rnd, it allows more genericity and
>> then it prepares its moving to mm/.
>>
>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Acked-by: Kees Cook <keescook@chromium.org>


Thanks !


> -Kees
>
>> ---
>>   arch/arm64/mm/mmap.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/arch/arm64/mm/mmap.c b/arch/arm64/mm/mmap.c
>> index 842c8a5fcd53..ed4f9915f2b8 100644
>> --- a/arch/arm64/mm/mmap.c
>> +++ b/arch/arm64/mm/mmap.c
>> @@ -54,7 +54,7 @@ unsigned long arch_mmap_rnd(void)
>>          unsigned long rnd;
>>
>>   #ifdef CONFIG_COMPAT
>> -       if (test_thread_flag(TIF_32BIT))
>> +       if (is_compat_task())
>>                  rnd = get_random_long() & ((1UL << mmap_rnd_compat_bits) - 1);
>>          else
>>   #endif
>> --
>> 2.20.1
>>
>

