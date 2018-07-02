Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1190E6B0271
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 23:12:31 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id m12-v6so2469955wma.9
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 20:12:31 -0700 (PDT)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id k7-v6si6747004wrf.130.2018.07.01.20.12.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 20:12:29 -0700 (PDT)
Subject: Re: [BUG] Swap xarray workingset eviction warning.
References: <2920a634-0646-1500-7c4d-62c56932fe49@gmail.com>
 <20180702025059.GA9865@bombadil.infradead.org>
From: Gao Xiang <gaoxiang25@huawei.com>
Message-ID: <cb59ba75-61eb-4559-0865-202f6c78d3d0@huawei.com>
Date: Mon, 2 Jul 2018 11:11:53 +0800
MIME-Version: 1.0
In-Reply-To: <20180702025059.GA9865@bombadil.infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Peter Geis <pgwipeout@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

Hi Matthew,

On 2018/7/2 10:50, Matthew Wilcox wrote:
> On Sun, Jul 01, 2018 at 07:09:41PM -0400, Peter Geis wrote:
>> The warning is as follows:
>> [10409.408904] ------------[ cut here ]------------
>> [10409.408912] WARNING: CPU: 0 PID: 38 at ./include/linux/xarray.h:53
>> workingset_eviction+0x14c/0x154
> This is interesting.  Here's the code that leads to the warning:
> 
> static void *pack_shadow(int memcgid, pg_data_t *pgdat, unsigned long eviction)
> {
>         eviction >>= bucket_order;
>         eviction = (eviction << MEM_CGROUP_ID_SHIFT) | memcgid;
>         eviction = (eviction << NODES_SHIFT) | pgdat->node_id;
> 
>         return xa_mk_value(eviction);
> }
> 
> The warning itself comes from:
> 
> static inline void *xa_mk_value(unsigned long v)
> {
>         WARN_ON((long)v < 0);
>         return (void *)((v << 1) | 1);
> }

Sorry for breaking in, how do you think about considering

[RFC PATCH v4] <linux/tagptr.h>: Introduce tagged pointer
https://marc.info/?l=linux-kernel&m=153035209012070&w=2

to replace these masks? It seems boths for the XArray or old radix trees has many hacked code...

or if you think this implmentation is not ok, could you please give some suggestions or alternatives on tagptr...

> 
> The fact that we haven't seen this on other architectures makes me wonder
> if NODES_SHIFT or MEM_CGROUP_ID_SHIFT are messed up on Tegra?
> 
> Johannes, I wonder if you could help out here?  I'm not terribly familiar
> with this part of the workingset code.
Thanks,
Gao Xiang
