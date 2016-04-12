Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 626DC6B0253
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:24:42 -0400 (EDT)
Received: by mail-qg0-f47.google.com with SMTP id f105so8791025qge.2
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 00:24:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y130si2603662qka.87.2016.04.12.00.24.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 00:24:41 -0700 (PDT)
Date: Tue, 12 Apr 2016 09:24:34 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2 11/11] mm/slab: lockless decision to grow cache
Message-ID: <20160412092434.0929a04c@redhat.com>
In-Reply-To: <1460436666-20462-12-git-send-email-iamjoonsoo.kim@lge.com>
References: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1460436666-20462-12-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, brouer@redhat.com

On Tue, 12 Apr 2016 13:51:06 +0900
js1304@gmail.com wrote:

> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> To check whther free objects exist or not precisely, we need to grab a
           ^^^^^^    
(spelling)
> lock.  But, accuracy isn't that important because race window would be
> even small and if there is too much free object, cache reaper would reap
> it.  So, this patch makes the check for free object exisistence not to
                                                      ^^^^^^^^^^^
(spelling)

> hold a lock.  This will reduce lock contention in heavily allocation case.
> 
> Note that until now, n->shared can be freed during the processing by
> writing slabinfo, but, with some trick in this patch, we can access it
> freely within interrupt disabled period.
> 
> Below is the result of concurrent allocation/free in slab allocation
> benchmark made by Christoph a long time ago.  I make the output simpler.
> The number shows cycle count during alloc/free respectively so less is
> better.

I cannot figure out which if Christoph's tests you are using.  And I
even have a copy of his test here:
 https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/slab_test.c

I think you need to describe the test a bit better...

Looking a long time at the output on my own system, I guess you are
showing results from the "Concurrent allocs".  Then it would be
relevant how many CPUs your system have.

It would also be relevant to mention that N=10000.  And perhaps mention
that it means, e.g all CPUs do N=10000 alloc concurrently, synchronize
before doing N free concurrently.

> * Before
> Kmalloc N*alloc N*free(32): Average=248/966
> Kmalloc N*alloc N*free(64): Average=261/949
> Kmalloc N*alloc N*free(128): Average=314/1016
> Kmalloc N*alloc N*free(256): Average=741/1061
> Kmalloc N*alloc N*free(512): Average=1246/1152
> Kmalloc N*alloc N*free(1024): Average=2437/1259
> Kmalloc N*alloc N*free(2048): Average=4980/1800
> Kmalloc N*alloc N*free(4096): Average=9000/2078
> 
> * After
> Kmalloc N*alloc N*free(32): Average=344/792
> Kmalloc N*alloc N*free(64): Average=347/882
> Kmalloc N*alloc N*free(128): Average=390/959
> Kmalloc N*alloc N*free(256): Average=393/1067
> Kmalloc N*alloc N*free(512): Average=683/1229
> Kmalloc N*alloc N*free(1024): Average=1295/1325
> Kmalloc N*alloc N*free(2048): Average=2513/1664
> Kmalloc N*alloc N*free(4096): Average=4742/2172
> 
> It shows that allocation performance decreases for the object size up to
> 128 and it may be due to extra checks in cache_alloc_refill().  But, with
> considering improvement of free performance, net result looks the same.
> Result for other size class looks very promising, roughly, 50% performance
> improvement.

Super nice performance boost.  The numbers on my system are
significantly smaller, but this is a before/after test and the absolute
numbers are not that important.

Oh, maybe this was because I ran the test with SLUB... recompiling with
SLAB... and the results are comparable to your numbers (on my 8 core
i7-4790K CPU @ 4.00GHz)

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
