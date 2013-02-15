Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 90DD76B00A0
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 18:42:37 -0500 (EST)
Date: Fri, 15 Feb 2013 15:42:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/2] mm: fincore()
Message-Id: <20130215154235.0fb36f53.akpm@linux-foundation.org>
In-Reply-To: <20130215231304.GB23930@cmpxchg.org>
References: <87a9rbh7b4.fsf@rustcorp.com.au>
	<20130211162701.GB13218@cmpxchg.org>
	<20130211141239.f4decf03.akpm@linux-foundation.org>
	<20130215063450.GA24047@cmpxchg.org>
	<20130215132738.c85c9eda.akpm@linux-foundation.org>
	<20130215231304.GB23930@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Stewart Smith <stewart@flamingspork.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org

On Fri, 15 Feb 2013 18:13:04 -0500
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Fri, Feb 15, 2013 at 01:27:38PM -0800, Andrew Morton wrote:
> > On Fri, 15 Feb 2013 01:34:50 -0500
> > Johannes Weiner <hannes@cmpxchg.org> wrote:
> > 
> > > + * The status is returned in a vector of bytes.  The least significant
> > > + * bit of each byte is 1 if the referenced page is in memory, otherwise
> > > + * it is zero.
> > 
> > Also, this is going to be dreadfully inefficient for some obvious cases.
> > 
> > We could address that by returning the info in some more efficient
> > representation.  That will be run-length encoded in some fashion.
> > 
> > The obvious way would be to populate an array of
> > 
> > struct page_status {
> > 	u32 present:1;
> > 	u32 count:31;
> > };
> > 
> > or whatever.
> 
> I'm having a hard time seeing how this could be extended to more
> status bits without stifling the optimization too much.

See other email: add a syscall arg which specifies the boolean status
which we're searching for.

>  If we just
> add more status bits to one page_status, the likelihood of long runs
> where all bits are in agreement decreases.  But as the optimization
> becomes less and less effective, we are stuck with an interface that
> is more PITA than just using mmap and mincore again.
> 
> The user has to supply a worst-case-sized vector with one struct
> page_status per page in the range, but the per-page item will be
> bigger than with the byte vector because of the additional run length
> variable.

Yes, we'd need to tell the kernel how much storage is available for the
structures.

> However, one struct page_status per run leaves you with a worst case
> of one syscall per page in the range.

Yes.

> I dunno.  The byte vector might not be optimal but its worst cases
> seem more attractive, is just as extensible, and dead simple to use.

But I think "which pages from this 4TB file are in core" will not be an
uncommon usage, and writing a gig of memory to find three pages is just
awful.

I wonder what the most common usage would be (one should know this
before merging the syscall :)).  I guess "is this relatively-small
range of the file in core" and/or "which pages from this
relatively-small range of the file will I need to read", etc.

The syscall should handle the common usages very well.  But it
shouldn't handle uncommon usages very badly!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
