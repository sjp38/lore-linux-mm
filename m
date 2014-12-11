Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4E72E6B006C
	for <linux-mm@kvack.org>; Thu, 11 Dec 2014 08:35:30 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id i13so3483263qae.41
        for <linux-mm@kvack.org>; Thu, 11 Dec 2014 05:35:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e5si1268896qcm.34.2014.12.11.05.35.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Dec 2014 05:35:29 -0800 (PST)
Date: Thu, 11 Dec 2014 14:35:18 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 0/7] slub: Fastpath optimization (especially for RT) V1
Message-ID: <20141211143518.02c781ee@redhat.com>
In-Reply-To: <20141210163017.092096069@linux.com>
References: <20141210163017.092096069@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo.kim@lge.com, brouer@redhat.com

On Wed, 10 Dec 2014 10:30:17 -0600
Christoph Lameter <cl@linux.com> wrote:

[...]
> 
> Slab Benchmarks on a kernel with CONFIG_PREEMPT show an improvement of
> 20%-50% of fastpath latency:
> 
> Before:
> 
> Single thread testing
[...]
> 2. Kmalloc: alloc/free test
[...]
> 10000 times kmalloc(256)/kfree -> 116 cycles
[...]
> 
> 
> After:
> 
> Single thread testing
[...]
> 2. Kmalloc: alloc/free test
[...]
> 10000 times kmalloc(256)/kfree -> 60 cycles
[...]

It looks like an impressive saving 116 -> 60 cycles.  I just don't see
the same kind of improvements with my similar tests[1][2].

My test[1] is just a fast-path loop over kmem_cache_alloc+free on
256bytes objects. (Results after explicitly inlining new func
is_pointer_to_page())

 baseline: 47 cycles(tsc) 19.032 ns
 patchset: 45 cycles(tsc) 18.135 ns

I do see the improvement, but it is not as high as I would have expected.

(CPU E5-2695)

[1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/time_bench_kmem_cache1.c
[2] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/qmempool_bench.c

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
