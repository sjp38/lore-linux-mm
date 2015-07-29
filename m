Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8EF346B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 11:28:42 -0400 (EDT)
Received: by laah7 with SMTP id h7so8525198laa.0
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 08:28:42 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id o3si414491lag.1.2015.07.29.08.28.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 08:28:40 -0700 (PDT)
Date: Wed, 29 Jul 2015 18:28:17 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v9 0/8] idle memory tracking
Message-ID: <20150729152817.GV8100@esperanza>
References: <cover.1437303956.git.vdavydov@parallels.com>
 <20150729123629.GI15801@dhcp22.suse.cz>
 <20150729135907.GT8100@esperanza>
 <20150729142618.GJ15801@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150729142618.GJ15801@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jul 29, 2015 at 04:26:19PM +0200, Michal Hocko wrote:
> On Wed 29-07-15 16:59:07, Vladimir Davydov wrote:
> > On Wed, Jul 29, 2015 at 02:36:30PM +0200, Michal Hocko wrote:
> > > On Sun 19-07-15 15:31:09, Vladimir Davydov wrote:
> > > [...]
> > > > ---- USER API ----
> > > > 
> > > > The user API consists of two new proc files:
> > > 
> > > I was thinking about this for a while. I dislike the interface.  It is
> > > quite awkward to use - e.g. you have to read the full memory to check a
> > > single memcg idleness. This might turn out being a problem especially on
> > > large machines.
> > 
> > Yes, with this API estimating the wss of a single memory cgroup will
> > cost almost as much as doing this for the whole system.
> > 
> > Come to think of it, does anyone really need to estimate idleness of one
> > particular cgroup?
> 
> It is certainly interesting for setting the low limit.

Yes, but IMO there is no point in setting the low limit for one
particular cgroup w/o considering what's going on with the rest of the
system.

> 
> > If we are doing this for finding an optimal memcg
> > limits configuration or while considering a load move within a cluster
> > (which I think are the primary use cases for the feature), we must do it
> > system-wide to see the whole picture.
> > 
> > > It also provides a very low level information (per-pfn idleness) which
> > > is inherently racy. Does anybody really require this level of detail?
> > 
> > Well, one might want to do it per-process, obtaining PFNs from
> > /proc/pid/pagemap.
> 
> Sure once the interface is exported you can do whatever ;) But my
> question is whether any real usecase _requires_ it. 

I only know/care about my use case, which is memcg configuration, but I
want to make the API as reusable as possible.

> 
> > > I would assume that most users are interested only in a single number
> > > which tells the idleness of the system/memcg.
> > 
> > Yes, that's what I need it for - estimating containers' wss for setting
> > their limits accordingly.
> 
> So why don't we export the single per memcg and global knobs then?
> This would have few advantages. First of all it would be much easier to
> use, you wouldn't have to export memcg ids and finally the implementation
> could be changed without any user visible changes (e.g. lru vs. pfn walks),
> potential caching and who knows what. In other words. Michel had a
> single number interface AFAIR, what was the primary reason to move away
> from that API?

Because there is too much to be taken care of in the kernel with such an
approach and chances are high that it won't satisfy everyone. What
should the scan period be equal too? Knob. How many kthreads do we want?
Knob. I want to keep history for last N intervals (this was a part of
Michel's implementation), what should N be equal to? Knob. I want to be
able to choose between an instant scan and a scan distributed in time.
Knob. I want to see stats for anon/locked/file/dirty memory separately,
please add them to the API. You see the scale of the problem with doing
it in the kernel?

The API this patch set introduces is simple and fair. It only defines
what "idle" flag mean and gives you a way to flip it. That's it. You
wanna history? DIY. You wanna periodic scans? DIY. Etc.

> 
> > > Well, you have mentioned a per-process reclaim but I am quite
> > > skeptical about this.
> > 
> > This is what Minchan mentioned initially. Personally, I'm not going to
> > use it per-process, but I wouldn't rule out this use case either.
> 
> Considering how many times we have been bitten by too broad interfaces I
> would rather be conservative.

I consider an API "broad" when it tries to do a lot of different things.
sys_prctl is a good example of a broad API.

/proc/kpageidle is not broad, because it does just one thing (I hope it
does it good :). If we attempted to implement the scanner in the kernel
with all those tunables I mentioned above, then we would get a broad API
IMO.

> 
> > > I guess the primary reason to rely on the pfn rather than the LRU walk,
> > > which would be more targeted (especially for memcg cases), is that we
> > > cannot hold lru lock for the whole LRU walk and we cannot continue
> > > walking after the lock is dropped. Maybe we can try to address that
> > > instead? I do not think this is easy to achieve but have you considered
> > > that as an option?
> > 
> > Yes, I have, and I've come to a conclusion it's not doable, because LRU
> > lists can be constantly rotating at an arbitrary rate. If you have an
> > idea in mind how this could be done, please share.
> 
> Yes this is really tricky with the current LRU implementation. I
> was playing with some ideas (do some checkpoints on the way) but
> none of them was really working out on a busy systems. But the LRU
> implementation might change in the future.

It might. Then we could come up with a new /proc or /sys file which
would do the same as /proc/kpageidle, but on per LRU^w whatever-it-is
basis, and give people a choice which one to use.

> I didn't mean this as a hard requirement it just sounds that the
> current implementation restrictions shape the user visible API which
> is a good sign to think twice about it.

Agree. That's why we are discussing it now :-)

> 
> > Speaking of LRU-vs-PFN walk, iterating over PFNs has its own advantages:
> >  - You can distribute a walk in time to avoid CPU bursts.
> 
> This would make the information even more volatile. I am not sure how
> helpful it would be in the end.

If you do it periodically, it is quite accurate.

> 
> >  - You are free to parallelize the scanner as you wish to decrease the
> >    scan time.
> 
> This is true but you could argue similar with per-node/lru threads if this
> was implemented in the kernel and really needed. I am not sure it would
> be really needed though. I would expect this would be a low priority
> thing.

But if you needed it one day, you'd have to extend the kernel API. With
/proc/kpageidle, you just go and fix your program.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
