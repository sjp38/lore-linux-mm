Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A83276B01EE
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 09:19:44 -0400 (EDT)
Message-ID: <4BCEFB4C.1070206@redhat.com>
Date: Wed, 21 Apr 2010 09:19:08 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/3] Avoid the use of congestion_wait under zone pressure
References: <20100322235053.GD9590@csn.ul.ie> <4BA940E7.2030308@redhat.com> <20100324145028.GD2024@csn.ul.ie> <4BCC4B0C.8000602@linux.vnet.ibm.com> <20100419214412.GB5336@cmpxchg.org> <4BCD55DA.2020000@linux.vnet.ibm.com> <20100420153202.GC5336@cmpxchg.org> <4BCDE2F0.3010009@redhat.com> <4BCE7DD1.70900@linux.vnet.ibm.com> <4BCEAAC6.7070602@linux.vnet.ibm.com>
In-Reply-To: <4BCEAAC6.7070602@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, gregkh@novell.com, Corrado Zoccolo <czoccolo@gmail.com>
List-ID: <linux-mm.kvack.org>

On 04/21/2010 03:35 AM, Christian Ehrhardt wrote:
>
>
> Christian Ehrhardt wrote:
>>
>>
>> Rik van Riel wrote:
>>> On 04/20/2010 11:32 AM, Johannes Weiner wrote:
>>>
>>>> The idea is that it pans out on its own. If the workload changes, new
>>>> pages get activated and when that set grows too large, we start
>>>> shrinking
>>>> it again.
>>>>
>>>> Of course, right now this unscanned set is way too large and we can end
>>>> up wasting up to 50% of usable page cache on false active pages.
>>>
>>> Thing is, changing workloads often change back.
>>>
>>> Specifically, think of a desktop system that is doing
>>> work for the user during the day and gets backed up
>>> at night.
>>>
>>> You do not want the backup to kick the working set
>>> out of memory, because when the user returns in the
>>> morning the desktop should come back quickly after
>>> the screensaver is unlocked.
>>
>> IMHO it is fine to prevent that nightly backup job from not being
>> finished when the user arrives at morning because we didn't give him
>> some more cache - and e.g. a 30 sec transition from/to both optimized
>> states is fine.
>> But eventually I guess the point is that both behaviors are reasonable
>> to achieve - depending on the users needs.
>>
>> What we could do is combine all our thoughts we had so far:
>> a) Rik could create an experimental patch that excludes the in flight
>> pages
>> b) Johannes could create one for his suggestion to "always scan active
>> file pages but only deactivate them when the ratio is off and
>> otherwise strip buffers of clean pages"

I think you are confusing "buffer heads" with "buffers".

You can strip buffer heads off pages, but that is not
your problem.

"buffers" in /proc/meminfo stands for cached metadata,
eg. the filesystem journal, inodes, directories, etc...
Caching such metadata is legitimate, because it reduces
the number of disk seeks down the line.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
