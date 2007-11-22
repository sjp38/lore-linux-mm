Date: Thu, 22 Nov 2007 01:44:55 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Page allocator: Get rid of the list of cold pages
Message-ID: <20071122014455.GH31674@csn.ul.ie>
References: <Pine.LNX.4.64.0711141148200.18811@schroedinger.engr.sgi.com> <20071115162706.4b9b9e2a.akpm@linux-foundation.org> <20071121222059.GC31674@csn.ul.ie> <Pine.LNX.4.64.0711211434290.3809@schroedinger.engr.sgi.com> <20071121230041.GE31674@csn.ul.ie> <Pine.LNX.4.64.0711211530370.4383@schroedinger.engr.sgi.com> <20071121235849.GG31674@csn.ul.ie> <Pine.LNX.4.64.0711211605010.4556@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711211605010.4556@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, apw@shadowen.org, Martin Bligh <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On (21/11/07 16:06), Christoph Lameter didst pronounce:
> On Wed, 21 Nov 2007, Mel Gorman wrote:
> 
> > I didn't think you were going to roll a patch and had queued this
> > slightly more agressive version. I think it is a superset of what your
> > patch does.
> 
> Looks okay.
> 

And the results were better as well. Running one instance per-CPU, the
joined lists ignoring temperature was marginally faster than no-PCPU or
the hotcold-PCPU up to 0.5MB which roughly corresponds to the some of L1
caches of the CPUs. At higher sizes, it starts to look slower but even
at 8MB files, it is by a much smaller amount. With list manuipulations,
it is about 0.3 seconds slower. With just the lists joined, it's 0.1
seconds and I think the patch could simplify the paths more than what we
have currently. The full graph is at

http://www.csn.ul.ie/~mel/postings/percpu-20071121/graph-elm3b6-4instance-fullrange-notemp.ps

> Also note that you can avoid mmap_sem cacheline bouncing by having 
> separate address spaces. Forking a series of processes that then fault 
> pages each into their own address space will usually do the trick.

The test is already forking for just that reason. I'll see what the results
look like for more CPUs before putting the time into modifying the test for
anonymous mmap()

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
