Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7DAD26B0010
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 22:51:02 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id b65-v6so9123088plb.5
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 19:51:02 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z15-v6si7594369pgs.570.2018.07.01.19.51.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 01 Jul 2018 19:51:01 -0700 (PDT)
Date: Sun, 1 Jul 2018 19:50:59 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [BUG] Swap xarray workingset eviction warning.
Message-ID: <20180702025059.GA9865@bombadil.infradead.org>
References: <2920a634-0646-1500-7c4d-62c56932fe49@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2920a634-0646-1500-7c4d-62c56932fe49@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Geis <pgwipeout@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Sun, Jul 01, 2018 at 07:09:41PM -0400, Peter Geis wrote:
> The warning is as follows:
> [10409.408904] ------------[ cut here ]------------
> [10409.408912] WARNING: CPU: 0 PID: 38 at ./include/linux/xarray.h:53
> workingset_eviction+0x14c/0x154

This is interesting.  Here's the code that leads to the warning:

static void *pack_shadow(int memcgid, pg_data_t *pgdat, unsigned long eviction)
{
        eviction >>= bucket_order;
        eviction = (eviction << MEM_CGROUP_ID_SHIFT) | memcgid;
        eviction = (eviction << NODES_SHIFT) | pgdat->node_id;

        return xa_mk_value(eviction);
}

The warning itself comes from:

static inline void *xa_mk_value(unsigned long v)
{
        WARN_ON((long)v < 0);
        return (void *)((v << 1) | 1);
}

The fact that we haven't seen this on other architectures makes me wonder
if NODES_SHIFT or MEM_CGROUP_ID_SHIFT are messed up on Tegra?

Johannes, I wonder if you could help out here?  I'm not terribly familiar
with this part of the workingset code.
