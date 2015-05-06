Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7056D6B0038
	for <linux-mm@kvack.org>; Tue,  5 May 2015 21:55:28 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so212005675pab.3
        for <linux-mm@kvack.org>; Tue, 05 May 2015 18:55:28 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id tl4si26952438pab.143.2015.05.05.18.55.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 May 2015 18:55:27 -0700 (PDT)
Date: Tue, 5 May 2015 19:01:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/13] Parallel struct page initialisation v4
Message-Id: <20150505190121.830013cb.akpm@linux-foundation.org>
In-Reply-To: <55496C8F.606@hp.com>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
	<554030D1.8080509@hp.com>
	<5543F802.9090504@hp.com>
	<554415B1.2050702@hp.com>
	<20150504143046.9404c572486caf71bdef0676@linux-foundation.org>
	<20150505104514.GC2462@suse.de>
	<20150505130255.49ff76bbf0a3b32d884ab2ce@linux-foundation.org>
	<55496C8F.606@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <waiman.long@hp.com>
Cc: Mel Gorman <mgorman@suse.de>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 05 May 2015 21:21:19 -0400 Waiman Long <waiman.long@hp.com> wrote:

> On 05/05/2015 04:02 PM, Andrew Morton wrote:
> > On Tue, 5 May 2015 11:45:14 +0100 Mel Gorman<mgorman@suse.de>  wrote:
> >
> >> On Mon, May 04, 2015 at 02:30:46PM -0700, Andrew Morton wrote:
> >>>> Before the patch, the boot time from elilo prompt to ssh login was 694s.
> >>>> After the patch, the boot up time was 346s, a saving of 348s (about 50%).
> >>> Having to guesstimate the amount of memory which is needed for a
> >>> successful boot will be painful.  Any number we choose will be wrong
> >>> 99% of the time.
> >>>
> >>> If the kswapd threads have started, all we need to do is to wait: take
> >>> a little nap in the allocator's page==NULL slowpath.
> >>>
> >>> I'm not seeing any reason why we can't start kswapd much earlier -
> >>> right at the start of do_basic_setup()?
> >> It doesn't even have to be kswapd, it just should be a thread pinned to
> >> a done. The difficulty is that dealing with the system hashes means the
> >> initialisation has to happen before vfs_caches_init_early() when there is
> >> no scheduler.
> > I bet we can run vfs_caches_init_early() after sched_init().  Might
> > need a few little fixups.
> >
> >> Those allocations could be delayed further but then there is
> >> the possibility that the allocations would not be contiguous and they'd
> >> have to rely on CMA to make the attempt. That potentially alters the
> >> performance of the large system hashes at run time.
> > hm, why.  If the kswapd threads are running and busily creating free
> > pages then alloc_pages(order=10) can detect this situation and stall
> > for a while, waiting for kswapd to create an order-10 page.
> >
> > Alternatively, the page allocator can go off and synchronously
> > initialize some pageframes itself.  Keep doing that until the
> > allocation attempt succeeds.
> >
> > Such an approach is much more robust than trying to predict how much
> > memory will be needed.
> >
> 
> Most of those hash tables are allocated before smp_boot. In UP mode, you 
> can't have another thread initializing memory. So we really need to 
> preallocate enough for those tables.

(copy-paste)

: Alternatively, the page allocator can go off and synchronously
: initialize some pageframes itself.  Keep doing that until the
: allocation attempt succeeds.

IOW, the caller of alloc_pages() goes off and does the work which
kswapd would have done later on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
