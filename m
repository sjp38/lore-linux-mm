From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [rfc] lockless get_user_pages for dio (and more)
Date: Thu, 17 Jan 2008 17:34:30 +1100
References: <20071008225234.GC27824@linux-os.sc.intel.com> <200712121640.17077.nickpiggin@yahoo.com.au> <1200513482.6935.15.camel@norville.austin.ibm.com>
In-Reply-To: <1200513482.6935.15.camel@norville.austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200801171734.30555.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Cc: "Siddha, Suresh B" <suresh.b.siddha@intel.com>, Ken Chen <kenchen@google.com>, Badari Pulavarty <pbadari@gmail.com>, linux-mm <linux-mm@kvack.org>, tony.luck@intel.com, Adam Litke <agl@us.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thursday 17 January 2008 06:58, Dave Kleikamp wrote:
> On Wed, 2007-12-12 at 16:40 +1100, Nick Piggin wrote:
> > On Wednesday 12 December 2007 16:11, Dave Kleikamp wrote:
> > > On Wed, 2007-12-12 at 15:57 +1100, Nick Piggin wrote:
> > > > Anyway, I am hoping that someone will one day and test if this and
> > > > find it helps their workload, but on the other hand, if it doesn't
> > > > help anyone then we don't have to worry about adding it to the
> > > > kernel ;) I don't have any real setups that hammers DIO with threads.
> > > > I'm guessing DB2 and/or Oracle does?
> > >
> > > I'll try to get someone to run a DB2 benchmark and see what it looks
> > > like.
> >
> > That would be great if you could.
>
> We weren't able to get in any runs before the holidays, but we finally
> have some good news from our performance team:
>
> "To test the effects of the patch, an OLTP workload was run on an IBM
> x3850 M2 server with 2 processors (quad-core Intel Xeon processors at
> 2.93 GHz) using IBM DB2 v9.5 running Linux 2.6.24rc7 kernel. Comparing
> runs with and without the patch resulted in an overall performance
> benefit of ~9.8%. Correspondingly, oprofiles showed that samples from
> __up_read and __down_read routines that is seen during thread contention
> for system resources was reduced from 2.8% down to .05%. Monitoring
> the /proc/vmstat output from the patched run showed that the counter for
> fast_gup contained a very high number while the fast_gup_slow value was
> zero."
>
> Great work, Nick!

Ah, excellent. Thanks for getting those numbers Dave. This will
be a great help towards getting the patch merged.

I'm just working on the final required piece for this thing (the
pte_special pte bit, required to distinguish whether or not we
can refcount a page without looking at the vma). It is strictly
just a correctness/security measure, which is why you were able
to run tests without it. And it won't add any significant cost to
the fastpaths, so the numbers remain valid.

FWIW, I cc'ed linux-arch: the lockless get_user_pages patch has
architecture specific elements, so it will need some attention
there. If other architectures are interested (eg. powerpc or
ia64), then I will be happy to work with maintainers to help
try to devise a way of fitting it into their tlb flushing scheme.
Ping me if you'd like to take up the offer.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
