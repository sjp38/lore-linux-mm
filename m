Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D48076B0008
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 07:09:56 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i68-v6so10471581pfb.9
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 04:09:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a1-v6si863302pls.476.2018.08.07.04.09.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 04:09:55 -0700 (PDT)
Date: Tue, 7 Aug 2018 13:09:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 200651] New: cgroups iptables-restor: vmalloc: allocation
 failure
Message-ID: <20180807110951.GZ10003@dhcp22.suse.cz>
References: <56597af4-73c6-b549-c5d5-b3a2e6441b8e@icdsoft.com>
 <6838c342-2d07-3047-e723-2b641bc6bf79@suse.cz>
 <8105b7b3-20d3-5931-9f3c-2858021a4e12@icdsoft.com>
 <20180731140520.kpotpihqsmiwhh7l@breakpoint.cc>
 <e5b24629-0296-5a4d-577a-c25d1c52b03b@suse.cz>
 <20180801083349.GF16767@dhcp22.suse.cz>
 <e5c5e965-a6bc-d61f-97fc-78da287b5d94@icdsoft.com>
 <20180802085043.GC10808@dhcp22.suse.cz>
 <85c86f17-6f96-6f01-2a3c-e2bad0ccb317@icdsoft.com>
 <5b5e872e-5785-2cfd-7d53-e19e017e5636@icdsoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5b5e872e-5785-2cfd-7d53-e19e017e5636@icdsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Georgi Nikolov <gnikolov@icdsoft.com>, Florian Westphal <fw@strlen.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, netfilter-devel@vger.kernel.org

On Tue 07-08-18 14:02:00, Georgi Nikolov wrote:
> On 08/06/2018 11:42 AM, Georgi Nikolov wrote:
> > On 08/02/2018 11:50 AM, Michal Hocko wrote:
> >> In other words, why don't we simply do the following? Note that this is
> >> not tested. I have also no idea what is the lifetime of this allocation.
> >> Is it bound to any specific process or is it a namespace bound? If the
> >> later then the memcg OOM killer might wipe the whole memcg down without
> >> making any progress. This would make the whole namespace unsuable until
> >> somebody intervenes. Is this acceptable?
> >> ---
> >> From 4dec96eb64954a7e58264ed551afadf62ca4c5f7 Mon Sep 17 00:00:00 2001
> >> From: Michal Hocko <mhocko@suse.com>
> >> Date: Thu, 2 Aug 2018 10:38:57 +0200
> >> Subject: [PATCH] netfilter/x_tables: do not fail xt_alloc_table_info too
> >>  easilly
> >>
> >> eacd86ca3b03 ("net/netfilter/x_tables.c: use kvmalloc()
> >> in xt_alloc_table_info()") has unintentionally fortified
> >> xt_alloc_table_info allocation when __GFP_RETRY has been dropped from
> >> the vmalloc fallback. Later on there was a syzbot report that this
> >> can lead to OOM killer invocations when tables are too large and
> >> 0537250fdc6c ("netfilter: x_tables: make allocation less aggressive")
> >> has been merged to restore the original behavior. Georgi Nikolov however
> >> noticed that he is not able to install his iptables anymore so this can
> >> be seen as a regression.
> >>
> >> The primary argument for 0537250fdc6c was that this allocation path
> >> shouldn't really trigger the OOM killer and kill innocent tasks. On the
> >> other hand the interface requires root and as such should allow what the
> >> admin asks for. Root inside a namespaces makes this more complicated
> >> because those might be not trusted in general. If they are not then such
> >> namespaces should be restricted anyway. Therefore drop the __GFP_NORETRY
> >> and replace it by __GFP_ACCOUNT to enfore memcg constrains on it.
> >>
> >> Fixes: 0537250fdc6c ("netfilter: x_tables: make allocation less aggressive")
> >> Reported-by: Georgi Nikolov <gnikolov@icdsoft.com>
> >> Suggested-by: Vlastimil Babka <vbabka@suse.cz>
> >> Signed-off-by: Michal Hocko <mhocko@suse.com>
> >> ---
> >>  net/netfilter/x_tables.c | 7 +------
> >>  1 file changed, 1 insertion(+), 6 deletions(-)
> >>
> >> diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> >> index d0d8397c9588..b769408e04ab 100644
> >> --- a/net/netfilter/x_tables.c
> >> +++ b/net/netfilter/x_tables.c
> >> @@ -1178,12 +1178,7 @@ struct xt_table_info *xt_alloc_table_info(unsigned int size)
> >>  	if (sz < sizeof(*info) || sz >= XT_MAX_TABLE_SIZE)
> >>  		return NULL;
> >>  
> >> -	/* __GFP_NORETRY is not fully supported by kvmalloc but it should
> >> -	 * work reasonably well if sz is too large and bail out rather
> >> -	 * than shoot all processes down before realizing there is nothing
> >> -	 * more to reclaim.
> >> -	 */
> >> -	info = kvmalloc(sz, GFP_KERNEL | __GFP_NORETRY);
> >> +	info = kvmalloc(sz, GFP_KERNEL | __GFP_ACCOUNT);
> >>  	if (!info)
> >>  		return NULL;
> >>  
> > I will check if this change fixes the problem.
> >
> > Regards,
> >
> > --
> > Georgi Nikolov
> 
> I can't reproduce it anymore.
> If i understand correctly this way memory allocated will be
> accounted to kmem of this cgroup (if inside cgroup).

s@this@caller's@

Florian, is this patch acceptable?

-- 
Michal Hocko
SUSE Labs
