Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 395FC6B0070
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 19:48:14 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id lz20so9679061obb.14
        for <linux-mm@kvack.org>; Wed, 21 Nov 2012 16:48:13 -0800 (PST)
Message-ID: <50AD7647.7050200@gmail.com>
Date: Thu, 22 Nov 2012 08:48:07 +0800
From: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
MIME-Version: 1.0
Subject: Re: Problem in Page Cache Replacement
References: <1353433362.85184.YahooMailNeo@web141101.mail.bf1.yahoo.com> <20121120182500.GH1408@quack.suse.cz> <20121121213417.GC24381@cmpxchg.org>
In-Reply-To: <20121121213417.GC24381@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Jan Kara <jack@suse.cz>, metin d <metdos@yahoo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 11/22/2012 05:34 AM, Johannes Weiner wrote:
> Hi,
>
> On Tue, Nov 20, 2012 at 07:25:00PM +0100, Jan Kara wrote:
>> On Tue 20-11-12 09:42:42, metin d wrote:
>>> I have two PostgreSQL databases named data-1 and data-2 that sit on the
>>> same machine. Both databases keep 40 GB of data, and the total memory
>>> available on the machine is 68GB.
>>>
>>> I started data-1 and data-2, and ran several queries to go over all their
>>> data. Then, I shut down data-1 and kept issuing queries against data-2.
>>> For some reason, the OS still holds on to large parts of data-1's pages
>>> in its page cache, and reserves about 35 GB of RAM to data-2's files. As
>>> a result, my queries on data-2 keep hitting disk.
>>>
>>> I'm checking page cache usage with fincore. When I run a table scan query
>>> against data-2, I see that data-2's pages get evicted and put back into
>>> the cache in a round-robin manner. Nothing happens to data-1's pages,
>>> although they haven't been touched for days.
>>>
>>> Does anybody know why data-1's pages aren't evicted from the page cache?
>>> I'm open to all kind of suggestions you think it might relate to problem.
> This might be because we do not deactive pages as long as there is
> cache on the inactive list.  I'm guessing that the inter-reference
> distance of data-2 is bigger than half of memory, so it's never
> getting activated and data-1 is never challenged.

Hi Johannes,

What's the meaning of "inter-reference distance" and why compare it with 
half of memoy, what's the trick?

Regards,
Jaegeuk

>
> I have a series of patches that detects a thrashing inactive list and
> handles working set changes up to the size of memory.  Would you be
> willing to test them?  They are currently based on 3.4, let me know
> what version works best for you.
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
