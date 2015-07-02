Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 91309280246
	for <linux-mm@kvack.org>; Thu,  2 Jul 2015 13:07:19 -0400 (EDT)
Received: by igcsj18 with SMTP id sj18so167364239igc.1
        for <linux-mm@kvack.org>; Thu, 02 Jul 2015 10:07:19 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id e16si2897672igo.1.2015.07.02.10.07.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jul 2015 10:07:18 -0700 (PDT)
Received: by igcsj18 with SMTP id sj18so167364022igc.1
        for <linux-mm@kvack.org>; Thu, 02 Jul 2015 10:07:18 -0700 (PDT)
Message-ID: <55956FC4.9070405@gmail.com>
Date: Thu, 02 Jul 2015 13:07:16 -0400
From: nick <xerofoify@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm:Make the function zap_huge_pmd bool
References: <1435775277-27381-1-git-send-email-xerofoify@gmail.com> <20150702072621.GB12547@dhcp22.suse.cz> <20150702160341.GC9456@thunk.org> <55956204.2060006@gmail.com>
In-Reply-To: <55956204.2060006@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, sasha.levin@oracle.com, Yalin.Wang@sonymobile.com, jmarchan@redhat.com, kirill@shutemov.name, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, ebru.akagunduz@gmail.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org



On 2015-07-02 12:08 PM, nick wrote:
> 
> 
> On 2015-07-02 12:03 PM, Theodore Ts'o wrote:
>> On Thu, Jul 02, 2015 at 09:26:21AM +0200, Michal Hocko wrote:
>>> On Wed 01-07-15 14:27:57, Nicholas Krause wrote:
>>>> This makes the function zap_huge_pmd have a return type of bool
>>>> now due to this particular function always returning one or zero
>>>> as its return value.
>>>
>>> How does this help anything? IMO this just generates a pointless churn
>>> in the code without a good reason.
>>
>> Hi Michal,
>>
>> My recommendation is to ignore patches sent by Nick.  In my experience
>> he doesn't understand code before trying to make mechanical changes,
>> and very few of his patches add any new value, and at least one that
>> he tried to send me just 2 weeks or so ago (cherry-picked to try to
>> "prove" why he had turned over a new leaf, so that I would support the
>> removal of his e-mail address from being blacklisted on
>> vger.kernel.org) was buggy, and when I asked him some basic questions
>> about what the code was doing, it was clear he had no clue how the
>> seq_file abstraction worked.  This didn't stop him from trying to
>> patch the code, and if he had tested it, it would have crashed and
>> burned instantly.
>>
>> Of course, do whatevery you want, but IMHO it's not really not worth
>> your time to deal with his patches, and if you reply, most people
>> won't see his original e-mail since the vger.kernel.org blacklist is
>> still in effect.
>>
>> Regards,
>>
>> 						- Ted
>>
> Ted,
> I looked into that patch further and would were correct it was wrong.
> However here is a bug fix for the drm driver code that somebody else
> stated was right but haven gotten a reply to from the maintainer and
> have tried resending.
> Nick
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
Ted,
Here are some other patches from this week and before that may be more useful then the ones applied/
acknowledged.
Nick
