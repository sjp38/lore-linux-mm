Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 124C3C282E3
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 06:43:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AEF9420868
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 06:43:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ozlabs-ru.20150623.gappssmtp.com header.i=@ozlabs-ru.20150623.gappssmtp.com header.b="N5cq2X5s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEF9420868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ozlabs.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B7B66B0006; Fri, 24 May 2019 02:43:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 367C56B0007; Fri, 24 May 2019 02:43:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 230DF6B0008; Fri, 24 May 2019 02:43:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DD3D46B0006
	for <linux-mm@kvack.org>; Fri, 24 May 2019 02:43:22 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id b127so4666730pfb.8
        for <linux-mm@kvack.org>; Thu, 23 May 2019 23:43:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :openpgp:autocrypt:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=vLgUtLgd34YoqqCTxqxpLbSxwvGV3M2LzlOeHp/1Cec=;
        b=pOrMWZ2P6cBJDI+q0AyL98sjndaS+09yrEcszWUiBp+Pa6KqIC3bDXQxtaxszFupyw
         hLwm5cHFxj3tmRXy3U2RLy+6SDoGtOXrWjqC1BGxz2bUaNDyGJiURQRTK3+4eeClABH4
         opGKcsYB7p3SLYrl+B+Ppsa2oyUBnQRvCCKep06MRvQkiv9zHmMCIJG9C/yr1LTUFHHu
         z8Z6j5x0d1BgW2yBkVir1x3EBExp2hPnH6rigzVa9xg6Krcbz0tMul9Kpjcttk4XMdOA
         9jJB88r/KkA4rHSCFZxTMKxRbVwxGqogwQzRm9gkW0qwd78MD0PFigyNdgosRsou/mtf
         Lnkw==
X-Gm-Message-State: APjAAAUeNjnlc5yrFTUAPA1YcMUeQjV+TjOg2P7Tg7GN7RcBX3LvTEWN
	hxSmZltYJ6NrElW7iN3X0rpziWLVPfjHwUukKxFex29c8EahPsCdGtnp5smeZV809pPEJMXXDLi
	GjddZ3GrmKEnMSLvFp6Jq10fAADeaalBkjjQpvxYNhfmhU60YdEpM+xrfcwgDh7nO6A==
X-Received: by 2002:a62:5e06:: with SMTP id s6mr50107879pfb.193.1558680202441;
        Thu, 23 May 2019 23:43:22 -0700 (PDT)
X-Received: by 2002:a62:5e06:: with SMTP id s6mr50107827pfb.193.1558680201596;
        Thu, 23 May 2019 23:43:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558680201; cv=none;
        d=google.com; s=arc-20160816;
        b=kY4hEoQxZYsg1Y8TQy4ciuN1PS+mTOBN61LUoJSN6o5Vy+gdW2AZvF9y49OF7CQFNr
         BDoDOJOHQA4r5sxLJoy4ZZjp6tOByQMApRCnJRmdaqxV6U+4WjaxKBKrUVI59l7xC1+F
         lekZcIqfx4bfe+ctT0EUiOYZaRt9OpDzzTmRnfDHREZaTGaCoGbDtiUeZIG49CpbaKoi
         z04DBwVFcU5ZfeGOr49oClSCj8vrVKSRqmpWJ7j4/QOwRO++BBa2Rkcd9Z3XNaHla2UP
         eiemDVOq75jCAnOU0pDzB4u3yRsZloOYShQk40mpeHpQ/3UympgbvGcAE1p3iT018N7h
         2ilw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject:dkim-signature;
        bh=vLgUtLgd34YoqqCTxqxpLbSxwvGV3M2LzlOeHp/1Cec=;
        b=Ut3+UQRfJOE5mjmnyTJ6WgCNgjorlfVQkF5UkGIhjedUCHptqYT2XcmXkKy+rlSDYb
         i1/PZ7dZi+KwPLiI2104n7LXtHtA0rBIIlytiR8y3dYjSTlOsD3oUndiu+nKo61WM4nx
         tpE+ArOzw1OfMYnoiAXQU0sYk1pReUUwXjtj6uBdsfNHWs2XOHt1QnCNHi8ndopHktup
         Lng/nNdbDPp9pbUTEVV3/cwnQFZ2awBnBOcA05EMM7Sq/BH9c3UqcmCIL/negfpv8ewG
         NCAX7tz0CpcoDdnwnnBedTDNqWRRqfinRXWZCbVYngkBe5Pa6pDhZciLqcN9hale5xYA
         0qTg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ozlabs-ru.20150623.gappssmtp.com header.s=20150623 header.b=N5cq2X5s;
       spf=pass (google.com: domain of aik@ozlabs.ru designates 209.85.220.65 as permitted sender) smtp.mailfrom=aik@ozlabs.ru
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c16sor1747591pgc.40.2019.05.23.23.43.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 23:43:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of aik@ozlabs.ru designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ozlabs-ru.20150623.gappssmtp.com header.s=20150623 header.b=N5cq2X5s;
       spf=pass (google.com: domain of aik@ozlabs.ru designates 209.85.220.65 as permitted sender) smtp.mailfrom=aik@ozlabs.ru
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ozlabs-ru.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:openpgp:autocrypt:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=vLgUtLgd34YoqqCTxqxpLbSxwvGV3M2LzlOeHp/1Cec=;
        b=N5cq2X5sCawY7Z9049rLPwU2gWCT9rIbtsT0Gz4DPk13eQy0LpN2Tna59vDAwMCKzz
         yntDPC/U/AQk4gBrEMzkYjB7r5K+SY6B47c8qwbFaxDoj1bmL8XacFpGy0WTlr8q7xNO
         SuryBhMNYUt/Ak5gHuag3fv9upiLR/uTCvmuKpm4e1XxqFEnAXoJst7wRjvlw1rHW/JW
         3WuI/9UfWTZq9oC3gtgoTqofkQjoiCbCPcagQyPFlsjvgHy7ND/g9q5OZB8HZ6MXXBZC
         XG1XChwOHdsCuhnpSUrbwPVGVmLJKrxvYh8WofIgx35W/kgfETXtzT1hWmmhxl3oHJ/e
         9hlw==
