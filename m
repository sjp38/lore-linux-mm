Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 433015F0001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 07:19:02 -0500 (EST)
Date: Tue, 3 Feb 2009 12:18:28 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] SLQB slab allocator
In-Reply-To: <1233646145.2604.137.camel@ymzhang>
Message-ID: <Pine.LNX.4.64.0902031150110.5290@blonde.anvils>
References: <20090121143008.GV24891@wotan.suse.de>
 <Pine.LNX.4.64.0901211705570.7020@blonde.anvils>
 <84144f020901220201g6bdc2d5maf3395fc8b21fe67@mail.gmail.com>
 <Pine.LNX.4.64.0901221239260.21677@blonde.anvils>
 <Pine.LNX.4.64.0901231357250.9011@blonde.anvils>  <1233545923.2604.60.camel@ymzhang>
  <1233565214.17835.13.camel@penberg-laptop> <1233646145.2604.137.camel@ymzhang>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Feb 2009, Zhang, Yanmin wrote:
> On Mon, 2009-02-02 at 11:00 +0200, Pekka Enberg wrote:
> > On Mon, 2009-02-02 at 11:38 +0800, Zhang, Yanmin wrote:
> > > Can we add a checking about free memory page number/percentage in function
> > > allocate_slab that we can bypass the first try of alloc_pages when memory
> > > is hungry?
> > 
> > If the check isn't too expensive, I don't any reason not to. How would
> > you go about checking how much free pages there are, though? Is there
> > something in the page allocator that we can use for this?
> 
> We can use nr_free_pages(), totalram_pages and hugetlb_total_pages(). Below
> patch is a try. I tested it with hackbench and tbench on my stoakley
> (2 qual-core processors) and tigerton (4 qual-core processors).
> There is almost no regression.

May I repeat what I said yesterday?  Certainly I'm oversimplifying,
but if I'm plain wrong, please correct me.

Having lots of free memory is a temporary accident following process
exit (when lots of anonymous memory has suddenly been freed), before
it has been put to use for page cache.  The kernel tries to run with
a certain amount of free memory in reserve, and the rest of memory
put to (potentially) good use.  I don't think we have the number
you're looking for there, though perhaps some approximation could
be devised (or I'm looking at the problem the wrong way round).

Perhaps feedback from vmscan.c, on how much it's having to write back,
would provide a good clue.  There's plenty of stats maintained there.

> 
> Besides this patch, I have another patch to try to reduce the calculation
> of "totalram_pages - hugetlb_total_pages()", but it touches many files.
> So just post the first simple patch here for review.
> 
> 
> Hugh,
> 
> Would you like to test it on your machines?

Indeed I shall, starting in a few hours when I've finished with trying
the script I promised yesterday to send you.  And I won't be at all
surprised if your patch eliminates my worst cases, because I don't
expect to have any significant amount of free memory during my testing,
and my swap testing suffers from slub's thirst for higher orders.

But I don't believe the kind of check you're making is appropriate,
and I do believe that when you try more extensive testing, you'll find
regressions in other tests which were relying on the higher orders.
If all of your testing happens to have lots of free memory around,
I'm surprised; but perhaps I'm naive about how things actually work,
especially on the larger machines.

Or maybe your tests are relying crucially on the slabs allocated at
system startup, when of course there should be plenty of free memory
around.

By the way, when I went to remind myself of what nr_free_pages()
actually does, my grep immediately hit this remark in mm/mmap.c:
		 * nr_free_pages() is very expensive on large systems,
I hope that's just a stale comment from before it was converted
to global_page_state(NR_FREE_PAGES)!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
