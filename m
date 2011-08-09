Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 96B9E6B0169
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 07:04:31 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p79B4PFt001573
	for <linux-mm@kvack.org>; Tue, 9 Aug 2011 04:04:25 -0700
Received: from qyk36 (qyk36.prod.google.com [10.241.83.164])
	by wpaz29.hot.corp.google.com with ESMTP id p79B4MiP015109
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 9 Aug 2011 04:04:24 -0700
Received: by qyk36 with SMTP id 36so1979325qyk.9
        for <linux-mm@kvack.org>; Tue, 09 Aug 2011 04:04:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110807142532.GC1823@barrios-desktop>
References: <1312492042-13184-1-git-send-email-walken@google.com>
	<CANN689HpuQ3bAW946c4OeoLLAUXHd6nzp+NVxkrFgZo7k3k0Kg@mail.gmail.com>
	<20110807142532.GC1823@barrios-desktop>
Date: Tue, 9 Aug 2011 04:04:21 -0700
Message-ID: <CANN689Edai1k4nmyTHZ_2EwWuTXdfmah-JiyibEBvSudcWhv+g@mail.gmail.com>
Subject: Re: [RFC PATCH 0/3] page count lock for simpler put_page
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

On Sun, Aug 7, 2011 at 7:25 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Thu, Aug 04, 2011 at 11:39:19PM -0700, Michel Lespinasse wrote:
>> On Thu, Aug 4, 2011 at 2:07 PM, Michel Lespinasse <walken@google.com> wrote:
>> > Patch 3 demonstrates my motivation for this patch series: in my pre-THP
>> > implementation of idle page tracking, I was able to use get_page_unless_zero
>> > in a way that __split_huge_page_refcount made unsafe. Building on top of
>> > patch 2, I can make the required operation safe again. If patch 2 was to
>> > be rejected, I would like to get suggestions about alternative approaches
>> > to implement the get_first_page_unless_zero() operation described here.
>>
>> I should add that I am quite worried about the places that use
>> get_page_unless_zero (or the page_cache_*_speculative wrappers) today.
>> My worrisome scenario would be as follows:
>>
>> - thread T finds a pointer to a page P (possibly from a radix tree in
>> find_get_page() )
>> - page P gets freed by another thread
>> - page P gets re-allocated as the tail of a THP page by another thread
>> - another thread gets a reference on page P
>> - thread T proceeds doing page_cache_get_speculative(P), intending to
>> then check that P is really the page it wanted
>> - another thread splits up P's compound page;
>> __split_huge_page_refcount subtracts T's refcount on P from head(P)'s
>> refcount
>> - thread T figures out that it didn't get the page it expected, calls
>> page_cache_release(P). But it's too late - the refcount for what used
>> to be head(P) has already been corrupted (incorrectly decremented).
>>
>> Does anything prevent the above ?
>
> I think it's possbile and you find a BUG.
> Andrea?

At this point I believe this is indeed a bug, though a very unlikely
one to hit. The interval between thread T finding a pointer to page P
and thread T getting a reference on P is typically just a few
instructions, while the time scale necessary for other threads to free
page P, reallocate it as a compound page, and decide to split it into
single pages is just much larger. So, there is no line of code I can
point to that would prevent the race, but it also looks like it would
be very hard to trigger it.

>> I can see that the page_cache_get_speculative comment in
>> include/linux/pagemap.h maps out one way to prevent the issue. If
>> thread T continually held an rcu read lock from the time it finds the
>> pointer to P until the time it calls get_page_unless_zero on that
>> page, AND there was a synchronize_rcu() call somewhere between the
>> time a THP page gets allocated and the time __split_huge_page_refcount
>> might first get called on that page, then things would be safe.
>> However, that does not seem to be true today: I could not find a
>> synchronize_rcu() call before __split_huge_page_refcount(), AND there
>> are also places (such as deactivate_page() for example) that call
>> get_page_unless_zero without being within an rcu read locked section
>> (or holding the zone lru lock to provide exclusion against
>> __split_huge_page_refcount).

Going forward, I can see several possible solutions:
- Use my proposed page count lock in order to avoid the race. One
would have to convert all get_page_unless_zero() sites to use it. I
expect the cost would be low but still measurable.
- Protect all get_page_unless_zero call sites with rcu read lock or
lru lock (page_cache_get_speculative already has it, but there are
others to consider), and add a synchronize_rcu() before splitting huge
pages.
- It'd be sweet if one could somehow record the time a THP page was
created, and wait for at least one RCU grace period *starting from the
recorded THP creation time* before splitting huge pages. In practice,
we would be very unlikely to have to wait since the grace period would
be already expired. However, I don't think RCU currently provides such
a mechanism - Paul, is this something that would seem easy to
implement or not ?
- Do nothing and hope one doesn't hit the race. This is not my
favourite "solution", but OTOH the race seems so hard to hit that it
may be hard to justify expensive solutions to work around it.

> When I make deactivate_page, I didn't consider that honestly.
> IMHO, It shouldn't be a problem as deactive_page hold a reference
> of page by pagevec_lookup so the page shouldn't be gone under us.

Agree - it seems like you are guaranteed to already hold a reference
(but then a straight get_page should be sufficient, right ?)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