X-Google-Smtp-Source: APXvYqxqG0xxpSvgFOlx2V/WqlpEOtxoiKjPS2ntAlHEUsHs+ZwOtWxQSUfVvqJLa+cBrl/pKYMGJg==
X-Received: by 2002:a63:5c1b:: with SMTP id q27mr104461120pgb.127.1558680200104;
        Thu, 23 May 2019 23:43:20 -0700 (PDT)
Received: from [10.61.2.175] ([122.99.82.10])
        by smtp.gmail.com with ESMTPSA id n27sm2608734pfb.129.2019.05.23.23.43.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 23:43:19 -0700 (PDT)
Subject: Re: [PATCH] mm: add account_locked_vm utility function
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: akpm@linux-foundation.org, Alan Tull <atull@kernel.org>,
 Alex Williamson <alex.williamson@redhat.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Christoph Lameter <cl@linux.com>, Christophe Leroy
 <christophe.leroy@c-s.fr>, Davidlohr Bueso <dave@stgolabs.net>,
 Jason Gunthorpe <jgg@mellanox.com>, Mark Rutland <mark.rutland@arm.com>,
 Michael Ellerman <mpe@ellerman.id.au>, Moritz Fischer <mdf@kernel.org>,
 Paul Mackerras <paulus@ozlabs.org>, Steve Sistare
 <steven.sistare@oracle.com>, Wu Hao <hao.wu@intel.com>, linux-mm@kvack.org,
 kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-fpga@vger.kernel.org, linux-kernel@vger.kernel.org
References: <20190503201629.20512-1-daniel.m.jordan@oracle.com>
 <4b42057f-b998-f87c-4e0f-a91abcb366f9@ozlabs.ru>
 <20190520153020.mzvjsjwefwxz6cau@ca-dmjordan1.us.oracle.com>
From: Alexey Kardashevskiy <aik@ozlabs.ru>
Openpgp: preference=signencrypt
Autocrypt: addr=aik@ozlabs.ru; keydata=
 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
Message-ID: <de375582-2c35-8e8a-4737-c816052a8e58@ozlabs.ru>
Date: Fri, 24 May 2019 16:43:10 +1000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190520153020.mzvjsjwefwxz6cau@ca-dmjordan1.us.oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 21/05/2019 01:30, Daniel Jordan wrote:
> On Mon, May 20, 2019 at 04:19:34PM +1000, Alexey Kardashevskiy wrote:
>> On 04/05/2019 06:16, Daniel Jordan wrote:
>>> locked_vm accounting is done roughly the same way in five places, so
>>> unify them in a helper.  Standardize the debug prints, which vary
>>> slightly.
>>
>> And I rather liked that prints were different and tell precisely which
>> one of three each printk is.
> 
> I'm not following.  One of three...callsites?  But there were five callsites.


