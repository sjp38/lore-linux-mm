Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 989646B0038
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 05:32:15 -0400 (EDT)
Date: Wed, 19 Jun 2013 04:32:13 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH v2] Make transparent hugepages cpuset aware
Message-ID: <20130619093212.GX3658@sgi.com>
References: <1370967244-5610-1-git-send-email-athorlton@sgi.com>
 <alpine.DEB.2.02.1306111517200.6141@chino.kir.corp.google.com>
 <20130618164537.GJ16067@sgi.com>
 <alpine.DEB.2.02.1306181654350.4503@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1306181654350.4503@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org, Robin Holt <holt@sgi.com>

On Tue, Jun 18, 2013 at 05:01:23PM -0700, David Rientjes wrote:
> On Tue, 18 Jun 2013, Alex Thorlton wrote:
> 
> > Thanks for your input, however, I believe the method of using a malloc
> > hook falls apart when it comes to static binaries, since we wont' have
> > any shared libraries to hook into.  Although using a malloc hook is a
> > perfectly suitable solution for most cases, we're looking to implement a
> > solution that can be used in all situations.
> > 
> 
> I guess the question would be why you don't want your malloc memory backed 
> by thp pages for certain static binaries and not others?  Is it because of 
> an increased rss due to khugepaged collapsing memory because of its 
> default max_ptes_none value?
> 
> > Aside from that particular shortcoming of the malloc hook solution,
> > there are some other situations having a cpuset-based option is a
> > much simpler and more efficient solution than the alternatives.
> 
> Sure, but why should this be a cpuset based solution?  What is special 
> about cpusets that make certain statically allocated binaries not want 
> memory backed by thp while others do?  This still seems based solely on 
> convenience instead of any hard requirement.

The convenience being that many batch schedulers have added cpuset
support.  They create the cpuset's and configure them as appropriate
for the job as determined by a mixture of input from the submitting
user but still under the control of the administrator.  That seems like
a fairly significant convenience given that it took years to get the
batch schedulers to adopt cpusets in the first place.  At this point,
expanding their use of cpusets is under the control of the system
administrator and would not require any additional development on
the batch scheduler developers part.

> > One
> > such situation that comes to mind would be an environment where a batch
> > scheduler is in use to ration system resources.  If an administrator
> > determines that a users jobs run more efficiently with thp always on,
> > the administrator can simply set the users jobs to always run with that
> > setting, instead of having to coordinate with that user to get them to
> > run their jobs in a different way.  I feel that, for cases such as this,
> > the this additional flag is in line with the other capabilities that
> > cgroups and cpusets provide.
> > 
> 
> That sounds like a memcg, i.e. container, type of an issue, not a cpuset 
> issue which is more geared toward NUMA optimizations.  User jobs should 
> always run more efficiently with thp always on, the worst-case scenario 
> should be if they run with the same performance as thp set to never.  In 
> other words, there shouldn't be any regression that requires certain 
> cpusets to disable thp because of a performance regression.  If there are 
> any, we'd like to investigate that separately from this patch.

Here are the entries in the cpuset:
cgroup.event_control  mem_exclusive    memory_pressure_enabled  notify_on_release         tasks
cgroup.procs          mem_hardwall     memory_spread_page       release_agent
cpu_exclusive         memory_migrate   memory_spread_slab       sched_load_balance
cpus                  memory_pressure  mems                     sched_relax_domain_level

There are scheduler, slab allocator, page_cache layout, etc controls.
Why _NOT_ add a thp control to that nicely contained central location?
It is a concise set of controls for the job.

Maybe I am misunderstanding.  Are you saying you want to put memcg
information into the cpuset or something like that?

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
