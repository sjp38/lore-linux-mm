From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: mm-more-likely-reclaim-madv_sequential-mappings.patch
Date: Tue, 21 Oct 2008 12:45:07 +1100
References: <20081015162232.f673fa59.akpm@linux-foundation.org> <200810191321.25490.nickpiggin@yahoo.com.au> <87skqshcnw.fsf@saeurebad.de>
In-Reply-To: <87skqshcnw.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810211245.08184.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 20 October 2008 01:39, Johannes Weiner wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> writes:
> >> >> Another access would mean another young PTE, which we will catch as a
> >> >> proper reference sooner or later while walking the mappings, no?
> >> >
> >> > No. Another access could come via read/write, or be subsequently
> >> > unmapped and put into PG_referenced.
> >>
> >> read/write use mark_page_accessed(), so after having two accesses, the
> >> page is already active.  If it's not and we find an access through a
> >> sequential mapping, we should be safe to clear PG_referenced.
> >
> > That's just handwaving. The patch still clears PG_referenced, which
> > is a shared resource, and it is wrong, conceptually. You can't argue
> > with that.
> >
> > What about if mark_page_accessed is only used on the page once? and
> > it is referenced but not active?
>
> I see the problem now, thanks for not giving up ;) Fixing up the fault
> paths and moving their mark_page_accessed to the unmap side seems like a
> good idea.

Thanks. I think I was skeptical of the patch the first time around, but
that could have been because of this other stuff you necessarily had to
hack around to make it work confused me for one reason or another.

With that fixed up, I think your patch should become much more "obviously
correct", and definitely a win for anyone using MADV_SEQUENTIAL.

Andrew's merged up most stuff now, so I'll send over some patches soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
