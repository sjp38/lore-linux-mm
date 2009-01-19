Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CE66A6B00A2
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 02:12:33 -0500 (EST)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id n0J7CHRt023585
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 12:42:17 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n0J7ALAo4337692
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 12:40:21 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id n0J7CGX9001371
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 18:12:17 +1100
Date: Mon, 19 Jan 2009 12:42:20 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: update document to mention swapoff should be
	test.
Message-ID: <20090119071220.GE6039@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090119155748.acc60988.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090119155748.acc60988.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-19 15:57:48]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Considering recently found problem:
>  memcg-fix-refcnt-handling-at-swapoff.patch
> 
> It's better to mention about swapoff behavior in memcg_test document.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  Documentation/cgroups/memcg_test.txt |   24 ++++++++++++++++++++++--
>  1 file changed, 22 insertions(+), 2 deletions(-)
> 
> Index: mmotm-2.6.29-Jan16/Documentation/cgroups/memcg_test.txt
> ===================================================================
> --- mmotm-2.6.29-Jan16.orig/Documentation/cgroups/memcg_test.txt
> +++ mmotm-2.6.29-Jan16/Documentation/cgroups/memcg_test.txt
> @@ -1,6 +1,6 @@
>  Memory Resource Controller(Memcg)  Implementation Memo.
> -Last Updated: 2008/12/15
> -Base Kernel Version: based on 2.6.28-rc8-mm.
> +Last Updated: 2009/1/19
> +Base Kernel Version: based on 2.6.29-rc2.
> 
>  Because VM is getting complex (one of reasons is memcg...), memcg's behavior
>  is complex. This is a document for memcg's internal behavior.
> @@ -340,3 +340,23 @@ Under below explanation, we assume CONFI
>  	# mount -t cgroup none /cgroup -t cpuset,memory,cpu,devices
> 
>  	and do task move, mkdir, rmdir etc...under this.
> +
> + 9.7 swapoff.
> +	Besides management of swap is one of complicated parts of memcg,
> +	call path of swap-in at swapoff is not same as usual swap-in path..
> +	It's worth to be tested explicitly.
> +
> +	For example, test like following is good.
> +	(Shell-A)
> +	# mount -t cgroup none /cgroup -t memory
> +	# mkdir /cgroup/test
> +	# echo 40M > /cgroup/test/memory.limit_in_bytes
> +	# echo 0 > /cgroup/test/tasks

0? shouldn't this be pid? Potentially echo $$

> +	Run malloc(100M) program under this. You'll see 60M of swaps.
> +	(Shell-B)
> +	# move all tasks in /cgroup/test to /cgroup
> +	# /sbin/swapoff -a
> +	# rmdir /test/cgroup
> +	# kill malloc task.
> +
> +	Of course, tmpfs v.s. swapoff test should be tested, too.
>


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
