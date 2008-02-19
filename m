From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [RFC][PATCH] the proposal of improve page reclaim by throttle
Date: Tue, 19 Feb 2008 17:34:59 +1100
References: <20080219134715.7E90.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080219134715.7E90.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200802191735.00222.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tuesday 19 February 2008 16:44, KOSAKI Motohiro wrote:
> background
> ========================================
> current VM implementation doesn't has limit of # of parallel reclaim.
> when heavy workload, it bring to 2 bad things
>   - heavy lock contention
>   - unnecessary swap out
>
> abount 2 month ago, KAMEZA Hiroyuki proposed the patch of page
> reclaim throttle and explain it improve reclaim time.
> 	http://marc.info/?l=linux-mm&m=119667465917215&w=2
>
> but unfortunately it works only memcgroup reclaim.
> Today, I implement it again for support global reclaim and mesure it.
>
>
> test machine, method and result
> ==================================================
> <test machine>
> 	CPU:  IA64 x8
> 	MEM:  8GB
> 	SWAP: 2GB
>
> <test method>
> 	got hackbench from
> 		http://people.redhat.com/mingo/cfs-scheduler/tools/hackbench.c
>
> 	$ /usr/bin/time hackbench 120 process 1000
>
> 	this parameter mean consume all physical memory and
> 	1GB swap space on my test environment.
>
> <test result (average of 3 times measurement)>
>
> before:
> 	hackbench result:		282.30
> 	/usr/bin/time result
> 		user:			14.16
> 		sys:			1248.47
> 		elapse:			432.93
> 		major fault:		29026
> 	max parallel reclaim tasks:	1298
> 	max consumption time of
> 	 try_to_free_pages():		70394
>
> after:
> 	hackbench result:		30.36
> 	/usr/bin/time result
> 		user:			14.26
> 		sys:			294.44
> 		elapse:			118.01
> 		major fault:		3064
> 	max parallel reclaim tasks:	4
> 	max consumption time of
> 	 try_to_free_pages():		12234
>
>
> conclusion
> =========================================
> this patch improve 3 things.
> 1. reduce unnecessary swap
>    (see above major fault. about 90% reduced)
> 2. improve throughput performance
>    (see above hackbench result. about 90% reduced)
> 3. improve interactive performance.
>    (see above max consumption of try_to_free_pages.
>     about 80% reduced)
> 4. reduce lock contention.
>    (see above sys time. about 80% reduced)
>
>
> Now, we got about 1000% performance improvement of hackbench :)
>
>
>
> foture works
> ==========================================================
>  - more discussion with memory controller guys.

Hi,

Yeah this is definitely needed and a nice result.

I'm worried about a) placing a global limit on parallelism, and b)
placing a limit on parallelism at all.

I think it should maybe be a per-zone thing...

What happens if you make it a per-zone mutex, and allow just a single
process to reclaim pages from a given zone at a time? I guess that is
going to slow down throughput a little bit in some cases though...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
