Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id EFF978E0014
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 02:01:13 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id i14so2298612edf.17
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 23:01:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l52sor2763092edc.17.2018.12.13.23.01.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Dec 2018 23:01:11 -0800 (PST)
Date: Fri, 14 Dec 2018 07:01:10 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, page_isolation: remove drain_all_pages() in
 set_migratetype_isolate()
Message-ID: <20181214070110.ksdimjkpjjilm2sm@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181214023912.77474-1-richard.weiyang@gmail.com>
 <20181213195712.1e7bacce774c403e82fe9fab@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181213195712.1e7bacce774c403e82fe9fab@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, mhocko@suse.com, osalvador@suse.de, david@redhat.com, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>

On Thu, Dec 13, 2018 at 07:57:12PM -0800, Andrew Morton wrote:
>On Fri, 14 Dec 2018 10:39:12 +0800 Wei Yang <richard.weiyang@gmail.com> wrote:
>
>> Below is a brief call flow for __offline_pages()
>
>Offtopic...
>
>set_migratetype_isolate() has the comment
>
>	/*
>	 * immobile means "not-on-lru" pages. If immobile is larger than
>	 * removable-by-driver pages reported by notifier, we'll fail.
>	 */
>
>what the heck does that mean?  It used to talk about unmovable pages,
>but this was mysteriously changed to use the unique term "immobile" by
>Minchan's ee6f509c32 ("mm: factor out memory isolate functions"). 
>Could someone please take a look?
>

What immobile stands for? I searched the whole kernel tree and just this
place use this terminology.

>
>> and
>> alloc_contig_range():
>> 
>>   __offline_pages()/alloc_contig_range()
>>       start_isolate_page_range()
>>           set_migratetype_isolate()
>>               drain_all_pages()
>>       drain_all_pages()
>> 
>> Since set_migratetype_isolate() is only used in
>> start_isolate_page_range(), which is just used in __offline_pages() and
>> alloc_contig_range(). And both of them call drain_all_pages() if every
>> check looks good. This means it is not necessary call drain_all_pages()
>> in each iteration of set_migratetype_isolate().
>>
>> By doing so, the logic seems a little bit clearer.
>> set_migratetype_isolate() handles pages in Buddy, while
>> drain_all_pages() takes care of pages in pcp.
>
>Well.  drain_all_pages() moves pages from pcp to buddy so I'm not sure
>that argument holds water.
>

You mean the wartermark?

>Can we step back a bit and ask ourselves what all these draining
>operations are actually for?  What is the intent behind each callsite? 
>Figuring that out (and perhaps even documenting it!) would help us
>decide the most appropriate places from which to perform the drain.

That is great. I found myself hard to understand current implementation.
Let me try to write down what I understand now.

Current mm subsystem manage memory with a hierarchic way.

  * Buddy system
  * pcp pageset
  * slub

With this background, we handle pages differently for different layer.

  * set_migratetype_isolate() handle pages still in Buddy system.
  * drain_all_pages() handle pages in pcp pageset.
  * I don't know who handle pages in slub.

While there are still pages out there, eg. page table, file pages, I
don't understand how they are handled during offline. Especially, how to
catch them all in a specific range.

Now go back to this patch. 

   __offline_pages()/alloc_contig_range()
       start_isolate_page_range()
           set_migratetype_isolate()
               drain_all_pages()
       drain_all_pages()

start_isolate_page_range() will iterate a range with pageblock step to
isolate them. Since both __offline_pages() and alloc_contig_range()
require this range to be in the same zone, drain_all_pages() will drain
the pcp pageset of the same zone several times. After that,
drain_all_pages() will be called again to drain pages.

One thing we can notice is after set_migratetype_isolate() for a
particular range, this range's page will not be available for
allocation. But the pages after this range still has a chance to be put
on pcp pageset. And during this process, pages of the same zone but out
of the whole range could be put on the pcp pageset. This means current
implementation would drain those pages several times and may increase
contention for this zone.

This behavior seems suboptimal. And we can do this just in once to drain
all of them.

-- 
Wei Yang
Help you, Help me
