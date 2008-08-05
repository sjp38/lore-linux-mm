Date: Tue, 5 Aug 2008 12:11:48 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC] [PATCH 0/5 V2] Huge page backed user-space stacks
Message-ID: <20080805111147.GD20243@csn.ul.ie>
References: <cover.1216928613.git.ebmunson@us.ibm.com> <20080730014308.2a447e71.akpm@linux-foundation.org> <20080730172317.GA14138@csn.ul.ie> <20080730103407.b110afc2.akpm@linux-foundation.org> <20080730193010.GB14138@csn.ul.ie> <20080730130709.eb541475.akpm@linux-foundation.org> <20080731103137.GD1704@csn.ul.ie> <1217884211.20260.144.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1217884211.20260.144.camel@nimitz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, ebmunson@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net, abh@cray.com
List-ID: <linux-mm.kvack.org>

On (04/08/08 14:10), Dave Hansen didst pronounce:
> On Thu, 2008-07-31 at 11:31 +0100, Mel Gorman wrote:
> > We are a lot more reliable than we were although exact quantification is
> > difficult because it's workload dependent. For a long time, I've been able
> > to test bits and pieces with hugepages by allocating the pool at the time
> > I needed it even after days of uptime. Previously this required a reboot.
> 
> This is also a pretty big expansion of fs/hugetlb/ use outside of the
> filesystem itself.  It is hacking the existing shared memory
> kernel-internal user to spit out effectively anonymous memory.
> 
> Where do we draw the line where we stop using the filesystem for this?
> Other than the immediate code reuse, does it gain us anything?
> 
> I have to think that actually refactoring the filesystem code and making
> it usable for really anonymous memory, then using *that* in these
> patches would be a lot more sane.  Especially for someone that goes to
> look at it in a year. :)
> 

See, that's great until you start dealing with MAP_SHARED|MAP_ANONYMOUS.
To get that right between children, you end up something very fs-like
when the child needs to fault in a page that is already populated by the
parent. I strongly suspect we end up back at hugetlbfs backing it :/

If you were going to do such a thing, you'd end up converting something
like ramfs to hugetlbfs and sharing that.


-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
