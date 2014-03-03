Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 93B5F6B0035
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 07:46:50 -0500 (EST)
Received: by mail-wg0-f43.google.com with SMTP id x13so2010914wgg.14
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 04:46:49 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x3si5824185wje.119.2014.03.03.04.46.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Mar 2014 04:46:48 -0800 (PST)
Message-ID: <531479B7.3070606@suse.cz>
Date: Mon, 03 Mar 2014 13:46:47 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 6/6] mm: use atomic bit operations in set_pageblock_flags_group()
References: <1393596904-16537-1-git-send-email-vbabka@suse.cz> <1393596904-16537-7-git-send-email-vbabka@suse.cz> <20140303082846.GB28899@lge.com>
In-Reply-To: <20140303082846.GB28899@lge.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 03/03/2014 09:28 AM, Joonsoo Kim wrote:
> On Fri, Feb 28, 2014 at 03:15:04PM +0100, Vlastimil Babka wrote:
>> set_pageblock_flags_group() is used to set either migratetype or skip bit of a
>> pageblock. Setting migratetype is done under zone->lock (except from __init
>> code), however changing the skip bits is not protected and the pageblock flags
>> bitmap packs migratetype and skip bits together and uses non-atomic bit ops.
>> Therefore, races between setting migratetype and skip bit are possible and the
>> non-atomic read-modify-update of the skip bit may cause lost updates to
>> migratetype bits, resulting in invalid migratetype values, which are in turn
>> used to e.g. index free_list array.
>>
>> The race has been observed to happen and cause panics, albeit during
>> development of series that increases frequency of migratetype changes through
>> {start,undo}_isolate_page_range() calls.
>>
>> Two possible solutions were investigated: 1) using zone->lock for changing
>> pageblock_skip bit and 2) changing the bitmap operations to be atomic. The
>> problem of 1) is that zone->lock is already contended and almost never held in
>> the compaction code that updates pageblock_skip bits. Solution 2) should scale
>> better, but adds atomic operations also to migratype changes which are already
>> protected by zone->lock.
>
> How about 3) introduce new bitmap for pageblock_skip?
> I guess that migratetype bitmap is read-intensive and set/clear pageblock_skip
> could make performance degradation.

Yes that would be also possible, but was deemed too ugly and maybe even 
uglier in case some new pageblock bits are introduced. But it seems no 
performance degradation was observed for 1) and 2).

I guess if we left the whole idea of packed bitmap we could also make 
atomic the update of the whole migratetype instead of processing each 
bit separately. But that would mean at least 8 bits per pageblock for 
migratetype (and I have no idea about specifics for other archs than x86 
here). Maybe 4 bits if it's even more ugly and distinguishes odd and 
even pageblocks...

>>
>> Using mmtests' stress-highalloc benchmark, little difference was found between
>> the two solutions. The base is 3.13 with recent compaction series by myself and
>> Joonsoo Kim applied.
>>
>>                  3.13        3.13        3.13
>>                  base     2)atomic     1)lock
>> User         6103.92     6072.09     6178.79
>> System       1039.68     1033.96     1042.92
>> Elapsed      2114.27     2090.20     2110.23
>>
>
> I really wonder how 2) is better than base although there is a little difference.
> Is it the avg result of 10 runs? Do you have any idea what happens?

It is avg of 10 runs but I guess this just means 10 runs are not enough 
to get results precise enough. One difference is that atomic version 
does not clear/set bits that don't need it, but the profiles show the 
whole operation is pretty negligible. And if at least one bit is changed 
(I guess it is, unless migratetypes are somewhere set to the same value 
as they already are), cache line becomes dirty anyway. And again, 
profiles suggest that very little cache is dirtied here.

Vlastimil

> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
