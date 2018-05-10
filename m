Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7ADF46B0610
	for <linux-mm@kvack.org>; Thu, 10 May 2018 10:04:46 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p1-v6so1466521wrm.7
        for <linux-mm@kvack.org>; Thu, 10 May 2018 07:04:46 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id t2-v6si991431edq.113.2018.05.10.07.04.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 May 2018 07:04:44 -0700 (PDT)
Date: Thu, 10 May 2018 15:04:16 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v3 1/2] mm: introduce memory.min
Message-ID: <20180510140410.GA11693@castle.DHCP.thefacebook.com>
References: <20180503114358.7952-1-guro@fb.com>
 <20180510133003.GH5325@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180510133003.GH5325@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>

On Thu, May 10, 2018 at 03:30:03PM +0200, Michal Hocko wrote:
> On Thu 03-05-18 12:43:57, Roman Gushchin wrote:
> > Memory controller implements the memory.low best-effort memory
> > protection mechanism, which works perfectly in many cases and
> > allows protecting working sets of important workloads from
> > sudden reclaim.
> > 
> > But its semantics has a significant limitation: it works
> > only as long as there is a supply of reclaimable memory.
> > This makes it pretty useless against any sort of slow memory
> > leaks or memory usage increases. This is especially true
> > for swapless systems. If swap is enabled, memory soft protection
> > effectively postpones problems, allowing a leaking application
> > to fill all swap area, which makes no sense.
> > The only effective way to guarantee the memory protection
> > in this case is to invoke the OOM killer.
> > 
> > It's possible to handle this case in userspace by reacting
> > on MEMCG_LOW events; but there is still a place for a fail-safe
> > in-kernel mechanism to provide stronger guarantees.
> > 
> > This patch introduces the memory.min interface for cgroup v2
> > memory controller. It works very similarly to memory.low
> > (sharing the same hierarchical behavior), except that it's
> > not disabled if there is no more reclaimable memory in the system.
> 
> Originally I was pushing for the hard guarantee before we landed with
> the best effort one. The assumption back then was that properly
> configured systems shouldn't see problems IIRC.

Personally, I'm also not a big fan of the current memory.low semantics.
If you remember, my very version of memory guarantee (back to 2013)
implemented a hard approach: https://lwn.net/Articles/540240/

> 
> It is not entirely clear to me what is the role of the low limit wrt.
> leaking application from the above description TBH. I presume you have a
> process without any low&hard limit which leaks and basically breaks the
> low limit expectation because of the lack of reclaimable memory and our
> memcg_low_reclaim fallback.
> 
> If that is the case then the hard limit should indeed protect the
> respective memcg from reclaim. But what is the actuall guarantee?
> We can reclaim that memory by the OOM killer, because there is no
> protection from killing a memcg under the min limit. So what is the
> actual semantic?

If memcg memory usage is under its effective min boundary, its memory
won't be reclaimed.

Making OOM killer aware of memory guarantees is a separate topic
(and definitely a good idea to discuss!), but let's agree on
a simple fact that there are many workloads which prefer
to be killed, rather than suffer from a too high memory pressure.

> 
> Also how is an admin supposed to configure those limits? low limit
> doesn't reall protect in some cases so why should it be used at all?
> I see how min matches max and low matches high, so there is a nice
> symmetry but aren't we adding additional complexity to the API?
> Isn't the real problem that the other guy (leaking application) doesn't
> have any cap?

My main point is that memory.low requires an userspace agent
to actually guarantee something. This agent supposed to track
low memory events and somehow decrease memory pressure,
if memory.low watermark is reached (stop some workloads, for example).
This is not always handy, and having strong guarantee makes sense, IMO.

We're experimenting with different setups, and the current approach
is to set memory.min to the minimal value which guarantees normal
functioning of a workload, while memory.low can be set to a much higher
value, which sometimes brings some performance gains.

Thanks!
