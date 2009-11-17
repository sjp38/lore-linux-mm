Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D70F36B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 03:33:52 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAH8XoDx031565
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 17 Nov 2009 17:33:50 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F1F645DE59
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 17:33:50 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id EC2E845DE58
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 17:33:49 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id BF2C41DB805F
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 17:33:49 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 675BD1DB803C
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 17:33:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/7] Kill PF_MEMALLOC abuse
In-Reply-To: <alpine.DEB.2.00.0911170004380.1564@chino.kir.corp.google.com>
References: <20091117161551.3DD4.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.0911170004380.1564@chino.kir.corp.google.com>
Message-Id: <20091117172802.3DF4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 17 Nov 2009 17:33:48 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Tue, 17 Nov 2009, KOSAKI Motohiro wrote:
> 
> > 
> > PF_MEMALLOC have following effects.
> >   (1) Ignore zone watermark
> >   (2) Don't call reclaim although allocation failure, instead return ENOMEM
> >   (3) Don't invoke OOM Killer
> >   (4) Don't retry internally in page alloc
> > 
> > Some subsystem paid attention (1) only, and start to use PF_MEMALLOC abuse.
> > But, the fact is, PF_MEMALLOC is the promise of "I have lots freeable memory.
> > if I allocate few memory, I can return more much meory to the system!".
> > Non MM subsystem must not use PF_MEMALLOC. Memory reclaim
> > need few memory, anyone must not prevent it. Otherwise the system cause
> > mysterious hang-up and/or OOM Killer invokation.
> > 
> > if many subsystem will be able to use emergency memory without any
> > usage rule, it isn't for emergency. it can become empty easily.
> > 
> > Plus, characteristics (2)-(4) mean PF_MEMALLOC don't fit to general
> > high priority memory allocation.
> > 
> > Thus, We kill all PF_MEMALLOC usage in no MM subsystem.
> 
> I agree in principle with removing non-VM users of PF_MEMALLOC, but I 
> think it should be left to the individual subsystem maintainers to apply 
> or ack since the allocations may depend on the __GFP_NORETRY | ~__GFP_WAIT 
> behavior of PF_MEMALLOC.  This could be potentially dangerous for a 
> PF_MEMALLOC user if allocations made by the kthread, for example, should 
> never retry for orders smaller than PAGE_ALLOC_COSTLY_ORDER or block on 
> direct reclaim.

if there is so such reason. we might need to implement another MM trick.
but keeping this strage usage is not a option. All memory freeing activity
(e.g. page out, task killing) need some memory. we need to protect its
emergency memory. otherwise linux reliability decrease dramatically when
the system face to memory stress.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
