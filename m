Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E9B5B6B000A
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 00:16:16 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id t10-v6so9062499plh.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2018 21:16:16 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id k6-v6si41602482pgl.454.2018.11.04.21.16.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Nov 2018 21:16:16 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH 1/2] mm: use kvzalloc for swap_info_struct allocation
References: <37b60523-d085-71e9-fef9-80b90bfcef18@virtuozzo.com>
	<87wopsbb5v.fsf@yhuang-dev.intel.com>
	<f702278c-4e2f-a7fd-0e0a-150284ec8cc1@virtuozzo.com>
Date: Mon, 05 Nov 2018 13:16:09 +0800
In-Reply-To: <f702278c-4e2f-a7fd-0e0a-150284ec8cc1@virtuozzo.com> (Vasily
	Averin's message of "Mon, 5 Nov 2018 07:59:13 +0300")
Message-ID: <878t28ayue.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasily Averin <vvs@virtuozzo.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Aaron Lu <aaron.lu@intel.com>

Vasily Averin <vvs@virtuozzo.com> writes:

> On 11/5/18 3:50 AM, Huang, Ying wrote:
>> Vasily Averin <vvs@virtuozzo.com> writes:
>> 
>>> commit a2468cc9bfdf ("swap: choose swap device according to numa node")
>>> increased size of swap_info_struct up to 44 Kbytes, now it requires
>>> 4th order page.
>> 
>> Why swap_info_struct could be so large?  Because MAX_NUMNODES could be
>> thousands so that 'avail_lists' field could be tens KB?  If so, I think
>> it's fair to use kvzalloc().  Can you add one line comment?  Because
>> struct swap_info_struct is quite small in default configuration.
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

I see.  So this is a more practical issue than my original imagination.

But for default config, I mean

$ make defconfig

And it turns out,

CONFIG_NODES_SHIFT=6

Best Regards,
Huang, Ying
