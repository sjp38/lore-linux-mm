Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 14E616B0005
	for <linux-mm@kvack.org>; Fri,  8 Mar 2013 22:28:43 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id dn14so1890325obc.18
        for <linux-mm@kvack.org>; Fri, 08 Mar 2013 19:28:42 -0800 (PST)
Message-ID: <513AAC63.3050207@gmail.com>
Date: Sat, 09 Mar 2013 11:28:35 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: mmap vs fs cache
References: <5136320E.8030109@symas.com> <20130307154312.GG6723@quack.suse.cz> <20130308020854.GC23767@cmpxchg.org> <5139975F.9070509@symas.com> <20130308084246.GA4411@shutemov.name> <5139B214.3040303@symas.com> <5139FA13.8090305@genband.com> <5139FD27.1030208@symas.com> <20130308161643.GE23767@cmpxchg.org>
In-Reply-To: <20130308161643.GE23767@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Howard Chu <hyc@symas.com>, Chris Friesen <chris.friesen@genband.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Jan Kara <jack@suse.cz>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hi Johannes,
On 03/09/2013 12:16 AM, Johannes Weiner wrote:
> On Fri, Mar 08, 2013 at 07:00:55AM -0800, Howard Chu wrote:
>> Chris Friesen wrote:
>>> On 03/08/2013 03:40 AM, Howard Chu wrote:
>>>
>>>> There is no way that a process that is accessing only 30GB of a mmap
>>>> should be able to fill up 32GB of RAM. There's nothing else running on
>>>> the machine, I've killed or suspended everything else in userland
>>>> besides a couple shells running top and vmstat. When I manually
>>>> drop_caches repeatedly, then eventually slapd RSS/SHR grows to 30GB and
>>>> the physical I/O stops.
>>> Is it possible that the kernel is doing some sort of automatic
>>> readahead, but it ends up reading pages corresponding to data that isn't
>>> ever queried and so doesn't get mapped by the application?
>> Yes, that's what I was thinking. I added a
>> posix_madvise(..POSIX_MADV_RANDOM) but that had no effect on the
>> test.
>>
>> First obvious conclusion - kswapd is being too aggressive. When free
>> memory hits the low watermark, the reclaim shrinks slapd down from
>> 25GB to 18-19GB, while the page cache still contains ~7GB of
>> unmapped pages. Ideally I'd like a tuning knob so I can say to keep
>> no more than 2GB of unmapped pages in the cache. (And the desired
>> effect of that would be to allow user processes to grow to 30GB
>> total, in this case.)
> We should find out where the unmapped page cache is coming from if you
> are only accessing mapped file cache and disabled readahead.
>
> How do you arrive at this number of unmapped page cache?
>
> What could happen is that previously used and activated pages do not
> get evicted anymore since there is a constant supply of younger

If a user process exit, its file pages and anonymous pages will be freed 
immediately or go through page reclaim?

> reclaimable cache that is actually thrashing.  Whenever you drop the
> caches, you get rid of those stale active pages and allow the
> previously thrashing cache to get activated.  However, that would
> require that there is already a significant amount of active file

Why you emphasize a *significant* amount of active file pages?

> pages before your workload starts (check the nr_active_file number in
> /proc/vmstat before launching slapd, try sync; echo 3 >drop_caches
> before launching to eliminate this option) OR that the set of pages
> accessed during your workload changes and the combined set of pages
> accessed by your workload is bigger than available memory -- which you
> claimed would not happen because you only access the 30GB file area on
> that system.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
