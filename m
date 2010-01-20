Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0DA356B006A
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 04:38:01 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp01.au.ibm.com (8.14.3/8.13.1) with ESMTP id o0K9a3St002683
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 20:36:03 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0K9XEAV1163352
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 20:33:15 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0K9br44021452
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 20:37:54 +1100
Message-ID: <4B56CEF0.2040406@linux.vnet.ibm.com>
Date: Wed, 20 Jan 2010 15:07:52 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH mmotm] memcg use generic percpu allocator instead of private
 one
References: <20100120161825.15c372ac.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100120161825.15c372ac.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, kirill@shutemov.name
List-ID: <linux-mm.kvack.org>

On Wednesday 20 January 2010 12:48 PM, KAMEZAWA Hiroyuki wrote:
> This patch is onto mmotm Jan/15.
> =
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> When per-cpu counter for memcg was implemneted, dynamic percpu allocator
> was not very good. But now, we have good one and useful macros.
> This patch replaces memcg's private percpu counter implementation with
> generic dynamic percpu allocator and macros.
> 
> The benefits are
> 	- We can remove private implementation.
> 	- The counters will be NUMA-aware. (Current one is not...)
> 	- This patch reduces sizeof(struct mem_cgroup). Then,
> 	  struct mem_cgroup may be fit in page size on small config.
> 
> By this, size of text is reduced.
>  [Before]
>  [kamezawa@bluextal mmotm-2.6.33-Jan15]$ size mm/memcontrol.o
>    text    data     bss     dec     hex filename
>   24373    2528    4132   31033    7939 mm/memcontrol.o
>  [After]
>  [kamezawa@bluextal mmotm-2.6.33-Jan15]$ size mm/memcontrol.o
>    text    data     bss     dec     hex filename
>   23913    2528    4132   30573    776d mm/memcontrol.o
> 
> This includes no functional changes.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


Before review, could you please post parallel pagefault data on a large
system, since root now uses these per cpu counters and its overhead is
now dependent on these counters. Also the data read from root cgroup is
also dependent on these, could you make sure that is not broken.

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
