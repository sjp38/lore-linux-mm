Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8015A8E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 08:56:38 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id i55so16437970ede.14
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 05:56:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id cc25-v6sor4890101ejb.20.2018.12.19.05.56.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Dec 2018 05:56:37 -0800 (PST)
Date: Wed, 19 Dec 2018 13:56:35 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v2] mm, page_isolation: remove drain_all_pages() in
 set_migratetype_isolate()
Message-ID: <20181219135635.yloh2sn4uskzpy7g@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181214023912.77474-1-richard.weiyang@gmail.com>
 <20181218204656.4297-1-richard.weiyang@gmail.com>
 <20181219095110.GB5758@dhcp22.suse.cz>
 <20181219132934.65vymftfgd2atcxa@master>
 <20181219134056.GL5758@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181219134056.GL5758@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, osalvador@suse.de, david@redhat.com

On Wed, Dec 19, 2018 at 02:40:56PM +0100, Michal Hocko wrote:
>On Wed 19-12-18 13:29:34, Wei Yang wrote:
>> On Wed, Dec 19, 2018 at 10:51:10AM +0100, Michal Hocko wrote:
>> >On Wed 19-12-18 04:46:56, Wei Yang wrote:
>> >> Below is a brief call flow for __offline_pages() and
>> >> alloc_contig_range():
>> >> 
>> >>   __offline_pages()/alloc_contig_range()
>> >>       start_isolate_page_range()
>> >>           set_migratetype_isolate()
>> >>               drain_all_pages()
>> >>       drain_all_pages()
>> >> 
>> >> Current logic is: isolate and drain pcp list for each pageblock and
>> >> drain pcp list again. This is not necessary and we could just drain pcp
>> >> list once after isolate this whole range.
>> >> 
>> >> The reason is start_isolate_page_range() will set the migrate type of
>> >> a range to MIGRATE_ISOLATE. After doing so, this range will never be
>> >> allocated from Buddy, neither to a real user nor to pcp list.
>> >
>> >But it is important to note that those pages still can be allocated from
>> >the pcp lists until we do drain_all_pages().
>> >
>> >One thing that I really do not like about this patch (and I believe I
>> >have mentioned that previously) that you rely on callers to do the right
>> >thing. The proper fix would be to do the draining in
>> >start_isolate_page_range and remove them from callers. Also what does
>> 
>> Well, I don't really understand this meaning previously.
>> 
>> So you prefer set_migratetype_isolate() do the drain instead of the
>> caller (__offline_pages) do the drain. Is my understanding correct?
>
>Either set_migratetype_isolate or start_isolate_page_range. The later
>only if this is guaranteed that we cannot intemix zones in the range.
>
>> >prevent start_isolate_page_range to work on multiple zones? At least
>> >contiguous allocator can do that in principle.
>> 
>> As the comment mentioned, in current implementation the range must be in
>> one zone.
>
>I do not see anything like that documented for set_migratetype_isolate.

The comment is not on set_migratetype_isolate, but for its two
(grandparent) callers:

   __offline_pages
   alloc_contig_range

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
