Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59042C4646B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 05:21:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED8E4208CB
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 05:21:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED8E4208CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A9CB6B0003; Wed, 26 Jun 2019 01:21:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 433DE8E0003; Wed, 26 Jun 2019 01:21:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FCD48E0002; Wed, 26 Jun 2019 01:21:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D2B396B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 01:21:07 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y24so1406411edb.1
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 22:21:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=5pjbrnpYwS/GXEKx778qKfAMNKb+zKXFQK12kH6bUDs=;
        b=kG2WbWwqMJ3aH+YB+J4ibtZGd0tjgL13zwpujWwMhTUZKU/+u7b3cdXZaFqNb9KOW5
         c9v7EC1gNbIUwtNN40MM86+O1F4eG7Iwb6Yg7PHc9BOYrocdhfbCb0ZwIM9q+lTAfxeO
         BoXJPrjCtlQhjVj2bs9tdqjaxvZWK7St9mTjJXM7Ce8uoG3UJL+d2z9SKHdz4W0YCv4t
         3hnWbrN3gZeRb972RcNLkq3c1kUbh8PYRXY61XHY8dWS6DY4hA6zm+Jt3RU8wZeQKzeU
         bO9Cu3vbBjlcB3PufxrkaFsJKGWymKdhHxTKrUjZVPy5KIDqMn3sozQqrqV5hFSYNWZl
         0oNw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.198 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVzWR3JFi2rmnUQYAF4fysZvzc5b/8VbDDYkZtNjuw2rBZee0ka
	f8uRPZuKS5xolPQWB9RAcPZxtGIHQJMOEdzrjMhSwkGD+sGDu2qmXurwagkFEEgKNPgQW1uuQzV
	Ueb9SD0vSX5iQnGblkYiHwVRXIGa/uKR+IdzAV3HLwZ+6bhULe1cEDqhz+JtWDJo=
X-Received: by 2002:a17:906:27c7:: with SMTP id k7mr2161392ejc.91.1561526467304;
        Tue, 25 Jun 2019 22:21:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBXC8Yyo6diqzvGbfkrJen4ROgFS1ykT9YWszMqE7exuTIrG6FVtXM8E9VDo0VxBnljYC0
X-Received: by 2002:a17:906:27c7:: with SMTP id k7mr2161333ejc.91.1561526466291;
        Tue, 25 Jun 2019 22:21:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561526466; cv=none;
        d=google.com; s=arc-20160816;
        b=RpX7y8bLGQvywoXYe6eHv1gWr0Jtlbu8oJz9VUYeOlWnWBl3NSaKxmH2LDJ8kbaz5D
         /QlxTV74aWbcJqQd7ymWBGcT+hK+n1RZmP2SkR1mwONMPVnfeCmbc3Xk64DFAZ0JW3Et
         OTNce/OzwOsF/sFGSjgkAs7RBIpMVYuv1M24gw7MsRzAq00P+dfTrNYrVmFUlazSrZyZ
         0LIF144Gvgy48EsqgtCmyERvCLCndaH4CZzad9YPm9x7WetkJXyZA9GSQ8usMlcGIDDY
         X4ycZE91QMDbRZjrC4pTt8JwjDIDaCUqFNsjxeNTv80IUE+ypBwpQQJPMsOiHY6mEAFs
         qobA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:references:subject:cc:to:from;
        bh=5pjbrnpYwS/GXEKx778qKfAMNKb+zKXFQK12kH6bUDs=;
        b=IURkiOdJPvqy0VOSQgCtU7NROqnqdL8OKfLg2a8k9z3b5Wi4Soha0rxX8D6YlPhQ0X
         4dQqiEnGZO76zcWBcP10WoMw3GtHsi47zvOo+M/QphQ4fdLsLGkrRXJ8YNGCAwmsmKbj
         01dirAfn+USBxcB51G5vO3NOKUMk31Bj8NOJno3JjmfXUt3gPTDQepQR/Kr1hmesTzX8
         BecEqUBPfCpZVMZVvqF5GgeH7hQVm6W7zujusWj1b9i05qhqcta8gbDLVigzWkW2Tqwq
         CO4Rvt035C0vsOaFN5E8DvV5xHyXEKFUfbT8kuIQq48CXZmeCjhfe+p7WhH5p8KuJ+kc
         h+IA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.198 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay6-d.mail.gandi.net (relay6-d.mail.gandi.net. [217.70.183.198])
        by mx.google.com with ESMTPS id p12si2616382eda.385.2019.06.25.22.21.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 25 Jun 2019 22:21:06 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.198 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.198;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.198 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from [192.168.0.12] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id BAAC4C0003;
	Wed, 26 Jun 2019 05:20:51 +0000 (UTC)
