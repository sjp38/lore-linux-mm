Date: Wed, 7 Mar 2007 01:26:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes
 nonlinear)
Message-Id: <20070307012638.793d9a9f.akpm@linux-foundation.org>
In-Reply-To: <20070307091823.GA8609@wotan.suse.de>
References: <20070221023656.6306.246.sendpatchset@linux.site>
	<20070221023735.6306.83373.sendpatchset@linux.site>
	<20070306225101.f393632c.akpm@linux-foundation.org>
	<20070307070853.GB15877@wotan.suse.de>
	<20070307081948.GA9563@wotan.suse.de>
	<20070307082755.GA25733@elte.hu>
	<E1HOrfO-0008AW-00@dorka.pomaz.szeredi.hu>
	<20070307004709.432ddf97.akpm@linux-foundation.org>
	<E1HOrsL-0008Dv-00@dorka.pomaz.szeredi.hu>
	<20070307010756.b31c8190.akpm@linux-foundation.org>
	<20070307091823.GA8609@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Miklos Szeredi <miklos@szeredi.hu>, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Mar 2007 10:18:23 +0100 Nick Piggin <npiggin@suse.de> wrote:

> On Wed, Mar 07, 2007 at 01:07:56AM -0800, Andrew Morton wrote:
> > On Wed, 07 Mar 2007 09:51:57 +0100 Miklos Szeredi <miklos@szeredi.hu> wrote:
> > 
> > > > > Dirty page accounting doesn't work either on
> > > > > non-linear mappings
> > > > 
> > > > It doesn't?  Confused - these things don't have anything to do with each
> > > > other do they?
> > > 
> > > Look in page_mkclean().  Where does it handle non-linear mappings?
> > > 
> > 
> > OK, I'd forgotten about that.  It won't break dirty memory accounting,
> > but it'll potentially break dirty memory balancing.
> > 
> > If we have the wrong page (due to nonlinear), page_check_address() will
> > fail and we'll leave the pte dirty.  That puts us back to the pre-2.6.17
> > algorithms and I guess it'll break the msync guarantees.
> > 
> > Peter, I thought we went through the nonlinear problem ages ago and decided
> > it was OK?
> 
> msync breakage is bad, but otherwise I don't know that we care about
> dirty page writeout efficiency.

Well.  We made so many changes to support the synchronous
dirty-the-page-when-we-dirty-the-pte thing that I'm rather doubtful that
the old-style approach still works.  It might seem to, most of the time. 
But if it _is_ subtly broken, boy it's going to take a long time for us to
find out.

> But I think we discovered that those msync changes are bogus anyway
> becuase there is a small race window where pte could be dirtied without
> page being set dirty?

Dunno, I don't recall that.  We dirty the page before the pte...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
