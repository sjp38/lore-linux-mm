Date: Thu, 20 Dec 2007 15:56:27 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 17/20] non-reclaimable mlocked pages
Message-ID: <20071220155627.6872b0e6@bree.surriel.com>
In-Reply-To: <1198080267.5333.22.camel@localhost>
References: <20071218211539.250334036@redhat.com>
	<20071218211550.186819416@redhat.com>
	<200712191156.48507.nickpiggin@yahoo.com.au>
	<20071219084534.4fee8718@bree.surriel.com>
	<1198080267.5333.22.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Dec 2007 11:04:26 -0500
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> On Wed, 2007-12-19 at 08:45 -0500, Rik van Riel wrote:
> > On Wed, 19 Dec 2007 11:56:48 +1100
> > Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> > > Hmm, I still don't know (or forgot) why you don't just use the
> > > old scheme of having an mlock count in the LRU bit, and removing
> > > the mlocked page from the LRU completely.
> > 
> > How do we detect those pages reliably in the lumpy reclaim code?
> 
> I wanted to try to treat nonreclaimable pages, whatever the reason,
> uniformly.  Lumpy reclaim wasn't there when I started on this, but we've
> been able to handle them.  I was more interested in page migration.  The
> act of isolating the page from the LRU [under zone lru_lock] arbitrates
> between racing tasks attempting to migrate the same page.  That and we
> keep the isolated pages on a list using the LRU links.  We can't migrate
> pages that we can't successfully isolate from the LRU list.

Good point.

Lets keep the nonreclaimable pages on a list, so we can keep
the migration code (and other code) consistent.

We can deal with lazily moving pages back to the nonreclaim
list if we find that, after one munlock, there are other
mlocking users of that page.

> I also agree they don't need to be scanned.  And, altho' having them on
> an LRU list has other uses, I suppose that having mlocked pages on the
> noreclaim list could be considered "clutter" if we did want to scan the
> noreclaim list for other types of non-reclaimable pages that might have
> become reclaimable.  

If we ever want to do that, we can always introduce separate
lists for those pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
