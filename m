Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DCD076B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 02:35:10 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p7Q6Ogip004712
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 23:24:46 -0700
Received: from gxk23 (gxk23.prod.google.com [10.202.11.23])
	by wpaz24.hot.corp.google.com with ESMTP id p7Q6OeWc012567
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 23:24:40 -0700
Received: by gxk23 with SMTP id 23so2695127gxk.0
        for <linux-mm@kvack.org>; Thu, 25 Aug 2011 23:24:40 -0700 (PDT)
Date: Thu, 25 Aug 2011 23:24:36 -0700
From: Michel Lespinasse <walken@google.com>
Subject: Re: [PATCH] thp: tail page refcounting fix #2
Message-ID: <20110826062436.GA5847@google.com>
References: <1313740111-27446-1-git-send-email-walken@google.com>
 <20110822213347.GF2507@redhat.com>
 <CANN689HE=TKyr-0yDQgXEoothGJ0Cw0HLB2iOvCKrOXVF2DNww@mail.gmail.com>
 <20110824000914.GH23870@redhat.com>
 <20110824002717.GI23870@redhat.com>
 <20110824133459.GP23870@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110824133459.GP23870@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Wed, Aug 24, 2011 at 03:34:59PM +0200, Andrea Arcangeli wrote:
> On Wed, Aug 24, 2011 at 02:27:17AM +0200, Andrea Arcangeli wrote:
> > On Wed, Aug 24, 2011 at 02:09:14AM +0200, Andrea Arcangeli wrote:
> > > That's an optimization I can look into agreed. I guess I just added
> > > one line and not even think too much at optimizing this,
> > > split_huge_page isn't in a fast path.
> > 
> > So this would more or less be the optimization (untested):
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -1169,8 +1169,8 @@ static void __split_huge_page_refcount(s
> >  		atomic_sub(page_mapcount(page_tail), &page->_count);
> >  		BUG_ON(atomic_read(&page->_count) <= 0);
> >  		BUG_ON(atomic_read(&page_tail->_count) != 0);
> > -		atomic_add(page_mapcount(page) + 1, &page_tail->_count);
> > -		atomic_add(page_mapcount(page_tail), &page_tail->_count);
> > +		atomic_add(page_mapcount(page) + page_mapcount(page_tail) + 1,
> > +			   &page_tail->_count);
> >  
> >  		/* after clearing PageTail the gup refcount can be released */
> >  		smp_mb();
> 
> So this is a new version incorporating only the above
> microoptimization. Unless somebody can guarantee me the atomic_set is
> safe in all archs (which requires get_page_unless_zero() running vs C
> language page_tail->_count = 1 to provide a deterministic result) I'd
> stick with the atomic_add above to be sure.
> 
> I think on even on x86 32bit it wouldn't be safe on PPro with OOSTORE
> (PPro errata 66, 92) which should also have PSE.

I had never heard before of locked instructions being necessary when a
straight assignment would do what we want, but after reading the erratas
you listed, I'm not so sure anymore. Given that, I think the version with
just one single atomic add is good enough.

(there are also 511 consecutive atomic_sub calls on the head page _count,
which could just as well be coalesced into a signle one at the end of the
tail page loop).


But enough about the atomics - there are other points I want to feedback on.


I think your current __get_page_tail() is unsafe when it takes the
compound lock on the head page, because there is no refcount held on it.
If the THP page gets broken up before we get the compound lock, the head
page could get freed. But it looks like you could fix that by doing
get_page_unless_zero on the head, and you should end up with something
very much like the put_page() function, which I find incredibly tricky
but seems to be safe.


I would suggest moving get_page_foll() and __get_page_tail_foll() to
mm/internal.h so that people writing code outside of mm/ don't get confused
about which get_page() version they must call.


In __get_page_tail(), you could add a VM_BUG_ON(page_mapcount(page) <= 0)
to reflect the fact that get_page() callers are expected to have already
gotten a reference on the page through a gup call.


(not your fault, you just moved that code) The comment above
reset_page_mapcount() and page_mapcount() mentions that _count starts from -1.
This does not seem to be accurate anymore - as you see page_count() just
returns the _count value without adding 1. I guess you could just remove
', like _count,' from the comment and that'd make it accurate :)


The use of _mapcount to store tail page counts should probably be
documented somewhere - probably in mm_types.h where _mapcount is
defined, and/or before the page_mapcount accessor function. Or, there
could be a tail_page_count() accessor function for that so that it's
evident in all call sites that we're accessing a refcount and not a mapcount:

static inline int tail_page_count(struct page *page)
{
	VM_BUG_ON(!PageTail(page));
	return page_mapcount(page);
}


(probably for another commit) I'm not too comfortable with having several
arch-specific fast gup functions knowning details about how page counts
are implemented. Linus's tree also adds such support in sparc arch
(and it doesn't even seem to be correct as it increments the head count
but not the tail count). This should probably be cleaned up sometime by
moving such details into generic inline helper functions.


Besides these comments, overall I like the change a lot & I'm especially
happy to see get_page() work in all cases again :)

Thanks,

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
