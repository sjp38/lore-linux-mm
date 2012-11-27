Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id AA4B46B002B
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 06:07:52 -0500 (EST)
Date: Tue, 27 Nov 2012 11:07:47 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: compaction: Fix return value of capture_free_page
Message-ID: <20121127110746.GN8218@suse.de>
References: <20121121192151.3FFE0A9A@kernel.stglabs.ibm.com>
 <20121126112350.GI8218@suse.de>
 <50B3858D.2060404@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <50B3858D.2060404@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, linux-mm@kvack.org

On Mon, Nov 26, 2012 at 07:06:53AM -0800, Dave Hansen wrote:
> On 11/26/2012 03:23 AM, Mel Gorman wrote:
> > On Wed, Nov 21, 2012 at 02:21:51PM -0500, Dave Hansen wrote:
> >>
> >> This needs to make it in before 3.7 is released.
> >>
> > 
> > This is also required. Dave, can you double check? The surprise is that
> > this does not blow up very obviously.
> ...
> > @@ -1422,7 +1422,7 @@ int capture_free_page(struct page *page, int alloc_order, int migratetype)
> >  		}
> >  	}
> > 
> > -	return 1UL << order;
> > +	return 1UL << alloc_order;
> >  }
> 
> compact_capture_page() only looks at the boolean return value out of
> capture_free_page(), so it wouldn't notice.  split_free_page() does.
> But, when it calls capture_free_page(), order==alloc_order, so it
> wouldn't make a difference.  So, there's probably no actual bug here,
> but it's certainly a wrong return value.
> 

I don't think it is fine in this case.

isolate_freepages_block
isolated = split_free_page(page);
  -> split_free_page
     nr_pages = capture_free_page(page, order, 0);
     -> capture_free_page (returns wrong value of too many pages)
     return nr_pages;

so now isolate_freepages_block has the wrong value with nr_pages holding
a value for a larger number of pages than are really isolated and does
this

                for (i = 0; i < isolated; i++) {
                        list_add(&page->lru, freelist);
                        page++;
                }

so potentially that is now adding pages that are already on the buddy list
to the local free list and "fun" ensues.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
