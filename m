Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EE73C76192
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 19:01:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8347C20665
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 19:01:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8347C20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01FCF6B0003; Tue, 16 Jul 2019 15:01:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F14478E0003; Tue, 16 Jul 2019 15:01:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDAC68E0001; Tue, 16 Jul 2019 15:01:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A5C5D6B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 15:01:30 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i2so12911800pfe.1
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 12:01:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=M6LW3IXaou+CfScndyVpe4DMuCkaGK9y/FO6AqMsF6U=;
        b=Hi2eezNYwLfS8J50492vufUHw3SW4Jh3xL8EB4DmHYoP2e0LTTvoIYMk6OP5uzTKDB
         f/fChiWxOqZrz+TQU2cc90QBE8awziVnMh8WYoQC/UTbF+VM94YLqf9ksKFYiWHGAtvE
         rXJmXYwJsHWW6I238W2JCdYwTH6PDEtJXeLaCh10U0sVW5RfsJTTo7imAzdlxm789A5b
         ZLCC4lG6Yo3HE+JhA4Zi53kSblEKGJ93RNVo2pI0nQQZS3HWQ9lCat/XjNgb5vakkUIL
         ZGQyVtvwkIrC42Rk1FYQY5q38le03Q23OcodMuyKBWF6dJPmtKYhrGJSAGOuwqaDrP50
         ccpw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXEaeX019foQu9narENjRswLAxC89ahj3dybq8plsg8kmvDQoTV
	fw+V9MGAgmYPV1s9M33RzK6m+9LlFeiYNp0TNzZApqNbeLQGD7WHxWKHQOJhWuPU25ixhFFX3p7
	FvLSwm627dA1V+59AafzwW5LVcJSP9xwDxRpwubgFnG0Ure9p09HP5MneMZcKtfnHDw==
X-Received: by 2002:a17:902:b48f:: with SMTP id y15mr38416813plr.268.1563303690228;
        Tue, 16 Jul 2019 12:01:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztjehIanltL5kPd4a58uI7HMZzoVIe5pGSBSKDvZDIujiBDOEDm03d5LQVSGpoaFOWXHu/
X-Received: by 2002:a17:902:b48f:: with SMTP id y15mr38416711plr.268.1563303689243;
        Tue, 16 Jul 2019 12:01:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563303689; cv=none;
        d=google.com; s=arc-20160816;
        b=xlLCFs30/d+5VCC7f5+iELWzRKIosjIQAJkrwKuotpK0CVoEmqEBrrPeWFQAm/pYR7
         HOQWMc1EnWUrq9XM93Vaph32gTDsSp2DiUfeTWtcU4mgeIZOZw7xOxyGcaak6OnIYwia
         acQPfg2uQ83kRAEMbBhHGra25RXxQ9HbZQ9U9yckgFP0i44yNpEFJkw9zQSI2zVbLx3R
         mHwqV3SqpnJ+j9IcruliSuxRzxEmviB72N7KQDlAmLYF/GWeE/tGsHPE22N1J0fze0la
         8r1uD/7jgUe+SiVk2NL1qrlDEzCdC08b8Nv5GNJTkwcskLFlJES9N6EspLK/x4XWTP0A
         FCSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=M6LW3IXaou+CfScndyVpe4DMuCkaGK9y/FO6AqMsF6U=;
        b=Bbtb8GQNsHWvU5Rvuy+sjoDfhEZxuKPp6NKJpGNYce0CMfNPZ2pJdjDYfgy5q3uD0d
         R4sHC9cJ9J+0XcSxWLImpvLrBF176hSz1P5M3OslcYhIeJ6Qa5fkptk0Xzvq3+znSJUR
         z8aORm18ia0zyysDpyGuiQSIeWmWwKzLHxX7jfGNgLEXYoRjavFZR8q6EYbgSQSe7TPG
         IfC+8HYWcWAtcG0raMXbUjxeQITZK42XSfE8Ovj5hYz2ZcqL/xYg0t//aWjXzOe4dJEL
         t4rxPwZtiZ+Yj0b+yYBUExXLIts/620F4/K64pZZziv/0T6+rJ0nWdAKaUDxxR9CWFS8
         1rUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id s24si16095838pfh.227.2019.07.16.12.01.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 12:01:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R101e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04423;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=9;SR=0;TI=SMTPD_---0TX4SjWv_1563303683;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TX4SjWv_1563303683)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 17 Jul 2019 03:01:26 +0800
Subject: Re: [PATCH] Revert "kmemleak: allow to coexist with fault injection"
To: Qian Cai <cai@lca.pw>, catalin.marinas@arm.com, mhocko@suse.com,
 dvyukov@google.com, rientjes@google.com, willy@infradead.org,
 akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1563299431-111710-1-git-send-email-yang.shi@linux.alibaba.com>
 <1563301410.4610.8.camel@lca.pw>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <a198d00d-d1f4-0d73-8eb8-6667c0bdac04@linux.alibaba.com>
