Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 07AEF6B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 21:38:53 -0500 (EST)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p0J2clsv019658
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 18:38:47 -0800
Received: from pvg6 (pvg6.prod.google.com [10.241.210.134])
	by wpaz5.hot.corp.google.com with ESMTP id p0J2cjDm026920
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 18:38:46 -0800
Received: by pvg6 with SMTP id 6so76336pvg.37
        for <linux-mm@kvack.org>; Tue, 18 Jan 2011 18:38:45 -0800 (PST)
Date: Tue, 18 Jan 2011 18:38:42 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/5] Add per cgroup reclaim watermarks.
In-Reply-To: <20110119095650.02db87e0.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1101181831110.25382@chino.kir.corp.google.com>
References: <1294956035-12081-1-git-send-email-yinghan@google.com> <1294956035-12081-3-git-send-email-yinghan@google.com> <20110114091119.2f11b3b9.kamezawa.hiroyu@jp.fujitsu.com> <AANLkTimo7c3pwFoQvE140o6uFDOaRvxdq6+r3tQnfuPe@mail.gmail.com>
 <alpine.DEB.2.00.1101181227220.18781@chino.kir.corp.google.com> <AANLkTi=oFTf9pLKdBU4wXm4tTsWjH+E2q9d5_nm_7gt9@mail.gmail.com> <20110119095650.02db87e0.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Jan 2011, KAMEZAWA Hiroyuki wrote:

> > so something like per-memcg min_wmark which also needs to be reserved upfront?
> > 
> 
> I think the variable name 'min_free_kbytes' is the source of confusion...
> It's just a watermark to trigger background reclaim. It's not reservation.
> 

min_free_kbytes alters the min watermark of zones, meaning it can increase 
or decrease the amount of memory that is reserved for GFP_ATOMIC 
allocations, those in irq context, etc.  Since oom killed tasks don't 
allocate from any watermark, it also can increase or decrease the amount 
of memory available to oom killed tasks.  In that case, it _is_ a 
reservation of memory.

The issue is that it's done per-zone and if you're contending for those 
memory reserves that some oom killed tasks need to exit and free their 
memory, then it may deplete all memory in the DoS scenario I described.

> > KAMEZAWA gave an example on his early post, which some enterprise user
> > like to keep fixed amount of free pages
> > regardless of the hard_limit.
> > 
> > Since setting the wmarks has impact on the reclaim behavior of each
> > memcg,  adding this flexibility helps the system where it like to
> > treat memcg differently based on the priority.
> > 
> 
> Please add some tricks to throttle the usage of cpu by kswapd-for-memcg
> even when the user sets some bad value. And the total number of threads/workers
> for all memcg should be throttled, too. (I think this parameter can be 
> sysctl or root cgroup parameter.)
> 

I think that you probably want to add a min_free_kbytes for each memcg 
(and users who choose not to pre-reserve memory for things like oom killed 
tasks in that cgroup may set it to 0) and then have all other watermarks 
based off that setting just like the VM currently does whenever the global 
min_free_kbytes changes.

And I agree with your point that some cpu throttling will be needed to not 
be harmful to other cgroups whenever one memcg continuously hits its low 
watermark.  I'd suggest a global sysctl for that purpose to avoid certain 
memcg's impacting the preformance of others when under continuous reclaim 
to make sure everyone's on the same playing field.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
