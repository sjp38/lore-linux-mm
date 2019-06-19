Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B77BDC31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:54:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67B5C208CB
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 05:54:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67B5C208CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00F5F6B0003; Wed, 19 Jun 2019 01:54:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F01408E0002; Wed, 19 Jun 2019 01:54:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC8728E0001; Wed, 19 Jun 2019 01:54:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 903246B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 01:54:33 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b21so24532590edt.18
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 22:54:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=3G3390t9ua8g8EG4NGiM6gw8EdNRT+c1H9JhEFzdToc=;
        b=jZbIjKyMJ5U99eI83koc9rOczdAUhPNp35GlxHgE3ECwdqDzaWenratMqIcvm2pm+6
         0aTRkzMw667fV4AOUKeSuvCLXK9Q+ma3jXkYwUzz0Un3NXwwGiC4BSHbAwBi5TjWunGd
         juCXgf+3JQArQNNYav3wNbgF31dJGCiZufI+RzsgZjVpBxQOVhkti8Wcj6TYzAzUOHhR
         H/5QzJXLHRxBpPbWbQvxxWaAHMkB3TbZqgeydkIvvhTHDwg56ApbYm5tXH1j0+gMTsme
         +Kw5jxxGjxmfWO+9qJFjGFb/leTqQE86H4b04c783jspkPKCGCDFuOoZYdvaEmT+NIcx
         dKxg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVDdunXhqC6uFGEBqbNoHrwRW6rcPm9H1xymPuCXXEABJC2zRIH
	h0otnCMc4qrgPUhr3wY96kXekdxaSF1nS9bFmOKsJ4iZQmUZ3oL/DmzE7Tfz+GehHbHx7HRPYtf
	66826xZMc60vtG8EFBOqw5k4HG6C6j73qKwX+gp6C+GdmO2W4YjQ5r2BlLPdcQBU=
X-Received: by 2002:a17:906:552:: with SMTP id k18mr17023186eja.117.1560923673149;
        Tue, 18 Jun 2019 22:54:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyckIzA8XRs7GjEsDg931Y6aH5SwQnBzo2vTHMvjyN0pPxbIknt9ppmr4Td9meNbVfpZ0J
X-Received: by 2002:a17:906:552:: with SMTP id k18mr17023159eja.117.1560923672357;
        Tue, 18 Jun 2019 22:54:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560923672; cv=none;
        d=google.com; s=arc-20160816;
        b=hXqyrdvuA0KyYYhIPPYg5pW+G11JSBsPJHjQEn3jlP12WBAnVfArD530wkSBQpyDQ4
         MWWnqFsM9kAZIPtoVDV8lsPJCgXM9UXuMtBykNZCv04HalHTXm39yzbQTvpiZdRkZsHZ
         qp0kXWBV7wJEd6C+8BbzdHT3l1vmWb3AzOcQMM71ryc8XCKiupE5RtYZIH3maHa4ZKsp
         H+DyBVMf632inTmh5lgc+26ExGdOTV3p9QPC/4dxxmHgYL4uj89chH80aV9IFLiDGSSn
         K4ynR5edU9UwJVqQguQN0W1e+diLGoNFGVtu5cKJzdAFGGUCB0NQe7eKv6s4QAwOZRSv
         jslA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:references:subject:cc:to:from;
        bh=3G3390t9ua8g8EG4NGiM6gw8EdNRT+c1H9JhEFzdToc=;
        b=wiIRqDFR6gDRtDxQGpJJPgmAknSNblJ0ACIPjqgbjj9+IKggVu5ssyQO70RkaWh8w4
         NU2UBLVDsDdUQnm/QIbChnc7P7wY/TM1MPtF06arDFBsTeocKgvuAsOQyeYHT1ovr7Td
         BE3l7ALQl3D6x2w9bzcphE7+Cs3qWKrfC76YWofSl1ABeAn33CyxgKsAwJdVgD9Mxa34
         2OAufISaAzIB1wVZU7TbqSYNe6Ndr9m5Nur7eSMB5BZREMOshERThQwUutw2HeUPPtbr
         AO8P2cILJUrxlLY+QV2B/hHoVV7inKvMj+GLKdthlISC/kkEyj0lqwXM1nx2s5gyDBIb
         wlrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net. [217.70.183.196])
        by mx.google.com with ESMTPS id l18si3225177ejc.87.2019.06.18.22.54.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Jun 2019 22:54:32 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.196;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from [192.168.0.12] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id E2F4DE000E;
	Wed, 19 Jun 2019 05:54:21 +0000 (UTC)
From: Alex Ghiti <alex@ghiti.fr>
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: "James E . J . Bottomley" <james.bottomley@hansenpartnership.com>,
 Helge Deller <deller@gmx.de>, Heiko Carstens <heiko.carstens@de.ibm.com>,
 Vasily Gorbik <gor@linux.ibm.com>,
 Christian Borntraeger <borntraeger@de.ibm.com>,
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
Subject: Re: [PATCH RESEND 1/8] s390: Start fallback of top-down mmap at
 mm->mmap_base
References: <20190619054224.5983-1-alex@ghiti.fr>
 <20190619054224.5983-2-alex@ghiti.fr>
Message-ID: <4fcd8c83-dc33-12ab-3ba2-85a8d851674d@ghiti.fr>
Date: Wed, 19 Jun 2019 01:54:20 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190619054224.5983-2-alex@ghiti.fr>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Really sorry about that, my connection is weird this morning, I'll retry 
tomorrow.

Sorry again,

Alex

On 6/19/19 1:42 AM, Alexandre Ghiti wrote:
> In case of mmap failure in top-down mode, there is no need to go through
> the whole address space again for the bottom-up fallback: the goal of this
> fallback is to find, as a last resort, space between the top-down mmap base
> and the stack, which is the only place not covered by the top-down mmap.
>
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> ---
>   arch/s390/mm/mmap.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/arch/s390/mm/mmap.c b/arch/s390/mm/mmap.c
> index cbc718ba6d78..4a222969843b 100644
> --- a/arch/s390/mm/mmap.c
> +++ b/arch/s390/mm/mmap.c
> @@ -166,7 +166,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
>   	if (addr & ~PAGE_MASK) {
>   		VM_BUG_ON(addr != -ENOMEM);
>   		info.flags = 0;
> -		info.low_limit = TASK_UNMAPPED_BASE;
> +		info.low_limit = mm->mmap_base;
>   		info.high_limit = TASK_SIZE;
>   		addr = vm_unmapped_area(&info);
>   		if (addr & ~PAGE_MASK)

