Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 19CEB6B0002
	for <linux-mm@kvack.org>; Wed, 22 May 2013 00:03:27 -0400 (EDT)
Message-ID: <519C4377.8020206@oracle.com>
Date: Wed, 22 May 2013 12:03:03 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] zswap: add zswap shrinker
References: <1369117567-26704-1-git-send-email-bob.liu@oracle.com> <20130521185720.GA3398@medulla>
In-Reply-To: <20130521185720.GA3398@medulla>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, ngupta@vflare.org, minchan@kernel.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, rcj@linux.vnet.ibm.com, mgorman@suse.de, riel@redhat.com, dave@sr71.net, hughd@google.com


On 05/22/2013 02:57 AM, Seth Jennings wrote:
> On Tue, May 21, 2013 at 02:26:07PM +0800, Bob Liu wrote:
>> In my understanding, currenlty zswap have a few problems.
>> 1. The zswap pool size is 20% of total memory that's too random and once it
>> gets full the performance may even worse because everytime pageout() an anon
>> page two disk-io write ops may happend instead of one.
> 
> Just to clarify, 20% is a default maximum amount that zswap can occupy.
> 
> Also, in the steady over-the-limit state, the average number of writebacks is
> equal to the number of pages coming into zswap.  The description above makes it
> sound like there is a reclaim amplification effect (two writebacks per zswap
> store) when, on average, there is none. The 2:1 effect only happens on one or
> two store operations right after the pool becomes full.

I don't think it only happens on one or two store operations.

When the system enter a situation or run a workload which have many anon
pages, the zswap pool will be full easily and most of the time.

But after it's full there are still many anon pages need to be reclaimed
and frontswap_store() will be entered and call zbud_reclaim_page() to
writeout two pages every time.

The effect to the user will be after the zswap is full, the disk IO is
always twice than disable it.

> 
> This is unclear though, mostly because the pool limit is enforced in
> zswap.  A situation exists where there might be an unbuddied zbud page with
> room for the upcoming allocation but, because we are over the pool limit,
> reclaim is done during that store anyway. I'm working on a clean way to fix

Yes, but always reclaim by writing out two pages.
So after the pool is full, there will be always more disk IO than normal
which can cause performance drop and make the user surprise.

> that up, probably by moving the limit enforcement into zbud as suggested by
> Mel.

Nice :)

> 
>> 2. The reclaim hook will only be triggered in frontswap_store().
>> It may be result that the zswap pool size can't be adjusted in time which may
>> caused 20% memory lose for other users.
>>
>> This patch introduce a zswap shrinker, it make the balance that the zswap
>> pool size will be the same as anon pages in use.
> 
> Using zbud, with 2 zpages per zbud page, that would mean that up to 2/3 of anon
> pages could be compressed while 1/3 remain uncompressed.
> 
> How did you conclude that this is the right balance?
> 

It may not, but at least it can be changed dynamically for different
workloads. It can be higher than 20%*total_mem if there are too many
anon pages and can be shrinked easily.

> If nr_reclaim in the shrinker became very large due to global_anon_pages_inuse
> suddenly dropping, we could be writing back a LOT of pages all at once.
> 

Hmm, that's a problem.

> Having already looked at the patch, I can say that this isn't going to be the
> way to do this.  I agree that there should be some sort of dynamic sizing, but

Yes, that's what I'm looking forward to see. A policy to manage/balance
the size of zswap pool dynamically.
Maybe you have better idea to implement it.

> IMHO using a shrinker isn't the way.  Dave Chinner would not be happy about
> this since it is based on the zcache shrinker logic and he didn't have many
> kind words to say about it: https://lkml.org/lkml/2012/11/27/552
> 
> Seth
> 

Thanks!

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