From: Alex Ghiti <alex@ghiti.fr>
To: Helge Deller <deller@gmx.de>
Cc: "James E . J . Bottomley" <james.bottomley@hansenpartnership.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>, Vasily Gorbik
 <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 "David S . Miller" <davem@davemloft.net>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 sparclinux@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RESEND 6/8] parisc: Use mmap_base, not mmap_legacy_base,
 as low_limit for bottom-up mmap
References: <20190620050328.8942-1-alex@ghiti.fr>
 <20190620050328.8942-7-alex@ghiti.fr>
 <438124ff-6838-7ced-044c-ca57a6b9cc91@gmx.de>
Message-ID: <7fb32983-3444-0747-4e5f-812d1b4d84c2@ghiti.fr>
Date: Wed, 26 Jun 2019 01:20:51 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <438124ff-6838-7ced-044c-ca57a6b9cc91@gmx.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/25/19 10:09 AM, Helge Deller wrote:
> On 20.06.19 07:03, Alexandre Ghiti wrote:
>> Bottom-up mmap scheme is used twice:
>>
>> - for legacy mode, in which mmap_legacy_base and mmap_base are equal.
>>
>> - in case of mmap failure in top-down mode, where there is no need to go
>> through the whole address space again for the bottom-up fallback: the goal
>> of this fallback is to find, as a last resort, space between the top-down
>> mmap base and the stack, which is the only place not covered by the
>> top-down mmap.
>>
>> Then this commit removes the usage of mmap_legacy_base field from parisc
>> code.
>>
>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Boot-tested on parisc and seems to work nicely, thus:
>
> Acked-by: Helge Deller <deller@gmx.de>

Thanks Helge,

Alex

>
> Helge
>
>
>
>> ---
>>   arch/parisc/kernel/sys_parisc.c | 8 +++-----
>>   1 file changed, 3 insertions(+), 5 deletions(-)
>>
>> diff --git a/arch/parisc/kernel/sys_parisc.c b/arch/parisc/kernel/sys_parisc.c
>> index 5d458a44b09c..e987f3a8eb0b 100644
>> --- a/arch/parisc/kernel/sys_parisc.c
>> +++ b/arch/parisc/kernel/sys_parisc.c
>> @@ -119,7 +119,7 @@ unsigned long arch_get_unmapped_area(struct file *filp, unsigned long addr,
>>
>>   	info.flags = 0;
>>   	info.length = len;
>> -	info.low_limit = mm->mmap_legacy_base;
>> +	info.low_limit = mm->mmap_base;
>>   	info.high_limit = mmap_upper_limit(NULL);
>>   	info.align_mask = last_mmap ? (PAGE_MASK & (SHM_COLOUR - 1)) : 0;
>>   	info.align_offset = shared_align_offset(last_mmap, pgoff);
>> @@ -240,13 +240,11 @@ static unsigned long mmap_legacy_base(void)
>>    */
>>   void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
>>   {
>> -	mm->mmap_legacy_base = mmap_legacy_base();
>> -	mm->mmap_base = mmap_upper_limit(rlim_stack);
>> -
>>   	if (mmap_is_legacy()) {
>> -		mm->mmap_base = mm->mmap_legacy_base;
>> +		mm->mmap_base = mmap_legacy_base();
>>   		mm->get_unmapped_area = arch_get_unmapped_area;
>>   	} else {
>> +		mm->mmap_base = mmap_upper_limit(rlim_stack);
>>   		mm->get_unmapped_area = arch_get_unmapped_area_topdown;
>>   	}
>>   }
>>

