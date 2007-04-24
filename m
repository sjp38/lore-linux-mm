Date: Tue, 24 Apr 2007 04:50:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 10/10] mm: per device dirty threshold
Message-Id: <20070424045027.f21a79ae.akpm@linux-foundation.org>
In-Reply-To: <E1HgJ5u-0000aD-00@dorka.pomaz.szeredi.hu>
References: <20070420155154.898600123@chello.nl>
	<20070420155503.608300342@chello.nl>
	<17965.29252.950216.971096@notabene.brown>
	<1177398589.26937.40.camel@twins>
	<E1HgGF4-00008p-00@dorka.pomaz.szeredi.hu>
	<1177403494.26937.59.camel@twins>
	<E1HgH69-0000Fl-00@dorka.pomaz.szeredi.hu>
	<1177406817.26937.65.camel@twins>
	<E1HgHcG-0000J5-00@dorka.pomaz.szeredi.hu>
	<20070424030021.a091018d.akpm@linux-foundation.org>
	<1177409538.26937.75.camel@twins>
	<20070424034024.f953f93f.akpm@linux-foundation.org>
	<E1HgJ5u-0000aD-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: a.p.zijlstra@chello.nl, neilb@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, 24 Apr 2007 13:22:02 +0200 Miklos Szeredi <miklos@szeredi.hu> wrote:

> > On Tue, 24 Apr 2007 12:12:18 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > 
> > > On Tue, 2007-04-24 at 03:00 -0700, Andrew Morton wrote:
> > > > On Tue, 24 Apr 2007 11:47:20 +0200 Miklos Szeredi <miklos@szeredi.hu> wrote:
> > > > 
> > > > > > Ahh, now I see; I had totally blocked out these few lines:
> > > > > > 
> > > > > > 			pages_written += write_chunk - wbc.nr_to_write;
> > > > > > 			if (pages_written >= write_chunk)
> > > > > > 				break;		/* We've done our duty */
> > > > > > 
> > > > > > yeah, those look dubious indeed... And reading back Neil's comments, I
> > > > > > think he agrees.
> > > > > > 
> > > > > > Shall we just kill those?
> > > > > 
> > > > > I think we should.
> > > > > 
> > > > > Athough I'm a little afraid, that Akpm will tell me again, that I'm a
> > > > > stupid git, and that those lines are in fact vitally important ;)
> > > > > 
> > > > 
> > > > It depends what they're replaced with.
> > > > 
> > > > That code is there, iirc, to prevent a process from getting stuck in
> > > > balance_dirty_pages() forever due to the dirtying activity of other
> > > > processes.
> > > > 
> > > > hm, we ask the process to write write_chunk pages each go around the loop.
> > > > So if it wrote write-chunk/2 pages on the first pass it might end up writing
> > > > write_chunk*1.5 pages total.  I guess that's rare and doesn't matter much
> > > > if it does happen - the upper bound is write_chunk*2-1, I think.
> > > 
> > > Right, but I think the problem is that its dirty -> writeback, not dirty
> > > -> writeback completed.
> > > 
> > > Ie. they don't guarantee progress, it could be that the total
> > > nr_reclaimable + nr_writeback will steadily increase due to this break.
> > 
> > Don't think so.  We call balance_dirty_pages() once per ratelimit_pages
> > dirtyings and when we get there, we write 1.5*ratelimit_pages pages.
> 
> No, we _start_ writeback for 1.5*ratelimit_pages pages, but do not
> wait for those writebacks to finish.
> 
> So for a slow device and a fast writer, dirty+writeback can indeed
> increase beyond the dirty threshold.
> 

Nope, try it.

If a process dirties 1000 pages it'll then go into balance_dirty_pages()
and start writeback against 1,500 pages.  When we hit dirty_ratio that
process will be required to write back 1,500 pages for each eight pages
which it dirtied.  We'll quickly reach the stage where there are no longer
1,500 pages to be written back and the process will block in
balance_dirty_pages() until the dirty+writeback level subsides.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
