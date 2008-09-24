Date: Thu, 25 Sep 2008 00:39:52 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/2] Report the pagesize backing a VMA in /proc/pid/smaps
Message-ID: <20080924233952.GB8598@csn.ul.ie>
References: <20080923211140.DC16.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080923194655.GA25542@csn.ul.ie> <20080924210309.8C3B.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080924154120.GA10837@csn.ul.ie> <1222272395.15523.3.camel@nimitz> <20080924171003.GD10837@csn.ul.ie> <1222282749.15523.59.camel@nimitz> <20080924191107.GA31324@csn.ul.ie> <1222284190.15523.64.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1222284190.15523.64.camel@nimitz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, agl@us.ibm.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (24/09/08 12:23), Dave Hansen didst pronounce:
> On Wed, 2008-09-24 at 20:11 +0100, Mel Gorman wrote:
> > I don't get what you mean by it being sprinkled in each smaps file. How
> > would you present the data?
> 
> 1. figure out what the file path is from smaps
> 2. look up the mount
> 3. look up the page sizes from the mount's information
> 

You should be able to do that today but it's not a particularly friendly
task. I expect without decent knowledge of how hugepages work that you'll get
it wrong. A userspace tool could do this of course and likely would use stat
on the file to get teh blocksize if it was hugetlbfs instead of consulting
mounts. It's just not as user-friendly. Consider "cat smaps" as opposed to
download this tool, run it and it'll give you an smaps-like output.

> > > We should be able to figure out which
> > > mount the file is from and, from there, maybe we need some per-mount
> > > information exported.  
> > 
> > Per-mount information is already exported and you can infer the data about
> > huge pagesizes. For example, if you know the default huge pagesize (from
> > /proc/meminfo), and the file is on hugetlbfs (read maps, then /proc/mounts)
> > and there is no pagesize= mount option (mounts again), you could guess what the
> > hugepage that is backing a VMA is. Shared memory segments are a little harder
> > but again, you can infer the information if you look around for long enough.
> > 
> > However, this is awkward and not very user-friendly. With the patches (minus
> > MMUPageSize as I think we've agreed to postpone that), it's easy to see what
> > pagesize is being used at a glance. Without it, you need to know a fair bit
> > about hugepages are implemented in Linux to infer the information correctly.
> 
> I agree completely.  But, if we consider this a user ABI thing, then
> we're stuck with it for a long time, and we better make it flexible
> enough to at least contain the gunk we're planning on adding in a small
> number of years, like the fallback.  We don't want to be adding this
> stuff if it isn't going to be stable.
> 

What's wrong with

KernelPageSize: X kB 

now which a parser can easily handle and later

KernelPageSize: X kb * nX Y kB * nY

where X is a pagesize, nX is the number of pages of that size in a VMA
later? The second format should not break a naive parser.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
