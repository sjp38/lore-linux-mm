From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [rfc] more granular page table lock for hugepages
Date: Sun, 14 Oct 2007 09:27:46 +1000
References: <20071008225234.GC27824@linux-os.sc.intel.com> <200710112139.51354.nickpiggin@yahoo.com.au> <20071012203421.GC19625@linux-os.sc.intel.com>
In-Reply-To: <20071012203421.GC19625@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710140927.46478.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Siddha, Suresh B" <suresh.b.siddha@intel.com>
Cc: Ken Chen <kenchen@google.com>, Badari Pulavarty <pbadari@gmail.com>, linux-mm <linux-mm@kvack.org>, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

On Saturday 13 October 2007 06:34, Siddha, Suresh B wrote:
> On Thu, Oct 11, 2007 at 04:39:51AM -0700, Nick Piggin wrote:
> > Attached is the really basic sketch of how it will work. Any
> > party poopers care tell me why I'm an idiot? :)
>
> I tried to be a party pooper but no. This sounds like a good idea as you
> are banking on the 'mm' being the 'active mm'.

Yeah, I think that's the common case, and definitely required for
this lockless path to work.


> sounds like two birds in one shot, I think.

OK, I'll flesh it out a bit more and see if I can actually get
something working (and working with hugepages too).


> On ia64, we have "tpa" instruction which does the virtual to physical
> address conversion for us. But talking to Tony, that will fault during not
> present or vhpt misses.
>
> Well, for now, manual walk is probably the best we have.

Hmm, we'd actually want it to fault, and go through the full
handle_mm_fault path if possible, and somehow just give an
-EFAULT if it can't be satisfied. The common case will be that
a mapping does actually exist, but sometimes there won't be a
pte entry... depending on the application, it may even be the
common case to have a hot TLB entry too... I don't know,
obviously the manual walk is needed to get a simple baseline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
