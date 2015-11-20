Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6C9186B0253
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 08:09:22 -0500 (EST)
Received: by obbnk6 with SMTP id nk6so85646310obb.2
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 05:09:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w8si9643316obo.67.2015.11.20.05.09.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Nov 2015 05:09:21 -0800 (PST)
Date: Fri, 20 Nov 2015 14:09:16 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Memory exhaustion testing?
Message-ID: <20151120140916.33ec7896@redhat.com>
In-Reply-To: <alpine.DEB.2.10.1511191239001.7151@chino.kir.corp.google.com>
References: <20151112215531.69ccec19@redhat.com>
	<alpine.DEB.2.10.1511131452130.6173@chino.kir.corp.google.com>
	<20151116152440.101ea77d@redhat.com>
	<20151117142120.494947f9@redhat.com>
	<alpine.DEB.2.10.1511191239001.7151@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm <linux-mm@kvack.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, brouer@redhat.com

On Thu, 19 Nov 2015 12:40:50 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 17 Nov 2015, Jesper Dangaard Brouer wrote:
> 
> > I did manage to provoke/test the error path in kmem_cache_alloc_bulk(),
> > by using fault-injection framework "fail_page_alloc".
> > 
> > But was a little hard to trigger SLUB errors with this, because SLUB
> > retries after a failure, and second call to alloc_pages() is done with
> > lower order.
> > 
> > If order is lowered to zero, then should_fail_alloc_page() will skip it.
> > And just lowering /sys/kernel/debug/fail_page_alloc/min-order=0 is not
> > feasible as even fork starts to fail.  I managed to work-around this by
> > using "space" setting.
> > 
> > Created a script to ease this tricky invocation:
> >  https://github.com/netoptimizer/prototype-kernel/blob/master/tests/fault-inject/fail01_kmem_cache_alloc_bulk.sh
> > 
> 
> Any chance you could proffer some of your scripts in the form of patches 
> to the tools/testing directory?  Anything that can reliably trigger rarely 
> executed code is always useful.

Perhaps that is a good idea.

I think should move the directory location in my git-repo
prototype-kernel[1] to reflect this directory layout, like I do with
real kernel stuff.  And when we are happy with the quality of the
scripts we can "move" it to the kernel.  (Like I did with my pktgen
tests[4], now located in samples/pktgen/).

A question; where should/could we place the kernel module
slab_bulk_test04_exhaust_mem[1] that my fail01 script depends on?


BTW, I've also added a script for testing NULL handling in normal
kmem_cache_alloc() call see[3].

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

[1] https://github.com/netoptimizer/prototype-kernel/

[2] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/slab_bulk_test04_exhaust_mem.c

[3] https://github.com/netoptimizer/prototype-kernel/blob/master/tests/fault-inject/fail02_kmem_cache_alloc.sh

[4] https://github.com/netoptimizer/network-testing/tree/master/pktgen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
