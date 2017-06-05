Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2CA0E6B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 14:35:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r203so24365937wmb.2
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 11:35:31 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id n49si1869490edd.16.2017.06.05.11.35.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 05 Jun 2017 11:35:29 -0700 (PDT)
Date: Mon, 5 Jun 2017 14:35:11 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/6] mm: vmstat: move slab statistics from zone to node
 counters
Message-ID: <20170605183511.GA8915@cmpxchg.org>
References: <20170530181724.27197-1-hannes@cmpxchg.org>
 <20170530181724.27197-3-hannes@cmpxchg.org>
 <20170531091256.GA5914@osiris>
 <20170531113900.GB5914@osiris>
 <20170531171151.e4zh7ffzbl4w33gd@yury-thinkpad>
 <87mv9s2f8f.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87mv9s2f8f.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Yury Norov <ynorov@caviumnetworks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, linux-s390@vger.kernel.org

On Thu, Jun 01, 2017 at 08:07:28PM +1000, Michael Ellerman wrote:
> Yury Norov <ynorov@caviumnetworks.com> writes:
> 
> > On Wed, May 31, 2017 at 01:39:00PM +0200, Heiko Carstens wrote:
> >> On Wed, May 31, 2017 at 11:12:56AM +0200, Heiko Carstens wrote:
> >> > On Tue, May 30, 2017 at 02:17:20PM -0400, Johannes Weiner wrote:
> >> > > To re-implement slab cache vs. page cache balancing, we'll need the
> >> > > slab counters at the lruvec level, which, ever since lru reclaim was
> >> > > moved from the zone to the node, is the intersection of the node, not
> >> > > the zone, and the memcg.
> >> > > 
> >> > > We could retain the per-zone counters for when the page allocator
> >> > > dumps its memory information on failures, and have counters on both
> >> > > levels - which on all but NUMA node 0 is usually redundant. But let's
> >> > > keep it simple for now and just move them. If anybody complains we can
> >> > > restore the per-zone counters.
> >> > > 
> >> > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> >> > 
> >> > This patch causes an early boot crash on s390 (linux-next as of today).
> >> > CONFIG_NUMA on/off doesn't make any difference. I haven't looked any
> >> > further into this yet, maybe you have an idea?
> >
> > The same on arm64.
> 
> And powerpc.

It looks like we need the following on top. I can't reproduce the
crash, but it's verifiable with WARN_ONs in the vmstat functions that
the nodestat array isn't properly initialized when slab bootstraps:

---
