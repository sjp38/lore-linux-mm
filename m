Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3800C468C0
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 04:22:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AC29205ED
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 04:22:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AC29205ED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB4D86B026F; Sat,  8 Jun 2019 00:22:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E3E7A6B0271; Sat,  8 Jun 2019 00:22:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDE8E6B0273; Sat,  8 Jun 2019 00:22:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9CE2D6B026F
	for <linux-mm@kvack.org>; Sat,  8 Jun 2019 00:22:28 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id z1so1919089oth.8
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 21:22:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=eeJY4hMhnpVgYhyzYdeQDYFsV639t8qyRowllY4LtdU=;
        b=QlWe/B3+SY3nYc+TTr3xRH87T7v/7dfz0BBSAYxlYFlxRZVSIOjHZls1Bnr728/4te
         vqhUtHNOBGtGPc+njFWFwMMNG5JujgmXKb0ik6Y/NbXZDMHfWTR6AEAG9cu5s2Ek1AA2
         P57RTxt9TPQXnTiUJG9GKplZJSu//ZZG+DBZwzQcca2Gnh+BC+aXHFNaPCbZs4m1aLQe
         TbHhzmgXTXJe34aOygMsKy2L1Tt7xEl9c9DLuTohHsMrCwxLr4VdTStUaUZx69D/6JmU
         E6e/vPkxj3yOcmcVXV/27lmTK4DbDDcQigI9x7F9AV/HCioZo1c7MZm/ZyBSRUj+8fxF
         gn3w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=guohanjun@huawei.com
X-Gm-Message-State: APjAAAXl74uV1pHfwO/0VjOi7P+QptXQN+OGNS7y5k47EjXe1K5OSR3z
	KMp1+Ytav+8z5ltZOexei2WcJo+zeubu1sKBb0HYp6R11WZeaqHAldsahakHcgLALFiIMFOFT3T
	u+ZfDqLFm68r33na6iNhnTFtkhMhOuc84Xvnbc0PPa8dGNEUFShjBbqCQ5/ZWY2jaBg==
X-Received: by 2002:aca:588a:: with SMTP id m132mr6050871oib.106.1559967748076;
        Fri, 07 Jun 2019 21:22:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypjKMudQHCXkbvbwWCsGyjLPwq49T2mZv1D/W1iStXJJunqytKIN6l8OIZ8mp0QTWgrwvZ
X-Received: by 2002:aca:588a:: with SMTP id m132mr6050840oib.106.1559967747219;
        Fri, 07 Jun 2019 21:22:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559967747; cv=none;
        d=google.com; s=arc-20160816;
        b=YWIfuLcuiP6j+ZARgo31LNkWXoAe7GoM+ecqrLsd9saOlaUs9aOh7Q6qYv82oeZk+2
         tshMTE9qLHGzJy3Hzy2uXpsVrfHn+L8BaNVO7UW3/e+8svs/TC4mFDNi3u2KZFVMaprn
         1rAH33i1e6ZeF8qpkZhscDgpOuIH5gUTAGcOSq0CBGH+oyRpZOL18Ccp0iuUVEDQECcF
         s2W6uhKRIJl7eAIrpKdDBIr5OYSGfQbUA4gwOOVAtMmO4uSJ4akAlCDz7tmcGRPn9lNF
         mcx5lPRb6O2U4Cs0/HYKqEyDSaJnzPROKivCNR17YvP2k9flYiHUE5dj3s9HDZprR+T+
         zr1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=eeJY4hMhnpVgYhyzYdeQDYFsV639t8qyRowllY4LtdU=;
        b=YLBY4teKPGW8ZGqnNjS4mDpFk+C24VFDbmfJODehEADxhi5iGyZhvHHBqwXBwWCCx7
         l1AkfDVRFDuaEsz9b0nuCwhS9uHAWGhnhwxj7gCgePO1LZx4Iu05fOZcTA//aao7Ix1k
         3KlvDVyhdz29hH+GBJb+CdjSUGzYtjV5MTdOYA+r7Y7XFAKVwlItPWWiJ3m0NzroRXwg
         3q6lQlmz72/PjML7cRaaIZ8Xedkn2QVkT5EruCQHMN0Vr5V92/qNXEoVlp/cWmkJRhla
         StLiZjG/7ccn/G+HFYZCbbm9jthoAZqrT1q2+ixo+MFNFmMaci3kkPj+n3OlZX2Cc/ui
         Nd0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=guohanjun@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id i7si2140153oih.171.2019.06.07.21.22.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 21:22:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of guohanjun@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=guohanjun@huawei.com
Received: from DGGEMS401-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id A743C53F4D0FF13F8075;
	Sat,  8 Jun 2019 12:22:23 +0800 (CST)
Received: from [127.0.0.1] (10.177.223.23) by DGGEMS401-HUB.china.huawei.com
 (10.3.19.201) with Microsoft SMTP Server id 14.3.439.0; Sat, 8 Jun 2019
 12:22:22 +0800
Subject: Re: [PATCH v11 0/3] remain and optimize memblock_next_valid_pfn on
 arm and arm64
