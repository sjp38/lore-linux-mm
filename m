Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5E2EA6B0221
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 13:04:44 -0400 (EDT)
Date: Fri, 9 Apr 2010 10:04:30 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] memcg: update documentation v4
Message-Id: <20100409100430.7409c7c4.randy.dunlap@oracle.com>
In-Reply-To: <20100409134553.58096f80.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100408145800.ca90ad81.kamezawa.hiroyu@jp.fujitsu.com>
	<20100409134553.58096f80.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, randy.dunlap@oracle.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 9 Apr 2010 13:45:53 +0900 KAMEZAWA Hiroyuki wrote:

> Documentation update.
> 
> Some information are old, and  I think current documentation doesn't work
> as "a guide for users".
> We need summary of all of our controls, at least.
> 
> Changelog: 2010/04/09
> * replace 'lru' with 'LRU' and 'oom' with 'OOM'
> * fixed double-space breakage
> * applied all comments and fixed wrong parts pointed out.
> * fixed cgroup.procs
> 
> Changelog: 2009/04/07
> * fixed tons of typos.
> * replaced "memcg" with "memory cgroup" AMAP.
> * replaced "mem+swap" with "memory+swap"
> 
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  Documentation/cgroups/memory.txt |  277 ++++++++++++++++++++++++++-------------
>  1 file changed, 188 insertions(+), 89 deletions(-)
> 
> Index: mmotm-temp/Documentation/cgroups/memory.txt
> ===================================================================
> --- mmotm-temp.orig/Documentation/cgroups/memory.txt
> +++ mmotm-temp/Documentation/cgroups/memory.txt

> @@ -106,14 +135,14 @@ the necessary data structures and check 
>  is over its limit. If it is then reclaim is invoked on the cgroup.
>  More details can be found in the reclaim section of this document.
>  If everything goes well, a page meta-data-structure called page_cgroup is
> -allocated and associated with the page.  This routine also adds the page to
> -the per cgroup LRU.
> +updated. page_cgroup has its own LRU on cgroup.
> +(*) page_cgroup structure is allocated at boot/memory-hotplug time.
>  
>  2.2.1 Accounting details
>  
>  All mapped anon pages (RSS) and cache pages (Page Cache) are accounted.
> -(some pages which never be reclaimable and will not be on global LRU
> - are not accounted. we just accounts pages under usual vm management.)
> +Some pages which are never reclaimable and will not be on the global LRU
> +are not accounted. We just accounts pages under usual VM management.

                      We just account

>  
>  RSS pages are accounted at page_fault unless they've already been accounted
>  for earlier. A file page will be accounted for as Page Cache when it's

> @@ -248,15 +297,24 @@ caches, RSS and Active pages/Inactive pa
>  
>  4. Testing
>  
> -Balbir posted lmbench, AIM9, LTP and vmmstress results [10] and [11].
> -Apart from that v6 has been tested with several applications and regular
> -daily use. The controller has also been tested on the PPC64, x86_64 and
> -UML platforms.
> +For testing features and implementation, see memcg_test.txt.
> +
> +Performance test is also important. To see pure memory cgroup's overhead,
> +testing on tmpfs will give you good numbers of small overheads.
> +Example: do kernel make on tmpfs.
> +
> +Page-fault scalability is also important. At measuring parallel
> +page fault test, multi-process test may be better than multi-thread
> +test because it has noise of shared objects/status.
> +
> +But above 2 is testing extreme situation. Trying usual test under memory cgroup

I would have said:
   But the above two are testing extreme situations.

> +is always helpful.
> +
>  
>  4.1 Troubleshooting
>  
>  Sometimes a user might find that the application under a cgroup is
> -terminated. There are several causes for this:
> +terminated by OOM killer. There are several causes for this:
>  
>  1. The cgroup limit is too low (just too low to do anything useful)
>  2. The user is using anonymous memory and swap is turned off or too low

> @@ -418,7 +517,7 @@ If we want to change this to 1G, we can 
>  # echo 1G > memory.soft_limit_in_bytes
>  
>  NOTE1: Soft limits take effect over a long period of time, since they involve
> -       reclaiming memory for balancing between memory cgroups
> +reclaiming memory for balancing between memory cgroups

Why remove those leading spaces (indent/text alignment)?
Compare below.

>  NOTE2: It is recommended to set the soft limit always below the hard limit,
>         otherwise the hard limit will take precedence.
>  
> @@ -495,27 +594,27 @@ It's applicable for root and non-root cg
>  
>  memory.oom_control file is for OOM notification and other controls.
>  
> -Memory controler implements oom notifier using cgroup notification
> -API (See cgroups.txt). It allows to register multiple oom notification
> -delivery and gets notification when oom happens.
> +Memory cgroup implements OOM notifier using cgroup notification
> +API (See cgroups.txt). It allows to register multiple OOM notification
> +delivery and gets notification when OOM happens.
>  
>  To register a notifier, application need:
>   - create an eventfd using eventfd(2)
>   - open memory.oom_control file
>   - write string like "<event_fd> <memory.oom_control>" to cgroup.event_control
>  
> -Application will be notifier through eventfd when oom happens.
> +Application will be notifier through eventfd when OOM happens.

                       notified

>  OOM notification doesn't work for root cgroup.
>  
> -You can disable oom-killer by writing "1" to memory.oom_control file.
> +You can disable OOM-killer by writing "1" to memory.oom_control file.
>  As.
>  	#echo 1 > memory.oom_control
>  
> -This operation is only allowed to the top cgroup of subhierarchy.
> -If oom-killer is disabled, tasks under cgroup will hang/sleep
> -in memcg's oom-waitq when they request accountable memory.
> +This operation is only allowed to the top cgroup of sub-hierarchy.
> +If OOM-killer is disabled, tasks under cgroup will hang/sleep
> +in memory cgroup's OOM-waitqueue when they request accountable memory.
>  
> -For running them, you have to relax the memcg's oom sitaution by
> +For running them, you have to relax the memory cgroup's OOM status by
>  	* enlarge limit or reduce usage.
>  To reduce usage,
>  	* kill some tasks.


Almost there.  :)

thanks,
---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
