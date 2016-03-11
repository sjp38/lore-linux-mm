Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 22AF66B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 09:22:30 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id l68so20135154wml.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 06:22:30 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id kd3si11295663wjb.84.2016.03.11.06.22.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 06:22:29 -0800 (PST)
Received: by mail-wm0-f51.google.com with SMTP id l68so20134554wml.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 06:22:28 -0800 (PST)
Date: Fri, 11 Mar 2016 15:22:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: reclaim when shrinking memory.high below
 usage
Message-ID: <20160311142227.GR27701@dhcp22.suse.cz>
References: <1457643015-8828-1-git-send-email-hannes@cmpxchg.org>
 <20160311083440.GI1946@esperanza>
 <20160311084238.GE27701@dhcp22.suse.cz>
 <20160311091303.GJ1946@esperanza>
 <20160311095309.GF27701@dhcp22.suse.cz>
 <20160311114934.GL1946@esperanza>
 <20160311133936.GQ27701@dhcp22.suse.cz>
 <20160311140146.GO1946@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160311140146.GO1946@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri 11-03-16 17:01:46, Vladimir Davydov wrote:
> On Fri, Mar 11, 2016 at 02:39:36PM +0100, Michal Hocko wrote:
> > On Fri 11-03-16 14:49:34, Vladimir Davydov wrote:
> > > On Fri, Mar 11, 2016 at 10:53:09AM +0100, Michal Hocko wrote:
> > > > > OTOH memory.low and memory.high are perfect to be changed dynamically,
> > > > > basing on containers' memory demand/pressure. A load manager might want
> > > > > to reconfigure these knobs say every 5 seconds. Spawning a thread per
> > > > > each container that often would look unnecessarily overcomplicated IMO.
> > > > 
> > > > The question however is whether we want to hide a potentially costly
> > > > operation and have it unaccounted and hidden in the kworker context.
> > > 
> > > There's already mem_cgroup->high_work doing reclaim in an unaccounted
> > > context quite often if tcp accounting is enabled.
> > 
> > I suspect this is done because the charging context cannot do much
> > better.
> > 
> > > And there's kswapd.
> > > memory.high knob is for the root only so it can't be abused by an
> > > unprivileged user. Regarding a privileged user, e.g. load manager, it
> > > can screw things up anyway, e.g. by configuring sum of memory.low to be
> > > greater than total RAM on the host and hence driving kswapd mad.
> > 
> > I am not worried about abuse. It is just weird to move something which
> > can be perfectly sync to an async mode.
> >  
> > > > I mean fork() + write() doesn't sound terribly complicated to me to have
> > > > a rather subtle behavior in the kernel.
> > > 
> > > It'd be just a dubious API IMHO. With memory.max everything's clear: it
> > > tries to reclaim memory hard, may stall for several seconds, may invoke
> > > OOM, but if it finishes successfully we have memory.current less than
> > > memory.max. With this patch memory.high knob behaves rather strangely:
> > > it might stall, but there's no guarantee you'll have memory.current less
> > > than memory.high; moreover, according to the documentation it's OK to
> > > have memory.current greater than memory.high, so what's the point in
> > > calling synchronous reclaim blocking the caller?
> > 
> > Even if the reclaim is best effort it doesn't mean we should hide it
> > into an async context. There is simply no reason to do so. We do the
> > some for other knobs which are performing a potentially expensive
> > operation and do not guarantee the result.
> 
> IMO it depends on what a knob is used for. If it's for testing or
> debugging or recovering the system (e.g. manual oom, compact,
> drop_caches), this must be synchronous, but memory.high is going to be
> tweaked at runtime during normal system operation every several seconds
> or so,

Is this really going to happen in the real life? And if yes is it really
probable that such an adjustment would cause such a large disruption?

> at least in my understanding. I understand your concern, and may
> be you're right in the end, but think about userspace that will probably
> have to spawn thousands threads every 5 seconds or so just to write to a
> file. It's painful IMO.
> 
> Are there any hidden non-obvious implications of handing over reclaim to
> a kernel worker on adjusting memory.high? May be, I'm just missing
> something obvious, and it can be really dangerous or sub-optimal.

I am just thinking about what would happen if workers just start
stacking up because they couldn't be processed and then would race with
each other. I mean this all would be fixable but I really fail to see
how that makes sense from the very beginning.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
