Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id D9EEC6B0038
	for <linux-mm@kvack.org>; Tue,  5 May 2015 18:13:35 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so198746835wgy.2
        for <linux-mm@kvack.org>; Tue, 05 May 2015 15:13:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t8si1562840wjr.69.2015.05.05.15.13.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 05 May 2015 15:13:34 -0700 (PDT)
Date: Tue, 5 May 2015 23:13:29 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/13] Parallel struct page initialisation v4
Message-ID: <20150505221329.GE2462@suse.de>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
 <554030D1.8080509@hp.com>
 <5543F802.9090504@hp.com>
 <554415B1.2050702@hp.com>
 <20150504143046.9404c572486caf71bdef0676@linux-foundation.org>
 <20150505104514.GC2462@suse.de>
 <20150505130255.49ff76bbf0a3b32d884ab2ce@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150505130255.49ff76bbf0a3b32d884ab2ce@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Waiman Long <waiman.long@hp.com>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, May 05, 2015 at 01:02:55PM -0700, Andrew Morton wrote:
> On Tue, 5 May 2015 11:45:14 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Mon, May 04, 2015 at 02:30:46PM -0700, Andrew Morton wrote:
> > > > Before the patch, the boot time from elilo prompt to ssh login was 694s. 
> > > > After the patch, the boot up time was 346s, a saving of 348s (about 50%).
> > > 
> > > Having to guesstimate the amount of memory which is needed for a
> > > successful boot will be painful.  Any number we choose will be wrong
> > > 99% of the time.
> > > 
> > > If the kswapd threads have started, all we need to do is to wait: take
> > > a little nap in the allocator's page==NULL slowpath.
> > > 
> > > I'm not seeing any reason why we can't start kswapd much earlier -
> > > right at the start of do_basic_setup()?
> > 
> > It doesn't even have to be kswapd, it just should be a thread pinned to
> > a done. The difficulty is that dealing with the system hashes means the
> > initialisation has to happen before vfs_caches_init_early() when there is
> > no scheduler.
> 
> I bet we can run vfs_caches_init_early() after sched_init().  Might
> need a few little fixups.
> 

For the large hashes, that would leave the CMA requirement because
allocation sizes can be larger than order-10. Arguably on NUMA, that's
a bad idea anyway because it should have been interleaved but it's not
something this patchset should change.

> > Those allocations could be delayed further but then there is
> > the possibility that the allocations would not be contiguous and they'd
> > have to rely on CMA to make the attempt. That potentially alters the
> > performance of the large system hashes at run time.
> 
> hm, why.  If the kswapd threads are running and busily creating free
> pages then alloc_pages(order=10) can detect this situation and stall
> for a while, waiting for kswapd to create an order-10 page.
> 

In Waiman's case, the OOM happened when kswapd was not necessarily available
but that's an implementation detail. I'll look tomorrow at what is required
to use dedicated threads to parallelisation the allocation and synchronously
wait for those threads to complete. It should be possible to create those
earlier than kswapd currently is. It'll take longer to boot but hopefully
not so long that it makes the series pointless.

> Alternatively, the page allocator can go off and synchronously
> initialize some pageframes itself.  Keep doing that until the
> allocation attempt succeeds.
> 

That was rejected during review of earlier attempts at this feature on
the grounds that it impacted allocator fast paths. 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
