Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id AE7208E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 13:37:10 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id w18so21415556qts.8
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 10:37:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n202sor49163114qkn.6.2019.01.21.10.37.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 Jan 2019 10:37:09 -0800 (PST)
Subject: Re: [PATCH] mm/hotplug: invalid PFNs from pfn_to_online_page()
References: <51e79597-21ef-3073-9036-cfc33291f395@lca.pw>
 <20190118021650.93222-1-cai@lca.pw> <20190121095352.GM4087@dhcp22.suse.cz>
 <1295f347-5a14-5b3b-23ef-2f001c25d980@lca.pw>
 <20190121181957.GX4087@dhcp22.suse.cz>
From: Qian Cai <cai@lca.pw>
Message-ID: <66167da5-f97d-df4e-4e95-35419a0b2928@lca.pw>
Date: Mon, 21 Jan 2019 13:37:08 -0500
MIME-Version: 1.0
In-Reply-To: <20190121181957.GX4087@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: akpm@linux-foundation.org, osalvador@suse.de, catalin.marinas@arm.com, vbabka@suse.cz, linux-mm@kvack.org



On 1/21/19 1:19 PM, Michal Hocko wrote:
> On Mon 21-01-19 11:38:49, Qian Cai wrote:
>>
>>
>> On 1/21/19 4:53 AM, Michal Hocko wrote:
>>> On Thu 17-01-19 21:16:50, Qian Cai wrote:
> [...]
>>>> Fixes: 2d070eab2e82 ("mm: consider zone which is not fully populated to
>>>> have holes")
>>>
>>> Did you mean 
>>> Fixes: 9f1eb38e0e11 ("mm, kmemleak: little  optimization while scanning")
>>
>> No, pfn_to_online_page() missed a few checks compared to pfn_valid() at least on
>> arm64 where the returned pfn is no longer valid (where pfn_valid() will skip those).
>>
>> 2d070eab2e82 introduced pfn_to_online_page(), so it was targeted to fix it.
> 
> But it is 9f1eb38e0e11 which has replaced pfn_valid by
> pfn_to_online_page.

Well, the comment of pfn_to_online_page() said,

/*
 * Return page for the valid pfn only if the page is online.
 * All pfn walkers which rely on the fully initialized
 * page->flags and others should use this rather than
 * pfn_valid && pfn_to_page
 */

That seems incorrect to me in the first place, as it currently not return "fully
initialized page->flags" pages in arm64.

Once this fixed, there is no problem with 9f1eb38e0e11. It seems to me
9f1eb38e0e11 just depends on a broken interface, so it is better to fix the
broken interface.

> 
>>
>>>
>>>> Signed-off-by: Qian Cai <cai@lca.pw>
>>>> ---
>>>>  include/linux/memory_hotplug.h | 2 +-
>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
>>>> index 07da5c6c5ba0..b8b36e6ac43b 100644
>>>> --- a/include/linux/memory_hotplug.h
>>>> +++ b/include/linux/memory_hotplug.h
>>>> @@ -26,7 +26,7 @@ struct vmem_altmap;
>>>>  	struct page *___page = NULL;			\
>>>>  	unsigned long ___nr = pfn_to_section_nr(pfn);	\
>>>>  							\
>>>> -	if (___nr < NR_MEM_SECTIONS && online_section_nr(___nr))\
>>>> +	if (online_section_nr(___nr) && pfn_valid(pfn))	\
>>>>  		___page = pfn_to_page(pfn);		\
>>>
>>> Why have you removed the bound check? Is this safe?
>>> Regarding the fix, I am not really sure TBH. If the secion is online
>>> then we assume all struct pages to be initialized. If anything this
>>> should be limited to werid arches which might have holes so
>>> pfn_valid_within().
>>
>> It looks to me at least on arm64 and x86_64, it has done this check in
>> pfn_valid() already.
>>
>> if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
>> 		return 0
> 
> But an everflow could happen before pfn_valid is evaluated, no?
> 

I guess you mean "overflow". I'll probably keep that check and use
pfn_valid_within() anyway, so I could optimize the checking if
CONFIG_HOLES_IN_ZONE=n.
