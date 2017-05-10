Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 939FF2808A3
	for <linux-mm@kvack.org>; Wed, 10 May 2017 11:24:04 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y106so9975675wrb.14
        for <linux-mm@kvack.org>; Wed, 10 May 2017 08:24:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m15si3854711wrm.44.2017.05.10.08.24.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 May 2017 08:24:03 -0700 (PDT)
Subject: Re: Question on ___GFP_NOLOCKDEP - Was: Re: [PATCH 1/1] Remove
 hardcoding of ___GFP_xxx bitmasks
References: <20170426133549.22603-1-igor.stoppa@huawei.com>
 <20170426133549.22603-2-igor.stoppa@huawei.com>
 <20170426144750.GH12504@dhcp22.suse.cz>
 <e3fe4d80-10a8-2008-1798-af3893fe418a@huawei.com>
 <9929419e-c22e-2a9f-a8a6-ad98d5a9da06@huawei.com>
 <20170427133523.GG4706@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0da15f82-bc01-64e8-94a6-d9a5745d3eb1@suse.cz>
Date: Wed, 10 May 2017 17:24:01 +0200
MIME-Version: 1.0
In-Reply-To: <20170427133523.GG4706@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Igor Stoppa <igor.stoppa@huawei.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: namhyung@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/27/2017 03:35 PM, Michal Hocko wrote:
> On Thu 27-04-17 15:16:47, Igor Stoppa wrote:
>> On 26/04/17 18:29, Igor Stoppa wrote:
>>
>>> On 26/04/17 17:47, Michal Hocko wrote:
>>
>> [...]
>>
>>>> Also the current mm tree has ___GFP_NOLOCKDEP which is not addressed
>>>> here so I suspect you have based your change on the Linus tree.
>>
>>> I used your tree from kernel.org
>>
>> I found it, I was using master, instead of auto-latest (is it correct?)
> 
> yes
> 
>> But now I see something that I do not understand (apologies if I'm
>> asking something obvious).
>>
>> First there is:
>>
>> [...]
>> #define ___GFP_WRITE		0x800000u
>> #define ___GFP_KSWAPD_RECLAIM	0x1000000u
>> #ifdef CONFIG_LOCKDEP
>> #define ___GFP_NOLOCKDEP	0x4000000u
>> #else
>> #define ___GFP_NOLOCKDEP	0
>> #endif
>>
>> Then:
>>
>> /* Room for N __GFP_FOO bits */
>> #define __GFP_BITS_SHIFT (25 + IS_ENABLED(CONFIG_LOCKDEP))
>>
>>
>>
>> Shouldn't it be either:
>> ___GFP_NOLOCKDEP	0x2000000u
> 
> Yes it should. At the time when this patch was written this value was
> used. Later I've removed __GFP_OTHER by 41b6167e8f74 ("mm: get rid of
> __GFP_OTHER_NODE") and forgot to refresh this one. Thanks for noticing
> this.
> 
> Andrew, could you fold the following in please?
> ---
> From 8dc9c917af215f659bb990fa48ae7b4753027c19 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Thu, 27 Apr 2017 15:28:10 +0200
> Subject: [PATCH] lockdep-allow-to-disable-reclaim-lockup-detection-fix
> 
> Igor Stoppa has noticed that __GFP_NOLOCKDEP can use a lower bit. At the
> time lockdep-allow-to-disable-reclaim-lockup-detection was written we
> still had __GFP_OTHER_NODE but I have removed it in 41b6167e8f74 ("mm:
> get rid of __GFP_OTHER_NODE") and forgot to lower the bit value.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Ping, I have noticed (at least in the mmotm-2017-05-08-16-30 git tag)
there's still 0x4000000u ?

> ---
>  include/linux/gfp.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 2b1a44f5bdb6..a89d37e8b387 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -41,7 +41,7 @@ struct vm_area_struct;
>  #define ___GFP_WRITE		0x800000u
>  #define ___GFP_KSWAPD_RECLAIM	0x1000000u
>  #ifdef CONFIG_LOCKDEP
> -#define ___GFP_NOLOCKDEP	0x4000000u
> +#define ___GFP_NOLOCKDEP	0x2000000u
>  #else
>  #define ___GFP_NOLOCKDEP	0
>  #endif
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
