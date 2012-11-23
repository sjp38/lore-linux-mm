Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 67AB56B005D
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 21:14:13 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id 10so15812919ied.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2012 18:14:12 -0800 (PST)
Message-ID: <50AEDBEF.8070408@gmail.com>
Date: Fri, 23 Nov 2012 10:14:07 +0800
From: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
MIME-Version: 1.0
Subject: Re: Problem in Page Cache Replacement
References: <1353433362.85184.YahooMailNeo@web141101.mail.bf1.yahoo.com> <20121120182500.GH1408@quack.suse.cz> <20121121213417.GC24381@cmpxchg.org> <50AD7647.7050200@gmail.com> <20121122010959.GF24381@cmpxchg.org> <50AE25AB.2060808@gmail.com> <20121122161743.GH24381@cmpxchg.org>
In-Reply-To: <20121122161743.GH24381@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Jan Kara <jack@suse.cz>, metin d <metdos@yahoo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 11/23/2012 12:17 AM, Johannes Weiner wrote:
> On Thu, Nov 22, 2012 at 09:16:27PM +0800, Jaegeuk Hanse wrote:
>> On 11/22/2012 09:09 AM, Johannes Weiner wrote:
>>> On Thu, Nov 22, 2012 at 08:48:07AM +0800, Jaegeuk Hanse wrote:
>>>> On 11/22/2012 05:34 AM, Johannes Weiner wrote:
>>>>> Hi,
>>>>>
>>>>> On Tue, Nov 20, 2012 at 07:25:00PM +0100, Jan Kara wrote:
>>>>>> On Tue 20-11-12 09:42:42, metin d wrote:
>>>>>>> I have two PostgreSQL databases named data-1 and data-2 that sit on the
>>>>>>> same machine. Both databases keep 40 GB of data, and the total memory
>>>>>>> available on the machine is 68GB.
>>>>>>>
>>>>>>> I started data-1 and data-2, and ran several queries to go over all their
>>>>>>> data. Then, I shut down data-1 and kept issuing queries against data-2.
>>>>>>> For some reason, the OS still holds on to large parts of data-1's pages
>>>>>>> in its page cache, and reserves about 35 GB of RAM to data-2's files. As
>>>>>>> a result, my queries on data-2 keep hitting disk.
>>>>>>>
>>>>>>> I'm checking page cache usage with fincore. When I run a table scan query
>>>>>>> against data-2, I see that data-2's pages get evicted and put back into
>>>>>>> the cache in a round-robin manner. Nothing happens to data-1's pages,
>>>>>>> although they haven't been touched for days.
>>>>>>>
>>>>>>> Does anybody know why data-1's pages aren't evicted from the page cache?
>>>>>>> I'm open to all kind of suggestions you think it might relate to problem.
>>>>> This might be because we do not deactive pages as long as there is
>>>>> cache on the inactive list.  I'm guessing that the inter-reference
>>>>> distance of data-2 is bigger than half of memory, so it's never
>>>>> getting activated and data-1 is never challenged.
>>>> Hi Johannes,
>>>>
>>>> What's the meaning of "inter-reference distance"
>>> It's the number of memory accesses between two accesses to the same
>>> page:
>>>
>>>    A B C D A B C E ...
>>>      |_______|
>>>      |       |
>>>
>>>> and why compare it with half of memoy, what's the trick?
>>> If B gets accessed twice, it gets activated.  If it gets evicted in
>>> between, the second access will be a fresh page fault and B will not
>>> be recognized as frequently used.
>>>
>>> Our cutoff for scanning the active list is cache size / 2 right now
>>> (inactive_file_is_low), leaving 50% of memory to the inactive list.
>>> If the inter-reference distance for pages on the inactive list is
>>> bigger than that, they get evicted before their second access.
>> Hi Johannes,
>>
>> Thanks for your explanation. But could you give a short description
>> of how you resolve this inactive list thrashing issues?
> I remember a time stamp of evicted file pages in the page cache radix
> tree that let me reconstruct the inter-reference distance even after a
> page has been evicted from cache when it's faulted back in.  This way
> I can tell a one-time sequence from thrashing, no matter how small the
> inactive list.
>
> When thrashing is detected, I start deactivating protected pages and
> put them next to the refaulted cache on the head of the inactive list
> and let them fight it out as usual.  In this reported case, the old
> data will be challenged and since it's no longer used, it will just
> drop off the inactive list eventually.  If the guess is wrong and the
> deactivated memory is used more heavily than the refaulting pages,
> they will just get activated again without incurring any disruption
> like a major fault.

Hi Johannes,

If you also add the time stamp to the protected pages which you deactive 
when incur thrashing?

Regards,
Jaegeuk



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
