Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5F4446B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 10:15:15 -0400 (EDT)
Date: Wed, 18 Aug 2010 16:13:08 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [TESTCASE] Clean pages clogging the VM
Message-ID: <20100818141308.GD1779@cmpxchg.org>
References: <20100809133000.GB6981@wil.cx> <20100817195001.GA18817@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100817195001.GA18817@linux.intel.com>
Sender: owner-linux-mm@kvack.org
To: Matthew Wilcox <willy@linux.intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Matthew,

On Tue, Aug 17, 2010 at 03:50:01PM -0400, Matthew Wilcox wrote:
> 
> No comment on this?  Was it just that I posted it during the VM summit?

I have not forgotten about it.  I just have a hard time reproducing
those extreme stalls you observed.

Running that test on a 2.5GHz machine with 2G of memory gives me
stalls of up to half a second.  The patchset I am experimenting with
gets me down to peaks of 70ms, but it needs further work.

Mapped file pages get two rounds on the LRU list, so once the VM
starts scanning, it has to go through all of them twice and can only
reclaim them on the second encounter.

At that point, since we scan without making progress, we start waiting
for IO, which is not happening in this case, so we sit there until a
timeout expires.

This stupid-waiting can be improved, and I am working on that.  But
since I can not reproduce your observations, I don't know if this is
the (sole) source of the problem.  Can I send you patches?

> On Mon, Aug 09, 2010 at 09:30:00AM -0400, Matthew Wilcox wrote:
> > 
> > This testcase shows some odd behaviour from the Linux VM.
> > 
> > It creates a 1TB sparse file, mmaps it, and randomly reads locations 
> > in it.  Due to the file being entirely sparse, the VM allocates new pages
> > and zeroes them.  Initially, it runs very fast, taking on the order of
> > 2.7 to 4us per page fault.  Eventually, the VM runs out of free pages,
> > and starts doing huge amounts of work trying to figure out which of
> > these clean pages to throw away.

This is similar to one of my test cases for:

	6457474 vmscan: detect mapped file pages used only once
	31c0569 vmscan: drop page_mapping_inuse()
	dfc8d63 vmscan: factor out page reference checks

because the situation was even worse before (see the series
description in dfc8d63).  Maybe asking the obvious, but the kernel you
tested on did include those commits, right?

And just to be sure, I sent you a test-patch to disable the used-once
detection on IRC the other day.  Did you have time to run it yet?
Here it is again:

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9c7e57c..c757bba 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -584,6 +584,7 @@ static enum page_references page_check_references(struct page *page,
 		return PAGEREF_RECLAIM;
 
 	if (referenced_ptes) {
+		return PAGEREF_ACTIVATE;
 		if (PageAnon(page))
 			return PAGEREF_ACTIVATE;
 		/*


> > In my testing with a 6GB machine and 2.9GHz CPU, one in every
> > 15,000 page faults takes over a second, and one in every 40,000
> > page faults take over seven seconds!
> > 
> > This test-case demonstrates a problem that occurs with a read-mostly 
> > mmap of a file on very fast media.  I wouldn't like to see a solution
> > that special-cases zeroed pages.  I think userspace has done its part
> > to tell the kernel what's it's doing by calling madvise(MADV_RANDOM).
> > This ought to be enough to hint to the kernel that it should be eagerly
> > throwing away pages in this VMA.

We can probably do something like the following, but I am not sure
this is a good fix, either.  How many applications are using
madvise()?

--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -495,7 +495,7 @@ int page_referenced_one(struct page *pag
 		 * mapping is already gone, the unmap path will have
 		 * set PG_referenced or activated the page.
 		 */
-		if (likely(!VM_SequentialReadHint(vma)))
+		if (likely(!(vma->vm_flags & (VM_SEQ_READ|VM_RAND_READ))))
 			referenced++;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
