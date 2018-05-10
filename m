Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 399D46B0603
	for <linux-mm@kvack.org>; Thu, 10 May 2018 09:30:06 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 70-v6so863608wmb.2
        for <linux-mm@kvack.org>; Thu, 10 May 2018 06:30:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k55-v6si1027960edd.138.2018.05.10.06.30.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 May 2018 06:30:04 -0700 (PDT)
Date: Thu, 10 May 2018 15:30:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 1/2] mm: introduce memory.min
Message-ID: <20180510133003.GH5325@dhcp22.suse.cz>
References: <20180503114358.7952-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180503114358.7952-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>

On Thu 03-05-18 12:43:57, Roman Gushchin wrote:
> Memory controller implements the memory.low best-effort memory
> protection mechanism, which works perfectly in many cases and
> allows protecting working sets of important workloads from
> sudden reclaim.
> 
> But its semantics has a significant limitation: it works
> only as long as there is a supply of reclaimable memory.
> This makes it pretty useless against any sort of slow memory
> leaks or memory usage increases. This is especially true
> for swapless systems. If swap is enabled, memory soft protection
> effectively postpones problems, allowing a leaking application
> to fill all swap area, which makes no sense.
> The only effective way to guarantee the memory protection
> in this case is to invoke the OOM killer.
> 
> It's possible to handle this case in userspace by reacting
> on MEMCG_LOW events; but there is still a place for a fail-safe
> in-kernel mechanism to provide stronger guarantees.
> 
> This patch introduces the memory.min interface for cgroup v2
> memory controller. It works very similarly to memory.low
> (sharing the same hierarchical behavior), except that it's
> not disabled if there is no more reclaimable memory in the system.

Originally I was pushing for the hard guarantee before we landed with
the best effort one. The assumption back then was that properly
configured systems shouldn't see problems IIRC.

It is not entirely clear to me what is the role of the low limit wrt.
leaking application from the above description TBH. I presume you have a
process without any low&hard limit which leaks and basically breaks the
low limit expectation because of the lack of reclaimable memory and our
memcg_low_reclaim fallback.

If that is the case then the hard limit should indeed protect the
respective memcg from reclaim. But what is the actuall guarantee?
We can reclaim that memory by the OOM killer, because there is no
protection from killing a memcg under the min limit. So what is the
actual semantic?

Also how is an admin supposed to configure those limits? low limit
doesn't reall protect in some cases so why should it be used at all?
I see how min matches max and low matches high, so there is a nice
symmetry but aren't we adding additional complexity to the API?
Isn't the real problem that the other guy (leaking application) doesn't
have any cap?

Please note I haven't looked at the implementation yet but I would like
to make sure I understand the whole concept first.
-- 
Michal Hocko
SUSE Labs
