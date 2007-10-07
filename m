From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: VMA lookup with RCU
Date: Sun, 7 Oct 2007 17:47:22 +1000
References: <46F01289.7040106@linux.vnet.ibm.com> <470509F5.4010902@linux.vnet.ibm.com> <1191518486.5574.24.camel@lappy>
In-Reply-To: <1191518486.5574.24.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710071747.23252.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Alexis Bruemmer <alexisb@us.ibm.com>, Balbir Singh <balbir@in.ibm.com>, Badari Pulavarty <pbadari@us.ibm.com>, Max Asbock <amax@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Bharata B Rao <bharata@in.ibm.com>
List-ID: <linux-mm.kvack.org>

On Friday 05 October 2007 03:21, Peter Zijlstra wrote:
> On Thu, 2007-10-04 at 21:12 +0530, Vaidyanathan Srinivasan wrote:

> > Per CPU last vma cache:  Currently we have the last vma referenced in a
> > one entry cache in mm_struct.  Can we have this cache per CPU or per node
> > so that a multi threaded application can have node/cpu local cache of
> > last vma referenced.  This may reduce btree/rbtree traversal.  Let the
> > hardware cache maintain the corresponding VMA object and its coherency.
> >
> > Please let me know your comment and thoughts.
>
> Nick Piggin (and I think Eric Dumazet) had nice patches for this. I
> think they were posted in the private futex thread.

All they need is testing and some results to show they help. I actually
don't really have a realistic workload where vma lookup contention is
a problem, since the malloc fixes and private futexes went in.

Actually -- there is one thing, apparently oprofile does lots of find_vmas,
which trashes the vma cache. Either it should have its own cache, or at
least use a "nontemporal" lookup.

What I implemented was a per-thread cache. Per-CPU I guess would be
equally possible and might be preferable in some cases (although worse
in others). Still, the per-thread cache should be fine for basic performance
testing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
