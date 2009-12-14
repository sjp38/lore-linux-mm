Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 883C66B003D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 09:40:47 -0500 (EST)
Message-ID: <4B264E66.9050206@redhat.com>
Date: Mon, 14 Dec 2009 09:40:38 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: limit concurrent reclaimers in shrink_zone
References: <20091210185626.26f9828a@cuia.bos.redhat.com> <87pr6hya86.fsf@basil.nowhere.org>
In-Reply-To: <87pr6hya86.fsf@basil.nowhere.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: lwoodman@redhat.com, kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On 12/14/2009 08:08 AM, Andi Kleen wrote:
> Rik van Riel<riel@redhat.com>  writes:
>
>> +max_zone_concurrent_reclaim:
>> +
>> +The number of processes that are allowed to simultaneously reclaim
>> +memory from a particular memory zone.
>> +
>> +With certain workloads, hundreds of processes end up in the page
>> +reclaim code simultaneously.  This can cause large slowdowns due
>> +to lock contention, freeing of way too much memory and occasionally
>> +false OOM kills.
>> +
>> +To avoid these problems, only allow a smaller number of processes
>> +to reclaim pages from each memory zone simultaneously.
>> +
>> +The default value is 8.
>
> I don't like the hardcoded number. Is the same number good for a 128MB
> embedded system as for as 1TB server?  Seems doubtful.
>
> This should be perhaps scaled with memory size and number of CPUs?

The limit is per _zone_, so the number of concurrent reclaimers
is automatically scaled by the number of memory zones in the
system.

Scaling up the per-zone value as well looks like it could lead
to the kind of lock contention we are aiming to avoid in the
first place.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
