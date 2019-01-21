Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F8918E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 13:20:00 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id d41so7949405eda.12
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 10:20:00 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 90si2709902edb.180.2019.01.21.10.19.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 10:19:58 -0800 (PST)
Date: Mon, 21 Jan 2019 19:19:57 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/hotplug: invalid PFNs from pfn_to_online_page()
Message-ID: <20190121181957.GX4087@dhcp22.suse.cz>
References: <51e79597-21ef-3073-9036-cfc33291f395@lca.pw>
 <20190118021650.93222-1-cai@lca.pw>
 <20190121095352.GM4087@dhcp22.suse.cz>
 <1295f347-5a14-5b3b-23ef-2f001c25d980@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1295f347-5a14-5b3b-23ef-2f001c25d980@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, osalvador@suse.de, catalin.marinas@arm.com, vbabka@suse.cz, linux-mm@kvack.org

On Mon 21-01-19 11:38:49, Qian Cai wrote:
> 
> 
> On 1/21/19 4:53 AM, Michal Hocko wrote:
> > On Thu 17-01-19 21:16:50, Qian Cai wrote:
[...]
> >> Fixes: 2d070eab2e82 ("mm: consider zone which is not fully populated to
> >> have holes")
> > 
> > Did you mean 
> > Fixes: 9f1eb38e0e11 ("mm, kmemleak: little  optimization while scanning")
> 
> No, pfn_to_online_page() missed a few checks compared to pfn_valid() at least on
> arm64 where the returned pfn is no longer valid (where pfn_valid() will skip those).
> 
> 2d070eab2e82 introduced pfn_to_online_page(), so it was targeted to fix it.

But it is 9f1eb38e0e11 which has replaced pfn_valid by
pfn_to_online_page.

> 
> > 
> >> Signed-off-by: Qian Cai <cai@lca.pw>
> >> ---
> >>  include/linux/memory_hotplug.h | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> >> index 07da5c6c5ba0..b8b36e6ac43b 100644
> >> --- a/include/linux/memory_hotplug.h
> >> +++ b/include/linux/memory_hotplug.h
> >> @@ -26,7 +26,7 @@ struct vmem_altmap;
> >>  	struct page *___page = NULL;			\
> >>  	unsigned long ___nr = pfn_to_section_nr(pfn);	\
> >>  							\
> >> -	if (___nr < NR_MEM_SECTIONS && online_section_nr(___nr))\
> >> +	if (online_section_nr(___nr) && pfn_valid(pfn))	\
> >>  		___page = pfn_to_page(pfn);		\
> > 
> > Why have you removed the bound check? Is this safe?
> > Regarding the fix, I am not really sure TBH. If the secion is online
> > then we assume all struct pages to be initialized. If anything this
> > should be limited to werid arches which might have holes so
> > pfn_valid_within().
> 
> It looks to me at least on arm64 and x86_64, it has done this check in
> pfn_valid() already.
> 
> if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
> 		return 0

But an everflow could happen before pfn_valid is evaluated, no?

-- 
Michal Hocko
SUSE Labs
