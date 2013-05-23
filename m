Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id BEF546B0002
	for <linux-mm@kvack.org>; Wed, 22 May 2013 21:56:50 -0400 (EDT)
Message-ID: <519D7753.2070801@oracle.com>
Date: Thu, 23 May 2013 09:56:35 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] zswap: add zswap shrinker
References: <1369117567-26704-1-git-send-email-bob.liu@oracle.com> <20130521185720.GA3398@medulla> <519C4377.8020206@oracle.com> <20130522140815.GA3589@cerebellum>
In-Reply-To: <20130522140815.GA3589@cerebellum>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, ngupta@vflare.org, minchan@kernel.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, rcj@linux.vnet.ibm.com, mgorman@suse.de, riel@redhat.com, dave@sr71.net, hughd@google.com


On 05/22/2013 10:08 PM, Seth Jennings wrote:
> On Wed, May 22, 2013 at 12:03:03PM +0800, Bob Liu wrote:
>>
>> On 05/22/2013 02:57 AM, Seth Jennings wrote:
>>> On Tue, May 21, 2013 at 02:26:07PM +0800, Bob Liu wrote:
>>>> In my understanding, currenlty zswap have a few problems.
>>>> 1. The zswap pool size is 20% of total memory that's too random and once it
>>>> gets full the performance may even worse because everytime pageout() an anon
>>>> page two disk-io write ops may happend instead of one.
>>>
>>> Just to clarify, 20% is a default maximum amount that zswap can occupy.
>>>
>>> Also, in the steady over-the-limit state, the average number of writebacks is
>>> equal to the number of pages coming into zswap.  The description above makes it
>>> sound like there is a reclaim amplification effect (two writebacks per zswap
>>> store) when, on average, there is none. The 2:1 effect only happens on one or
>>> two store operations right after the pool becomes full.
>>
>> I don't think it only happens on one or two store operations.
>>
>> When the system enter a situation or run a workload which have many anon
>> pages, the zswap pool will be full easily and most of the time.
> 
> I think the part missing here is the just because a page is reclaimed on a
> particular store because we are over the zswap limit doesn't necessarily mean
> that page will be reallocated to the pool on the next zbud_alloc().  The
> reclaimed page is only reallocated if there is no unbuddied page in the pool
> with enough free space to hold the requested allocation.
> 
> In the case that the reclaimed page is not reallocated to the pool, we will be
> under the pool limit on the next zswap store and not do reclaim.
> 

That's true, I see your idea here.
But it's probably that there will be no suitable unbuddied pages in the
pool.
Mel gave a very good and detail example about nchunks in thread:
Re: [PATCHv11 2/4] zbud: add to mm/

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
