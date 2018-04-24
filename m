Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 43F506B000D
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 09:27:27 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id n4so8692463pgn.9
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 06:27:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m13si11898943pgs.49.2018.04.24.06.27.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Apr 2018 06:27:25 -0700 (PDT)
Date: Tue, 24 Apr 2018 07:27:21 -0600
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: per-NUMA memory limits in mem cgroup?
Message-ID: <20180424132721.GF17484@dhcp22.suse.cz>
References: <5ADA26AB.6080209@windriver.com>
 <20180422124648.GD17484@dhcp22.suse.cz>
 <5ADDFBD1.7010009@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5ADDFBD1.7010009@windriver.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Friesen <chris.friesen@windriver.com>
Cc: "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Mon 23-04-18 11:29:21, Chris Friesen wrote:
> On 04/22/2018 08:46 AM, Michal Hocko wrote:
> > On Fri 20-04-18 11:43:07, Chris Friesen wrote:
> 
> > > The specific scenario I'm considering is that of a hypervisor host.  I have
> > > system management stuff running on the host that may need more than one
> > > core, and currently these host tasks might be affined to cores from multiple
> > > NUMA nodes.  I'd like to put a cap on how much memory the host tasks can
> > > allocate from each NUMA node in order to ensure that there is a guaranteed
> > > amount of memory available for VMs on each NUMA node.
> > > 
> > > Is this possible, or are the knobs just not there?
> > 
> > Not possible right now. What would be the policy when you reach the
> > limit on one node? Fallback to other nodes? What if those hit the limit
> > as well? OOM killer or an allocation failure?
> 
> I'd envision it working exactly the same as the current memory cgroup, but
> with the ability to specify optional per-NUMA-node limits in addition to
> system-wide.

OK, so you would have a per numa percentage of the hard limit? But more
importantly, note that the page allocation is done way before the charge
so we do not have any control over where the memory get allocated from
so we would have to play nasty tricks in the reclaim to somehow balance
NUMA charge pools. And I can easily imagine we would go OOM before we
saturate all NUMA pools. But I didn't get to think this whole thing
through as I am conferencing these days. I am even not sure the whole
thing is the best idea as well. It sounds more easily then it would end
up, I suspect.
-- 
Michal Hocko
SUSE Labs
