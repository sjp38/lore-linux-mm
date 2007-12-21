From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 17/20] non-reclaimable mlocked pages
Date: Fri, 21 Dec 2007 21:52:19 +1100
References: <20071218211539.250334036@redhat.com> <1198080267.5333.22.camel@localhost> <20071220155627.6872b0e6@bree.surriel.com>
In-Reply-To: <20071220155627.6872b0e6@bree.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200712212152.19260.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Friday 21 December 2007 07:56, Rik van Riel wrote:
> On Wed, 19 Dec 2007 11:04:26 -0500
>
> Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> > On Wed, 2007-12-19 at 08:45 -0500, Rik van Riel wrote:
> > > On Wed, 19 Dec 2007 11:56:48 +1100
> > >
> > > Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> > > > Hmm, I still don't know (or forgot) why you don't just use the
> > > > old scheme of having an mlock count in the LRU bit, and removing
> > > > the mlocked page from the LRU completely.
> > >
> > > How do we detect those pages reliably in the lumpy reclaim code?
> >
> > I wanted to try to treat nonreclaimable pages, whatever the reason,
> > uniformly.  Lumpy reclaim wasn't there when I started on this, but we've
> > been able to handle them.  I was more interested in page migration.  The
> > act of isolating the page from the LRU [under zone lru_lock] arbitrates
> > between racing tasks attempting to migrate the same page.  That and we
> > keep the isolated pages on a list using the LRU links.  We can't migrate
> > pages that we can't successfully isolate from the LRU list.
>
> Good point.

Ah: that's what it was. The migration code got harder with my mlock
code (although I did have something that should have worked in theory,
it involved a few steps).

I don't have a particular problem with putting mlock pages on the slow
scan lists, although if you have huge mlocked data sets, you could
effectively speed up slow scan list scanning by orders of magnitude by
avoiding the mlocked pages.

I won't push it now, but I might see if I can rewrite it one day :)

BTW. if you have any workloads that are limited by page reclaim,
especially unmapped file backed pagecache reclaim, then I have some
stright-line-speedup patches which you might find interesting (I can
send them if you'd like to test).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
