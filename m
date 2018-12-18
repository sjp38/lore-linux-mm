Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C06848E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 15:48:47 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id o21so13829391edq.4
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 12:48:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j27-v6sor4325667eja.3.2018.12.18.12.48.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Dec 2018 12:48:46 -0800 (PST)
Date: Tue, 18 Dec 2018 20:48:44 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, page_isolation: remove drain_all_pages() in
 set_migratetype_isolate()
Message-ID: <20181218204844.tmlv5jpie6smhnhn@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181214023912.77474-1-richard.weiyang@gmail.com>
 <20181213195712.1e7bacce774c403e82fe9fab@linux-foundation.org>
 <20181214151756.kxtxgqb6i5vmrymw@master>
 <20181217122132.GH30879@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181217122132.GH30879@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, osalvador@suse.de, david@redhat.com, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>

On Mon, Dec 17, 2018 at 01:21:32PM +0100, Michal Hocko wrote:
>On Fri 14-12-18 15:17:56, Wei Yang wrote:
>> On Thu, Dec 13, 2018 at 07:57:12PM -0800, Andrew Morton wrote:
>> >On Fri, 14 Dec 2018 10:39:12 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:
>> >
>> >> Below is a brief call flow for __offline_pages()
>> >
>> >Offtopic...
>> >
>> >set_migratetype_isolate() has the comment
>> >
>> >	/*
>> >	 * immobile means "not-on-lru" pages. If immobile is larger than
>> >	 * removable-by-driver pages reported by notifier, we'll fail.
>> >	 */
>> >
>> >what the heck does that mean?  It used to talk about unmovable pages,
>> >but this was mysteriously changed to use the unique term "immobile" by
>> >Minchan's ee6f509c32 ("mm: factor out memory isolate functions"). 
>> >Could someone please take a look?
>> >
>> >
>> >> and
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
>> >Well.  drain_all_pages() moves pages from pcp to buddy so I'm not sure
>> >that argument holds water.
>> >
>> >Can we step back a bit and ask ourselves what all these draining
>> >operations are actually for?  What is the intent behind each callsite? 
>> >Figuring that out (and perhaps even documenting it!) would help us
>> >decide the most appropriate places from which to perform the drain.
>> 
>> With some rethinking we even could take drain_all_pages() out of the
>> repeat loop. Because after isolation, the page in this range will not be
>> put to pcp pageset. So we just need to drain pages once.
>> 
>> The change may look like this.
>
>No, this is incorrect. Draining pcp lists before scan_movable_pages is
>most likely sub-optimal, because scan_movable_pages will simply ignore
>pages being on the pcp lists. But we definitely want to drain before we
>terminate the offlining phase because we do not want to have isolated
>pages on those lists before we allow the final hotremove.
>
>The way how we retry the migration loop until there is no page in use
>just guarantees that drain_all_pages is called. If you put it out of the
>loop then you just break that assumption. Moving drain_all_pages down
>after the migration is done should work well AFAICS but I didn't really
>think through all potential side effects nor have time to do so now.
>

After discussion, do you agree with this proposal?

>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 6910e0eea074..120e9fdfd055 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1590,6 +1590,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
>>         if (ret)
>>                 goto failed_removal;
>> 
>> +       drain_all_pages(zone);
>>         pfn = start_pfn;
>>  repeat:
>>         /* start memory hot removal */
>> @@ -1599,7 +1600,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
>> 
>>         cond_resched();
>>         lru_add_drain_all();
>> -       drain_all_pages(zone);
>> 
>>         pfn = scan_movable_pages(start_pfn, end_pfn);
>>         if (pfn) { /* We have movable pages */
>> 
>> -- 
>> Wei Yang
>> Help you, Help me
>
>-- 
>Michal Hocko
>SUSE Labs

-- 
Wei Yang
Help you, Help me
