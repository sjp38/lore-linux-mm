Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 69AEB6B0007
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 01:10:20 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id o17so7285656pgi.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2018 22:10:20 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id i13-v6si42073056pgd.311.2018.11.04.22.10.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Nov 2018 22:10:19 -0800 (PST)
Date: Mon, 5 Nov 2018 14:10:16 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH 1/2] mm: use kvzalloc for swap_info_struct allocation
Message-ID: <20181105061016.GA4502@intel.com>
References: <37b60523-d085-71e9-fef9-80b90bfcef18@virtuozzo.com>
 <87wopsbb5v.fsf@yhuang-dev.intel.com>
 <f702278c-4e2f-a7fd-0e0a-150284ec8cc1@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f702278c-4e2f-a7fd-0e0a-150284ec8cc1@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasily Averin <vvs@virtuozzo.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Mon, Nov 05, 2018 at 07:59:13AM +0300, Vasily Averin wrote:
> 
> 
> On 11/5/18 3:50 AM, Huang, Ying wrote:
> > Vasily Averin <vvs@virtuozzo.com> writes:
> > 
> >> commit a2468cc9bfdf ("swap: choose swap device according to numa node")
> >> increased size of swap_info_struct up to 44 Kbytes, now it requires
> >> 4th order page.
> > 
> > Why swap_info_struct could be so large?  Because MAX_NUMNODES could be
> > thousands so that 'avail_lists' field could be tens KB?  If so, I think
> > it's fair to use kvzalloc().  Can you add one line comment?  Because
> > struct swap_info_struct is quite small in default configuration.
> 
> I was incorrect not 44Kb but 40kb should be here.
> We have found CONFIG_NODES_SHIFT=10 in new RHEL7 update 6 kernel,
> default ubuntu kernels have the same setting too.
> 
> crash> struct swap_info_struct -o
> struct swap_info_struct {
>       [0] unsigned long flags;
>       [8] short prio;
>            ...
>     [140] spinlock_t lock;
>     [144] struct plist_node list;
>     [184] struct plist_node avail_lists[1024]; <<<< here

So every 'struct plist_node' takes 40 bytes and 1024 of them take a
total of 40960 bytes, which is 10 pages and need an order-4 page to host
them. It looks a little too much, especially consider most of the space
will left be unused since most systems have nodes <= 4. I didn't realize
this problem when developing this patch, thanks for pointing this out.

I think using kvzalloc() as is done by your patch is better here as it
can avoid possible failure of swapon.

Acked-by: Aaron Lu <aaron.lu@intel.com>

BTW, for systems with few swap devices this may not be a big deal, but
according to your description, your workload will create a lot of swap
devices and each of them will likely cause an order-4 unmovable pages
allocated(when kvzalloc() doesn't fallback). I was thinking maybe we
should convert avail_lists to a pointer in swap_info_struct and use
vzalloc() for it.

Thanks,
Aaron

>   [41144] struct swap_cluster_info *cluster_info;
>   [41152] struct swap_cluster_list free_clusters;
>           ...
>   [41224] spinlock_t cont_lock;
> }
> SIZE: 41232
> 
> struct swap_info_struct {
>         ...
>         RH_KABI_EXTEND(struct plist_node avail_lists[MAX_NUMNODES]) /* entry in swap_avail_head */
>         ...
> }
> 
> #define MAX_NUMNODES    (1 << NODES_SHIFT)
> 
> #ifdef CONFIG_NODES_SHIFT 
> #define NODES_SHIFT     CONFIG_NODES_SHIFT
> #else
> #define NODES_SHIFT     0
> #endif
> 
> /boot/config-4.15.0-38-generic:CONFIG_NODES_SHIFT=10
> 
