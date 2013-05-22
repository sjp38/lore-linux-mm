Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 16D196B0033
	for <linux-mm@kvack.org>; Wed, 22 May 2013 02:05:57 -0400 (EDT)
Message-ID: <519C6031.7080205@oracle.com>
Date: Wed, 22 May 2013 14:05:37 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] zswap: add zswap shrinker
References: <1369117567-26704-1-git-send-email-bob.liu@oracle.com> <20130521185720.GA3398@medulla> <519C4377.8020206@oracle.com>
In-Reply-To: <519C4377.8020206@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, ngupta@vflare.org, minchan@kernel.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, rcj@linux.vnet.ibm.com, mgorman@suse.de, riel@redhat.com, dave@sr71.net, hughd@google.com

On 05/22/2013 12:03 PM, Bob Liu wrote:
> 
> On 05/22/2013 02:57 AM, Seth Jennings wrote:
>> On Tue, May 21, 2013 at 02:26:07PM +0800, Bob Liu wrote:
>>> In my understanding, currenlty zswap have a few problems.
>>> 1. The zswap pool size is 20% of total memory that's too random and once it
>>> gets full the performance may even worse because everytime pageout() an anon
>>> page two disk-io write ops may happend instead of one.
>>
>> Just to clarify, 20% is a default maximum amount that zswap can occupy.
>>
>> Also, in the steady over-the-limit state, the average number of writebacks is
>> equal to the number of pages coming into zswap.  The description above makes it
>> sound like there is a reclaim amplification effect (two writebacks per zswap
>> store) when, on average, there is none. The 2:1 effect only happens on one or
>> two store operations right after the pool becomes full.
> 
> I don't think it only happens on one or two store operations.
> 
> When the system enter a situation or run a workload which have many anon
> pages, the zswap pool will be full easily and most of the time.
> 
> But after it's full there are still many anon pages need to be reclaimed
> and frontswap_store() will be entered and call zbud_reclaim_page() to
> writeout two pages every time.
> 
> The effect to the user will be after the zswap is full, the disk IO is
> always twice than disable it.
> 
>>
>> This is unclear though, mostly because the pool limit is enforced in
>> zswap.  A situation exists where there might be an unbuddied zbud page with
>> room for the upcoming allocation but, because we are over the pool limit,
>> reclaim is done during that store anyway. I'm working on a clean way to fix
> 
> Yes, but always reclaim by writing out two pages.
> So after the pool is full, there will be always more disk IO than normal
> which can cause performance drop and make the user surprise.
> 

I found my concern is the same as Mel mentioned about nchunks.
Setting nchunks=2 is a way to workaround this issue.

But what I'm trying to do is dynamically change the pool size hoping to
reduce zswap_is_full() happen. And do the writeback in background in a
shrinker instead of the direct path pageout() > frontswap_store().

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