To: Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@arm.com>
CC: Mark Rutland <mark.rutland@arm.com>, Michal Hocko <mhocko@suse.com>,
	Catalin Marinas <catalin.marinas@arm.com>, Wei Yang
	<richard.weiyang@gmail.com>, Linux-MM <linux-mm@kvack.org>, Jia He
	<hejianet@gmail.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Petr Tesarik
	<ptesarik@suse.com>, Nikolay Borisov <nborisov@suse.com>, Russell King
	<linux@armlinux.org.uk>, Daniel Jordan <daniel.m.jordan@oracle.com>, "AKASHI
 Takahiro" <takahiro.akashi@linaro.org>, Gioh Kim
	<gi-oh.kim@profitbricks.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Laura Abbott <labbott@redhat.com>, Daniel Vacek <neelx@redhat.com>, Mel
 Gorman <mgorman@suse.de>, "Vladimir Murzin" <vladimir.murzin@arm.com>, Kees
 Cook <keescook@chromium.org>, "Philip Derrin" <philip@cog.systems>, YASUAKI
 ISHIMATSU <yasu.isimatu@gmail.com>, "Jia He" <jia.he@hxt-semitech.com>, Kemi
 Wang <kemi.wang@intel.com>, "Vlastimil Babka" <vbabka@suse.cz>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Steve Capper
	<steve.capper@arm.com>, Linux Kernel Mailing List
	<linux-kernel@vger.kernel.org>, James Morse <james.morse@arm.com>, Johannes
 Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
References: <1534907237-2982-1-git-send-email-jia.he@hxt-semitech.com>
 <CAKv+Gu9u8RcrzSHdgXiqHS9HK1aSrjbPxVUSCP0DT4erAhx0pw@mail.gmail.com>
 <20180907144447.GD12788@arm.com>
From: Hanjun Guo <guohanjun@huawei.com>
Message-ID: <84b8e874-2a52-274c-4806-968470e66a08@huawei.com>
Date: Sat, 8 Jun 2019 12:22:13 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:52.0) Gecko/20100101
 Thunderbird/52.5.0
MIME-Version: 1.0
In-Reply-To: <20180907144447.GD12788@arm.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.223.23]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ard, Will,

This week we were trying to debug an issue of time consuming in mem_init(),
and leading to this similar solution form Jia He, so I would like to bring this
thread back, please see my detail test result below.

On 2018/9/7 22:44, Will Deacon wrote:
> On Thu, Sep 06, 2018 at 01:24:22PM +0200, Ard Biesheuvel wrote:
>> On 22 August 2018 at 05:07, Jia He <hejianet@gmail.com> wrote:
>>> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
>>> where possible") optimized the loop in memmap_init_zone(). But it causes
>>> possible panic bug. So Daniel Vacek reverted it later.
>>>
>>> But as suggested by Daniel Vacek, it is fine to using memblock to skip
>>> gaps and finding next valid frame with CONFIG_HAVE_ARCH_PFN_VALID.
>>>
>>> More from what Daniel said:
>>> "On arm and arm64, memblock is used by default. But generic version of
>>> pfn_valid() is based on mem sections and memblock_next_valid_pfn() does
>>> not always return the next valid one but skips more resulting in some
>>> valid frames to be skipped (as if they were invalid). And that's why
>>> kernel was eventually crashing on some !arm machines."
>>>
>>> About the performance consideration:
>>> As said by James in b92df1de5,
>>> "I have tested this patch on a virtual model of a Samurai CPU with a
>>> sparse memory map.  The kernel boot time drops from 109 to 62 seconds."
>>> Thus it would be better if we remain memblock_next_valid_pfn on arm/arm64.
>>>
>>> Besides we can remain memblock_next_valid_pfn, there is still some room
>>> for improvement. After this set, I can see the time overhead of memmap_init
>>> is reduced from 27956us to 13537us in my armv8a server(QDF2400 with 96G
>>> memory, pagesize 64k). I believe arm server will benefit more if memory is
>>> larger than TBs
>>>
>>
>> OK so we can summarize the benefits of this series as follows:
>> - boot time on a virtual model of a Samurai CPU drops from 109 to 62 seconds
>> - boot time on a QDF2400 arm64 server with 96 GB of RAM drops by ~15
>> *milliseconds*
>>
>> Google was not very helpful in figuring out what a Samurai CPU is and
>> why we should care about the boot time of Linux running on a virtual
>> model of it, and the 15 ms speedup is not that compelling either.

Testing this patch set on top of Kunpeng 920 based ARM64 server, with
384G memory in total, we got the time consuming below

             without this patch set      with this patch set
mem_init()        13310ms                      1415ms

So we got about 8x speedup on this machine, which is very impressive.

The time consuming is related the memory DIMM size and where to locate those
memory DIMMs in the slots. In above case, we are using 16G memory DIMM.
We also tested 1T memory with 64G size for each memory DIMM on another ARM64
machine, the time consuming reduced from 20s to 2s (I think it's related to
firmware implementations).

>>
>> Apologies to Jia that it took 11 revisions to reach this conclusion,
>> but in /my/ opinion, tweaking the fragile memblock/pfn handling code
>> for this reason is totally unjustified, and we're better off
>> disregarding these patches.

Indeed this patch set has a bug, For exampe, if we have 3 regions which
is [a, b] [c, d] [e, f] if address of pfn is bigger than the end address of
last region, we will increase early_region_idx to count of region, which is
out of bound of the regions. Fixed by patch below,

 mm/memblock.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index 8279295..8283bf0 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1252,13 +1252,17 @@ unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn)
 		if (pfn >= start_pfn && pfn < end_pfn)
 			return pfn;

-		early_region_idx++;
+		/* try slow path */
+		if (++early_region_idx == type->cnt)
+			goto slow_path;
+
 		next_start_pfn = PFN_DOWN(regions[early_region_idx].base);

 		if (pfn >= end_pfn && pfn <= next_start_pfn)
 			return next_start_pfn;
 	}

+slow_path:
 	/* slow path, do the binary searching */
 	do {
 		mid = (right + left) / 2;

As the really impressive speedup on our ARM64 server system, could you reconsider
this patch set for merge? if you want more data I'm willing to clarify and give
more test.

Thanks
Hanjun

