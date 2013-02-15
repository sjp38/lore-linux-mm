Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 24A696B009D
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 18:13:19 -0500 (EST)
Date: Fri, 15 Feb 2013 18:13:04 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/2] mm: fincore()
Message-ID: <20130215231304.GB23930@cmpxchg.org>
References: <87a9rbh7b4.fsf@rustcorp.com.au>
 <20130211162701.GB13218@cmpxchg.org>
 <20130211141239.f4decf03.akpm@linux-foundation.org>
 <20130215063450.GA24047@cmpxchg.org>
 <20130215132738.c85c9eda.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130215132738.c85c9eda.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Stewart Smith <stewart@flamingspork.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org

On Fri, Feb 15, 2013 at 01:27:38PM -0800, Andrew Morton wrote:
> On Fri, 15 Feb 2013 01:34:50 -0500
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > + * The status is returned in a vector of bytes.  The least significant
> > + * bit of each byte is 1 if the referenced page is in memory, otherwise
> > + * it is zero.
> 
> Also, this is going to be dreadfully inefficient for some obvious cases.
> 
> We could address that by returning the info in some more efficient
> representation.  That will be run-length encoded in some fashion.
> 
> The obvious way would be to populate an array of
> 
> struct page_status {
> 	u32 present:1;
> 	u32 count:31;
> };
> 
> or whatever.

I'm having a hard time seeing how this could be extended to more
status bits without stifling the optimization too much.  If we just
add more status bits to one page_status, the likelihood of long runs
where all bits are in agreement decreases.  But as the optimization
becomes less and less effective, we are stuck with an interface that
is more PITA than just using mmap and mincore again.

The user has to supply a worst-case-sized vector with one struct
page_status per page in the range, but the per-page item will be
bigger than with the byte vector because of the additional run length
variable.

> Another way would be to define the syscall so it returns "number of
> pages present/absent starting at offset `start'".  In other words, one
> call to fincore() will return a single `struct page_status'.  Userspace
> can then walk through the file and generate the full picture, if needed.
> 
> This also gets inefficient in obvious cases, but it's not as obviously
> bad?

Any run-length encoding will have a problem with multiple status bits,
I guess.

Maybe with a mask of bits the user is interested in?

struct page_status {
	unsigned long states;
	unsigned long count;
};

int fincore(int fd, loff_t start, loff_t len,
            unsigned long states_mask,
            struct page_status *status)

However, one struct page_status per run leaves you with a worst case
of one syscall per page in the range.

I dunno.  The byte vector might not be optimal but its worst cases
seem more attractive, is just as extensible, and dead simple to use.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
