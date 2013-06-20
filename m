Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id BB8D06B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 22:27:43 -0400 (EDT)
Date: Wed, 19 Jun 2013 21:27:39 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH v2] Make transparent hugepages cpuset aware
Message-ID: <20130620022739.GF3658@sgi.com>
References: <1370967244-5610-1-git-send-email-athorlton@sgi.com>
 <alpine.DEB.2.02.1306111517200.6141@chino.kir.corp.google.com>
 <20130618164537.GJ16067@sgi.com>
 <alpine.DEB.2.02.1306181654350.4503@chino.kir.corp.google.com>
 <20130619093212.GX3658@sgi.com>
 <alpine.DEB.2.02.1306191419081.13015@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1306191419081.13015@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Robin Holt <holt@sgi.com>, Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 19, 2013 at 02:24:07PM -0700, David Rientjes wrote:
> On Wed, 19 Jun 2013, Robin Holt wrote:
> 
> > The convenience being that many batch schedulers have added cpuset
> > support.  They create the cpuset's and configure them as appropriate
> > for the job as determined by a mixture of input from the submitting
> > user but still under the control of the administrator.  That seems like
> > a fairly significant convenience given that it took years to get the
> > batch schedulers to adopt cpusets in the first place.  At this point,
> > expanding their use of cpusets is under the control of the system
> > administrator and would not require any additional development on
> > the batch scheduler developers part.
> > 
> 
> You can't say the same for memcg?

I am not aware of batch scheduler support for memory controllers.
The request came from our benchmarking group.

> > Here are the entries in the cpuset:
> > cgroup.event_control  mem_exclusive    memory_pressure_enabled  notify_on_release         tasks
> > cgroup.procs          mem_hardwall     memory_spread_page       release_agent
> > cpu_exclusive         memory_migrate   memory_spread_slab       sched_load_balance
> > cpus                  memory_pressure  mems                     sched_relax_domain_level
> > 
> > There are scheduler, slab allocator, page_cache layout, etc controls.
> 
> I think this is mostly for historical reasons since cpusets were 
> introduced before cgroups.
> 
> > Why _NOT_ add a thp control to that nicely contained central location?
> > It is a concise set of controls for the job.
> > 
> 
> All of the above seem to be for cpusets primary purpose, i.e. NUMA 
> optimizations.  It has nothing to do with transparent hugepages.  (I'm not 
> saying thp has anything to do with memcg either, but a "memory controller" 
> seems more appropriate for controlling thp behavior.)

cpusets was not for NUMA.  It has no preference for "nodes" or anything like
that.  It was for splitting a machine into layered smaller groups.  Usually,
we see one cpuset with contains the batch scheduler.  The batch scheduler then
creates cpusets for jobs it starts.  Has nothing to do with nodes.  That is
more an administrator issue.  They set the minimum grouping of resources
for scheduled jobs.

> > Maybe I am misunderstanding.  Are you saying you want to put memcg
> > information into the cpuset or something like that?
> > 
> 
> I'm saying there's absolutely no reason to have thp controlled by a 
> cpuset, or ANY cgroup for that matter, since you chose not to respond to 
> the question I asked: why do you want to control thp behavior for certain 
> static binaries and not others?  Where is the performance regression or 
> the downside?  Is it because of max_ptes_none for certain jobs blowing up 
> the rss?  We need information, and even if were justifiable then it 
> wouldn't have anything to do with ANY cgroup but rather a per-process 
> control.  It has nothing to do with cpusets whatsoever.

It was a request from our benchmarking group that has found some jobs
benefit from thp, while other are harmed.  Let me ask them for more
details.

> (And I'm very curious why you didn't even cc the cpusets maintainer on 
> this patch in the first place who would probably say the same thing.)

I didn't know there was a cpuset maintainer.  Paul Jackson (SGI retired)
had originally worked to get cpusets introduced and then converted to
use cgroups.  I had never known there was a maintainer after him.  Sorry
for that.

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
