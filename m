Date: Wed, 27 Feb 2008 16:51:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] page reclaim throttle take2
Message-Id: <20080227165139.18e5933e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.1.00.0802262315030.11433@chino.kir.corp.google.com>
References: <47C4F9C0.5010607@linux.vnet.ibm.com>
	<alpine.DEB.1.00.0802262201390.1613@chino.kir.corp.google.com>
	<20080227160746.425E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<alpine.DEB.1.00.0802262315030.11433@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 26 Feb 2008 23:19:08 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:
> My suggestion is merely to make the number of concurrent page reclaim 
> threads be a function of how many online cpus there are.  Threads can 
> easily be added or removed for cpu hotplug events by callback functions.
> 
> That's different than allowing users to change the number of threads with 
> yet another sysctl.  Unless there are situations that can be presented 
> where tuning the number of threads is advantageous to reduce lock 
> contention, for example, and not simply working around other VM problems, 
> then I see no point for an additional sysctl.
> 
> So my suggestion is to implement this in terms of 
> CONFIG_NUM_RECLAIM_THREADS_PER_CPU and add callback functions for cpu 
> hotplug events that add or remove this number of threads.
> 

Hmm, but kswapd, which is main worker of page reclaiming, is per-node.
And reclaim is done based on zone.
per-zone/per-node throttling seems to make sense.

I know his environment has 4cpus per node but throttle to 3 was the best
number in his measurement. Then it seems num-per-cpu is excessive.
(At least, ratio(%) is better.)
When zone-reclaiming is improved to be scale well, we'll have to change
this throttle.

BTW, could someone try his patch on x86_64/ppc ? 
I'd like to see how contention is heavy on other machines.

Thanks,
-kame
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
