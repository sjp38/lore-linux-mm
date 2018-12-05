Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C1AF06B7509
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 10:37:36 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id v4so9774840edm.18
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 07:37:36 -0800 (PST)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id a15si396094eds.294.2018.12.05.07.37.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 07:37:35 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 068171C25C0
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 15:37:35 +0000 (GMT)
Date: Wed, 5 Dec 2018 15:37:33 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/2] mm, pageblock: make sure pageblock won't exceed
 mem_sectioin
Message-ID: <20181205153733.GB23260@techsingularity.net>
References: <20181205091905.27727-1-richard.weiyang@gmail.com>
 <20181205111513.GA23260@techsingularity.net>
 <20181205120820.3gbhfvxgmclvj3wu@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181205120820.3gbhfvxgmclvj3wu@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org

On Wed, Dec 05, 2018 at 12:08:20PM +0000, Wei Yang wrote:
> On Wed, Dec 05, 2018 at 11:15:13AM +0000, Mel Gorman wrote:
> >On Wed, Dec 05, 2018 at 05:19:04PM +0800, Wei Yang wrote:
> >> When SPARSEMEM is used, there is an indication that pageblock is not
> >> allowed to exceed one mem_section. Current code doesn't have this
> >> constrain explicitly.
> >> 
> >> This patch adds this to make sure it won't.
> >> 
> >> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> >
> >Is this even possible? This would imply that the section size is smaller
> >than max order which would be quite a crazy selection for a sparesemem
> >section size. A lot of assumptions on the validity of PFNs within a
> >max-order boundary would be broken with such a section size. I'd be
> >surprised if such a setup could even boot, let alone run.
> 
> pageblock_order has two definitions.
> 
>     #define pageblock_order        HUGETLB_PAGE_ORDER
> 
>     #define pageblock_order        (MAX_ORDER-1)
> 
> If CONFIG_HUGETLB_PAGE is not enabled, pageblock_order is related to
> MAX_ORDER, which ensures it is smaller than section size.
> 
> If CONFIG_HUGETLB_PAGE is enabled, pageblock_order is not related to
> MAX_ORDER. I don't see HUGETLB_PAGE_ORDER is ensured to be less than
> section size. Maybe I missed it?
> 

HUGETLB_PAGE_ORDER is less than MAX_ORDER on the basis that normal huge
pages (not gigantic) pages are served from the buddy allocator which is
limited by MAX_ORDER.

-- 
Mel Gorman
SUSE Labs
