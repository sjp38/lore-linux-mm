Date: Tue, 31 Aug 2004 13:02:02 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on swap partition
Message-ID: <20040831160202.GB11149@logos.cnet>
References: <20040829131824.1b39f2e8.akpm@osdl.org> <20040829203011.GA11878@suse.de> <20040829135917.3e8ffed8.akpm@osdl.org> <20040830152025.GA2901@logos.cnet> <41336B6F.6050806@pandora.be> <20040830203339.GA2955@logos.cnet> <20040830153730.18e431c2.akpm@osdl.org> <20040830221727.GE2955@logos.cnet> <20040830165100.535e68e5.akpm@osdl.org> <20040831102342.GA3207@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040831102342.GA3207@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: karl.vogel@pandora.be, axboe@suse.de, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 31, 2004 at 07:23:42AM -0300, Marcelo Tosatti wrote:
> On Mon, Aug 30, 2004 at 04:51:00PM -0700, Andrew Morton wrote:
> > Marcelo Tosatti <marcelo.tosatti@cyclades.com> wrote:
> > >
> > > What you think of this, which tries to address your comments
> > 
> > Suggest you pass the scan_control structure down into pageout(), stick
> > `inflight' into struct scan_control and use some flag in scan_control to
> 
> Done the scan_control modifications.
> 
> > ensure that we only throttle once per try_to_free_pages()/blaance_pgdat()
> > pass.
> 
> Throttling once is enough

I meant "throttling once is not enough" 

Any comments?

> I added a 
> 
> +		 if (sc->throttled < 5) {
> +                       blk_congestion_wait(WRITE, HZ/5);
> +                       sc->throttled++;
> +               }
> 
> To loop five times max per try_to_free_pages()/balance_pgdat().
> 
> Because only one blk_congestion_wait(WRITE, HZ/5)
> makes my 64MB boot testcase with 8192 nr_requests fail. The OOM killer
> triggers prematurely.
> 
> > See, page reclaim is now, as much as possible, "batched".  Think of it as
> > operating in units of 32 pages at a time.  We should only examine the dirty
> > memory thresholds and throttle once per "batch", not once per page.
> 
> That should do it 
> 
> --- mm/vmscan.c.orig	2004-08-30 20:19:05.000000000 -0300
> +++ mm/vmscan.c	2004-08-31 08:30:08.323989416 -0300
> @@ -73,6 +73,10 @@
>  	unsigned int gfp_mask;
>  
>  	int may_writepage;
> +
> +	int inflight;
> +
> +	int throttled; /* how many times have we throttled on VM inflight IO limit */
>  };
>  
>  /*
> @@ -245,8 +249,30 @@
>  	return page_count(page) - !!PagePrivate(page) == 2;
>  }
>  
> -static int may_write_to_queue(struct backing_dev_info *bdi)
> +/*
> + * This function calculates the maximum pinned-for-IO memory
> + * the page eviction threads can generate. If we hit the max,
> + * we throttle taking a nap.
> + *
> + * Returns true if we cant writeout.
> + */
> +int vm_eviction_limits(struct scan_control *sc)
> +{
> +        if (sc->inflight > (totalram_pages * vm_dirty_ratio) / 100)  {
> +		if (sc->throttled < 5) {
> +			blk_congestion_wait(WRITE, HZ/5);
> +			sc->throttled++;
> +		}
> +                return 1;
> +        }
> +        return 0;
> +}
> +
> +static int may_write_to_queue(struct backing_dev_info *bdi, struct scan_control *sc)
>  {
> +	if (vm_eviction_limits(sc)) /* Check VM writeout limit */
> +		return 0;
> +
>  	if (current_is_kswapd())
>  		return 1;
>  	if (current_is_pdflush())	/* This is unlikely, but why not... */
> @@ -286,7 +312,7 @@
>  /*
>   * pageout is called by shrink_list() for each dirty page. Calls ->writepage().
>   */
> -static pageout_t pageout(struct page *page, struct address_space *mapping)
> +static pageout_t pageout(struct page *page, struct address_space *mapping, struct scan_control *sc)
>  {
>  	/*
>  	 * If the page is dirty, only perform writeback if that write
> @@ -311,7 +337,7 @@
>  		return PAGE_KEEP;
>  	if (mapping->a_ops->writepage == NULL)
>  		return PAGE_ACTIVATE;
> -	if (!may_write_to_queue(mapping->backing_dev_info))
> +	if (!may_write_to_queue(mapping->backing_dev_info, sc))
>  		return PAGE_KEEP;
>  
>  	if (clear_page_dirty_for_io(page)) {
> @@ -421,7 +447,7 @@
>  				goto keep_locked;
>  
>  			/* Page is dirty, try to write it out here */
> -			switch(pageout(page, mapping)) {
> +			switch(pageout(page, mapping, sc)) {
>  			case PAGE_KEEP:
>  				goto keep_locked;
>  			case PAGE_ACTIVATE:
> @@ -807,6 +833,7 @@
>  		nr_inactive = 0;
>  
>  	sc->nr_to_reclaim = SWAP_CLUSTER_MAX;
> +	sc->throttled = 0;
>  
>  	while (nr_active || nr_inactive) {
>  		if (nr_active) {
> @@ -819,6 +846,7 @@
>  		if (nr_inactive) {
>  			sc->nr_to_scan = min(nr_inactive,
>  					(unsigned long)SWAP_CLUSTER_MAX);
> +			sc->inflight = read_page_state(nr_writeback);
>  			nr_inactive -= sc->nr_to_scan;
>  			shrink_cache(zone, sc);
>  			if (sc->nr_to_reclaim <= 0)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
