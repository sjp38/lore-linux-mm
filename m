Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 45B1A6B0070
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 21:23:15 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so19140537pdj.26
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 18:23:14 -0800 (PST)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id n5si9513842pac.69.2013.12.02.18.23.12
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 18:23:14 -0800 (PST)
Date: Tue, 3 Dec 2013 11:25:39 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 4/5] slab: introduce byte sized index for the freelist
 of a slab
Message-ID: <20131203022539.GF31168@lge.com>
References: <1385974183-31423-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1385974183-31423-5-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1385974183-31423-5-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 02, 2013 at 05:49:42PM +0900, Joonsoo Kim wrote:
> Currently, the freelist of a slab consist of unsigned int sized indexes.
> Since most of slabs have less number of objects than 256, large sized
> indexes is needless. For example, consider the minimum kmalloc slab. It's
> object size is 32 byte and it would consist of one page, so 256 indexes
> through byte sized index are enough to contain all possible indexes.
> 
> There can be some slabs whose object size is 8 byte. We cannot handle
> this case with byte sized index, so we need to restrict minimum
> object size. Since these slabs are not major, wasted memory from these
> slabs would be negligible.
> 
> Some architectures' page size isn't 4096 bytes and rather larger than
> 4096 bytes (One example is 64KB page size on PPC or IA64) so that
> byte sized index doesn't fit to them. In this case, we will use
> two bytes sized index.
> 
> Below is some number for this patch.
> 
> * Before *
> kmalloc-512          525    640    512    8    1 : tunables   54   27    0 : slabdata     80     80      0
> kmalloc-256          210    210    256   15    1 : tunables  120   60    0 : slabdata     14     14      0
> kmalloc-192         1016   1040    192   20    1 : tunables  120   60    0 : slabdata     52     52      0
> kmalloc-96           560    620    128   31    1 : tunables  120   60    0 : slabdata     20     20      0
> kmalloc-64          2148   2280     64   60    1 : tunables  120   60    0 : slabdata     38     38      0
> kmalloc-128          647    682    128   31    1 : tunables  120   60    0 : slabdata     22     22      0
> kmalloc-32         11360  11413     32  113    1 : tunables  120   60    0 : slabdata    101    101      0
> kmem_cache           197    200    192   20    1 : tunables  120   60    0 : slabdata     10     10      0
> 
> * After *
> kmalloc-512          521    648    512    8    1 : tunables   54   27    0 : slabdata     81     81      0
> kmalloc-256          208    208    256   16    1 : tunables  120   60    0 : slabdata     13     13      0
> kmalloc-192         1029   1029    192   21    1 : tunables  120   60    0 : slabdata     49     49      0
> kmalloc-96           529    589    128   31    1 : tunables  120   60    0 : slabdata     19     19      0
> kmalloc-64          2142   2142     64   63    1 : tunables  120   60    0 : slabdata     34     34      0
> kmalloc-128          660    682    128   31    1 : tunables  120   60    0 : slabdata     22     22      0
> kmalloc-32         11716  11780     32  124    1 : tunables  120   60    0 : slabdata     95     95      0
> kmem_cache           197    210    192   21    1 : tunables  120   60    0 : slabdata     10     10      0
> 
> kmem_caches consisting of objects less than or equal to 256 byte have
> one or more objects than before. In the case of kmalloc-32, we have 11 more
> objects, so 352 bytes (11 * 32) are saved and this is roughly 9% saving of
> memory. Of couse, this percentage decreases as the number of objects
> in a slab decreases.
> 
> Here are the performance results on my 4 cpus machine.
> 
> * Before *
> 
>  Performance counter stats for 'perf bench sched messaging -g 50 -l 1000' (10 runs):
> 
>        229,945,138 cache-misses                                                  ( +-  0.23% )
> 
>       11.627897174 seconds time elapsed                                          ( +-  0.14% )
> 
> * After *
> 
>  Performance counter stats for 'perf bench sched messaging -g 50 -l 1000' (10 runs):
> 
>        218,640,472 cache-misses                                                  ( +-  0.42% )
> 
>       11.504999837 seconds time elapsed                                          ( +-  0.21% )
> 
> cache-misses are reduced by this patchset, roughly 5%.
> And elapsed times are improved by 1%.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 

Hello, Christoph.

Can I get your ACK for this patch?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
