Subject: Re: [patch 17/20] non-reclaimable mlocked pages
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20071219084534.4fee8718@bree.surriel.com>
References: <20071218211539.250334036@redhat.com>
	 <20071218211550.186819416@redhat.com>
	 <200712191156.48507.nickpiggin@yahoo.com.au>
	 <20071219084534.4fee8718@bree.surriel.com>
Content-Type: text/plain
Date: Wed, 19 Dec 2007 11:04:26 -0500
Message-Id: <1198080267.5333.22.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-12-19 at 08:45 -0500, Rik van Riel wrote:
> On Wed, 19 Dec 2007 11:56:48 +1100
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
> > On Wednesday 19 December 2007 08:15, Rik van Riel wrote:
> > 
> > > Rework of a patch by Nick Piggin -- part 1 of 2.
> > >
> > > This patch:
> > >
> > > 1) defines the [CONFIG_]NORECLAIM_MLOCK sub-option and the
> > >    stub version of the mlock/noreclaim APIs when it's
> > >    not configured.  Depends on [CONFIG_]NORECLAIM.
> 
> > Hmm, I still don't know (or forgot) why you don't just use the
> > old scheme of having an mlock count in the LRU bit, and removing
> > the mlocked page from the LRU completely.
> 
> How do we detect those pages reliably in the lumpy reclaim code?

I wanted to try to treat nonreclaimable pages, whatever the reason,
uniformly.  Lumpy reclaim wasn't there when I started on this, but we've
been able to handle them.  I was more interested in page migration.  The
act of isolating the page from the LRU [under zone lru_lock] arbitrates
between racing tasks attempting to migrate the same page.  That and we
keep the isolated pages on a list using the LRU links.  We can't migrate
pages that we can't successfully isolate from the LRU list.  Nick had
addressed this by putting mlocked pages back on the lru for migration.
Seemed like unnecessary work to me.  And, as I recall, this lost the
mlock count and it had to be reestablished over time.

>  
> > These mlocked pages don't need to be on a non-reclaimable list,
> > because we can find them again via the ptes when they become
> > unlocked, and there is no point background scanning them, because
> > they're always going to be locked while they're mlocked.
> 
> Agreed.

I also agree they don't need to be scanned.  And, altho' having them on
an LRU list has other uses, I suppose that having mlocked pages on the
noreclaim list could be considered "clutter" if we did want to scan the
noreclaim list for other types of non-reclaimable pages that might have
become reclaimable.  

Lee

> 
> The main reason I sent out these patches now is that I just
> wanted to get some comments from other upstream developers.
> 
> I have gotten distracted by other work so much that I spent
> most of my time forward porting the patch set, and not enough
> time working with the rest of the upstream community to get
> the code moving forward.
> 
> To be honest, I have only briefly looked at the non-reclaimable
> code.  I would be more than happy to merge any improvements to
> that code.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