Date: Tue, 16 Jul 2019 12:01:22 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <1563301410.4610.8.camel@lca.pw>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/16/19 11:23 AM, Qian Cai wrote:
> On Wed, 2019-07-17 at 01:50 +0800, Yang Shi wrote:
>> When running ltp's oom test with kmemleak enabled, the below warning was
>> triggerred since kernel detects __GFP_NOFAIL & ~__GFP_DIRECT_RECLAIM is
>> passed in:
>>
>> WARNING: CPU: 105 PID: 2138 at mm/page_alloc.c:4608
>> __alloc_pages_nodemask+0x1c31/0x1d50
>> Modules linked in: loop dax_pmem dax_pmem_core ip_tables x_tables xfs
>> virtio_net net_failover virtio_blk failover ata_generic virtio_pci virtio_ring
>> virtio libata
>> CPU: 105 PID: 2138 Comm: oom01 Not tainted 5.2.0-next-20190710+ #7
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.10.2-0-
>> g5f4c7b1-prebuilt.qemu-project.org 04/01/2014
>> RIP: 0010:__alloc_pages_nodemask+0x1c31/0x1d50
>> ...
>>   kmemleak_alloc+0x4e/0xb0
>>   kmem_cache_alloc+0x2a7/0x3e0
>>   ? __kmalloc+0x1d6/0x470
>>   ? ___might_sleep+0x9c/0x170
>>   ? mempool_alloc+0x2b0/0x2b0
>>   mempool_alloc_slab+0x2d/0x40
>>   mempool_alloc+0x118/0x2b0
>>   ? __kasan_check_read+0x11/0x20
>>   ? mempool_resize+0x390/0x390
>>   ? lock_downgrade+0x3c0/0x3c0
>>   bio_alloc_bioset+0x19d/0x350
>>   ? __swap_duplicate+0x161/0x240
>>   ? bvec_alloc+0x1b0/0x1b0
>>   ? do_raw_spin_unlock+0xa8/0x140
>>   ? _raw_spin_unlock+0x27/0x40
>>   get_swap_bio+0x80/0x230
>>   ? __x64_sys_madvise+0x50/0x50
>>   ? end_swap_bio_read+0x310/0x310
>>   ? __kasan_check_read+0x11/0x20
>>   ? check_chain_key+0x24e/0x300
>>   ? bdev_write_page+0x55/0x130
>>   __swap_writepage+0x5ff/0xb20
>>
>> The mempool_alloc_slab() clears __GFP_DIRECT_RECLAIM, however kmemleak has
>> __GFP_NOFAIL set all the time due to commit
>> d9570ee3bd1d4f20ce63485f5ef05663866fe6c0 ("kmemleak: allow to coexist
>> with fault injection").  But, it doesn't make any sense to have
>> __GFP_NOFAIL and ~__GFP_DIRECT_RECLAIM specified at the same time.
>>
>> According to the discussion on the mailing list, the commit should be
>> reverted for short term solution.  Catalin Marinas would follow up with a
>> better
>> solution for longer term.
>>
>> The failure rate of kmemleak metadata allocation may increase in some
>> circumstances, but this should be expected side effect.
> As mentioned in anther thread, the situation for kmemleak under memory pressure
> has already been unhealthy. I don't feel comfortable to make it even worse by
> reverting this commit alone. This could potentially make kmemleak kill itself
> easier and miss some more real memory leak later.
>
> To make it really a short-term solution before the reverting, I think someone
> needs to follow up with the mempool solution with tunable pool size mentioned
> in,
>
> https://lore.kernel.org/linux-mm/20190328145917.GC10283@arrakis.emea.arm.com/
>
> I personally not very confident that Catalin will find some time soon to
> implement embedding kmemleak metadata into the slab. Even he or someone does
> eventually, it probably need quite some time to test and edge out many of corner
> cases that kmemleak could have by its natural.

Thanks for sharing some background. I didn't notice this topic had been 
discussed. I'm not sure if this revert would make things worse since I'm 
supposed real memory leak would be detected sooner before oom kicks in, 
and kmemleak is already broken with __GFP_NOFAIL.

It seems everyone agree __GFP_NPFAIL should be removed? Anyway, I would 
like leave the decision to Catalin.

>
>> Suggested-by: Catalin Marinas <catalin.marinas@arm.com>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Dmitry Vyukov <dvyukov@google.com>
>> Cc: David Rientjes <rientjes@google.com>
>> Cc: Matthew Wilcox <willy@infradead.org>
>> Cc: Qian Cai <cai@lca.pw>
>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>> ---
>>   mm/kmemleak.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
>> index 9dd581d..884a5e3 100644
>> --- a/mm/kmemleak.c
>> +++ b/mm/kmemleak.c
>> @@ -114,7 +114,7 @@
>>   /* GFP bitmask for kmemleak internal allocations */
>>   #define gfp_kmemleak_mask(gfp)	(((gfp) & (GFP_KERNEL | GFP_ATOMIC)) |
>> \
>>   				 __GFP_NORETRY | __GFP_NOMEMALLOC | \
>> -				 __GFP_NOWARN | __GFP_NOFAIL)
>> +				 __GFP_NOWARN)
>>   
>>   /* scanning area inside a memory block */
>>   struct kmemleak_scan_area {

