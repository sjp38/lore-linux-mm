Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D1E646B0078
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 06:20:47 -0400 (EDT)
Received: by fxm18 with SMTP id 18so1237544fxm.14
        for <linux-mm@kvack.org>; Thu, 09 Jun 2011 03:20:42 -0700 (PDT)
Date: Thu, 9 Jun 2011 12:20:38 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm: dmapool: fix possible use after free in
 dmam_pool_destroy()
Message-ID: <20110609102038.GE11773@htj.dyndns.org>
References: <20110602142242.GA4115@maxin>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110602142242.GA4115@maxin>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxin B John <maxin.john@gmail.com>
Cc: eike-kernel@sf-tec.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dima@android.com, willy@linux.intel.com, segooon@gmail.com, jkosina@suse.cz, tglx@linutronix.de

Hello,

On Thu, Jun 02, 2011 at 05:22:42PM +0300, Maxin B John wrote:
> > The pool itself is not used there, only the address where the pool
> > has been.This will only lead to any trouble if something else is allocated to
> > the same place and inserted into the devres list of the same device between
> > the dma_pool_destroy() and devres_destroy().

Which can't happen.  devres release is bound to device driver model
and a device can't be re-attached before release is complete.
ie. those operations are serialized, so the failure mode is only
theoretical.

> Thank you very much for explaining it in detail. 
> 
> > But I agree that this is bad style. But if you are going to change
> > this please also have a look at devm_iounmap() in lib/devres.c. Maybe also the
> > devm_*irq* functions need the same changes.
> 
> As per your suggestion, I have made similar modifications for lib/devres.c and
> kernel/irq/devres.c
> 
> CCed the maintainers of the respective files.
>  
> Signed-off-by: Maxin B. John <maxin.john@gmail.com>

But it shouldn't hurt and if it helps memleak.

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
