From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: mm-more-likely-reclaim-madv_sequential-mappings.patch
References: <20081015162232.f673fa59.akpm@linux-foundation.org>
	<200810171321.40725.nickpiggin@yahoo.com.au>
	<87k5c74135.fsf@saeurebad.de>
	<200810181230.33688.nickpiggin@yahoo.com.au>
Date: Sat, 18 Oct 2008 12:45:38 +0200
In-Reply-To: <200810181230.33688.nickpiggin@yahoo.com.au> (Nick Piggin's
	message of "Sat, 18 Oct 2008 12:30:33 +1100")
Message-ID: <87fxmu41wt.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <nickpiggin@yahoo.com.au> writes:

> On Saturday 18 October 2008 03:51, Johannes Weiner wrote:
>> Nick Piggin <nickpiggin@yahoo.com.au> writes:
>> > On Friday 17 October 2008 04:04, Rik van Riel wrote:
>> >> Nick Piggin wrote:
>> >> > ClearPageReferenced I don't know if it should be cleared like this.
>> >> > PageReferenced is more of a bit for the mark_page_accessed state
>> >> > machine, rather than the pte_young stuff. Although when unmapping, the
>> >> > latter somewhat collapses back to the former, but I don't know if
>> >> > there is a very good reason to fiddle with it here.
>> >> >
>> >> > Ignoring the young bit in the pte for sequential hint maybe is OK (and
>> >> > seems to be effective as per the benchmarks). But I would prefer not
>> >> > to merge the PageReferenced parts unless they get their own
>> >> > justification.
>> >>
>> >> Unless we clear the PageReferenced bit, we will still activate
>> >> the page - even if its only access came through a sequential
>> >> mapping.
>> >>
>> >> Faulting the page into the sequential mapping ends up setting
>> >> PageReferenced, IIRC.
>> >
>> > Yes I see. But that's stupid because then you can end up putting a
>> > sequential mapping on a page, and cause that to deactivate somebody
>> > else's references... and the deactivation _only_ happens if the
>> > sequential mapping pte is young and the page happens not to be
>> > active, which is totally arbitrary.
>>
>> Another access would mean another young PTE, which we will catch as a
>> proper reference sooner or later while walking the mappings, no?
>
> No. Another access could come via read/write, or be subsequently unmapped
> and put into PG_referenced.

read/write use mark_page_accessed(), so after having two accesses, the
page is already active.  If it's not and we find an access through a
sequential mapping, we should be safe to clear PG_referenced.

So the combination of young pte, page not active and scanning a
sequential mapping is not an arbitrary condition at all.

The only incorrect behaviour I can see here is what you already pointed
out: zap_pte_range() should mark_page_accessed().

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
