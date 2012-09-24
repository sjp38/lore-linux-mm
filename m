Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 56D1D6B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 13:43:52 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so359298pbb.14
        for <linux-mm@kvack.org>; Mon, 24 Sep 2012 10:43:51 -0700 (PDT)
Date: Mon, 24 Sep 2012 10:43:46 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 15/16] memcg/sl[au]b: shrink dead caches
Message-ID: <20120924174346.GB7694@google.com>
References: <1347977530-29755-1-git-send-email-glommer@parallels.com>
 <1347977530-29755-16-git-send-email-glommer@parallels.com>
 <20120921204035.GQ7264@google.com>
 <506018DC.2020907@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <506018DC.2020907@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

Hello,

On Mon, Sep 24, 2012 at 12:25:00PM +0400, Glauber Costa wrote:
> > This is kinda nasty.  Do we really need to do this?  How long would a
> > dead cache stick around?
> 
> Without targeted shrinking, until all objects are manually freed, which
> may need to wait global reclaim to kick in.
> 
> In general, if we agree with duplicating the caches, the problem that
> they may stick around for some time will not be avoidable. If you have
> any suggestions about alternative ways for it, I'm all ears.

I don't have much problem with caches sticking around waiting to be
reaped.  I'm just wondering whether renaming trick is really
necessary.

> > Reaping dead caches doesn't exactly sound like a high priority thing
> > and adding a branch to hot path for that might not be the best way to
> > do it.  Why not schedule an extremely lazy deferrable delayed_work
> > which polls for emptiness, say, every miniute or whatever?
> > 
> 
> Because this branch is marked as unlikely, I would expect it not to be a
> big problem. It will be not taken most of the time, and becomes a very
> cheap branch. I considered this to be simpler than a deferred work
> mechanism.
> 
> If even then, you guys believe this is still too high, I can resort to that.

It's still an otherwise unnecessary branch on a very hot path.  If you
can remove it, there's no reason not to.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
