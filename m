Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 447998E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 09:44:13 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e12so12752474edd.16
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 06:44:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l52sor9412385edc.17.2018.12.18.06.44.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Dec 2018 06:44:11 -0800 (PST)
Date: Tue, 18 Dec 2018 14:44:10 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, page_isolation: remove drain_all_pages() in
 set_migratetype_isolate()
Message-ID: <20181218144410.mrm45xthqhqvw5zw@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181214023912.77474-1-richard.weiyang@gmail.com>
 <20181217122523.GI30879@dhcp22.suse.cz>
 <20181217150819.zqz7u5kjswkvqoqu@master>
 <20181217154812.GU30879@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181217154812.GU30879@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, osalvador@suse.de, david@redhat.com

On Mon, Dec 17, 2018 at 04:48:12PM +0100, Michal Hocko wrote:
>On Mon 17-12-18 15:08:19, Wei Yang wrote:
>> On Mon, Dec 17, 2018 at 01:25:23PM +0100, Michal Hocko wrote:
>> >On Fri 14-12-18 10:39:12, Wei Yang wrote:
>> >> Below is a brief call flow for __offline_pages() and
>> >> alloc_contig_range():
>> >> 
>> >>   __offline_pages()/alloc_contig_range()
>> >>       start_isolate_page_range()
>> >>           set_migratetype_isolate()
>> >>               drain_all_pages()
>> >>       drain_all_pages()
>> >> 
>> >> Since set_migratetype_isolate() is only used in
>> >> start_isolate_page_range(), which is just used in __offline_pages() and
>> >> alloc_contig_range(). And both of them call drain_all_pages() if every
>> >> check looks good. This means it is not necessary call drain_all_pages()
>> >> in each iteration of set_migratetype_isolate().
>> >> 
>> >> By doing so, the logic seems a little bit clearer.
>> >> set_migratetype_isolate() handles pages in Buddy, while
>> >> drain_all_pages() takes care of pages in pcp.
>> >
>> >I have to confess I am not sure about the purpose of the draining here.
>> >I suspect it is to make sure that pages in the pcp lists really get
>> >isolated and if that is the case then it makes sense.
>> >
>> >In any case I strongly suggest not touching this code without a very
>> >good explanation on why this is not needed. Callers do XYZ is not a
>> >proper explanation because assumes that all callers will know that this
>> >has to be done. So either we really need to drain and then it is better
>> >to make it here or we don't but that requires some explanation.
>> >
>> 
>> Yep, let me try to explain what is trying to do.
>> 
>> Based on my understanding, online_pages do two things
>> 
>>     * adjust zone/pgdat status
>>     * put pages into Buddy
>> 
>> Generally, offline_pages do the reverse
>> 
>>     * take pages out of Buddy
>>     * adjust zone/pgdat status
>> 
>> While it is not that easy to take pages out of Buddy, since pages are
>> 
>>     * pcp list
>>     * slub
>>     * other usage
>> 
>> This means before taking a page out of Buddy, we need to return it first
>> to Buddy.
>> 
>> Current implementation is interesting by introducing migrate type. By
>> setting migrate type to MIGRATE_ISOLATE, this range of pages will never
>> be allocated from Buddy. And every page returned in this range will
>> never be touched by Buddy.
>> 
>> Function start_isolate_page_range() just do this.
>> 
>> Then let's focus on the pcp list. This is a little bit different
>> than other allocated pages. These are actually "partially" allocated
>> pages. They are not counted in Buddy Free pages, either no real use. So
>> we have two choice to get back those pages:
>> 
>>     * wait until it is allocated to a real user and wait for return
>>     * or drain them directly
>> 
>> Current implementation take 2nd approach.
>> 
>> Then we can see there are also two way to drain them:
>> 
>>     * drain them range by range
>>     * drain them in a whole range
>> 
>> Both looks good, but not necessary to do them both. Because after we set
>> a pageblock migrate type to MIGRATE_ISOLATE, pages in this range will
>> never be allocated nor be put on pcp list. So after we drain one
>> particular range, it is not necessary to drain this range again.
>
>OK, this is an important point and actually the argument that i am
>wrong. I have missed that free_unref_page_commit skips pcp lists for
>MIGRATE_ISOLATE (resp. all migrate types above MIGRATE_PCPTYPES).
>Then you are right that we are OK to drain the zone only once _after_ we
>have isolated the full range.
>
>So please send a new patch with this clarification in the changelog and
>I will ack it.
> 
>> The reason why I choose to drain them in a whole range is current
>> drain_all_pages() just carry zone information. For example, a zone may
>> have 1G while a pageblock is 128M. The pageblock is 1/8 of this zone.
>> This means in case there are 8 pages on pcp list, only 1 page drained by
>> drain_all_pages belongs to this pageblock. But we drain other 7 healthy
>> pages.
>> 
>>  CPU1 pcp list                            CPU2 pcp list
>> 
>>  +---------------+                        +---------------+ 
>>  |A1  B3  C8  F6 |                        |E1  G3  D8  B6 |
>>  +---------------+                        +---------------+
>> 
>> 
>>    A         B         C         D         E         F         G
>>   +---------+---------+---------+---------+---------+---------+---------+
>>   |012345678|         |         |         |         |         |         |
>>   +---------+---------+---------+---------+---------+---------+---------+
>>                                 |<-pgblk->|
>>   |<-                              Zone                               ->|
>> 
>> 
>> This is a chart for illustration. In case we want to isolate pgblk D,
>> while zone pcp list has 8 pages and only one belongs to this pgblk D.
>> This means the drain on pgblk base has much side effect. And with one
>> drain on each pgblk, this may increase the contention on this zone.
>> 
>> Well, another approach is to enable drain_all_pages() with exact range
>> information. But neither approach needs to do them both.
>
>Is this actually worth the additional complexity? Have you seen an
>actual workload that would benefit from that?

No, I just mention the possible approach in my mind. While currently
drain pcp list once is enough.

I will prepare v2 with more detailed changelog with migratetype thing.

>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
