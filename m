Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2CA846B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 04:53:12 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id l68so10303409wml.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 01:53:12 -0800 (PST)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id 5si1782203wmw.30.2016.03.11.01.53.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 01:53:11 -0800 (PST)
Received: by mail-wm0-f45.google.com with SMTP id l68so10842762wml.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 01:53:10 -0800 (PST)
Date: Fri, 11 Mar 2016 10:53:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: reclaim when shrinking memory.high below
 usage
Message-ID: <20160311095309.GF27701@dhcp22.suse.cz>
References: <1457643015-8828-1-git-send-email-hannes@cmpxchg.org>
 <20160311083440.GI1946@esperanza>
 <20160311084238.GE27701@dhcp22.suse.cz>
 <20160311091303.GJ1946@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160311091303.GJ1946@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri 11-03-16 12:13:04, Vladimir Davydov wrote:
> On Fri, Mar 11, 2016 at 09:42:39AM +0100, Michal Hocko wrote:
> > On Fri 11-03-16 11:34:40, Vladimir Davydov wrote:
> > > On Thu, Mar 10, 2016 at 03:50:13PM -0500, Johannes Weiner wrote:
> > > > When setting memory.high below usage, nothing happens until the next
> > > > charge comes along, and then it will only reclaim its own charge and
> > > > not the now potentially huge excess of the new memory.high. This can
> > > > cause groups to stay in excess of their memory.high indefinitely.
> > > > 
> > > > To fix that, when shrinking memory.high, kick off a reclaim cycle that
> > > > goes after the delta.
> > > 
> > > I agree that we should reclaim the high excess, but I don't think it's a
> > > good idea to do it synchronously. Currently, memory.low and memory.high
> > > knobs can be easily used by a single-threaded load manager implemented
> > > in userspace, because it doesn't need to care about potential stalls
> > > caused by writes to these files. After this change it might happen that
> > > a write to memory.high would take long, seconds perhaps, so in order to
> > > react quickly to changes in other cgroups, a load manager would have to
> > > spawn a thread per each write to memory.high, which would complicate its
> > > implementation significantly.
> > 
> > Is the complication on the managing part really an issue though. Such a
> > manager would have to spawn a process/thread to change the .max already.
> 
> IMO memory.max is not something that has to be changed often. In most
> cases it will be set on container start and stay put throughout
> container lifetime. I can also imagine a case when memory.max will be
> changed for all containers when a container starts or stops, so as to
> guarantee that if <= N containers of M go mad, the system will survive.
> In any case, memory.max is reconfigured rarely, it rather belongs to the
> static configuration.

I see
 
> OTOH memory.low and memory.high are perfect to be changed dynamically,
> basing on containers' memory demand/pressure. A load manager might want
> to reconfigure these knobs say every 5 seconds. Spawning a thread per
> each container that often would look unnecessarily overcomplicated IMO.

The question however is whether we want to hide a potentially costly
operation and have it unaccounted and hidden in the kworker context.
I mean fork() + write() doesn't sound terribly complicated to me to have
a rather subtle behavior in the kernel.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
