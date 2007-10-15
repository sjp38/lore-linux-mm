From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [rfc] more granular page table lock for hugepages
Date: Mon, 15 Oct 2007 14:17:53 +1000
References: <20071008225234.GC27824@linux-os.sc.intel.com> <200710140927.46478.nickpiggin@yahoo.com.au> <20071014154223.GD19625@linux-os.sc.intel.com>
In-Reply-To: <20071014154223.GD19625@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710151417.53342.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Cc: Ken Chen <kenchen@google.com>, Badari Pulavarty <pbadari@gmail.com>, linux-mm <linux-mm@kvack.org>, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

On Monday 15 October 2007 01:42, Siddha, Suresh B wrote:
> On Sun, Oct 14, 2007 at 09:27:46AM +1000, Nick Piggin wrote:
> > On Saturday 13 October 2007 06:34, Siddha, Suresh B wrote:
> > > On ia64, we have "tpa" instruction which does the virtual to physical
> > > address conversion for us. But talking to Tony, that will fault during
> > > not present or vhpt misses.
> > >
> > > Well, for now, manual walk is probably the best we have.
> >
> > Hmm, we'd actually want it to fault, and go through the full
> > handle_mm_fault path if possible, and somehow just give an
>
> But, this walk was happening with interrupts disabled. So the best will be
> to have a peek at the page tables without faulting and the peek can
> comeback and say, sorry, you have to go through slowest path.

Oh yeah, you're right of course. I guess it is probably better to
do that way anyway: either way we have to take mmap_sem, and once
taken, it is probably better to hold it and batch up the rest of
the operations in the slowpath.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
