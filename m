Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A72AC4646D
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 14:09:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5919421721
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 14:09:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5919421721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E84A28E0005; Mon,  1 Jul 2019 10:09:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5C8C8E0002; Mon,  1 Jul 2019 10:09:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D97FB8E0005; Mon,  1 Jul 2019 10:09:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f77.google.com (mail-ed1-f77.google.com [209.85.208.77])
	by kanga.kvack.org (Postfix) with ESMTP id 8ED3D8E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 10:09:50 -0400 (EDT)
Received: by mail-ed1-f77.google.com with SMTP id l26so16965075eda.2
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 07:09:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=A81OVS1KDh7qO0tzRmGTsGOsFereGYPuzxYasHMR3R4=;
        b=UOPx+M8oLAhlL0cgW1yYLvgkmkhmAOEDyM3Iw2EEQqKQxCQaX+GF5bSTwLzm4JIR9J
         tIR9ALo3C5CAvLoUK/Sj0sr3NKL+RnU0XlXVh1fBExW0PEn5YuefPM97MTaHWuApp5Fq
         PdZ+l58pRE1uH2C3dM0i9qwaDZ2w/TO5UQiffH1kE+/WQqE8sbIfHS0eERiAi/FroSDD
         XGFwsjFjMPa0QBru4jv9AqmiwbyopkYfcmV5KuiJpkzbRjDrngkXTEhuHYpDsRUbS0FG
         khSMOIfW+F0xFFqswqoExCLnvXKn2CeeJrtILvy14HdOYtJPmRRwCrKuzKJEFhJFJBSt
         e7jA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAWZhpyBpsSZh9A+3c+MpQkXdZHl1CT9DnmBp6bL99TGwWPancea
	Kva/TDvLLd+VeE2xg+akjl5cSowfO9lpC+ENPd0q2i4ALvuuuGO1yMvwbBMZyc+0Pk22lC0qLo1
	CNGjgDcpeGiGhM6DkXraBZYEknG4OTM3iS9gjLyYHkmIjdS1juxzCLDyrHvK/UkrNwQ==
X-Received: by 2002:a17:906:3419:: with SMTP id c25mr5060305ejb.305.1561990190133;
        Mon, 01 Jul 2019 07:09:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwL4nC/fgJw8kkqzUTw6GN1ipcTL2UGDY54fPtPCUgC7qtRpL5KEV95GV68X+gLQANAnp0
X-Received: by 2002:a17:906:3419:: with SMTP id c25mr5060225ejb.305.1561990189320;
        Mon, 01 Jul 2019 07:09:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561990189; cv=none;
        d=google.com; s=arc-20160816;
        b=jO1x6gooRdpqDoeC18T3rkMb80kBn0uIcvROAI9zfM2vH+1ijce9Edom1036Dk3Vhm
         CEqgHAd5+2mVPazJkBpz4hyz4XYEgg562nJ1A0lwk0RxfSSnYTAwJp3IB3EHlD8H/t0J
         QN10T5LF5tEHqfWoITA8MDBstHExsfe7uyIzA6bdMLiywlRfp7v77ZRabGLtAwgA2aZo
         htB6ctr5oTtG3YSw1ng1QvQFVxwGPi7m4/WxE5U+yjfwMD9WY2SUsDzZYlMIqXgx5oCI
         O5Ypk0DWWuQfdF3w5eg+gMCDJNY5Gt6qwqdl6EP9Fc9RMKpkeqkUFH1TyvOPymPm7dAR
         MBew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=A81OVS1KDh7qO0tzRmGTsGOsFereGYPuzxYasHMR3R4=;
        b=GWQfbZqazC2WjemCdxucinX9wJsS7dm7Sn+314rHFsVHy5bkT0fj9bs/usURgOHBgE
         EZBdD2037FHKFr7sUKS+XktyxQAzGT71niXWRebLghSpQ/Qh/yZ2F548/hUu4qWRWAJx
         KJYmepZglyLHw9OD4SnDtQ1h+sPg7PaoUBD4Gcygm1GLTuVzpdZUakmVOY0oRvk8Xxs7
         OoGJ5POlxYMpuq4OWZrQ7G8r1B4rO8jUEV9LRMhw02ufQTWZY5JNy+acnPsL2NJCfanS
         SkDGNQcXy+jUtqD072D+WVh5Oe6gys66HGOeBK/ew0vl/4O4ynaixCq66TMrZa6yomJz
         GD7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id p12si9905521eda.385.2019.07.01.07.09.49
        for <linux-mm@kvack.org>;
        Mon, 01 Jul 2019 07:09:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 75D6E344;
	Mon,  1 Jul 2019 07:09:48 -0700 (PDT)
