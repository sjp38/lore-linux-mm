Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id E5B7B6B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 22:43:26 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lj1so5806737pab.17
        for <linux-mm@kvack.org>; Wed, 19 Jun 2013 19:43:26 -0700 (PDT)
Date: Wed, 19 Jun 2013 19:43:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] Make transparent hugepages cpuset aware
In-Reply-To: <20130620022739.GF3658@sgi.com>
Message-ID: <alpine.DEB.2.02.1306191939250.24151@chino.kir.corp.google.com>
References: <1370967244-5610-1-git-send-email-athorlton@sgi.com> <alpine.DEB.2.02.1306111517200.6141@chino.kir.corp.google.com> <20130618164537.GJ16067@sgi.com> <alpine.DEB.2.02.1306181654350.4503@chino.kir.corp.google.com> <20130619093212.GX3658@sgi.com>
 <alpine.DEB.2.02.1306191419081.13015@chino.kir.corp.google.com> <20130620022739.GF3658@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org

On Wed, 19 Jun 2013, Robin Holt wrote:

> cpusets was not for NUMA.  It has no preference for "nodes" or anything like
> that.  It was for splitting a machine into layered smaller groups.  Usually,
> we see one cpuset with contains the batch scheduler.  The batch scheduler then
> creates cpusets for jobs it starts.  Has nothing to do with nodes.  That is
> more an administrator issue.  They set the minimum grouping of resources
> for scheduled jobs.
> 

I disagree with all of the above, it's not what Paul Jackson developed 
cpusets for, it's not what he wrote in Documentation/cgroups/cpusets.txt, 
and it's not why libnuma immediately supported it.  Cpusets is for NUMA, 
like it or not.

> > I'm saying there's absolutely no reason to have thp controlled by a 
> > cpuset, or ANY cgroup for that matter, since you chose not to respond to 
> > the question I asked: why do you want to control thp behavior for certain 
> > static binaries and not others?  Where is the performance regression or 
> > the downside?  Is it because of max_ptes_none for certain jobs blowing up 
> > the rss?  We need information, and even if were justifiable then it 
> > wouldn't have anything to do with ANY cgroup but rather a per-process 
> > control.  It has nothing to do with cpusets whatsoever.
> 
> It was a request from our benchmarking group that has found some jobs
> benefit from thp, while other are harmed.  Let me ask them for more
> details.
> 

Yes, please, because if some jobs are harmed by thp then we need to fix 
that regression and not paper around with it with some cpuset-based 
solution.  People should be able to run with CONFIG_TRANSPARENT_HUGEPAGE 
enabled and not be required to enable CONFIG_CPUSETS for optimal behavior.  
I'm suspecting that you're referring to enlarged rss because of 
khugepaged's max_ptes_none and because you're abusing the purpose of 
cpusets for containerization.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
