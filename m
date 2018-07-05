Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3AA656B0007
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 12:57:51 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n2-v6so3568522edr.5
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 09:57:51 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 64-v6si5433799eda.432.2018.07.05.09.57.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 05 Jul 2018 09:57:49 -0700 (PDT)
Date: Thu, 5 Jul 2018 13:00:19 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [BUG] Swap xarray workingset eviction warning.
Message-ID: <20180705170019.GA14929@cmpxchg.org>
References: <2920a634-0646-1500-7c4d-62c56932fe49@gmail.com>
 <20180702025059.GA9865@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180702025059.GA9865@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Peter Geis <pgwipeout@gmail.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Hello,

On Sun, Jul 01, 2018 at 07:50:59PM -0700, Matthew Wilcox wrote:
> On Sun, Jul 01, 2018 at 07:09:41PM -0400, Peter Geis wrote:
> > The warning is as follows:
> > [10409.408904] ------------[ cut here ]------------
> > [10409.408912] WARNING: CPU: 0 PID: 38 at ./include/linux/xarray.h:53
> > workingset_eviction+0x14c/0x154
> 
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
> 
> The fact that we haven't seen this on other architectures makes me wonder
> if NODES_SHIFT or MEM_CGROUP_ID_SHIFT are messed up on Tegra?
> 
> Johannes, I wonder if you could help out here?  I'm not terribly familiar
> with this part of the workingset code.

This could be a matter of uptime, but the warning triggers on a thing
that is supposed to happen everywhere eventually. Let's fix it.

The eviction timestamp is from a monotonically increasing counter that
will eventually reach values high enough that the left-shifts for
memcg id and node id will truncate the upper bits.

The bucketing logic isn't supposed to prevent this truncation, it's
just making sure that the namespace of the truncated timestamp field
is big enough to cover the full range of actionable refault pages.

xa_mk_value() doesn't understand that we're okay with it chopping off
our upper-most bit. We shouldn't make this an API behavior, either, so
let's fix the workingset code to always clear those bits before hand.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/mm/workingset.c b/mm/workingset.c
index a466e731231d..1da19c04b6f7 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -173,6 +173,7 @@ static unsigned int bucket_order __read_mostly;
 static void *pack_shadow(int memcgid, pg_data_t *pgdat, unsigned long eviction)
 {
 	eviction >>= bucket_order;
+	eviction &= EVICTION_MASK;
 	eviction = (eviction << MEM_CGROUP_ID_SHIFT) | memcgid;
 	eviction = (eviction << NODES_SHIFT) | pgdat->node_id;
 