Well, 3 of them are mine, I was referring to them :)


> Anyway, I added a _RET_IP_ to the debug print so you can differentiate.


I did not know that existed, cool!


> 
>> I commented below but in general this seems working.
>>
>> Tested-by: Alexey Kardashevskiy <aik@ozlabs.ru>
> 
> Thanks!  And for the review as well.
> 
>>> diff --git a/drivers/vfio/vfio_iommu_spapr_tce.c b/drivers/vfio/vfio_iommu_spapr_tce.c
>>> index 6b64e45a5269..d39a1b830d82 100644
>>> --- a/drivers/vfio/vfio_iommu_spapr_tce.c
>>> +++ b/drivers/vfio/vfio_iommu_spapr_tce.c
>>> @@ -34,49 +35,13 @@
>>>  static void tce_iommu_detach_group(void *iommu_data,
>>>  		struct iommu_group *iommu_group);
>>>  
>>> -static long try_increment_locked_vm(struct mm_struct *mm, long npages)
>>> +static int tce_account_locked_vm(struct mm_struct *mm, unsigned long npages,
>>> +				 bool inc)
>>>  {
>>> -	long ret = 0, locked, lock_limit;
>>> -
>>>  	if (WARN_ON_ONCE(!mm))
>>>  		return -EPERM;
>>
>>
>> If this WARN_ON is the only reason for having tce_account_locked_vm()
>> instead of calling account_locked_vm() directly, you can then ditch the
>> check as I have never ever seen this triggered.
> 
> Great, will do.
> 
>>> diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
>>> index d0f731c9920a..15ac76171ccd 100644
>>> --- a/drivers/vfio/vfio_iommu_type1.c
>>> +++ b/drivers/vfio/vfio_iommu_type1.c
>>> @@ -273,25 +273,14 @@ static int vfio_lock_acct(struct vfio_dma *dma, long npage, bool async)
>>>  		return -ESRCH; /* process exited */
>>>  
>>>  	ret = down_write_killable(&mm->mmap_sem);
>>> -	if (!ret) {
>>> -		if (npage > 0) {
>>> -			if (!dma->lock_cap) {
>>> -				unsigned long limit;
>>> -
>>> -				limit = task_rlimit(dma->task,
>>> -						RLIMIT_MEMLOCK) >> PAGE_SHIFT;
>>> -
>>> -				if (mm->locked_vm + npage > limit)
>>> -					ret = -ENOMEM;
>>> -			}
>>> -		}
>>> +	if (ret)
>>> +		goto out;
>>
>>
>> A single "goto" to jump just 3 lines below seems unnecessary.
> 
> No strong preference here, I'll take out the goto.
> 
>>> +int __account_locked_vm(struct mm_struct *mm, unsigned long pages, bool inc,
>>> +			struct task_struct *task, bool bypass_rlim)
>>> +{
>>> +	unsigned long locked_vm, limit;
>>> +	int ret = 0;
>>> +
>>> +	locked_vm = mm->locked_vm;
>>> +	if (inc) {
>>> +		if (!bypass_rlim) {
>>> +			limit = task_rlimit(task, RLIMIT_MEMLOCK) >> PAGE_SHIFT;
>>> +			if (locked_vm + pages > limit) {
>>> +				ret = -ENOMEM;
>>> +				goto out;
>>> +			}
>>> +		}
>>
>> Nit:
>>
>> if (!ret)
>>
>> and then you don't need "goto out".
> 
> Ok, sure.
> 
>>> +		mm->locked_vm = locked_vm + pages;
>>> +	} else {
>>> +		WARN_ON_ONCE(pages > locked_vm);
>>> +		mm->locked_vm = locked_vm - pages;
>>
>>
>> Can go negative here. Not a huge deal but inaccurate imo.
> 
> I hear you, but setting a negative value to zero, as we had done previously,
> doesn't make much sense to me.


Ok then. I have not seen these WARN_ON for a very long time anyway.


-- 
Alexey

