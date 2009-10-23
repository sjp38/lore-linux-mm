Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EC1286B004D
	for <linux-mm@kvack.org>; Fri, 23 Oct 2009 12:58:38 -0400 (EDT)
Received: by fxm20 with SMTP id 20so10255897fxm.38
        for <linux-mm@kvack.org>; Fri, 23 Oct 2009 09:58:35 -0700 (PDT)
Date: Fri, 23 Oct 2009 18:58:10 +0200
From: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC
	failures V2
Message-ID: <20091023165810.GA4588@bizet.domek.prywatny>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1256221356-26049-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 22, 2009 at 03:22:31PM +0100, Mel Gorman wrote:

[Cut everything but my bug]
> [Bug #14265] ifconfig: page allocation failure. order:5, mode:0x8020 w/ e100
> 	Karol Lewandows reported that e100 fails to allocate order-5
> 	GFP_ATOMIC when loading firmware during resume. This has started
> 	happening relatively recent.


> Test 1: Verify your problem occurs on 2.6.32-rc5 if you can

Yes, bug is still there.


> Test 2: Apply the following two patches and test again
> 
>   1/5 page allocator: Always wake kswapd when restarting an allocation attempt after direct reclaim failed
>   2/5 page allocator: Do not allow interrupts to use ALLOC_HARDER
> 
> 
> 	These patches correct problems introduced by me during the 2.6.31-rc1
> 	merge window. The patches were not meant to introduce any functional
> 	changes but two were missed.
> 
> 	If your problem goes away with just these two patches applied,
> 	please tell me.

Likewise.


> Test 3: If you are getting allocation failures, try with the following patch
> 
>   3/5 vmscan: Force kswapd to take notice faster when high-order watermarks are being hit
> 
> 	This is a functional change that causes kswapd to notice sooner
> 	when high-order watermarks have been hit. There have been a number
> 	of changes in page reclaim since 2.6.30 that might have delayed
> 	when kswapd kicks in for higher orders
> 
> 	If your problem goes away with these three patches applied, please
> 	tell me

No, problem doesn't go away with these patches (1+2+3).  However, from
my testing this particular patch makes it way, way harder to trigger
allocation failures (but these are still present).

This bothers me - should I test following patches with or without
above patch?  This patch makes bug harder to find, IMVHO it doesn't
fix the real problem.

(Rest not tested yet.)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
