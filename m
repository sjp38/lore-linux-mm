Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3AD076B0035
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 16:07:14 -0500 (EST)
Received: by mail-qa0-f45.google.com with SMTP id m5so3668696qaj.4
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 13:07:14 -0800 (PST)
Received: from mail-qc0-x22f.google.com (mail-qc0-x22f.google.com [2607:f8b0:400d:c01::22f])
        by mx.google.com with ESMTPS id t7si2156174qav.100.2014.02.13.13.07.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Feb 2014 13:07:13 -0800 (PST)
Received: by mail-qc0-f175.google.com with SMTP id x13so18556930qcv.20
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 13:07:12 -0800 (PST)
Date: Thu, 13 Feb 2014 16:07:09 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] memcg: barriers to see memcgs as fully initialized
Message-ID: <20140213210709.GE17608@htj.dyndns.org>
References: <alpine.LSU.2.11.1402121717420.5917@eggly.anvils>
 <alpine.LSU.2.11.1402121727050.5917@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1402121727050.5917@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello, Hugh.

On Wed, Feb 12, 2014 at 05:29:09PM -0800, Hugh Dickins wrote:
> Commit d8ad30559715 ("mm/memcg: iteration skip memcgs not yet fully
> initialized") is not bad, but Greg Thelen asks "Are barriers needed?"
> 
> Yes, I'm afraid so: this makes it a little heavier than the original,
> but there's no point in guaranteeing that mem_cgroup_iter() returns only
> fully initialized memcgs, if we don't guarantee that the initialization
> is visible.
> 
> If we move online_css()'s setting CSS_ONLINE after rcu_assign_pointer()
> (I don't see why not), we can reasonably rely on the smp_wmb() in that.
> But I can't find a pre-existing barrier at the mem_cgroup_iter() end,
> so add an smp_rmb() where __mem_cgroup_iter_next() returns non-NULL.

Hmmm.... so, CSS_ONLINE was never meant to be used outside cgroup
proper.  The only guarantee that the css iterators make is that a css
which has finished its ->css_online() will be included in the
iteration, which implies that css's which haven't finished
->css_online() or already went past ->css_offline() may be included in
the iteration.  In fact, it's impossible to achieve the guarantee
without such implications if we want to avoid synchronizing everything
using common locking, which we apparently can't do across different
controllers.

The expectation is that if a controller needs to distinguish fully
online css's, it will perform its own synchronization among its
online, offline and iterations, which can usually be achieved through
per-css synchronization. There is asymmetry here due to the way
css_tryget() behaves.  Unfortuantely, I don't think it can be expanded
to become symmetrical for online testing without adding, say,
->css_post_online() callback.

So, the only thing that memcg can depend on while iterating is that it
will include all css's which finished ->css_online() and if memcg
wants to filter out the ones which haven't yet, it should do its own
marking in ->css_online() rather than depending on what cgroup core
does with the flags.  That way, locking rules are a lot more evident
in each subsystem and we don't end up depending on cgroup internal
details which aren't immediately obvious.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
