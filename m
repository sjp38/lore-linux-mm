Date: Sun, 22 Apr 2007 00:19:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 08/10] mm: count writeback pages per BDI
Message-Id: <20070422001949.4d697fe5.akpm@linux-foundation.org>
In-Reply-To: <1177153636.2934.43.camel@lappy>
References: <20070420155154.898600123@chello.nl>
	<20070420155503.334628394@chello.nl>
	<20070421025525.042ed73a.akpm@linux-foundation.org>
	<1177153636.2934.43.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

On Sat, 21 Apr 2007 13:07:16 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> On Sat, 2007-04-21 at 02:55 -0700, Andrew Morton wrote:
> > On Fri, 20 Apr 2007 17:52:02 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > 
> > > Count per BDI writeback pages.
> > > 
> > > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > > ---
> > >  include/linux/backing-dev.h |    1 +
> > >  mm/page-writeback.c         |   12 ++++++++++--
> > >  2 files changed, 11 insertions(+), 2 deletions(-)
> > > 
> > > Index: linux-2.6/mm/page-writeback.c
> > > ===================================================================
> > > --- linux-2.6.orig/mm/page-writeback.c	2007-04-20 15:27:28.000000000 +0200
> > > +++ linux-2.6/mm/page-writeback.c	2007-04-20 15:28:10.000000000 +0200
> > > @@ -979,14 +979,18 @@ int test_clear_page_writeback(struct pag
> > >  	int ret;
> > >  
> > >  	if (mapping) {
> > > +		struct backing_dev_info *bdi = mapping->backing_dev_info;
> > >  		unsigned long flags;
> > >  
> > >  		write_lock_irqsave(&mapping->tree_lock, flags);
> > >  		ret = TestClearPageWriteback(page);
> > > -		if (ret)
> > > +		if (ret) {
> > >  			radix_tree_tag_clear(&mapping->page_tree,
> > >  						page_index(page),
> > >  						PAGECACHE_TAG_WRITEBACK);
> > > +			if (bdi_cap_writeback_dirty(bdi))
> > > +				__dec_bdi_stat(bdi, BDI_WRITEBACK);
> > 
> > Why do we test bdi_cap_writeback_dirty() here?
> > 
> > If we remove that test, we end up accumulating statistics for
> > non-writebackable backing devs, but does that matter? 
> 
> It would not, had I not cheated:
> 
> +void bdi_init(struct backing_dev_info *bdi)
> +{
> +       int i;
> +
> +       if (!(bdi_cap_writeback_dirty(bdi) || bdi_cap_account_dirty(bdi)))
> +               return;
> +
> +       for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
> +               percpu_counter_init(&bdi->bdi_stat[i], 0);
> +}
> +EXPORT_SYMBOL(bdi_init);
> 
> >  Probably the common
> > case is writebackable backing-devs, so eliminating the test-n-branch might
> > be a net microgain.
> 
> Time vs space. Now we don't even have storage for those BDIs..
> 
> Don't particularly care on this point though, I just thought it might be
> worthwhile to save on the percpu data.

It could be that we never call test_clear_page_writeback() against
!bdi_cap_writeback_dirty() pages anwyay.  I can't think why we would, but
the relationships there aren't very clear.  Does "don't account for dirty
memory" imply "doesn't ever do writeback"?  One would need to check, and
it's perhaps a bit fragile.

It's worth checking though.  Boy we're doing a lot of stuff in there
nowadays.

OT: it might be worth looking into batching this work up - the predominant
caller should be mpage_end_io_write(), and he has a whole bunch of pages
which are usually all from the same file, all contiguous.  It's pretty
inefficient to be handling that data one-page-at-a-time, and some
significant speedups may be available.

Instead, everyone seems to think that variable pagecache page size is the
only way of improving things.  Shudder.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