Received: from [10.1.197.57] (e110467-lin.cambridge.arm.com [10.1.197.57])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 82FB63F246;
	Mon,  1 Jul 2019 07:09:47 -0700 (PDT)
Subject: Re: DMA-API attr - DMA_ATTR_NO_KERNEL_MAPPING
To: Pankaj Suryawanshi <pankajssuryawanshi@gmail.com>,
 Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, iommu@lists.linux-foundation.org,
 linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>,
 Michal Hocko <mhocko@kernel.org>
References: <CACDBo564RoWpi8y2pOxoddnn0s3f3sA-fmNxpiXuxebV5TFBJA@mail.gmail.com>
 <CACDBo55GfomD4yAJ1qaOvdm8EQaD-28=etsRHb39goh+5VAeqw@mail.gmail.com>
 <20190626175131.GA17250@infradead.org>
 <CACDBo56fNVxVyNEGtKM+2R0X7DyZrrHMQr6Yw4NwJ6USjD5Png@mail.gmail.com>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <c9fe4253-5698-a226-c643-32a21df8520a@arm.com>
Date: Mon, 1 Jul 2019 15:09:46 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CACDBo56fNVxVyNEGtKM+2R0X7DyZrrHMQr6Yw4NwJ6USjD5Png@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 28/06/2019 17:29, Pankaj Suryawanshi wrote:
> On Wed, Jun 26, 2019 at 11:21 PM Christoph Hellwig <hch@infradead.org> wrote:
>>
>> On Wed, Jun 26, 2019 at 10:12:45PM +0530, Pankaj Suryawanshi wrote:
>>> [CC: linux kernel and Vlastimil Babka]
>>
>> The right list is the list for the DMA mapping subsystem, which is
>> iommu@lists.linux-foundation.org.  I've also added that.
>>
>>>> I am writing driver in which I used DMA_ATTR_NO_KERNEL_MAPPING attribute
>>>> for cma allocation using dma_alloc_attr(), as per kernel docs
>>>> https://www.kernel.org/doc/Documentation/DMA-attributes.txt  buffers
>>>> allocated with this attribute can be only passed to user space by calling
>>>> dma_mmap_attrs().
>>>>
>>>> how can I mapped in kernel space (after dma_alloc_attr with
>>>> DMA_ATTR_NO_KERNEL_MAPPING ) ?
>>
>> You can't.  And that is the whole point of that API.
> 
> 1. We can again mapped in kernel space using dma_remap() api , because
> when we are using  DMA_ATTR_NO_KERNEL_MAPPING for dma_alloc_attr it
> returns the page as virtual address(in case of CMA) so we can mapped
> it again using dma_remap().

No, you really can't. A caller of dma_alloc_attrs(..., 
DMA_ATTR_NO_KERNEL_MAPPING) cannot make any assumptions about the void* 
it returns, other than that it must be handed back to dma_free_attrs() 
later. The implementation is free to ignore the flag and give back a 
virtual mapping anyway. Any driver which depends on how one particular 
implementation on one particular platform happens to behave today is, 
essentially, wrong.

> 2. We can mapped in kernel space using vmap() as used for ion-cma
> https://github.com/torvalds/linux/tree/master/drivers/staging/android/ion
>   as used in function ion_heap_map_kernel().
> 
> Please let me know if i am missing anything.

If you want a kernel mapping, *don't* explicitly request not to have a 
kernel mapping in the first place. It's that simple.

Robin.

