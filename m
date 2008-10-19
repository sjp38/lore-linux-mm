From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: mm-more-likely-reclaim-madv_sequential-mappings.patch
Date: Sun, 19 Oct 2008 13:21:25 +1100
References: <20081015162232.f673fa59.akpm@linux-foundation.org> <200810181230.33688.nickpiggin@yahoo.com.au> <87fxmu41wt.fsf@saeurebad.de>
In-Reply-To: <87fxmu41wt.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810191321.25490.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Saturday 18 October 2008 21:45, Johannes Weiner wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> writes:
> > On Saturday 18 October 2008 03:51, Johannes Weiner wrote:
> >> Nick Piggin <nickpiggin@yahoo.com.au> writes:
> >> > On Friday 17 October 2008 04:04, Rik van Riel wrote:
> >> >> Nick Piggin wrote:
> >> >> > ClearPageReferenced I don't know if it should be cleared like this.
> >> >> > PageReferenced is more of a bit for the mark_page_accessed state
> >> >> > machine, rather than the pte_young stuff. Although when unmapping,
> >> >> > the latter somewhat collapses back to the former, but I don't know
> >> >> > if there is a very good reason to fiddle with it here.
> >> >> >
> >> >> > Ignoring the young bit in the pte for sequential hint maybe is OK
> >> >> > (and seems to be effective as per the benchmarks). But I would
> >> >> > prefer not to merge the PageReferenced parts unless they get their
> >> >> > own justification.
> >> >>
> >> >> Unless we clear the PageReferenced bit, we will still activate
> >> >> the page - even if its only access came through a sequential
> >> >> mapping.
> >> >>
> >> >> Faulting the page into the sequential mapping ends up setting
> >> >> PageReferenced, IIRC.
> >> >
> >> > Yes I see. But that's stupid because then you can end up putting a
> >> > sequential mapping on a page, and cause that to deactivate somebody
> >> > else's references... and the deactivation _only_ happens if the
> >> > sequential mapping pte is young and the page happens not to be
> >> > active, which is totally arbitrary.
> >>
> >> Another access would mean another young PTE, which we will catch as a
> >> proper reference sooner or later while walking the mappings, no?
> >
> > No. Another access could come via read/write, or be subsequently unmapped
> > and put into PG_referenced.
>
> read/write use mark_page_accessed(), so after having two accesses, the
> page is already active.  If it's not and we find an access through a
> sequential mapping, we should be safe to clear PG_referenced.

That's just handwaving. The patch still clears PG_referenced, which
is a shared resource, and it is wrong, conceptually. You can't argue
with that.

What about if mark_page_accessed is only used on the page once? and
it is referenced but not active?


> So the combination of young pte, page not active and scanning a
> sequential mapping is not an arbitrary condition at all.

No, it is a specific condition. And specifically it is wrong.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
