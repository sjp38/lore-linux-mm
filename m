Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 210298D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 01:52:25 -0400 (EDT)
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp07.au.ibm.com (8.14.4/8.13.1) with ESMTP id p2V5qIfb017210
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 16:52:18 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2V5qHtU2084878
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 16:52:17 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2V5qHn7013614
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 16:52:17 +1100
Date: Thu, 31 Mar 2011 11:22:12 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages (v5)
Message-ID: <20110331055212.GK2879@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20110330052819.8212.1359.stgit@localhost6.localdomain6>
 <20110330053129.8212.81574.stgit@localhost6.localdomain6>
 <20110330163545.1599779f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110330163545.1599779f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com

* Andrew Morton <akpm@linux-foundation.org> [2011-03-30 16:35:45]:

> On Wed, 30 Mar 2011 11:02:38 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > Changelog v4
> > 1. Added documentation for max_unmapped_pages
> > 2. Better #ifdef'ing of max_unmapped_pages and min_unmapped_pages
> > 
> > Changelog v2
> > 1. Use a config option to enable the code (Andrew Morton)
> > 2. Explain the magic tunables in the code or at-least attempt
> >    to explain them (General comment)
> > 3. Hint uses of the boot parameter with unlikely (Andrew Morton)
> > 4. Use better names (balanced is not a good naming convention)
> > 
> > Provide control using zone_reclaim() and a boot parameter. The
> > code reuses functionality from zone_reclaim() to isolate unmapped
> > pages and reclaim them as a priority, ahead of other mapped pages.
> > 
> 
> This:
> 
> akpm:/usr/src/25> grep '^+#' patches/provide-control-over-unmapped-pages-v5.patch 
> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL) || defined(CONFIG_NUMA)
> +#endif
> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
> +#endif
> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL) || defined(CONFIG_NUMA)
> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
> +#endif
> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
> +#else
> +#endif
> +#ifdef CONFIG_NUMA
> +#else
> +#define zone_reclaim_mode 0
> +#endif
> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL) || defined(CONFIG_NUMA)
> +#endif
> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
> +#endif
> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL) || defined(CONFIG_NUMA)
> +#endif
> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
> +#endif
> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL) || defined(CONFIG_NUMA)
> +#endif
> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
> +#endif
> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
> +#else /* !CONFIG_UNMAPPED_PAGECACHE_CONTROL */
> +#endif
> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL) || defined(CONFIG_NUMA)
> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
> +#endif
> +#endif
> +#if defined(CONFIG_UNMAPPED_PAGECACHE_CONTROL)
> 
> is getting out of control.  What happens if we just make the feature
> non-configurable?
>

I added the configuration based on review comments I received. If the
feature is made non-configurable, it should be easy to remove them or
just set the default value to "y" in the config.
 
> > +static int __init unmapped_page_control_parm(char *str)
> > +{
> > +	unmapped_page_control = 1;
> > +	/*
> > +	 * XXX: Should we tweak swappiness here?
> > +	 */
> > +	return 1;
> > +}
> > +__setup("unmapped_page_control", unmapped_page_control_parm);
> 
> That looks like a pain - it requires a reboot to change the option,
> which makes testing harder and slower.  Methinks you're being a bit
> virtualization-centric here!

:-) The reason for the boot parameter is to ensure that people know
what they are doing.

> 
> > +#else /* !CONFIG_UNMAPPED_PAGECACHE_CONTROL */
> > +static inline void reclaim_unmapped_pages(int priority,
> > +				struct zone *zone, struct scan_control *sc)
> > +{
> > +	return 0;
> > +}
> > +#endif
> > +
> >  static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
> >  						  struct scan_control *sc)
> >  {
> > @@ -2371,6 +2394,12 @@ loop_again:
> >  				shrink_active_list(SWAP_CLUSTER_MAX, zone,
> >  							&sc, priority, 0);
> >  
> > +			/*
> > +			 * We do unmapped page reclaim once here and once
> > +			 * below, so that we don't lose out
> > +			 */
> > +			reclaim_unmapped_pages(priority, zone, &sc);
> 
> Doing this here seems wrong.  balance_pgdat() does two passes across
> the zones.  The first pass is a read-only work-out-what-to-do pass and
> the second pass is a now-reclaim-some-stuff pass.  But here we've stuck
> a do-some-reclaiming operation inside the first, work-out-what-to-do pass.
>

The reason is primarily for balancing, zone_watermark's do not give us
a good idea of whether unmapped pages are balanced, hence the code.
 
> 
> > @@ -2408,6 +2437,11 @@ loop_again:
> >  				continue;
> >  
> >  			sc.nr_scanned = 0;
> > +			/*
> > +			 * Reclaim unmapped pages upfront, this should be
> > +			 * really cheap
> 
> Comment is mysterious.  Why is it cheap?

Cheap because we do a quick check to see if unmapped pages exceed a
threshold. If selective users enable this functionality (which is
expected), the use case is primarily for embedded and virtualization
folks, this should be a simple check.

> 
> > +			 */
> > +			reclaim_unmapped_pages(priority, zone, &sc);
> 
> 
> I dunno, the whole thing seems rather nasty to me.
> 
> It sticks a magical reclaim-unmapped-pages operation right in the
> middle of regular page reclaim.  This means that reclaim will walk the
> LRU looking at mapped and unmapped pages.  Then it will walk some more,
> looking at only unmapped pages and moving the mapped ones to the head
> of the LRU.  Then it goes back to looking at mapped and unmapped pages.
> So it rather screws up the LRU ordering and page aging, does it not?
>

This was brought up earlier, it is no different than zone_reclaim of
unmapped pages, in that

1. It is a specialized case where we want explicit control of unmapped
pages and what you mention is the price
2. This situation can be improved with an incremental patch to be
smart about page isolation.
 
> Also, the special-case handling sticks out like a sore thumb.  Would it
> not be better to manage the mapped/unmapped bias within the core of the
> regular scanning?  ie: in shrink_page_list().

Or in isolating, we could check if we really want to isolate mapped
pages or not. I intend to send an incremental patch to improve that
part.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
