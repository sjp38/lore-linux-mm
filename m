Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 285998E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 12:39:02 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id u32so42895356qte.1
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 09:39:02 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r23sor49564805qtn.39.2019.01.03.09.39.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 09:39:00 -0800 (PST)
Subject: Re: [PATCH v3] mm/page_owner: fix for deferred struct page init
References: <20181220185031.43146-1-cai@lca.pw>
 <20181220203156.43441-1-cai@lca.pw> <20190103115114.GL31793@dhcp22.suse.cz>
 <e3ff1455-06cc-063e-24f0-3b525c345b84@lca.pw>
 <20190103165927.GU31793@dhcp22.suse.cz>
From: Qian Cai <cai@lca.pw>
Message-ID: <5d8f3a98-a954-c8ab-83d9-2f94c614f268@lca.pw>
Date: Thu, 3 Jan 2019 12:38:59 -0500
MIME-Version: 1.0
In-Reply-To: <20190103165927.GU31793@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, Pavel.Tatashin@microsoft.com, mingo@kernel.org, hpa@zytor.com, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, yang.shi@linaro.org, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 1/3/19 11:59 AM, Michal Hocko wrote:
>> As mentioned above, "If deselected DEFERRED_STRUCT_PAGE_INIT, it is still better
>> to call page_ext_init() earlier, so page owner could catch more early page
>> allocation call sites."
> 
> Do you have any numbers to show how many allocation are we losing that
> way? In other words, do we care enough to create an ugly code?

Well, I don't have any numbers, but I read that Joonsoo did not really like to
defer page_ext_init() unconditionally.

"because deferring page_ext_init() would make page owner which uses page_ext
miss some early page allocation callsites. Although it already miss some early
page allocation callsites, we don't need to miss more."

https://lore.kernel.org/lkml/20160524053714.GB32186@js1304-P5Q-DELUXE/

>>>> diff --git a/mm/page_ext.c b/mm/page_ext.c
>>>> index ae44f7adbe07..d76fd51e312a 100644
>>>> --- a/mm/page_ext.c
>>>> +++ b/mm/page_ext.c
>>>> @@ -399,9 +399,8 @@ void __init page_ext_init(void)
>>>>  			 * -------------pfn-------------->
>>>>  			 * N0 | N1 | N2 | N0 | N1 | N2|....
>>>>  			 *
>>>> -			 * Take into account DEFERRED_STRUCT_PAGE_INIT.
>>>>  			 */
>>>> -			if (early_pfn_to_nid(pfn) != nid)
>>>> +			if (pfn_to_nid(pfn) != nid)
>>>>  				continue;
>>>>  			if (init_section_page_ext(pfn, nid))
>>>>  				goto oom;
>>>
>>> Also this doesn't seem to be related, right?
>>
>> No, it is related. Because of this patch, page_ext_init() is called after all
>> the memory has already been initialized,
>> so no longer necessary to call early_pfn_to_nid().
> 
> Yes, but it looks like a follow up cleanup/optimization to me.

That early_pfn_to_nid() was introduced in fe53ca54270 (mm: use early_pfn_to_nid
in page_ext_init) which also messed up the order of page_ext_init() in
start_kernel(), so this patch basically revert that commit.
