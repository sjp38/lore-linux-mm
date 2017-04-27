Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 096EA6B0038
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 14:03:37 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id l198so14292342ybl.16
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:03:37 -0700 (PDT)
Received: from mail-qt0-x244.google.com (mail-qt0-x244.google.com. [2607:f8b0:400d:c0d::244])
        by mx.google.com with ESMTPS id p66si1375362ywh.354.2017.04.27.11.03.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 11:03:36 -0700 (PDT)
Received: by mail-qt0-x244.google.com with SMTP id o36so5445169qtb.2
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 11:03:36 -0700 (PDT)
Subject: Re: [PATCH v2 1/3] mm: Silence vmap() allocation failures based on
 caller gfp_flags
References: <20170427173900.2538-1-f.fainelli@gmail.com>
 <20170427173900.2538-2-f.fainelli@gmail.com>
 <20170427175653.GB30672@dhcp22.suse.cz>
From: Florian Fainelli <f.fainelli@gmail.com>
Message-ID: <416a788c-6160-1ce8-fccc-839f719b2a88@gmail.com>
Date: Thu, 27 Apr 2017 11:03:31 -0700
MIME-Version: 1.0
In-Reply-To: <20170427175653.GB30672@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-arm-kernel@lists.infradead.org, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, zijun_hu <zijun_hu@htc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Chris Wilson <chris@chris-wilson.co.uk>, open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, angus@angusclark.org

On 04/27/2017 10:56 AM, Michal Hocko wrote:
> On Thu 27-04-17 10:38:58, Florian Fainelli wrote:
>> If the caller has set __GFP_NOWARN don't print the following message:
>> vmap allocation for size 15736832 failed: use vmalloc=<size> to increase
>> size.
>>
>> This can happen with the ARM/Linux or ARM64/Linux module loader built
>> with CONFIG_ARM{,64}_MODULE_PLTS=y which does a first attempt at loading
>> a large module from module space, then falls back to vmalloc space.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> just a nit
> 
>> ---
>>  mm/vmalloc.c | 4 ++++
>>  1 file changed, 4 insertions(+)
>>
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index 0b057628a7ba..d8a851634674 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -521,9 +521,13 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
>>  		}
>>  	}
>>  
>> +	if (gfp_mask & __GFP_NOWARN)
>> +		goto out;
>> +
>>  	if (printk_ratelimit())
> 
> 	if (!(gfp_mask & __GFP_NOWARN) && printk_ratelimit())
>>  		pr_warn("vmap allocation for size %lu failed: use vmalloc=<size> to increase size\n",
>>  			size);
> 
> would be shorter and you wouldn't need the goto and a label.

Do you want me to resubmit with that change included?
-- 
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
