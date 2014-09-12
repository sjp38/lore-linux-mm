Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 55A2B6B0035
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 05:03:14 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id v10so795851pde.3
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 02:03:14 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id dk1si6413846pdb.179.2014.09.12.02.03.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Sep 2014 02:03:13 -0700 (PDT)
Date: Fri, 12 Sep 2014 13:02:58 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH RFC 2/2] memcg: add threshold for anon rss
Message-ID: <20140912090258.GI4151@esperanza>
References: <cover.1410447097.git.vdavydov@parallels.com>
 <b7e7abb6cadc1301a775177ef3d4f4944192c579.1410447097.git.vdavydov@parallels.com>
 <54124AFC.6020700@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <54124AFC.6020700@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@parallels.com>, Konstantin Khorenko <khorenko@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Fri, Sep 12, 2014 at 10:23:08AM +0900, Kamezawa Hiroyuki wrote:
> (2014/09/12 0:41), Vladimir Davydov wrote:
> > Though hard memory limits suit perfectly for sand-boxing, they are not
> > that efficient when it comes to partitioning a server's resources among
> > multiple containers. The point is a container consuming a particular
> > amount of memory most of time may have infrequent spikes in the load.
> > Setting the hard limit to the maximal possible usage (spike) will lower
> > server utilization while setting it to the "normal" usage will result in
> > heavy lags during the spikes.
> > 
> > To handle such scenarios soft limits were introduced. The idea is to
> > allow a container to breach the limit freely when there's enough free
> > memory, but shrink it back to the limit aggressively on global memory
> > pressure. However, the concept of soft limits is intrinsically unsafe
> > by itself: if a container eats too much anonymous memory, it will be
> > very slow or even impossible (if there's no swap) to reclaim its
> > resources back to the limit. As a result the whole system will be
> > feeling bad until it finally realizes the culprit must die.
> > 
> > Currently we have no way to react to anonymous memory + swap usage
> > growth inside a container: the memsw counter accounts both anonymous
> > memory and file caches and swap, so we have neither a limit for
> > anon+swap nor a threshold notification. Actually, memsw is totally
> > useless if one wants to make full use of soft limits: it should be set
> > to a very large value or infinity then, otherwise it just makes no
> > sense.
> > 
> > That's one of the reasons why I think we should replace memsw with a
> > kind of anonsw so that it'd account only anon+swap. This way we'd still
> > be able to sand-box apps, but it'd also allow us to avoid nasty
> > surprises like the one I described above. For more arguments for and
> > against this idea, please see the following thread:
> > 
> > http://www.spinics.net/lists/linux-mm/msg78180.html
> > 
> > There's an alternative to this approach backed by Kamezawa. He thinks
> > that OOM on anon+swap limit hit is a no-go and proposes to use memory
> > thresholds for it. I still strongly disagree with the proposal, because
> > it's unsafe (what if the userspace handler won't react in time?).
> > Nevertheless, I implement his idea in this RFC. I hope this will fuel
> > the debate, because sadly enough nobody seems to care about this
> > problem.
> > 
> > So this patch adds the "memory.rss" file that shows the amount of
> > anonymous memory consumed by a cgroup and the event to handle threshold
> > notifications coming from it. The notification works exactly in the same
> > fashion as the existing memory/memsw usage notifications.
> > 
> >
> 
> So, now, you know you can handle "threshould".
> 
> If you want to implement "automatic-oom-killall-in-a-contanier-threshold-in-kernel",
> I don't have any objections.
> 
> What you want is not limit, you want a trigger for killing process.
> Threshold + Kill is enough, using res_counter for that is overspec.

I'm still unsure if it's always enough. Handing this job out to the
userspace may work in 90% percent of situations, but fail under some
circumstances (a bunch of containers go mad so that the userspace daemon
doesn't react in time). Can the admin take a risk like that?

> You don't need res_counter and don't need to break other guy's use case.

This is the time when we have a great chance to rework the user
interface. That's why I started this thread.

>From what I read from the comment to the memsw patch and slides,
anon+swap wasn't even considered as an alternative to anon+cache+swap.
The only question raised was "Why not a separate swap limit, why
mem+swap?". It was clearly answered "no need to recharge on swap
in/out", but anon+swap isn't a bit worse in this respect - caches can't
migrate from swap to mem anyway. I guess nobody considered the anon+swap
alternative, simply because there was no notion of soft limits at that
time, so mem+swap had no problems. But today the things have changed, so
let's face it now. Why not anon+swap?

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
