Date: Thu, 20 Dec 2007 15:26:00 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [rfc][patch] mm: madvise(WILLNEED) for anonymous memory
In-Reply-To: <1198162078.6821.27.camel@twins>
Message-ID: <Pine.LNX.4.64.0712201508290.857@blonde.wat.veritas.com>
References: <1198155938.6821.3.camel@twins>  <Pine.LNX.4.64.0712201339010.18399@blonde.wat.veritas.com>
 <1198162078.6821.27.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, riel <riel@redhat.com>, Lennart Poettering <mztabzr@0pointer.de>
List-ID: <linux-mm.kvack.org>

On Thu, 20 Dec 2007, Peter Zijlstra wrote:
> On Thu, 2007-12-20 at 14:09 +0000, Hugh Dickins wrote:
> > On Thu, 20 Dec 2007, Peter Zijlstra wrote:
> > 
> > I certainly agree with this in principle: it just seems an unnecessary
> > and surprising restriction to refuse on anonymous vmas; I guess the only
> > reason for not adding this was not having anyone asking for it until now.
> > Though, does Lennart realize he could use MAP_POPULATE in the mmap?
> 
> I think he's trying to get his data swapped-in.

That's perfectly reasonable, fair enough.

> > > +{
> > > +	int ret, len;
> > > +
> > > +	*prev = vma;
> > > +	if (end > vma->vm_end)
> > > +		end = vma->vm_end;
> > 
> > Please check, but I think the upper level ensures end is within range.
> 
> It certainly looks like it, but I since the file case did this check I
> thought it prudent to also do it. I guess I might as well remove both.

Ah, so it does.  Yes, please do remove both.

> > Hmm, might it be better to use make_pages_present itself,
> > fixing its retval, rather than using get_user_pages directly?
> > (I'd hope the caching makes its repeat of find_vma not an overhead.)
> > 
> > Interesting divergence: make_pages_present faults in writable pages
> > in a writable vma, whereas the file case's force_page_cache_readahead
> > doesn't even insert the pages into the mm.
> 
> Yeah, the find_vma and write fault thing are the reason I didn't use
> make_pages_present.

The write fault thing is irrelevant now, actually: now do_anonymous_page
doesn't use ZERO_PAGE, it puts in a writable page if the vma flags permit,
even when it's just a read fault (and its write_access arg is redundant).

> 
> I had noticed the difference in pte population between
> force_page_cache_readahead and make_pages_present, but it seemed to me
> that writing a function to walk the page tables and populate the
> swapcache but not populate the ptes wasn't worth the effort.

I was about to agree with you, when you made the observation:

> Ah, another, more important difference:
> 
> force_page_cache_readahead will not wait for the read to complete,
> whereas get_user_pages() will be fully synchronous.
> 
> I think I'd better come up with something else then,..

Yes, that's an interesting point.  Maybe first put in what you have,
to stop it from saying -EBADF on anon; then make it asynch later.

The asynch code: perhaps not worth doing for MADV_WILLNEED alone,
but might prove useful for more general use when swapping in.
Not really the same as Con's swap prefetch, but worth looking
at that for reference.  But I guess this becomes a much bigger
issue than you were intending to get into here.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
