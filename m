Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C025F6B0038
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 01:55:28 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id j16so16012954pga.6
        for <linux-mm@kvack.org>; Sun, 17 Sep 2017 22:55:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k10si4540071pln.759.2017.09.17.22.55.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 17 Sep 2017 22:55:27 -0700 (PDT)
Date: Mon, 18 Sep 2017 07:55:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Detecting page cache trashing state
Message-ID: <20170918055517.w57eed6zqynvuyeb@dhcp22.suse.cz>
References: <150543458765.3781.10192373650821598320@takondra-t460s>
 <20170915143619.2ifgex2jxck2xt5u@dhcp22.suse.cz>
 <20170915212028.GZ9731@shells.gnugeneration.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170915212028.GZ9731@shells.gnugeneration.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vcaputo@pengaru.com
Cc: Taras Kondratiuk <takondra@cisco.com>, linux-mm@kvack.org, xe-linux-external@cisco.com, Ruslan Ruslichenko <rruslich@cisco.com>, linux-kernel@vger.kernel.org

On Fri 15-09-17 14:20:28, vcaputo@pengaru.com wrote:
> On Fri, Sep 15, 2017 at 04:36:19PM +0200, Michal Hocko wrote:
> > On Thu 14-09-17 17:16:27, Taras Kondratiuk wrote:
> > > Hi
> > > 
> > > In our devices under low memory conditions we often get into a trashing
> > > state when system spends most of the time re-reading pages of .text
> > > sections from a file system (squashfs in our case). Working set doesn't
> > > fit into available page cache, so it is expected. The issue is that
> > > OOM killer doesn't get triggered because there is still memory for
> > > reclaiming. System may stuck in this state for a quite some time and
> > > usually dies because of watchdogs.
> > > 
> > > We are trying to detect such trashing state early to take some
> > > preventive actions. It should be a pretty common issue, but for now we
> > > haven't find any existing VM/IO statistics that can reliably detect such
> > > state.
> > > 
> > > Most of metrics provide absolute values: number/rate of page faults,
> > > rate of IO operations, number of stolen pages, etc. For a specific
> > > device configuration we can determine threshold values for those
> > > parameters that will detect trashing state, but it is not feasible for
> > > hundreds of device configurations.
> > > 
> > > We are looking for some relative metric like "percent of CPU time spent
> > > handling major page faults". With such relative metric we could use a
> > > common threshold across all devices. For now we have added such metric
> > > to /proc/stat in our kernel, but we would like to find some mechanism
> > > available in upstream kernel.
> > > 
> > > Has somebody faced similar issue? How are you solving it?
> > 
> > Yes this is a pain point for a _long_ time. And we still do not have a
> > good answer upstream. Johannes has been playing in this area [1].
> > The main problem is that our OOM detection logic is based on the ability
> > to reclaim memory to allocate new memory. And that is pretty much true
> > for the pagecache when you are trashing. So we do not know that
> > basically whole time is spent refaulting the memory back and forth.
> > We do have some refault stats for the page cache but that is not
> > integrated to the oom detection logic because this is really a
> > non-trivial problem to solve without triggering early oom killer
> > invocations.
> > 
> > [1] http://lkml.kernel.org/r/20170727153010.23347-1-hannes@cmpxchg.org
> 
> For desktop users running without swap, couldn't we just provide a kernel
> setting which marks all executable pages as unevictable when first faulted
> in?

This could result in the immediate DoS vector and you could see trashing
elsewhere. In fact we already do protect executable pages and reclaim
them later (see page_check_references).

I am afraid that the only way to resolve the trashing behavior is to
release a larger amount of memory because shifting the reclaim priority
will just push the suboptimal behavior somewhere else. In order to do
that we really have to detect that the working set doesn't fit into
memory and refaults are predominating system activity.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
