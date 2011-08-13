Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id DF5076B016C
	for <linux-mm@kvack.org>; Sat, 13 Aug 2011 00:07:57 -0400 (EDT)
Received: by gyg10 with SMTP id 10so3010317gyg.14
        for <linux-mm@kvack.org>; Fri, 12 Aug 2011 21:07:55 -0700 (PDT)
Date: Sat, 13 Aug 2011 13:07:46 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [RFC PATCH 0/3] page count lock for simpler put_page
Message-ID: <20110813040746.GA1905@barrios-desktop>
References: <1312492042-13184-1-git-send-email-walken@google.com>
 <CANN689HpuQ3bAW946c4OeoLLAUXHd6nzp+NVxkrFgZo7k3k0Kg@mail.gmail.com>
 <20110807142532.GC1823@barrios-desktop>
 <CANN689Edai1k4nmyTHZ_2EwWuTXdfmah-JiyibEBvSudcWhv+g@mail.gmail.com>
 <CAEwNFnA3o_9SJZEeSg5azO45-E3HhEcSnww0GarN5m6n-qL_Vw@mail.gmail.com>
 <CANN689HQjNUDHWXn9PuvHxP0A-6_ypsW=jdt=UvnMr8M0xm-WA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689HQjNUDHWXn9PuvHxP0A-6_ypsW=jdt=UvnMr8M0xm-WA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

On Fri, Aug 12, 2011 at 03:35:25PM -0700, Michel Lespinasse wrote:
> On Tue, Aug 9, 2011 at 3:22 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> > On Tue, Aug 9, 2011 at 8:04 PM, Michel Lespinasse <walken@google.com> wrote:
> >> On Sun, Aug 7, 2011 at 7:25 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> >>> On Thu, Aug 04, 2011 at 11:39:19PM -0700, Michel Lespinasse wrote:
> >>>> I can see that the page_cache_get_speculative comment in
> >>>> include/linux/pagemap.h maps out one way to prevent the issue. If
> >>>> thread T continually held an rcu read lock from the time it finds the
> >>>> pointer to P until the time it calls get_page_unless_zero on that
> >>>> page, AND there was a synchronize_rcu() call somewhere between the
> >>>> time a THP page gets allocated and the time __split_huge_page_refcount
> >>>> might first get called on that page, then things would be safe.
> >>>> However, that does not seem to be true today: I could not find a
> >>>> synchronize_rcu() call before __split_huge_page_refcount(), AND there
> >>>> are also places (such as deactivate_page() for example) that call
> >>>> get_page_unless_zero without being within an rcu read locked section
> >>>> (or holding the zone lru lock to provide exclusion against
> >>>> __split_huge_page_refcount).
> >>
> >> Going forward, I can see several possible solutions:
> >> - Use my proposed page count lock in order to avoid the race. One
> >> would have to convert all get_page_unless_zero() sites to use it. I
> >> expect the cost would be low but still measurable.
> >
> > It's not necessary to apply it on *all* get_page_unless_zero sites.
> > Because deactivate_page does it on file pages while THP handles only anon pages.
> > So the race should not a problem.
> 
> But it doesn't matter what kind of page the get_page_unless_zero call
> site hopes to get a reference on - if it doesn't already hold a
> reference on the page (either directly as a reference, or if a known
> mapping points to that page and the page table lock is taken or
> interrupts are disabled in order to guarantee the mapping won't get
> yanked), then the page can get yanked and a THP page could show up
> there before the call site gets a reference.

As I said, the caller of deactivate hold a reference at now so it should be okay.
But I admit deactivate_page doesn't have to call get_page_unless_zero but get_page
is enough if caller makes sure to hold a reference on the page like current situation.
I will add such comment on the deactivate_page and change get_page_unless_zero with
get_page for easy use in future.

I have't notice that.
Thanks for giving the chance to think of it, Michel.

> 
> >> - Protect all get_page_unless_zero call sites with rcu read lock or
> >> lru lock (page_cache_get_speculative already has it, but there are
> >> others to consider), and add a synchronize_rcu() before splitting huge
> >> pages.
> >
> > I think it can't be a solution.
> > If we don't have any lock for protect write-side, page_count could be
> > unstable again while we peek page->count in
> > __split_huge_page_refcount after calling synchronize_rcu.
> > Do I miss something?
> 
> The tail page count would be unstable for at most one rcu grace period
> after the page got allocated. This is guaranteed by making all
> get_page_unless_zero call sites make sure they somehow determine the
> page is not a THP tail page (for example because they found it in
> radix tree) before calling get_page_unless_zero and having an rcu read
> lock wrapping these two together. This is basically the protocol
> described in the comment for page_cache_get_speculative() in pagemap.h

Absolutely

> 
> -- 
> Michel "Walken" Lespinasse
> A program is never fully debugged until the last user dies.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
