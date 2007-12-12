From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [rfc] lockless get_user_pages for dio (and more)
Date: Wed, 12 Dec 2007 16:40:16 +1100
References: <20071008225234.GC27824@linux-os.sc.intel.com> <200712121557.20807.nickpiggin@yahoo.com.au> <1197436306.6367.12.camel@norville.austin.ibm.com>
In-Reply-To: <1197436306.6367.12.camel@norville.austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200712121640.17077.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Cc: "Siddha, Suresh B" <suresh.b.siddha@intel.com>, Ken Chen <kenchen@google.com>, Badari Pulavarty <pbadari@gmail.com>, linux-mm <linux-mm@kvack.org>, tony.luck@intel.com, Adam Litke <agl@us.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 12 December 2007 16:11, Dave Kleikamp wrote:
> On Wed, 2007-12-12 at 15:57 +1100, Nick Piggin wrote:
> > On Tuesday 11 December 2007 08:30, Dave Kleikamp wrote:
> > > Nick,
> > > I've played with the fast_gup patch a bit.  I was able to find a
> > > problem in follow_hugetlb_page() that Adam Litke fixed.  I'm haven't
> > > been brave enough to implement it on any other architectures, but I did
> > > add  a default that takes mmap_sem and calls the normal
> > > get_user_pages() if the architecture doesn't define fast_gup().  I put
> > > it in linux/mm.h, for lack of a better place, but it's a little kludgy
> > > since I didn't want mm.h to have to include sched.h.  This patch is
> > > against 2.6.24-rc4. It's not ready for inclusion yet, of course.
> >
> > Hi Dave,
> >
> > Thanks so much. This makes it much more a complete patch (although
> > still missing the "normal page" detection).
> >
> > I think I missed -- or forgot -- what was the follow_hugetlb_page
> > problem?
>
> Badari found a problem running some tests and handed it off to me to
> look at.  I didn't share it publicly.  Anyway, we were finding that
> fastgup was taking the slow path almost all the time with huge pages.
> The problem was that follow_hugetlb_page was failing to fault on a
> non-writable page when it needed a writable one.  So we'd keep seeing a
> non-writable page over and over.  This is fixed in 2.6.24-rc5.

Ah yes, I just saw that fix in the changelog. So not a problem with my
patch as such, but good to get that fixed.


> > Anyway, I am hoping that someone will one day and test if this and
> > find it helps their workload, but on the other hand, if it doesn't
> > help anyone then we don't have to worry about adding it to the
> > kernel ;) I don't have any real setups that hammers DIO with threads.
> > I'm guessing DB2 and/or Oracle does?
>
> I'll try to get someone to run a DB2 benchmark and see what it looks
> like.

That would be great if you could.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
