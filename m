Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m96ABh2r003548
	for <linux-mm@kvack.org>; Mon, 6 Oct 2008 15:41:43 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m96ABh2A446560
	for <linux-mm@kvack.org>; Mon, 6 Oct 2008 15:41:43 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m96ABgbN004773
	for <linux-mm@kvack.org>; Mon, 6 Oct 2008 15:41:43 +0530
Date: Mon, 6 Oct 2008 15:41:41 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/6] memcg: allocate page_cgroup at boot
Message-ID: <20081006101141.GB1202@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20081001165233.404c8b9c.kamezawa.hiroyu@jp.fujitsu.com> <20081001165603.a6e73c0d.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20081001165603.a6e73c0d.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-10-01 16:56:03]:

> Allocate all page_cgroup at boot and remove page_cgroup poitner
> from struct page. This patch adds an interface as
> 
>  struct page_cgroup *lookup_page_cgroup(struct page*)
> 
> All FLATMEM/DISCONTIGMEM/SPARSEMEM  and MEMORY_HOTPLUG is supported.
> 
> Remove page_cgroup pointer reduces the amount of memory by
>  - 4 bytes per PAGE_SIZE.
>  - 8 bytes per PAGE_SIZE
> if memory controller is disabled. (even if configured.)
> 
> On usual 8GB x86-32 server, this saves 8MB of NORMAL_ZONE memory.
> On my x86-64 server with 48GB of memory, this saves 96MB of memory.
> I think this reduction makes sense.
> 
> By pre-allocation, kmalloc/kfree in charge/uncharge are removed. 
> This means
>   - we're not necessary to be afraid of kmalloc faiulre.
>     (this can happen because of gfp_mask type.)
>   - we can avoid calling kmalloc/kfree.
>   - we can avoid allocating tons of small objects which can be fragmented.
>   - we can know what amount of memory will be used for this extra-lru handling.
> 
> I added printk message as
> 
> 	"allocated %ld bytes of page_cgroup"
>         "please try cgroup_disable=memory option if you don't want"
> 
> maybe enough informative for users.
> 
> Changelog: v5 -> v6.
>  * reflected comments.
>  * coding style fixes.
>  * removed "ctype" from uncharge.
>  * improved comment to show FLAT_NODE_MEM_MAP == !SPARSEMEM
>  * fixed errors in !SPARSEMEM codes
>  * removed unused function in !SPARSEMEM codes.
> (start from v5 because of series..)
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I like this patch very much

Reviewed-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
