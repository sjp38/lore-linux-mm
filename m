Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7F009828DF
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 04:13:26 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id td3so64516831pab.2
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 01:13:26 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id m67si12577330pfi.45.2016.03.11.01.13.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 01:13:25 -0800 (PST)
Date: Fri, 11 Mar 2016 12:13:04 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: memcontrol: reclaim when shrinking memory.high below
 usage
Message-ID: <20160311091303.GJ1946@esperanza>
References: <1457643015-8828-1-git-send-email-hannes@cmpxchg.org>
 <20160311083440.GI1946@esperanza>
 <20160311084238.GE27701@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160311084238.GE27701@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Mar 11, 2016 at 09:42:39AM +0100, Michal Hocko wrote:
> On Fri 11-03-16 11:34:40, Vladimir Davydov wrote:
> > On Thu, Mar 10, 2016 at 03:50:13PM -0500, Johannes Weiner wrote:
> > > When setting memory.high below usage, nothing happens until the next
> > > charge comes along, and then it will only reclaim its own charge and
> > > not the now potentially huge excess of the new memory.high. This can
> > > cause groups to stay in excess of their memory.high indefinitely.
> > > 
> > > To fix that, when shrinking memory.high, kick off a reclaim cycle that
> > > goes after the delta.
> > 
> > I agree that we should reclaim the high excess, but I don't think it's a
> > good idea to do it synchronously. Currently, memory.low and memory.high
> > knobs can be easily used by a single-threaded load manager implemented
> > in userspace, because it doesn't need to care about potential stalls
> > caused by writes to these files. After this change it might happen that
> > a write to memory.high would take long, seconds perhaps, so in order to
> > react quickly to changes in other cgroups, a load manager would have to
> > spawn a thread per each write to memory.high, which would complicate its
> > implementation significantly.
> 
> Is the complication on the managing part really an issue though. Such a
> manager would have to spawn a process/thread to change the .max already.

IMO memory.max is not something that has to be changed often. In most
cases it will be set on container start and stay put throughout
container lifetime. I can also imagine a case when memory.max will be
changed for all containers when a container starts or stops, so as to
guarantee that if <= N containers of M go mad, the system will survive.
In any case, memory.max is reconfigured rarely, it rather belongs to the
static configuration.

OTOH memory.low and memory.high are perfect to be changed dynamically,
basing on containers' memory demand/pressure. A load manager might want
to reconfigure these knobs say every 5 seconds. Spawning a thread per
each container that often would look unnecessarily overcomplicated IMO.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
