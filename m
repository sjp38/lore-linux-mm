Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 081106B0035
	for <linux-mm@kvack.org>; Wed, 17 Sep 2014 12:51:09 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so2537951pad.7
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 09:51:09 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id qa6si35652394pdb.55.2014.09.17.08.59.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Sep 2014 08:59:28 -0700 (PDT)
Date: Wed, 17 Sep 2014 19:59:15 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [RFC] memory cgroup: my thoughts on memsw
Message-ID: <20140917155915.GB5065@esperanza>
References: <20140904143055.GA20099@esperanza>
 <20140915191435.GA8950@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140915191435.GA8950@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@parallels.com>, Konstantin Khorenko <khorenko@parallels.com>, LKML-MM <linux-mm@kvack.org>, LKML-cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

Hi Johannes,

On Mon, Sep 15, 2014 at 03:14:35PM -0400, Johannes Weiner wrote:
> > Finally, my understanding (may be crazy!) how the things should be
> > configured. Just like now, there should be mem_cgroup->res accounting
> > and limiting total user memory (cache+anon) usage for processes inside
> > cgroups. This is where there's nothing to do. However, mem_cgroup->memsw
> > should be reworked to account *only* memory that may be swapped out plus
> > memory that has been swapped out (i.e. swap usage).
> 
> But anon pages are not a resource, they are a swap space liability.
> Think of virtual memory vs. physical pages - the use of one does not
> necessarily result in the use of the other.  Without memory pressure,
> anonymous pages do not consume swap space.
> 
> What we *should* be accounting and limiting here is the actual finite
> resource: swap space.  Whenever we try to swap a page, its owner
> should be charged for the swap space - or the swapout be rejected.

I've been thinking quite a bit on the problem, and finally I believe
you're right: a separate swap limit would be better than anon+swap.

Provided we make the OOM-killer kill cgroups that exceed their soft
limit and can't be reclaimed, it will solve the problem with soft limits
I described above.

Besides, comparing to anon+swap, swap limit would be more efficient (we
only need to charge one res counter, not two) and understandable to
users (it's simple to setup a limit for both kinds of resources then,
because they never mix).

Finally, we could transfer user configuration from cgroup v1 to v2
easily: just setup swap.limit to be equal to memsw.limit-mem.limit; it
won't be exactly the same, but I bet nobody will notice any difference.

So, at least for now, I vote for moving from mem+swap to swap
accounting.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
