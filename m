Date: Wed, 24 Sep 2008 20:11:08 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] Report the pagesize backing a VMA in /proc/pid/smaps
Message-ID: <20080924191107.GA31324@csn.ul.ie>
References: <20080923211140.DC16.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080923194655.GA25542@csn.ul.ie> <20080924210309.8C3B.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080924154120.GA10837@csn.ul.ie> <1222272395.15523.3.camel@nimitz> <20080924171003.GD10837@csn.ul.ie> <1222282749.15523.59.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1222282749.15523.59.camel@nimitz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, agl@us.ibm.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (24/09/08 11:59), Dave Hansen didst pronounce:
> On Wed, 2008-09-24 at 18:10 +0100, Mel Gorman wrote:
> > On (24/09/08 09:06), Dave Hansen didst pronounce:
> > > On Wed, 2008-09-24 at 16:41 +0100, Mel Gorman wrote:
> > > > I admit it's ppc64-specific. In the latest patch series, I made this a
> > > > separate patch so that it could be readily dropped again for this reason.
> > > > Maybe an alternative would be to display MMUPageSize *only* where it differs
> > > > from KernelPageSize. Would that be better or similarly confusing?
> > > 
> > > I would also think that any arch implementing fallback from large to
> > > small pages in a hugetlbfs area (Adam needs to post his patches :) would
> > > also use this.
> > > 
> > 
> > Fair point. Maybe the thing to do is backburner this patch for the moment and
> > reintroduce it when/if an architecture supports demotion? The KernelPageSize
> > reporting in smaps and what the hpagesize in maps is still useful though
> > I believe. Any comment?
> 
> I'd kinda prefer to see it normalized into a single place rather than
> sprinkle it in each smaps file. 

I don't get what you mean by it being sprinkled in each smaps file. How
would you present the data?

> We should be able to figure out which
> mount the file is from and, from there, maybe we need some per-mount
> information exported.  
> 

Per-mount information is already exported and you can infer the data about
huge pagesizes. For example, if you know the default huge pagesize (from
/proc/meminfo), and the file is on hugetlbfs (read maps, then /proc/mounts)
and there is no pagesize= mount option (mounts again), you could guess what the
hugepage that is backing a VMA is. Shared memory segments are a little harder
but again, you can infer the information if you look around for long enough.

However, this is awkward and not very user-friendly. With the patches (minus
MMUPageSize as I think we've agreed to postpone that), it's easy to see what
pagesize is being used at a glance. Without it, you need to know a fair bit
about hugepages are implemented in Linux to infer the information correctly.

> > (future stuff from here on)
> > 
> > In the future if demotion does happen then the MMUPageSize information may
> > be genuinely useful instead of just a curious oddity on ppc64. As you point
> > out, Adam (added to cc) has worked on this area (starting with x86 demotion)
> > in the past but it's a while before it'll be considered for merging I believe.
> > 
> > That aside, more would need to be done with the page size reporting then
> > anyway. For example, it maybe indicate how much of each pagesize is in a VMA
> > or indicate that KernelPageSize is what is being requested but in reality
> > it is mixed like;
> > 
> > KernelPageSize:		2048 kB (mixed)
> > 
> > or
> > 
> > KernelPageSize:		2048 kB * 5, 4096 kB * 20
> 
> Looks a bit verbose, but I agree with the sentiment.
> 

Grand, I'll keep note of this to revisit it in the future when/if
pagesizes get mixed in a VMA. Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
