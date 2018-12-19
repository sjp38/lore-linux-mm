Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 55F158E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 09:13:45 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id v4so16220292edm.18
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 06:13:45 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l91si4873509ede.307.2018.12.19.06.13.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 06:13:44 -0800 (PST)
Date: Wed, 19 Dec 2018 15:13:43 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v2] mm, page_isolation: remove drain_all_pages() in
 set_migratetype_isolate()
Message-ID: <20181219141343.GN5758@dhcp22.suse.cz>
References: <20181214023912.77474-1-richard.weiyang@gmail.com>
 <20181218204656.4297-1-richard.weiyang@gmail.com>
 <20181219095110.GB5758@dhcp22.suse.cz>
 <20181219095715.73x6hvmndyku2rec@d104.suse.de>
 <20181219135307.bjd6rckseczpfeae@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219135307.bjd6rckseczpfeae@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org, akpm@linux-foundation.org, david@redhat.com

On Wed 19-12-18 13:53:07, Wei Yang wrote:
> On Wed, Dec 19, 2018 at 10:57:19AM +0100, Oscar Salvador wrote:
> >On Wed, Dec 19, 2018 at 10:51:10AM +0100, Michal Hocko wrote:
> >> On Wed 19-12-18 04:46:56, Wei Yang wrote:
> >> > Below is a brief call flow for __offline_pages() and
> >> > alloc_contig_range():
> >> > 
> >> >   __offline_pages()/alloc_contig_range()
> >> >       start_isolate_page_range()
> >> >           set_migratetype_isolate()
> >> >               drain_all_pages()
> >> >       drain_all_pages()
> >> > 
> >> > Current logic is: isolate and drain pcp list for each pageblock and
> >> > drain pcp list again. This is not necessary and we could just drain pcp
> >> > list once after isolate this whole range.
> >> > 
> >> > The reason is start_isolate_page_range() will set the migrate type of
> >> > a range to MIGRATE_ISOLATE. After doing so, this range will never be
> >> > allocated from Buddy, neither to a real user nor to pcp list.
> >> 
> >> But it is important to note that those pages still can be allocated from
> >> the pcp lists until we do drain_all_pages().
> >
> >I had the same fear, but then I saw that move_freepages_block()->move_freepages() moves
> >the pages to a new list:
> >
> ><--
> >list_move(&page->lru,
> >			  &zone->free_area[order].free_list[migratetype]);
> >-->
> >
> >
> >But looking at it again, I see that this is only for BuddyPages, so I guess
> >that pcp-pages do not really get unlinked, so we could still allocate them.
> 
> Well, I think you are right. But with this in mind, current code looks
> buggy.
> 
> Between has_unmovable_pages() and drain_all_pages(), others still could
> allocate pages on pcp list, right? This means we thought we have
> isolated the range, but not.

THere is no guarantee in that regards and I believe there is also no
demand for such a strong semantic. Or I do not see it at least. 
-- 
Michal Hocko
SUSE Labs
