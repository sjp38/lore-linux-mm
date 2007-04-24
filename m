Subject: Re: [PATCH 10/10] mm: per device dirty threshold
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <E1HgH69-0000Fl-00@dorka.pomaz.szeredi.hu>
References: <20070420155154.898600123@chello.nl>
	 <20070420155503.608300342@chello.nl>
	 <17965.29252.950216.971096@notabene.brown>
	 <1177398589.26937.40.camel@twins>
	 <E1HgGF4-00008p-00@dorka.pomaz.szeredi.hu>
	 <1177403494.26937.59.camel@twins>
	 <E1HgH69-0000Fl-00@dorka.pomaz.szeredi.hu>
Content-Type: text/plain
Date: Tue, 24 Apr 2007 11:26:57 +0200
Message-Id: <1177406817.26937.65.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: neilb@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, 2007-04-24 at 11:14 +0200, Miklos Szeredi wrote:

> > > I'm still not quite sure what purpose the above "soft" limiting
> > > serves.  It seems to just give advantage to writers, which managed to
> > > accumulate lots of dirty pages, and then can convert that into even
> > > more dirtyings.
> > 
> > The queues only limit the actual in-flight writeback pages,
> > balance_dirty_pages() considers all pages that might become writeback as
> > well as those that are.
> > 
> > > Would it make sense to remove this behavior, and ensure that
> > > balance_dirty_pages() doesn't return until the per-queue limits have
> > > been complied with?
> > 
> > I don't think that will help, balance_dirty_pages drives the queues.
> > That is, it converts pages from mere dirty to writeback.
> 
> Yes.  But current logic says, that if you convert "write_chunk" dirty
> to writeback, you are allowed to dirty "ratelimit" more. 
> 
> D: number of dirty pages
> W: number of writeback pages
> L: global limit
> C: write_chunk = ratelimit_pages * 1.5
> R: ratelimit
> 
> If D+W >= L, then R = 8
> 
> Let's assume, that D == L and W == 0.  And that all of the dirty pages
> belong to a single device.  Also for simplicity, lets assume an
> infinite length queue, and a slow device.
> 
> Then while converting the dirty pages to writeback, D / C * R new
> dirty pages can be created.  So when all existing dirty have been
> converted:
> 
>   D = L / C * R
>   W = L
> 
>   D + W = L * (1 + R / C)
> 
> So we see, that we're now even more above the limit than before the
> conversion.  This means, that we starve writers to other devices,
> which don't have as many dirty pages, because until the slow device
> doesn't finish these writes they will not get to do anything.
> 
> Your patch helps this in that if the other writers have an empty queue
> and no dirty, they will be allowed to slowly start writing.  But they
> will not gain their full share until the slow dirty-hog goes below the
> global limit, which may take some time.
> 
> So I think the logical thing to do, is if the dirty-hog is over it's
> queue limit, don't let it dirty any more until it's dirty+writeback go
> below the limit.  That allowes other devices to more quickly gain
> their share of dirty pages.

Ahh, now I see; I had totally blocked out these few lines:

			pages_written += write_chunk - wbc.nr_to_write;
			if (pages_written >= write_chunk)
				break;		/* We've done our duty */

yeah, those look dubious indeed... And reading back Neil's comments, I
think he agrees.

Shall we just kill those?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
