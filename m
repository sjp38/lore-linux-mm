Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 61BEC6B0037
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 04:27:44 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so735762pab.18
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 01:27:44 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ss8si6523945pab.0.2014.09.12.01.27.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Sep 2014 01:27:43 -0700 (PDT)
Date: Fri, 12 Sep 2014 12:27:04 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH RFC 2/2] memcg: add threshold for anon rss
Message-ID: <20140912082704.GH4151@esperanza>
References: <cover.1410447097.git.vdavydov@parallels.com>
 <b7e7abb6cadc1301a775177ef3d4f4944192c579.1410447097.git.vdavydov@parallels.com>
 <5411D9E2.5030408@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <5411D9E2.5030408@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Austin S Hemmelgarn <ahferroin7@gmail.com>
Cc: linux-kernel@vger.kernel.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@parallels.com>, Konstantin Khorenko <khorenko@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

Hi Austin,

On Thu, Sep 11, 2014 at 01:20:34PM -0400, Austin S Hemmelgarn wrote:
> On 2014-09-11 11:41, Vladimir Davydov wrote:
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
> I have actually seen this happen on a number of occasions.  I use
> cgroups to sandbox anything I run under wine (cause it's gotten so good
> at mimicking windows that a number of windows viruses will run on it),
> and have had issues with wine processes with memory leaks bringing the
> system to it's knees on occasion.  There are a lot of other stupid
> programs out there too, I've seen stuff that does it's own caching, but
> doesn't free any of the cached items until it either gets a failed
> malloc() or the system starts swapping it out.

Good example. For desktop users, it can be solved by setting hard memsw
limit, but when there are hundreds of containers running on the same
server setting memsw limit for each container would be just inflexible.
There might be containers that would make use of extra file caches, and
hard limiting them would increase overall disk load. OTOH setting only
soft limit would be dangerous if there's e.g. a wine user in one of the
containers.

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
> 
> So, I've actually been following the discussion mentioned above rather
> closely, I just haven't had the time to comment on it.
> Personally, I think both ideas have merits, but would like to propose a
> third solution.
> 
> I would propose that we keep memsw like it is right now (because being
> able to limit the sum of anon+cache+swap is useful, especially if you
> are using cgroups to do strict partitioning of a machine), but give it a
> better name (vss maybe?), add a separate counter for anonymous memory
> and swap, and then provide for each of them an option to control whether
> the OOM killer is used when the limit is hit (possibly with the option
> of a delay before running the OOM killer), and a separate option for
> threshold notifications.  Users than would be able to choose whether
> they want a particular container killed when it hits a particular limit,
> and whether or not they want notifications when it gets within a certain
> percentage of the limit, or potentially both.

The problem is adding yet another counter means extra overhead, more
code written, wider user interface. I don't think anybody would accept
that. There is even an opinion we don't need a separate kmem limit (i.e.
kmem should only be accounted in mem and memsw).

> We still need to have a way to hard limit sum of anon+cache+swap (and
> ideally kmem once that is working correctly), because that useful for
> systems that have to provide guaranteed minimum amounts of virtual
> memory to containers.

Do you have any use cases where anon+swap and anon+cache can't satisfy
the user request while anon+cache+swap and anon+cache can? I'd
appreciate if you could provide me with one, because currently I'm
pretty convinced that anon+swap and anon+cache would be sufficient for
both sand-boxing and loose partitioning, it'd be just a bit different to
configure. That's why for now I stand for substituting anon+cache+swap
with anon+swap.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
