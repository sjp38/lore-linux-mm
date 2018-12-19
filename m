Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C4AAA8E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 08:40:58 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id v4so16138680edm.18
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 05:40:58 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b20si5768643edr.54.2018.12.19.05.40.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 05:40:57 -0800 (PST)
Date: Wed, 19 Dec 2018 14:40:56 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v2] mm, page_isolation: remove drain_all_pages() in
 set_migratetype_isolate()
Message-ID: <20181219134056.GL5758@dhcp22.suse.cz>
References: <20181214023912.77474-1-richard.weiyang@gmail.com>
 <20181218204656.4297-1-richard.weiyang@gmail.com>
 <20181219095110.GB5758@dhcp22.suse.cz>
 <20181219132934.65vymftfgd2atcxa@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219132934.65vymftfgd2atcxa@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, osalvador@suse.de, david@redhat.com

On Wed 19-12-18 13:29:34, Wei Yang wrote:
> On Wed, Dec 19, 2018 at 10:51:10AM +0100, Michal Hocko wrote:
> >On Wed 19-12-18 04:46:56, Wei Yang wrote:
> >> Below is a brief call flow for __offline_pages() and
> >> alloc_contig_range():
> >> 
> >>   __offline_pages()/alloc_contig_range()
> >>       start_isolate_page_range()
> >>           set_migratetype_isolate()
> >>               drain_all_pages()
> >>       drain_all_pages()
> >> 
> >> Current logic is: isolate and drain pcp list for each pageblock and
> >> drain pcp list again. This is not necessary and we could just drain pcp
> >> list once after isolate this whole range.
> >> 
> >> The reason is start_isolate_page_range() will set the migrate type of
> >> a range to MIGRATE_ISOLATE. After doing so, this range will never be
> >> allocated from Buddy, neither to a real user nor to pcp list.
> >
> >But it is important to note that those pages still can be allocated from
> >the pcp lists until we do drain_all_pages().
> >
> >One thing that I really do not like about this patch (and I believe I
> >have mentioned that previously) that you rely on callers to do the right
> >thing. The proper fix would be to do the draining in
> >start_isolate_page_range and remove them from callers. Also what does
> 
> Well, I don't really understand this meaning previously.
> 
> So you prefer set_migratetype_isolate() do the drain instead of the
> caller (__offline_pages) do the drain. Is my understanding correct?

Either set_migratetype_isolate or start_isolate_page_range. The later
only if this is guaranteed that we cannot intemix zones in the range.

> >prevent start_isolate_page_range to work on multiple zones? At least
> >contiguous allocator can do that in principle.
> 
> As the comment mentioned, in current implementation the range must be in
> one zone.

I do not see anything like that documented for set_migratetype_isolate.
-- 
Michal Hocko
SUSE Labs
