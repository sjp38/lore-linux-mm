Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 80CA86B0358
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 03:03:08 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id h12so1579167wre.12
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 00:03:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a8si98567edn.479.2017.12.06.00.03.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Dec 2017 00:03:06 -0800 (PST)
Date: Wed, 6 Dec 2017 09:03:05 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [mmotm] mm/page_owner: align with pageblock_nr_pages
Message-ID: <20171206080305.GA16386@dhcp22.suse.cz>
References: <1512395284-13588-1-git-send-email-zhongjiang@huawei.com>
 <20171205165826.aed52f6b6e5ca4cd7994ce31@linux-foundation.org>
 <5A275987.3070001@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A275987.3070001@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, vbabka@suse.cz, linux-mm@kvack.org

On Wed 06-12-17 10:44:23, zhong jiang wrote:
> On 2017/12/6 8:58, Andrew Morton wrote:
> > On Mon, 4 Dec 2017 21:48:04 +0800 zhong jiang <zhongjiang@huawei.com> wrote:
> >
> >> Currently, init_pages_in_zone walk the zone in pageblock_nr_pages
> >> steps.  MAX_ORDER_NR_PAGES is possible to have holes when
> >> CONFIG_HOLES_IN_ZONE is set. it is likely to be different between
> >> MAX_ORDER_NR_PAGES and pageblock_nr_pages. if we skip the size of
> >> MAX_ORDER_NR_PAGES, it will result in the second 2M memroy leak.
> >>
> >> meanwhile, the change will make the code consistent. because the
> >> entire function is based on the pageblock_nr_pages steps.
> >>
> >> ...
> >>
> >> --- a/mm/page_owner.c
> >> +++ b/mm/page_owner.c
> >> @@ -527,7 +527,7 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
> >>  	 */
> >>  	for (; pfn < end_pfn; ) {
> >>  		if (!pfn_valid(pfn)) {
> >> -			pfn = ALIGN(pfn + 1, MAX_ORDER_NR_PAGES);
> >> +			pfn = ALIGN(pfn + 1, pageblock_nr_pages);
> >>  			continue;
> >>  		}
> > I *think* Michal and Vlastimil will be OK with this as-newly-presented.
> > Guys, can you please have another think?
> According to Vlastimil's comment,  it is not simple as it looks to cover all corners.
> Maybe  architecture need explicit define the hole granularity to use correctly.
> so far,  I have no a good idea to solve it perfectly. 
> Anyway. I will go further to find out.

Yes please! The thing is clear as mud right now and doing cosmetic
changes without further clarification doesn't help to improve the
situation much.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
