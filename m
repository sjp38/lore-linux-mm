Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E76246008E4
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 23:40:55 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o733VTj3021139
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 23:31:29 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o733jH1D389638
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 23:45:17 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o733jHF0014048
	for <linux-mm@kvack.org>; Mon, 2 Aug 2010 23:45:17 -0400
Date: Tue, 3 Aug 2010 09:15:13 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mm 2/5] use ID in page cgroup
Message-ID: <20100803034513.GF3863@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100802191113.05c982e4.kamezawa.hiroyu@jp.fujitsu.com>
 <20100802191410.cbf03d67.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100802191410.cbf03d67.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, gthelen@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-08-02 19:14:10]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, addresses of memory cgroup can be calculated by their ID without complex.
> This patch relplaces pc->mem_cgroup from a pointer to a unsigned short.
> On 64bit architecture, this offers us more 6bytes room per page_cgroup.
> Use 2bytes for blkio-cgroup's page tracking. More 4bytes will be used for
> some light-weight concurrent access.
> 
> We may able to move this id onto flags field but ...go step by step.
> 
> Changelog: 20100730
>  - fixed some garbage added by debug code in early stage
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/page_cgroup.h |    3 ++-
>  mm/memcontrol.c             |   32 +++++++++++++++++++-------------
>  mm/page_cgroup.c            |    2 +-
>  3 files changed, 22 insertions(+), 15 deletions(-)
> 
> Index: mmotm-0727/include/linux/page_cgroup.h
> ===================================================================
> --- mmotm-0727.orig/include/linux/page_cgroup.h
> +++ mmotm-0727/include/linux/page_cgroup.h
> @@ -12,7 +12,8 @@
>   */
>  struct page_cgroup {
>  	unsigned long flags;
> -	struct mem_cgroup *mem_cgroup;
> +	unsigned short mem_cgroup;	/* ID of assigned memory cgroup */
> +	unsigned short blk_cgroup;	/* Not Used..but will be. */
>  	struct page *page;
>  	struct list_head lru;		/* per cgroup LRU list */
>  };

Can I recommend that on 64 bit systems, we merge the flag, mem_cgroup
and blk_cgroup into one 8 byte value. We could use
__attribute("packed") and do something like this

struct page_cgroup {
        unsigned int flags;
        unsigned short mem_cgroup;
        unsigned short blk_cgroup;
        ...
} __attribute(("packed"));

Then we need to make sure we don't use more that 32 bits for flags,
which is very much under control at the moment.

This will save us 8 bytes in total on 64 bit systems and nothing on 32
bit systems, but will enable blkio cgroup to co-exist.


-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
