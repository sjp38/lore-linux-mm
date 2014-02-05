Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 195B36B0035
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 10:42:06 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id e16so869159qcx.24
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 07:42:05 -0800 (PST)
Received: from mail-qc0-x232.google.com (mail-qc0-x232.google.com [2607:f8b0:400d:c01::232])
        by mx.google.com with ESMTPS id o46si20875152qgo.58.2014.02.05.07.42.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Feb 2014 07:42:05 -0800 (PST)
Received: by mail-qc0-f178.google.com with SMTP id m20so859710qcx.23
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 07:42:05 -0800 (PST)
Date: Wed, 5 Feb 2014 10:42:02 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH -v2 4/6] memcg: make sure that memcg is not offline when
 charging
Message-ID: <20140205154202.GA2786@htj.dyndns.org>
References: <1391520540-17436-1-git-send-email-mhocko@suse.cz>
 <1391520540-17436-5-git-send-email-mhocko@suse.cz>
 <20140204162939.GP6963@cmpxchg.org>
 <20140205133834.GB2425@dhcp22.suse.cz>
 <20140205152821.GY6963@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140205152821.GY6963@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hello, guys.

On Wed, Feb 05, 2014 at 10:28:21AM -0500, Johannes Weiner wrote:
> I thought more about this and talked to Tejun as well.  He told me
> that the rcu grace period between disabling tryget and calling
> css_offline() is currently an implementation detail of the refcounter
> that css uses, but it's not a guarantee.  So my initial idea of

Yeah, that's an implementation detail coming from how percpu_ref is
implemented at the moment.  Also, it's a sched_rcu grace period, not a
normal one.  The only RCU-related guarnatee that cgroup core gives is
that there will be a full RCU grace period between css's ref reaching
zero and invocation of ->css_free() so that it's safe to do
css_tryget() inside RCU critical sections.

In short, offlining is *not* protected by RCU.  Freeing is.

> Well, css_free() is the callback invoked when the ref counter hits 0,
> and that is a guarantee.  From a memcg perspective, it's the right
> place to do reparenting, not css_offline().

So, css_offline() is cgroup telling controllers two things.

* The destruction of the css, which will commence when css ref reaches
  zero, has initiated.  If you're holding any long term css refs for
  caching and stuff, put them so that destruction can actually happen.

* Any css_tryget() attempts which haven't finished yet are guaranteed
  to fail.  (there's no implied RCU protection here)

Maybe offline is a bit of misnomer.  It's really just telling the
controllers to get prepared to be destroyed.

> Here is the only exception to the above: swapout records maintain
> permanent css references, so they prevent css_free() from running.
> For that reason alone we should run one optimistic reparenting in
> css_offline() to make sure one swap record does not pin gigabytes of
> pages in an offlined cgroup, which is unreachable for reclaim.  But
> the reparenting for *correctness* is in css_free(), not css_offline().

A more canonical use case can be found in blkcg.  blkcg holds "cache"
css refs for optimization in the indexing data structure.  On offline,
blkcg purges those refs so that those stale cache refs don't put off
actual destruction for too long.  But yeah the above sounds like a
plausible use case too.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
