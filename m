Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AD2C76B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 03:36:51 -0500 (EST)
Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id nAH8al1X002208
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 00:36:48 -0800
Received: from pxi2 (pxi2.prod.google.com [10.243.27.2])
	by spaceape7.eur.corp.google.com with ESMTP id nAH8ai7d029070
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 00:36:45 -0800
Received: by pxi2 with SMTP id 2so4731959pxi.11
        for <linux-mm@kvack.org>; Tue, 17 Nov 2009 00:36:44 -0800 (PST)
Date: Tue, 17 Nov 2009 00:36:38 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/7] Kill PF_MEMALLOC abuse
In-Reply-To: <20091117172802.3DF4.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0911170034500.22639@chino.kir.corp.google.com>
References: <20091117161551.3DD4.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.0911170004380.1564@chino.kir.corp.google.com> <20091117172802.3DF4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Nov 2009, KOSAKI Motohiro wrote:

> > I agree in principle with removing non-VM users of PF_MEMALLOC, but I 
> > think it should be left to the individual subsystem maintainers to apply 
> > or ack since the allocations may depend on the __GFP_NORETRY | ~__GFP_WAIT 
> > behavior of PF_MEMALLOC.  This could be potentially dangerous for a 
> > PF_MEMALLOC user if allocations made by the kthread, for example, should 
> > never retry for orders smaller than PAGE_ALLOC_COSTLY_ORDER or block on 
> > direct reclaim.
> 
> if there is so such reason. we might need to implement another MM trick.
> but keeping this strage usage is not a option. All memory freeing activity
> (e.g. page out, task killing) need some memory. we need to protect its
> emergency memory. otherwise linux reliability decrease dramatically when
> the system face to memory stress.
> 

Right, that's why I agree with trying to remove non-VM use of PF_MEMALLOC, 
but I think this patchset needs to go through the individual subsystem 
maintainers so they can ensure the conversion doesn't cause undesirable 
results if their kthreads' memory allocations depend on the __GFP_NORETRY 
behavior that PF_MEMALLOC ensures.  Otherwise it looks good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
