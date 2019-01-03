Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 988358E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 14:07:20 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id y35so34236525edb.5
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 11:07:20 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c20si455595edj.234.2019.01.03.11.07.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 11:07:19 -0800 (PST)
Date: Thu, 3 Jan 2019 20:07:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm/page_owner: fix for deferred struct page init
Message-ID: <20190103190715.GZ31793@dhcp22.suse.cz>
References: <20181220185031.43146-1-cai@lca.pw>
 <20181220203156.43441-1-cai@lca.pw>
 <20190103115114.GL31793@dhcp22.suse.cz>
 <e3ff1455-06cc-063e-24f0-3b525c345b84@lca.pw>
 <20190103165927.GU31793@dhcp22.suse.cz>
 <5d8f3a98-a954-c8ab-83d9-2f94c614f268@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5d8f3a98-a954-c8ab-83d9-2f94c614f268@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, Pavel.Tatashin@microsoft.com, mingo@kernel.org, hpa@zytor.com, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, yang.shi@linaro.org, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 03-01-19 12:38:59, Qian Cai wrote:
> On 1/3/19 11:59 AM, Michal Hocko wrote:
> >> As mentioned above, "If deselected DEFERRED_STRUCT_PAGE_INIT, it is still better
> >> to call page_ext_init() earlier, so page owner could catch more early page
> >> allocation call sites."
> > 
> > Do you have any numbers to show how many allocation are we losing that
> > way? In other words, do we care enough to create an ugly code?
> 
> Well, I don't have any numbers, but I read that Joonsoo did not really like to
> defer page_ext_init() unconditionally.
> 
> "because deferring page_ext_init() would make page owner which uses page_ext
> miss some early page allocation callsites. Although it already miss some early
> page allocation callsites, we don't need to miss more."

This is quite unspecific.

> https://lore.kernel.org/lkml/20160524053714.GB32186@js1304-P5Q-DELUXE/
> 
> >>>> diff --git a/mm/page_ext.c b/mm/page_ext.c
> >>>> index ae44f7adbe07..d76fd51e312a 100644
> >>>> --- a/mm/page_ext.c
> >>>> +++ b/mm/page_ext.c
> >>>> @@ -399,9 +399,8 @@ void __init page_ext_init(void)
> >>>>  			 * -------------pfn-------------->
> >>>>  			 * N0 | N1 | N2 | N0 | N1 | N2|....
> >>>>  			 *
> >>>> -			 * Take into account DEFERRED_STRUCT_PAGE_INIT.
> >>>>  			 */
> >>>> -			if (early_pfn_to_nid(pfn) != nid)
> >>>> +			if (pfn_to_nid(pfn) != nid)
> >>>>  				continue;
> >>>>  			if (init_section_page_ext(pfn, nid))
> >>>>  				goto oom;
> >>>
> >>> Also this doesn't seem to be related, right?
> >>
> >> No, it is related. Because of this patch, page_ext_init() is called after all
> >> the memory has already been initialized,
> >> so no longer necessary to call early_pfn_to_nid().
> > 
> > Yes, but it looks like a follow up cleanup/optimization to me.
> 
> That early_pfn_to_nid() was introduced in fe53ca54270 (mm: use early_pfn_to_nid
> in page_ext_init) which also messed up the order of page_ext_init() in
> start_kernel(), so this patch basically revert that commit.

So can we make the revert with an explanation that the patch was wrong?
If we want to make hacks to catch more objects to be tracked then it
would be great to have some numbers in hands.
-- 
Michal Hocko
SUSE Labs
