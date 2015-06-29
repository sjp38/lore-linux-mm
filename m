Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 873126B0032
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 11:50:29 -0400 (EDT)
Received: by iecuq6 with SMTP id uq6so18597216iec.2
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 08:50:29 -0700 (PDT)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com. [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id 30si24293786ios.82.2015.06.29.08.50.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jun 2015 08:50:29 -0700 (PDT)
Received: by igcur8 with SMTP id ur8so40368328igc.0
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 08:50:29 -0700 (PDT)
Message-ID: <55916943.50402@gmail.com>
Date: Mon, 29 Jun 2015 11:50:27 -0400
From: nick <xerofoify@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm:Make the function alloc_mem_cgroup_per_zone_info bool
References: <1435587233-27976-1-git-send-email-xerofoify@gmail.com> <20150629150311.GC4612@dhcp22.suse.cz> <3320C010-248A-4296-A5E4-30D9E7B3E611@gmail.com> <20150629153623.GC4617@dhcp22.suse.cz> <559167D8.80803@gmail.com>
In-Reply-To: <559167D8.80803@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: hannes@cmpxchg.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 2015-06-29 11:44 AM, nick wrote:
> 
> 
> On 2015-06-29 11:36 AM, Michal Hocko wrote:
>> On Mon 29-06-15 11:23:08, Nicholas Krause wrote:
>> [...]
>>> I agree with and looked into the callers about this wasn't sure if you
>>> you wanted me to return - ENOMEM.  I will rewrite this patch the other
>>> way. 
>>
>> I am not sure this path really needs a cleanup.
>>
>>> Furthermore I apologize about this and do have actual useful
>>> patches but will my rep it's hard to get replies from maintainers.
>>
>> You can hardly expect somebody will be thrilled about your patches when
>> their fault rate is close to 100%. Reviewing each patch takes time and
>> that is a scarce resource. If you want people to follow your patches
>> make sure you are offering something that might be interesting or
>> useful. Cleanups like these usually are not interesting without
>> either building something bigger on top of them or when they improve
>> readability considerably.
>>
>> [...]
>>
> Actually my patch record is much better now it's at the worst case 60% are correct and 40 % are not
> and this based on the few that have been merged. Here is a patch series I have been trying to merge
> for a bug in the gma500 other the last few patches. There are other patches I have like this lying
> around.
> Nick 
> 
> From 2d2ddb5d9a2c4fcbae45339d4f775fcde49f36e1 Mon Sep 17 00:00:00 2001
> From: Nicholas Krause <xerofoify@gmail.com>
> Date: Wed, 13 May 2015 21:36:44 -0400
> Subject: [PATCH 1/2] gma500:Add proper use of the variable ret for the
>  function, psb_mmu_inset_pfn_sequence
> 
> This adds proper use of the variable ret by returning it
> at the end of the function, psb_mmu_inset_pfn_sequence for
> indicating to callers when an error has occurred. Further
> more remove the unneeded double setting of ret to the error
> code, -ENOMEM after checking if a call to the function,
> psb_mmu_pt_alloc_map_lock is successful.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
>  drivers/gpu/drm/gma500/mmu.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/gpu/drm/gma500/mmu.c b/drivers/gpu/drm/gma500/mmu.c
> index 0eaf11c..d2c4bac 100644
> --- a/drivers/gpu/drm/gma500/mmu.c
> +++ b/drivers/gpu/drm/gma500/mmu.c
> @@ -677,10 +677,9 @@ int psb_mmu_insert_pfn_sequence(struct psb_mmu_pd *pd, uint32_t start_pfn,
>  	do {
>  		next = psb_pd_addr_end(addr, end);
>  		pt = psb_mmu_pt_alloc_map_lock(pd, addr);
> -		if (!pt) {
> -			ret = -ENOMEM;
> +		if (!pt)
>  			goto out;
> -		}
> +
>  		do {
>  			pte = psb_mmu_mask_pte(start_pfn++, type);
>  			psb_mmu_set_pte(pt, addr, pte);
> @@ -700,7 +699,7 @@ out:
>  	if (pd->hw_context != -1)
>  		psb_mmu_flush(pd->driver);
>  
> -	return 0;
> +	return ret;
>  }
>  
>  int psb_mmu_insert_pages(struct psb_mmu_pd *pd, struct page **pages,
> 
Sorry the second patch in the drm was the wrong one this was another patch I am lying around.
Below is the actual second patch for the bug fix.
Nick
