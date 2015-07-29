Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2176B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 10:26:23 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so28820870wib.0
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 07:26:23 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id y7si1190193wju.76.2015.07.29.07.26.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 07:26:22 -0700 (PDT)
Received: by wibud3 with SMTP id ud3so223145532wib.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 07:26:21 -0700 (PDT)
Date: Wed, 29 Jul 2015 16:26:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -mm v9 0/8] idle memory tracking
Message-ID: <20150729142618.GJ15801@dhcp22.suse.cz>
References: <cover.1437303956.git.vdavydov@parallels.com>
 <20150729123629.GI15801@dhcp22.suse.cz>
 <20150729135907.GT8100@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150729135907.GT8100@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 29-07-15 16:59:07, Vladimir Davydov wrote:
> On Wed, Jul 29, 2015 at 02:36:30PM +0200, Michal Hocko wrote:
> > On Sun 19-07-15 15:31:09, Vladimir Davydov wrote:
> > [...]
> > > ---- USER API ----
> > > 
> > > The user API consists of two new proc files:
> > 
> > I was thinking about this for a while. I dislike the interface.  It is
> > quite awkward to use - e.g. you have to read the full memory to check a
> > single memcg idleness. This might turn out being a problem especially on
> > large machines.
> 
> Yes, with this API estimating the wss of a single memory cgroup will
> cost almost as much as doing this for the whole system.
> 
> Come to think of it, does anyone really need to estimate idleness of one
> particular cgroup?

It is certainly interesting for setting the low limit.

> If we are doing this for finding an optimal memcg
> limits configuration or while considering a load move within a cluster
> (which I think are the primary use cases for the feature), we must do it
> system-wide to see the whole picture.
> 
> > It also provides a very low level information (per-pfn idleness) which
> > is inherently racy. Does anybody really require this level of detail?
> 
> Well, one might want to do it per-process, obtaining PFNs from
> /proc/pid/pagemap.

Sure once the interface is exported you can do whatever ;) But my
question is whether any real usecase _requires_ it. 

> > I would assume that most users are interested only in a single number
> > which tells the idleness of the system/memcg.
> 
> Yes, that's what I need it for - estimating containers' wss for setting
> their limits accordingly.

So why don't we export the single per memcg and global knobs then?
This would have few advantages. First of all it would be much easier to
use, you wouldn't have to export memcg ids and finally the implementation
could be changed without any user visible changes (e.g. lru vs. pfn walks),
potential caching and who knows what. In other words. Michel had a
single number interface AFAIR, what was the primary reason to move away
from that API?

> > Well, you have mentioned a per-process reclaim but I am quite
> > skeptical about this.
> 
> This is what Minchan mentioned initially. Personally, I'm not going to
> use it per-process, but I wouldn't rule out this use case either.

Considering how many times we have been bitten by too broad interfaces I
would rather be conservative.

> > I guess the primary reason to rely on the pfn rather than the LRU walk,
> > which would be more targeted (especially for memcg cases), is that we
> > cannot hold lru lock for the whole LRU walk and we cannot continue
> > walking after the lock is dropped. Maybe we can try to address that
> > instead? I do not think this is easy to achieve but have you considered
> > that as an option?
> 
> Yes, I have, and I've come to a conclusion it's not doable, because LRU
> lists can be constantly rotating at an arbitrary rate. If you have an
> idea in mind how this could be done, please share.

Yes this is really tricky with the current LRU implementation. I
was playing with some ideas (do some checkpoints on the way) but
none of them was really working out on a busy systems. But the LRU
implementation might change in the future. I didn't mean this as a hard
requirement it just sounds that the current implementation restrictions
shape the user visible API which is a good sign to think twice about it.

> Speaking of LRU-vs-PFN walk, iterating over PFNs has its own advantages:
>  - You can distribute a walk in time to avoid CPU bursts.

This would make the information even more volatile. I am not sure how
helpful it would be in the end.

>  - You are free to parallelize the scanner as you wish to decrease the
>    scan time.

This is true but you could argue similar with per-node/lru threads if this
was implemented in the kernel and really needed. I am not sure it would
be really needed though. I would expect this would be a low priority
thing.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
