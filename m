Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id A80776B0034
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 20:01:26 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so4460978pdj.28
        for <linux-mm@kvack.org>; Tue, 18 Jun 2013 17:01:26 -0700 (PDT)
Date: Tue, 18 Jun 2013 17:01:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] Make transparent hugepages cpuset aware
In-Reply-To: <20130618164537.GJ16067@sgi.com>
Message-ID: <alpine.DEB.2.02.1306181654350.4503@chino.kir.corp.google.com>
References: <1370967244-5610-1-git-send-email-athorlton@sgi.com> <alpine.DEB.2.02.1306111517200.6141@chino.kir.corp.google.com> <20130618164537.GJ16067@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org, Robin Holt <holt@sgi.com>

On Tue, 18 Jun 2013, Alex Thorlton wrote:

> Thanks for your input, however, I believe the method of using a malloc
> hook falls apart when it comes to static binaries, since we wont' have
> any shared libraries to hook into.  Although using a malloc hook is a
> perfectly suitable solution for most cases, we're looking to implement a
> solution that can be used in all situations.
> 

I guess the question would be why you don't want your malloc memory backed 
by thp pages for certain static binaries and not others?  Is it because of 
an increased rss due to khugepaged collapsing memory because of its 
default max_ptes_none value?

> Aside from that particular shortcoming of the malloc hook solution,
> there are some other situations having a cpuset-based option is a
> much simpler and more efficient solution than the alternatives.

Sure, but why should this be a cpuset based solution?  What is special 
about cpusets that make certain statically allocated binaries not want 
memory backed by thp while others do?  This still seems based solely on 
convenience instead of any hard requirement.

> One
> such situation that comes to mind would be an environment where a batch
> scheduler is in use to ration system resources.  If an administrator
> determines that a users jobs run more efficiently with thp always on,
> the administrator can simply set the users jobs to always run with that
> setting, instead of having to coordinate with that user to get them to
> run their jobs in a different way.  I feel that, for cases such as this,
> the this additional flag is in line with the other capabilities that
> cgroups and cpusets provide.
> 

That sounds like a memcg, i.e. container, type of an issue, not a cpuset 
issue which is more geared toward NUMA optimizations.  User jobs should 
always run more efficiently with thp always on, the worst-case scenario 
should be if they run with the same performance as thp set to never.  In 
other words, there shouldn't be any regression that requires certain 
cpusets to disable thp because of a performance regression.  If there are 
any, we'd like to investigate that separately from this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
