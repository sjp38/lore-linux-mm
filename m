Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 69EEF6B0078
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 15:04:36 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so2277836pad.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 12:04:35 -0800 (PST)
Date: Fri, 16 Nov 2012 12:04:32 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
In-Reply-To: <50A60873.3000607@parallels.com>
Message-ID: <alpine.DEB.2.00.1211161157390.2788@chino.kir.corp.google.com>
References: <20121107105348.GA25549@lizard> <20121107112136.GA31715@shutemov.name> <CAOJsxLHY+3ZzGuGX=4o1pLfhRqjkKaEMyhX0ejB5nVrDvOWXNA@mail.gmail.com> <20121107114321.GA32265@shutemov.name> <alpine.DEB.2.00.1211141910050.14414@chino.kir.corp.google.com>
 <20121115033932.GA15546@lizard.sbx05977.paloaca.wayport.net> <alpine.DEB.2.00.1211141946370.14414@chino.kir.corp.google.com> <20121115073420.GA19036@lizard.sbx05977.paloaca.wayport.net> <alpine.DEB.2.00.1211142351420.4410@chino.kir.corp.google.com>
 <20121115085224.GA4635@lizard> <alpine.DEB.2.00.1211151303510.27188@chino.kir.corp.google.com> <50A60873.3000607@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On Fri, 16 Nov 2012, Glauber Costa wrote:

> My personal take:
> 
> Most people hate memcg due to the cost it imposes. I've already
> demonstrated that with some effort, it doesn't necessarily have to be
> so. (http://lwn.net/Articles/517634/)
> 
> The one thing I missed on that work, was precisely notifications. If you
> can come up with a good notifications scheme that *lives* in memcg, but
> does not *depend* in the memcg infrastructure, I personally think it
> could be a big win.
> 

This doesn't allow users of cpusets without memcg to have an API for 
memory pressure, that's why I thought it should be a new cgroup that can 
be mounted alongside any existing cgroup, any cgroup in the future, or 
just by itself.

> Doing this in memcg has the advantage that the "per-group" vs "global"
> is automatically solved, since the root memcg is just another name for
> "global".
> 

That's true of any cgroup.

> I honestly like your low/high/oom scheme better than memcg's
> "threshold-in-bytes". I would also point out that those thresholds are
> *far* from exact, due to the stock charging mechanism, and can be wrong
> by as much as O(#cpus). So far, nobody complained. So in theory it
> should be possible to convert memcg to low/high/oom, while still
> accepting writes in bytes, that would be thrown in the closest bucket.
> 

I'm wondering if we should have more than three different levels.

> Another thing from one of your e-mails, that may shift you in the memcg
> direction:
> 
> "2. The last time I checked, cgroups memory controller did not (and I
> guess still does not) not account kernel-owned slabs. I asked several
> times why so, but nobody answered."
> 
> It should, now, in the latest -mm, although it won't do per-group
> reclaim (yet).
> 

Not sure where that was written, but I certainly didn't write it and it's 
not really relevant in this discussion: memory pressure notifications 
would be triggered by reclaim when trying to allocate memory; why we need 
to reclaim or how we got into that state is tangential.  It certainly may 
be because a lot of slab was allocated, but that's not the only case.

> I am also failing to see how cpusets would be involved in here. I
> understand that you may have free memory in terms of size, but still be
> further restricted by cpuset. But I also think that having multiple
> entry points for this buy us nothing at all. So the choices I see are:
> 

Umm, why do users of cpusets not want to be able to trigger memory 
pressure notifications?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
