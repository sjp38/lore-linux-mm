Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id F19AB6B004D
	for <linux-mm@kvack.org>; Wed, 28 Dec 2011 17:57:41 -0500 (EST)
Received: by qcsd17 with SMTP id d17so9313869qcs.14
        for <linux-mm@kvack.org>; Wed, 28 Dec 2011 14:57:41 -0800 (PST)
Message-ID: <4EFB9EE2.1050903@gmail.com>
Date: Wed, 28 Dec 2011 17:57:38 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: Kswapd in 3.2.0-rc5 is a CPU hog
References: <1324437036.4677.5.camel@hakkenden.homenet> <20111221095249.GA28474@tiehlicka.suse.cz> <20111221225512.GG23662@dastard> <1324630880.562.6.camel@rybalov.eng.ttk.net> <20111223102027.GB12731@dastard> <1324638242.562.15.camel@rybalov.eng.ttk.net> <20111223204503.GC12731@dastard> <20111227111543.5e486eb7.kamezawa.hiroyu@jp.fujitsu.com> <1324954208.4634.2.camel@hakkenden.homenet> <20111227134405.9902dcbb.kamezawa.hiroyu@jp.fujitsu.com> <20111228213359.GF12731@dastard>
In-Reply-To: <20111228213359.GF12731@dastard>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Nikolay S." <nowhere@hakkenden.ath.cx>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

(12/28/11 4:33 PM), Dave Chinner wrote:
> On Tue, Dec 27, 2011 at 01:44:05PM +0900, KAMEZAWA Hiroyuki wrote:
>> To me,  it seems kswapd does usual work...reclaim small memory until free
>> gets enough. And it seems 'dd' allocates its memory from ZONE_DMA32 because
>> of gfp_t fallbacks.
>>
>>
>> Memo.
>>
>> 1. why shrink_slab() should be called per zone, which is not zone aware.
>>     Isn't it enough to call it per priority ?
>
> It is intended that it should be zone aware, but the current
> shrinkers only have global LRUs and hence cannot discriminate
> between objects from different zones easily. And if only a single
> node/zone is being scanned, then we still have to call shirnk_slab()
> to try to free objects in that zone/node, despite it's current
> global scope.
>
> I have some prototype patches that make the major slab caches and
> shrinkers zone/node aware - that is the eventual goal here - but
> first all the major slab cache LRUs need to be converted to be node
> aware first. Then we can pass a nodemask into shrink_slab() and down
> to the shrinkers so that those that have per-node LRUs can scan only
> the appropriate nodes for objects to free. This is someting that I'm
> working on in my spare time, but I have very little of that at the
> moment, unfortunately.

His machine only have one node. per node basis don't help him. We need
1) to make per zone LRU or 2) to implement more clever inter zone 
balancing code. but it seems off topic. I'm not sure why you are starting
talk about per node shrinker.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
