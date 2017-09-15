Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6D1806B0253
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 17:15:32 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v82so6522640pgb.5
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 14:15:32 -0700 (PDT)
Received: from shells.gnugeneration.com (shells.gnugeneration.com. [66.240.222.126])
        by mx.google.com with ESMTP id z185si1152949pgb.162.2017.09.15.14.15.30
        for <linux-mm@kvack.org>;
        Fri, 15 Sep 2017 14:15:31 -0700 (PDT)
Date: Fri, 15 Sep 2017 14:20:28 -0700
From: vcaputo@pengaru.com
Subject: Re: Detecting page cache trashing state
Message-ID: <20170915212028.GZ9731@shells.gnugeneration.com>
References: <150543458765.3781.10192373650821598320@takondra-t460s>
 <20170915143619.2ifgex2jxck2xt5u@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170915143619.2ifgex2jxck2xt5u@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Taras Kondratiuk <takondra@cisco.com>, linux-mm@kvack.org, xe-linux-external@cisco.com, Ruslan Ruslichenko <rruslich@cisco.com>, linux-kernel@vger.kernel.org

On Fri, Sep 15, 2017 at 04:36:19PM +0200, Michal Hocko wrote:
> On Thu 14-09-17 17:16:27, Taras Kondratiuk wrote:
> > Hi
> > 
> > In our devices under low memory conditions we often get into a trashing
> > state when system spends most of the time re-reading pages of .text
> > sections from a file system (squashfs in our case). Working set doesn't
> > fit into available page cache, so it is expected. The issue is that
> > OOM killer doesn't get triggered because there is still memory for
> > reclaiming. System may stuck in this state for a quite some time and
> > usually dies because of watchdogs.
> > 
> > We are trying to detect such trashing state early to take some
> > preventive actions. It should be a pretty common issue, but for now we
> > haven't find any existing VM/IO statistics that can reliably detect such
> > state.
> > 
> > Most of metrics provide absolute values: number/rate of page faults,
> > rate of IO operations, number of stolen pages, etc. For a specific
> > device configuration we can determine threshold values for those
> > parameters that will detect trashing state, but it is not feasible for
> > hundreds of device configurations.
> > 
> > We are looking for some relative metric like "percent of CPU time spent
> > handling major page faults". With such relative metric we could use a
> > common threshold across all devices. For now we have added such metric
> > to /proc/stat in our kernel, but we would like to find some mechanism
> > available in upstream kernel.
> > 
> > Has somebody faced similar issue? How are you solving it?
> 
> Yes this is a pain point for a _long_ time. And we still do not have a
> good answer upstream. Johannes has been playing in this area [1].
> The main problem is that our OOM detection logic is based on the ability
> to reclaim memory to allocate new memory. And that is pretty much true
> for the pagecache when you are trashing. So we do not know that
> basically whole time is spent refaulting the memory back and forth.
> We do have some refault stats for the page cache but that is not
> integrated to the oom detection logic because this is really a
> non-trivial problem to solve without triggering early oom killer
> invocations.
> 
> [1] http://lkml.kernel.org/r/20170727153010.23347-1-hannes@cmpxchg.org

For desktop users running without swap, couldn't we just provide a kernel
setting which marks all executable pages as unevictable when first faulted
in?  Then at least thrashing within the space occupied by executables and
shared libraries before eventual OOM would be avoided, and only the
remaining file-backed non-executable pages would be thrashable.

On my swapless laptops I'd much rather have OOM killer kick in immediately
rather than wait for a few minutes of thrashing to pass while the bogged
down system crawls through depleting what's left of technically reclaimable
memory.  It's much improved on modern SSDs, but still annoying.

Regards,
Vito Caputo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
