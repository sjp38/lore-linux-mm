Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 94EC66B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 04:01:57 -0500 (EST)
Received: by qgec40 with SMTP id c40so82728604qge.2
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 01:01:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 127si12961296qhr.57.2015.12.04.01.01.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 01:01:56 -0800 (PST)
Date: Fri, 4 Dec 2015 10:01:51 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 0/2] slab: implement bulking for SLAB allocator
Message-ID: <20151204100151.1e96935a@redhat.com>
In-Reply-To: <20151203155600.3589.86568.stgit@firesoul>
References: <20151203155600.3589.86568.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, brouer@redhat.com

On Thu, 03 Dec 2015 16:56:32 +0100 Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> Normal SLAB fastpath 95 cycles(tsc) 23.852 ns, when compiled without
> debugging options enabled.
> 
> Benchmarked[1] obj size 256 bytes on CPU i7-4790K @ 4.00GHz:
> [1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/slab_bulk_test01.c
> 
>   1 - 115 cycles(tsc) 28.812 ns - 42 cycles(tsc) 10.715 ns - improved 63.5%
>   2 - 103 cycles(tsc) 25.956 ns - 27 cycles(tsc)  6.985 ns - improved 73.8%
>   3 - 101 cycles(tsc) 25.336 ns - 22 cycles(tsc)  5.733 ns - improved 78.2%
>   4 - 100 cycles(tsc) 25.147 ns - 21 cycles(tsc)  5.319 ns - improved 79.0%
>   8 -  98 cycles(tsc) 24.616 ns - 18 cycles(tsc)  4.620 ns - improved 81.6%
>  16 -  97 cycles(tsc) 24.408 ns - 17 cycles(tsc)  4.344 ns - improved 82.5%
>  30 -  98 cycles(tsc) 24.641 ns - 16 cycles(tsc)  4.202 ns - improved 83.7%
>  32 -  98 cycles(tsc) 24.607 ns - 16 cycles(tsc)  4.199 ns - improved 83.7%
>  34 -  98 cycles(tsc) 24.605 ns - 18 cycles(tsc)  4.579 ns - improved 81.6%
>  48 -  97 cycles(tsc) 24.463 ns - 17 cycles(tsc)  4.405 ns - improved 82.5%
>  64 -  97 cycles(tsc) 24.370 ns - 17 cycles(tsc)  4.384 ns - improved 82.5%
> 128 -  99 cycles(tsc) 24.763 ns - 19 cycles(tsc)  4.755 ns - improved 80.8%
> 158 -  98 cycles(tsc) 24.708 ns - 18 cycles(tsc)  4.723 ns - improved 81.6%
> 250 - 101 cycles(tsc) 25.342 ns - 20 cycles(tsc)  5.035 ns - improved 80.2%

Ups, copy-past mistake, these (above) were the old results, from the old
rejected patch [2].

[2] http://people.netfilter.org/hawk/patches/slab_rejected/slab-implement-bulking-for-slab-allocator.patch

The results from this patchset is:

  1 - 112 cycles(tsc) 28.060 ns - 45 cycles(tsc) 11.454 ns - improved 59.8%
  2 - 102 cycles(tsc) 25.735 ns - 28 cycles(tsc) 7.038 ns - improved 72.5%
  3 -  98 cycles(tsc) 24.666 ns - 22 cycles(tsc) 5.518 ns - improved 77.6%
  4 -  97 cycles(tsc) 24.437 ns - 18 cycles(tsc) 4.746 ns - improved 81.4%
  8 -  95 cycles(tsc) 23.875 ns - 15 cycles(tsc) 3.782 ns - improved 84.2%
 16 -  95 cycles(tsc) 24.002 ns - 14 cycles(tsc) 3.621 ns - improved 85.3%
 30 -  95 cycles(tsc) 23.893 ns - 14 cycles(tsc) 3.577 ns - improved 85.3%
 32 -  95 cycles(tsc) 23.875 ns - 13 cycles(tsc) 3.402 ns - improved 86.3%
 34 -  95 cycles(tsc) 23.794 ns - 13 cycles(tsc) 3.385 ns - improved 86.3%
 48 -  94 cycles(tsc) 23.721 ns - 14 cycles(tsc) 3.550 ns - improved 85.1%
 64 -  94 cycles(tsc) 23.608 ns - 13 cycles(tsc) 3.427 ns - improved 86.2%
128 -  96 cycles(tsc) 24.045 ns - 15 cycles(tsc) 3.936 ns - improved 84.4%
158 -  95 cycles(tsc) 23.886 ns - 17 cycles(tsc) 4.289 ns - improved 82.1%
250 -  97 cycles(tsc) 24.358 ns - 17 cycles(tsc) 4.329 ns - improved 82.5%

These results are likely better because there is now less instructions
in the more tight bulk loops (mostly in kmem_cache_alloc_bulk). SLUB
itself might also have improved at bit since old patch.

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
