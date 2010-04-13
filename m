Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 93DE76B01E3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 11:55:35 -0400 (EDT)
Message-ID: <4BC493B4.2040709@oracle.com>
Date: Tue, 13 Apr 2010 08:54:28 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: update documentation v6
References: <20100408145800.ca90ad81.kamezawa.hiroyu@jp.fujitsu.com>	<20100409134553.58096f80.kamezawa.hiroyu@jp.fujitsu.com>	<20100409100430.7409c7c4.randy.dunlap@oracle.com>	<20100413134553.7e2c4d3d.kamezawa.hiroyu@jp.fujitsu.com>	<20100413060405.GF3994@balbir.in.ibm.com>	<20100413152048.55408738.kamezawa.hiroyu@jp.fujitsu.com>	<20100413064855.GH3994@balbir.in.ibm.com> <20100413155841.ca6bc425.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100413155841.ca6bc425.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 04/12/10 23:58, KAMEZAWA Hiroyuki wrote:
> On Tue, 13 Apr 2010 12:18:55 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-04-13 15:20:48]:
>>
>> [snip]
>>
>> The alignment does not show up in the patches, hence the comments
>>
> 
> Should I replace TABs with SPACEs ? I think my mailer doesn't
> break TABS...

I'd stay with tabs.


> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  Documentation/cgroups/memory.txt |  277 ++++++++++++++++++++++++++-------------
>  1 file changed, 188 insertions(+), 89 deletions(-)
> 
> Index: mmotm-temp/Documentation/cgroups/memory.txt
> ===================================================================
> --- mmotm-temp.orig/Documentation/cgroups/memory.txt
> +++ mmotm-temp/Documentation/cgroups/memory.txt

> @@ -33,6 +23,45 @@ d. A CD/DVD burner could control the amo
>  e. There are several other use cases, find one or use the controller just
>     for fun (to learn and hack on the VM subsystem).
>  
> +Current Status: linux-2.6.34-mmotm(development version of 2010/April)
> +
> +Features:
> + - accounting anonymous pages, file caches, swap caches usage and limit them.

                                                                 and limiting them.

> + - private LRU and reclaim routine. (system's global LRU and private LRU
> +   work independently from each other)
> + - optionally, memory+swap usage can be accounted and limited.
> + - hierarchical accounting
> + - soft limit
> + - moving(recharging) account at moving a task is selectable.
> + - usage threshold notifier
> + - oom-killer disable knob and oom-notifier
> + - Root cgroup has no limit controls.
> +
> + Kernel memory and Hugepages are not under control yet. We just manage
> + pages on LRU. To add more controls, we have to take care of performance.
> +
> +Brief summary of control files.

> @@ -121,12 +150,19 @@ inserted into inode (radix-tree). While 
>  processes, duplicate accounting is carefully avoided.
>  
>  A RSS page is unaccounted when it's fully unmapped. A PageCache page is
> -unaccounted when it's removed from radix-tree.
> +unaccounted when it's removed from radix-tree. Even if RSS pages are fully
> +unmapped (by kswapd), they may exist as SwapCache in the system until they
> +are really freed. Such SwapCaches also also accounted.
> +A swapped-in page is not accounted until it's mapped.
> +
> +Note: The kernel does swapin-readahead and read multiple swaps at once.
> +This means swapped-in pages may contain pages for other tasks than a task
> +causing page fault. So, we avoid accounting at swap-in I/O.
>  
>  At page migration, accounting information is kept.
>  
> -Note: we just account pages-on-lru because our purpose is to control amount
> -of used pages. not-on-lru pages are tend to be out-of-control from vm view.
> +Note: we just account pages-on-LRU because our purpose is to control amount
> +of used pages, not-on-LRU pages tend to be out-of-control from VM view.

using a         ; there would be even better.
(yes, I know that you just changed it.)

>  
>  2.3 Shared Page Accounting
>  

> @@ -209,31 +260,29 @@ c. Enable CONFIG_CGROUP_MEM_RES_CTLR
>  
>  2. Make the new group and move bash into it
>  # mkdir /cgroups/0
> -# echo $$ >  /cgroups/0/tasks
> +# echo $$ > /cgroups/0/tasks
>  
>  Since now we're in the 0 cgroup,
>  We can alter the memory limit:

   we
(and no need for 2 lines above)

>  # echo 4M > /cgroups/0/memory.limit_in_bytes

> @@ -418,7 +516,7 @@ If we want to change this to 1G, we can 
>  # echo 1G > memory.soft_limit_in_bytes
>  
>  NOTE1: Soft limits take effect over a long period of time, since they involve
> -       reclaiming memory for balancing between memory cgroups
> +reclaiming memory for balancing between memory cgroups

Put the indentation back, please.

>  NOTE2: It is recommended to set the soft limit always below the hard limit,
>         otherwise the hard limit will take precedence.
>  



-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
