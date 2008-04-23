Date: Wed, 23 Apr 2008 16:14:29 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC] Reserve huge pages for reliable MAP_PRIVATE hugetlbfs mappings
Message-ID: <20080423151428.GA15834@csn.ul.ie>
References: <20080421183621.GA13100@csn.ul.ie> <87hcdsznep.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <87hcdsznep.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: wli@holomorphy.com, agl@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (23/04/08 15:55), Andi Kleen didst pronounce:
> Mel Gorman <mel@csn.ul.ie> writes:
> 
> > MAP_SHARED mappings on hugetlbfs reserve huge pages at mmap() time. This is
> > so that all future faults will be guaranteed to succeed. Applications are not
> > expected to use mlock() as this can result in poor NUMA placement.
> >
> > MAP_PRIVATE mappings do not reserve pages. This can result in an application
> > being SIGKILLed later if a large page is not available at fault time. This
> > makes huge pages usage very ill-advised in some cases as the unexpected
> > application failure is intolerable. Forcing potential poor placement with
> > mlock() is not a great solution either.
> >
> > This patch reserves huge pages at mmap() time for MAP_PRIVATE mappings similar
> > to what happens for MAP_SHARED mappings. 
> 
> This will break all applications that mmap more hugetlbpages than they
> actually use. How do you know these don't exist?
> 

If the large pages exist to satisfy the mapping, the application will not
even notice this change. They will only break if the are creating larger
mappings than large pages exist for (or can be allocated for in the event
they have enabled dynamic resizing with nr_overcommit_hugepages). If they
are doing that, they are running a big risk as they may get arbitrarily
killed later. Sometimes their app will run, other times it dies. If more
than one application is running on the system that is behaving like this,
they are really playing with fire.

With this change, a mmap() failure is a clear indication that the mapping
would have been unsafe to use and they should try mmap()ing with small pages
instead. 


> > Opinions?
> 
> Seems like a risky interface change to me.
> 

Using MAP_PRIVATE at all is a faily major risk as it is. I am failing to
see why risk of random SIGKILL is a desirable "feature".

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
