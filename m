Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id D0DA36B0036
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 06:30:47 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id p9so708438lbv.38
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 03:30:47 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k3si2357199lag.22.2014.09.05.03.30.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Sep 2014 03:30:46 -0700 (PDT)
Date: Fri, 5 Sep 2014 11:30:42 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: page_alloc: Default to node-ordering on 64-bit NUMA
 machines
Message-ID: <20140905103041.GH17501@suse.de>
References: <20140901125551.GI12424@suse.de>
 <20140902135120.GC29501@cmpxchg.org>
 <20140902152143.GL12424@suse.de>
 <20140904152915.GB10794@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140904152915.GB10794@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linuxfoundation.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Fengguang Wu <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 04, 2014 at 11:29:29AM -0400, Johannes Weiner wrote:
> On Tue, Sep 02, 2014 at 04:21:43PM +0100, Mel Gorman wrote:
> > On Tue, Sep 02, 2014 at 09:51:20AM -0400, Johannes Weiner wrote:
> > > On Mon, Sep 01, 2014 at 01:55:51PM +0100, Mel Gorman wrote:
> > > > I cannot find a good reason to incur a performance penalty on all 64-bit NUMA
> > > > machines in case someone throws a brain damanged TV or graphics card in there.
> > > > This patch defaults to node-ordering on 64-bit NUMA machines. I was tempted
> > > > to make it default everywhere but I understand that some embedded arches may
> > > > be using 32-bit NUMA where I cannot predict the consequences.
> > > 
> > > This patch is a step in the right direction, but I'm not too fond of
> > > further fragmenting this code and where it applies, while leaving all
> > > the complexity from the heuristics and the zonelist building in, just
> > > on spec.  Could we at least remove the heuristics too?  If anybody is
> > > affected by this, they can always override the default on the cmdline.
> > 
> > I see no problem with deleting the heuristics. Default node for 64-bit
> > and default zone for 32-bit sound ok to you?
> 
> Is there a strong reason against defaulting both to node order?  Zone
> ordering, if anything, is a niche application.  We might even be able
> to remove it in the future.  We still have the backup of allowing the
> user to explicitely request zone ordering on the commandline, should
> someone depend on it unexpectedly.

Low memory depletion is the reason to default to zone order on 32-bit
NUMA. If processes on node 0 deplete the Normal zone from normal
activity then other nodes must keep reclaiming from Normal for all kernel
allocations. The problem is worse if CONFIG_HIGHPTE is not set.

A default of node-ordering on 32-bit NUMA increases low memory pressure
leading to increased reclaim and potentially easier to trigger OOM. I
expect this problem was worse in the past when the normal zone could be
filled with dirty pages under writeback.  However low memory pressure is
still enough of a concern that I'm wary of changing the default of 32-bit
NUMA without knowing who even cares about 32-bit NUMA.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
