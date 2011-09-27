Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 033FA9000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 21:22:47 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p8R1MiJc007254
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:22:45 -0700
Received: from yie21 (yie21.prod.google.com [10.243.66.21])
	by hpaq2.eem.corp.google.com with ESMTP id p8R1MHTP029033
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:22:43 -0700
Received: by yie21 with SMTP id 21so6932051yie.40
        for <linux-mm@kvack.org>; Mon, 26 Sep 2011 18:22:43 -0700 (PDT)
Date: Mon, 26 Sep 2011 18:22:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH] slab: fix caller tracking
 onCONFIG_OPTIMIZE_INLINING.
In-Reply-To: <201109251421.BEB71358.OFOHJVMFQOFLtS@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.00.1109261815510.10419@chino.kir.corp.google.com>
References: <201109241208.IEH26037.FtSVLJOOQHMFFO@I-love.SAKURA.ne.jp> <alpine.DEB.2.00.1109241550230.14043@chino.kir.corp.google.com> <201109251421.BEB71358.OFOHJVMFQOFLtS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: cl@linux-foundation.org, penberg@cs.helsinki.fi, mpm@selenic.com, vegard.nossum@gmail.com, dmonakhov@openvz.org, catalin.marinas@arm.com, dfeng@redhat.com, linux-mm@kvack.org

On Sun, 25 Sep 2011, Tetsuo Handa wrote:

> > So this is going against the inlining algorithms in gcc 4.x which will 
> > make the kernel image significantly larger even though there seems to be 
> > no benefit unless you have CONFIG_DEBUG_SLAB_LEAK, although this patch 
> > changes behavior for every system running CONFIG_SLAB with tracing 
> > support.
> 
> If use of address of kzalloc() itself is fine for tracing functionality, we
> don't need to force tracing functionality to use caller address of kzalloc().
> 
> I merely want /proc/slab_allocators to print caller address of kzalloc() rather
> than kzalloc() address itself.
> 

Yeah, I understand the intent of the patch, but I don't think we need to 
force inlining in all the conditions that you specified it.  We know that 
CONFIG_DEBUG_SLAB_LEAK kernels aren't performance critical and it seems 
reasonable that they aren't image size critical either, but we certainly 
don't need this for kernels configured for SLUB or for SLAB kernels with 
tracing support and not CONFIG_DEBUG_SLAB_LEAK.

The "caller" formal to cache_alloc_debugcheck_after() wants the true 
caller of the allocation for CONFIG_DEBUG_SLAB_LEAK.  kmalloc() is already 
__always_inline, so just define slabtrace_inline to be __always_inline for 
CONFIG_DEBUG_SLAB_LEAK?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
