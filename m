Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 561966B002C
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 13:32:06 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so295580pbc.14
        for <linux-mm@kvack.org>; Tue, 07 Feb 2012 10:32:05 -0800 (PST)
Date: Tue, 7 Feb 2012 10:31:36 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH BUGFIX] mm: fix find_get_page() for shmem exceptional
 entries
In-Reply-To: <4F31003E.2090901@openvz.org>
Message-ID: <alpine.LSU.2.00.1202071011450.1849@eggly.anvils>
References: <20120207103121.28345.28611.stgit@zurg> <4F31003E.2090901@openvz.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, 7 Feb 2012, Konstantin Khlebnikov wrote:

> Bug was added in commit v3.0-7291-g8079b1c (mm: clarify the radix_tree
> exceptional cases)
> So, v3.1 and v3.2 affected.
> 
> Konstantin Khlebnikov wrote:
> > It should return NULL, otherwise the caller will be very surprised.
> > 
> > Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>

Thanks for worrying about it, but Nak to this patch.

If you have found somewhere that is surprised by an exceptional entry
instead of a page, then indeed we shall need to fix that: I'm not
aware of any.

There are several places that are prepared for the possibility:
find_lock_page() (and your patch would be breaking shmem.c's use of
find_lock_page()), mincore_page(), memcontrol.c's mc_handle_file_pte().

Of the remaining calls to find_get_page(), my understanding is that
either they are filesystems operating upon their own pagecache, or
they involve using ->readpage() - that's one of the two reasons why
I gave shmem its own ->splice_read() and removed its ->readpage()
before switching over to use the exceptional entries.

Hugh

> > ---
> >   mm/filemap.c |    1 +
> >   1 files changed, 1 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index 518223b..ca98cb5 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -693,6 +693,7 @@ repeat:
> >   			 * here as an exceptional entry: so return it without
> >   			 * attempting to raise page count.
> >   			 */
> > +			page = NULL;
> >   			goto out;
> >   		}
> >   		if (!page_cache_get_speculative(page))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
