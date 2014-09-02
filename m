Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id C81FD6B0036
	for <linux-mm@kvack.org>; Tue,  2 Sep 2014 18:18:39 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id 10so113203lbg.16
        for <linux-mm@kvack.org>; Tue, 02 Sep 2014 15:18:38 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id l18si6620414lbg.26.2014.09.02.15.18.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 02 Sep 2014 15:18:37 -0700 (PDT)
Date: Tue, 2 Sep 2014 18:18:14 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: regression caused by cgroups optimization in 3.17-rc2
Message-ID: <20140902221814.GA18069@cmpxchg.org>
References: <54061505.8020500@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54061505.8020500@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Hi Dave,

On Tue, Sep 02, 2014 at 12:05:41PM -0700, Dave Hansen wrote:
> I'm seeing a pretty large regression in 3.17-rc2 vs 3.16 coming from the
> memory cgroups code.  This is on a kernel with cgroups enabled at
> compile time, but not _used_ for anything.  See the green lines in the
> graph:
> 
> 	https://www.sr71.net/~dave/intel/regression-from-05b843012.png
> 
> The workload is a little parallel microbenchmark doing page faults:

Ouch.

> > https://github.com/antonblanchard/will-it-scale/blob/master/tests/page_fault2.c
> 
> The hardware is an 8-socket Westmere box with 160 hardware threads.  For
> some reason, this does not affect the version of the microbenchmark
> which is doing completely anonymous page faults.
> 
> I bisected it down to this commit:
> 
> > commit 05b8430123359886ef6a4146fba384e30d771b3f
> > Author: Johannes Weiner <hannes@cmpxchg.org>
> > Date:   Wed Aug 6 16:05:59 2014 -0700
> > 
> >     mm: memcontrol: use root_mem_cgroup res_counter
> >     
> >     Due to an old optimization to keep expensive res_counter changes at a
> >     minimum, the root_mem_cgroup res_counter is never charged; there is no
> >     limit at that level anyway, and any statistics can be generated on
> >     demand by summing up the counters of all other cgroups.
> >     
> >     However, with per-cpu charge caches, res_counter operations do not even
> >     show up in profiles anymore, so this optimization is no longer
> >     necessary.
> >     
> >     Remove it to simplify the code.

Accounting new pages is buffered through per-cpu caches, but taking
them off the counters on free is not, so I'm guessing that above a
certain allocation rate the cost of locking and changing the counters
takes over.  Is there a chance you could profile this to see if locks
and res_counter-related operations show up?

I can't reproduce this complete breakdown on my smaller test gear, but
I do see an improvement with the following patch:

---
