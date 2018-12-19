Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BDBB48E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 09:33:30 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e17so16433885edr.7
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 06:33:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s23-v6sor4919553eju.43.2018.12.19.06.33.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Dec 2018 06:33:29 -0800 (PST)
Date: Wed, 19 Dec 2018 14:33:27 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v2] mm, page_isolation: remove drain_all_pages() in
 set_migratetype_isolate()
Message-ID: <20181219143327.wdsufbn2oh6ygnne@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181214023912.77474-1-richard.weiyang@gmail.com>
 <20181218204656.4297-1-richard.weiyang@gmail.com>
 <20181219095110.GB5758@dhcp22.suse.cz>
 <20181219095715.73x6hvmndyku2rec@d104.suse.de>
 <20181219135307.bjd6rckseczpfeae@master>
 <20181219141343.GN5758@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219141343.GN5758@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org, akpm@linux-foundation.org, david@redhat.com

On Wed, Dec 19, 2018 at 03:13:43PM +0100, Michal Hocko wrote:
>On Wed 19-12-18 13:53:07, Wei Yang wrote:
>> On Wed, Dec 19, 2018 at 10:57:19AM +0100, Oscar Salvador wrote:
>> >On Wed, Dec 19, 2018 at 10:51:10AM +0100, Michal Hocko wrote:
>> >> On Wed 19-12-18 04:46:56, Wei Yang wrote:
>> >> > Below is a brief call flow for __offline_pages() and
>> >> > alloc_contig_range():
>> >> > 
>> >> >   __offline_pages()/alloc_contig_range()
>> >> >       start_isolate_page_range()
>> >> >           set_migratetype_isolate()
>> >> >               drain_all_pages()
>> >> >       drain_all_pages()
>> >> > 
>> >> > Current logic is: isolate and drain pcp list for each pageblock and
>> >> > drain pcp list again. This is not necessary and we could just drain pcp
>> >> > list once after isolate this whole range.
>> >> > 
>> >> > The reason is start_isolate_page_range() will set the migrate type of
>> >> > a range to MIGRATE_ISOLATE. After doing so, this range will never be
>> >> > allocated from Buddy, neither to a real user nor to pcp list.
>> >> 
>> >> But it is important to note that those pages still can be allocated from
>> >> the pcp lists until we do drain_all_pages().
>> >
>> >I had the same fear, but then I saw that move_freepages_block()->move_freepages() moves
>> >the pages to a new list:
>> >
>> ><--
>> >list_move(&page->lru,
>> >			  &zone->free_area[order].free_list[migratetype]);
>> >-->
>> >
>> >
>> >But looking at it again, I see that this is only for BuddyPages, so I guess
>> >that pcp-pages do not really get unlinked, so we could still allocate them.
>> 
>> Well, I think you are right. But with this in mind, current code looks
>> buggy.
>> 
>> Between has_unmovable_pages() and drain_all_pages(), others still could
>> allocate pages on pcp list, right? This means we thought we have
>> isolated the range, but not.
>
>THere is no guarantee in that regards and I believe there is also no
>demand for such a strong semantic. Or I do not see it at least. 

If there is no demand for this, allocating page before drain_all_pages()
is reasonable. The time gap between isolating page and drain_all_pages
is fine.

Then I am confused about the objection to this patch. Finally, we drain
all the pages in pcp list and the range is isolated.

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
