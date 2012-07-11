Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id BA4CA6B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 19:55:05 -0400 (EDT)
Date: Thu, 12 Jul 2012 08:55:04 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm: Warn about costly page allocation
Message-ID: <20120711235504.GA5204@bbox>
References: <1341878153-10757-1-git-send-email-minchan@kernel.org>
 <20120709170856.ca67655a.akpm@linux-foundation.org>
 <20120710002510.GB5935@bbox>
 <alpine.DEB.2.00.1207101756070.684@chino.kir.corp.google.com>
 <20120711022304.GA17425@bbox>
 <alpine.DEB.2.00.1207102223000.26591@chino.kir.corp.google.com>
 <4FFD15B2.6020001@kernel.org>
 <alpine.DEB.2.00.1207111337430.3635@chino.kir.corp.google.com>
 <CAEwNFnB1Z92f22ms=EsBEOOY4Q_JRA8rMPUvQmoqik7rt-EgcQ@mail.gmail.com>
 <alpine.DEB.2.00.1207111556190.24516@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1207111556190.24516@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Wed, Jul 11, 2012 at 04:02:00PM -0700, David Rientjes wrote:
> On Thu, 12 Jul 2012, Minchan Kim wrote:
> 
> > There is QA team in embedded company and they have tested their product.
> > In test scenario, they can allocate 100 high order allocation.
> > (they don't matter how many high order allocations in kernel are needed
> > during test. their concern is just only working well or fail of their
> > middleware/application) High order allocation will be serviced well
> > by natural buddy allocation without lumpy's help. So they released
> > the product and sold out all over the world.
> > Unfortunately, in real practice, sometime, 105 high order allocation was
> > needed rarely and fortunately, lumpy reclaim could help it so the product
> > doesn't have a problem until now.
> > 
> 
> If the QA team is going to consider upgrading to a kernel since lumpy 
> reclaim has been removed, before they qualify such a kernel they would 
> (hopefully) do some due diligence in running this workload and noticing 
> the page allocation failure that is emitted to the kernel log for the high 
> order page allocations.

hopefully, but I guess they will run same test which worked well because
they didn't noticed any problems until now.

> 
> > If they use latest kernel, they will see the new config CONFIG_COMPACTION
> > which is very poor documentation, and they can't know it's replacement of
> > lumpy reclaim(even, they don't know lumpy reclaim) so they simply disable
> > that option for size optimization.
> 
> Improving the description for CONFIG_COMPACTION or adding additional 
> documentation in Documentation/vm would be very appreciated by both me and 
> this hypothetical engineer :)

Agreed and that's why I suggested following patch.
It's not elegant but at least, it could attract interest of configuration
people and they could find a regression during test phase.
This description could be improved later by writing new documenation which
includes more detailed story and method for capturing high order allocation
by ftrace once we see regression report.

At the moment, I would like to post this patch, simply.
(Of course, I hope fluent native people will correct a sentence. :) )

Any objections, Andrew, David?

diff --git a/mm/Kconfig b/mm/Kconfig
index 16f6b42..099e681 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -195,6 +195,10 @@ config COMPACTION
        depends on MMU
        help
          Allows the compaction of memory for the allocation of huge pages.
+         Notice. We replaced lumpy reclaim which was scheme of helping
+         high-order allocations with compaction at 3.4 so if you don't
+         care about high-order allocations but want the smallest kernel,
+         you could select "N", otherwise, "y" is preferred.
 
 #
 # support for page migration

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
