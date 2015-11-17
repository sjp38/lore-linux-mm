Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f46.google.com (mail-vk0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id E3ACD6B0257
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 08:21:25 -0500 (EST)
Received: by vkha189 with SMTP id a189so4927399vkh.1
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 05:21:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x145si2640482vke.199.2015.11.17.05.21.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Nov 2015 05:21:24 -0800 (PST)
Date: Tue, 17 Nov 2015 14:21:20 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Memory exhaustion testing?
Message-ID: <20151117142120.494947f9@redhat.com>
In-Reply-To: <20151116152440.101ea77d@redhat.com>
References: <20151112215531.69ccec19@redhat.com>
	<alpine.DEB.2.10.1511131452130.6173@chino.kir.corp.google.com>
	<20151116152440.101ea77d@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm <linux-mm@kvack.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, brouer@redhat.com


On Mon, 16 Nov 2015 15:24:40 +0100 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> On Fri, 13 Nov 2015 14:54:37 -0800 (PST) David Rientjes <rientjes@google.com> wrote:
> 
> > [...]  This is why 
> > failslab had been used in the past, and does a good job at runtime 
> > testing.  
> 
> Thanks for mentioning CONFIG_FAILSLAB.  First I disregarded
> "failslab" (I did notice it in the slub code) because it didn't
> exercised the code path I wanted in kmem_cache_alloc_bulk().
> 
> But went to looking up the config setting I notice that we do have a
> hole section for "Fault-injection".  Which is great, and what I was
> looking for.
> 
> Menu config Location:
>  -> Kernel hacking
>   -> Fault-injection framework (FAULT_INJECTION [=y])
> 
> I think what I need can be covered by FAIL_PAGE_ALLOC, or should_fail_alloc_page().
> I'll try and play a bit with it...

I did manage to provoke/test the error path in kmem_cache_alloc_bulk(),
by using fault-injection framework "fail_page_alloc".

But was a little hard to trigger SLUB errors with this, because SLUB
retries after a failure, and second call to alloc_pages() is done with
lower order.

If order is lowered to zero, then should_fail_alloc_page() will skip it.
And just lowering /sys/kernel/debug/fail_page_alloc/min-order=0 is not
feasible as even fork starts to fail.  I managed to work-around this by
using "space" setting.

Created a script to ease this tricky invocation:
 https://github.com/netoptimizer/prototype-kernel/blob/master/tests/fault-inject/fail01_kmem_cache_alloc_bulk.sh

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
