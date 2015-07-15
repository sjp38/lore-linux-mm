Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id E090328027E
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 12:01:51 -0400 (EDT)
Received: by qget71 with SMTP id t71so20175037qge.2
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 09:01:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d140si5852799qhc.123.2015.07.15.09.01.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 09:01:51 -0700 (PDT)
Subject: [PATCH 0/3] slub: introducing detached freelist
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 15 Jul 2015 18:01:08 +0200
Message-ID: <20150715155934.17525.2835.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Alexander Duyck <alexander.duyck@gmail.com>, Hannes Frederic Sowa <hannes@stressinduktion.org>, Jesper Dangaard Brouer <brouer@redhat.com>

Introducing what I call detached freelist, for improving the
performance of object freeing in the "slowpath" of kmem_cache_free_bulk,
which calls __slab_free().

The benchmarking tool are avail here:
 https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/mm
 See: slab_bulk_test0{1,2,3}.c

Compared against existing bulk-API (in AKPMs tree), we see a small
regression for the fastpath (between 2-5 cycles), but a huge
improvement for the slowpath.

bulk- Bulk-API-before           - Bulk-API with patchset
  1 -  42 cycles(tsc) 10.520 ns - 47 cycles(tsc) 11.931 ns - improved -11.9%
  2 -  26 cycles(tsc)  6.697 ns - 29 cycles(tsc)  7.368 ns - improved -11.5%
  3 -  22 cycles(tsc)  5.589 ns - 24 cycles(tsc)  6.003 ns - improved -9.1%
  4 -  19 cycles(tsc)  4.921 ns - 22 cycles(tsc)  5.543 ns - improved -15.8%
  8 -  17 cycles(tsc)  4.499 ns - 20 cycles(tsc)  5.047 ns - improved -17.6%
 16 -  69 cycles(tsc) 17.424 ns - 20 cycles(tsc)  5.015 ns - improved 71.0%
 30 -  88 cycles(tsc) 22.075 ns - 20 cycles(tsc)  5.062 ns - improved 77.3%
 32 -  83 cycles(tsc) 20.965 ns - 20 cycles(tsc)  5.089 ns - improved 75.9%
 34 -  80 cycles(tsc) 20.039 ns - 28 cycles(tsc)  7.006 ns - improved 65.0%
 48 -  76 cycles(tsc) 19.252 ns - 31 cycles(tsc)  7.755 ns - improved 59.2%
 64 -  86 cycles(tsc) 21.523 ns - 68 cycles(tsc) 17.203 ns - improved 20.9%
128 -  97 cycles(tsc) 24.444 ns - 72 cycles(tsc) 18.195 ns - improved 25.8%
158 -  96 cycles(tsc) 24.036 ns - 73 cycles(tsc) 18.372 ns - improved 24.0%
250 - 100 cycles(tsc) 25.007 ns - 73 cycles(tsc) 18.430 ns - improved 27.0%

Patchset based on top of commit aefbef10e3ae with previous accepted
bulk patchset(V2) applied (avail in AKPMs quilt).

Small note, benchmark run with kernel compiled with .config
CONFIG_FTRACE in-order to use the perf probes to measure the amount of
page bulking into __slab_free().  While running the "worse-case"
testing module slab_bulk_test03.c

---

Jesper Dangaard Brouer (3):
      slub: extend slowpath __slab_free() to handle bulk free
      slub: optimize bulk slowpath free by detached freelist
      slub: build detached freelist with look-ahead


 mm/slub.c |  141 ++++++++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 111 insertions(+), 30 deletions(-)

--
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
