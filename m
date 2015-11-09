Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id C77116B0253
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 13:17:01 -0500 (EST)
Received: by ioc74 with SMTP id 74so128607190ioc.2
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 10:17:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k4si13515651ioe.26.2015.11.09.10.17.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 10:17:01 -0800 (PST)
Subject: [PATCH V3 0/2] SLUB bulk API interactions with kmem cgroup
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 09 Nov 2015 19:16:58 +0100
Message-ID: <20151109181604.8231.22983.stgit@firesoul>
In-Reply-To: <20151105161048.GG29259@esperanza>
References: <20151105161048.GG29259@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: vdavydov@virtuozzo.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Added correct support for kmem cgroup interaction with SLUB bulk API.

I've compiled kernel with CONFIG_MEMCG_KMEM=y, and have tested the
kernel with the setup provide by Vladimir Davydov.  And with my
network stack use-case patchset applied, to actually activate the API.

Patch01: I've verified the loop in slab_post_alloc_hook() gets removed
 by the compiler (when no debug options defined). This was actually
 tricky due to kernel gcc compile options, and I wrote a small program
 to figure this out [1].

Patch02: The "try_crash" mode of the test module slab_bulk_test03 [2]
 have been modified as after this change we no longer handle error
 cases like passing of NULL pointers in the array to free, when
 CONFIG_MEMCG_KMEM is enabled.

[1] https://github.com/netoptimizer/network-testing/blob/master/src/compiler_test01.c
[2] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/slab_bulk_test03.c

---

Jesper Dangaard Brouer (2):
      slub: fix kmem cgroup bug in kmem_cache_alloc_bulk
      slub: add missing kmem cgroup support to kmem_cache_free_bulk


 mm/slub.c |   41 +++++++++++++++++++++++++++--------------
 1 file changed, 27 insertions(+), 14 deletions(-)

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
