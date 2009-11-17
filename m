Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 334CB6B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 03:07:55 -0500 (EST)
Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id nAH87nJA011811
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 08:07:50 GMT
Received: from pwi15 (pwi15.prod.google.com [10.241.219.15])
	by zps77.corp.google.com with ESMTP id nAH8782K021876
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 00:07:47 -0800
Received: by pwi15 with SMTP id 15so3895342pwi.4
        for <linux-mm@kvack.org>; Tue, 17 Nov 2009 00:07:46 -0800 (PST)
Date: Tue, 17 Nov 2009 00:07:44 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/7] Kill PF_MEMALLOC abuse
In-Reply-To: <20091117161551.3DD4.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0911170004380.1564@chino.kir.corp.google.com>
References: <20091117161551.3DD4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Nov 2009, KOSAKI Motohiro wrote:

> 
> PF_MEMALLOC have following effects.
>   (1) Ignore zone watermark
>   (2) Don't call reclaim although allocation failure, instead return ENOMEM
>   (3) Don't invoke OOM Killer
>   (4) Don't retry internally in page alloc
> 
> Some subsystem paid attention (1) only, and start to use PF_MEMALLOC abuse.
> But, the fact is, PF_MEMALLOC is the promise of "I have lots freeable memory.
> if I allocate few memory, I can return more much meory to the system!".
> Non MM subsystem must not use PF_MEMALLOC. Memory reclaim
> need few memory, anyone must not prevent it. Otherwise the system cause
> mysterious hang-up and/or OOM Killer invokation.
> 
> if many subsystem will be able to use emergency memory without any
> usage rule, it isn't for emergency. it can become empty easily.
> 
> Plus, characteristics (2)-(4) mean PF_MEMALLOC don't fit to general
> high priority memory allocation.
> 
> Thus, We kill all PF_MEMALLOC usage in no MM subsystem.
> 

I agree in principle with removing non-VM users of PF_MEMALLOC, but I 
think it should be left to the individual subsystem maintainers to apply 
or ack since the allocations may depend on the __GFP_NORETRY | ~__GFP_WAIT 
behavior of PF_MEMALLOC.  This could be potentially dangerous for a 
PF_MEMALLOC user if allocations made by the kthread, for example, should 
never retry for orders smaller than PAGE_ALLOC_COSTLY_ORDER or block on 
direct reclaim.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
