Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id B7A356B017F
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:44:19 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id x12so81282wgg.38
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:44:19 -0800 (PST)
Received: from mail-we0-x22d.google.com (mail-we0-x22d.google.com. [2a00:1450:400c:c03::22d])
        by mx.google.com with ESMTPS id hl4si124139901wjb.1.2015.01.06.13.44.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:44:19 -0800 (PST)
Received: by mail-we0-f173.google.com with SMTP id q58so89677wes.32
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:44:19 -0800 (PST)
Date: Tue, 6 Jan 2015 22:44:16 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V4 1/4] mm: set page->pfmemalloc in prep_new_page()
Message-ID: <20150106214416.GA8391@dhcp22.suse.cz>
References: <1420478263-25207-1-git-send-email-vbabka@suse.cz>
 <1420478263-25207-2-git-send-email-vbabka@suse.cz>
 <20150106143008.GA20860@dhcp22.suse.cz>
 <54AC4F5F.90306@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54AC4F5F.90306@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Tue 06-01-15 22:10:55, Vlastimil Babka wrote:
> On 01/06/2015 03:30 PM, Michal Hocko wrote:
[...]
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 1bb65e6f48dd..1682d766cb8e 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2175,10 +2175,11 @@ zonelist_scan:
> >  		}
> >  
> >  try_this_zone:
> > -		page = buffered_rmqueue(preferred_zone, zone, order,
> > +		do {
> > +			page = buffered_rmqueue(preferred_zone, zone, order,
> >  						gfp_mask, migratetype);
> > -		if (page)
> > -			break;
> > +		} while (page && prep_new_page(page, order, gfp_mask,
> > +					       alloc_flags));
> 
> Hm but here we wouldn't return page on success.

Right.

> I wonder if you overlooked the return, hence your "not breaking out of
> the loop" remark?

This was merely to show the intention. Sorry for not being clear enough.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
