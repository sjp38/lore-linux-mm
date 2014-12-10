Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id F3CDF6B0073
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 11:30:36 -0500 (EST)
Received: by mail-qa0-f47.google.com with SMTP id s7so2231295qap.34
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 08:30:36 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id c8si4183904qab.109.2014.12.10.08.30.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 08:30:35 -0800 (PST)
Message-Id: <20141210163017.092096069@linux.com>
Date: Wed, 10 Dec 2014 10:30:17 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 0/7] slub: Fastpath optimization (especially for RT) V1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

We had to insert a preempt enable/disable in the fastpath a while ago. This
was mainly due to a lot of state that is kept to be allocating from the per
cpu freelist. In particular the page field is not covered by
this_cpu_cmpxchg used in the fastpath to do the necessary atomic state
change for fast path allocation and freeing.

This patch removes the need for the page field to describe the state of the
per cpu list. The freelist pointer can be used to determine the page struct
address if necessary.

However, currently this does not work for the termination value of a list
which is NULL and the same for all slab pages. If we use a valid pointer
into the page as well as set the last bit then all freelist pointers can
always be used to determine the address of the page struct and we will not
need the page field anymore in the per cpu are for a slab. Testing for the
end of the list is a test if the first bit is set.

So the first patch changes the termination pointer for freelists to do just
that. The second removes the page field and then third can then remove the
preempt enable/disable.

Removing the ->page field reduces the cache footprint of the fastpath so hopefully overall
allocator effectiveness will increase further. Also RT uses full preemption which means
that currently pretty expensive code has to be inserted into the fastpath. This approach
allows the removal of that code and a corresponding performance increase.

For V1 a number of changes were made to avoid the overhead of virt_to_page
and page_address from the RFC.

Slab Benchmarks on a kernel with CONFIG_PREEMPT show an improvement of
20%-50% of fastpath latency:

Before:

Single thread testing
1. Kmalloc: Repeatedly allocate then free test
10000 times kmalloc(8) -> 68 cycles kfree -> 107 cycles
10000 times kmalloc(16) -> 69 cycles kfree -> 108 cycles
10000 times kmalloc(32) -> 78 cycles kfree -> 112 cycles
10000 times kmalloc(64) -> 97 cycles kfree -> 112 cycles
10000 times kmalloc(128) -> 111 cycles kfree -> 119 cycles
10000 times kmalloc(256) -> 114 cycles kfree -> 139 cycles
10000 times kmalloc(512) -> 110 cycles kfree -> 142 cycles
10000 times kmalloc(1024) -> 114 cycles kfree -> 156 cycles
10000 times kmalloc(2048) -> 155 cycles kfree -> 174 cycles
10000 times kmalloc(4096) -> 203 cycles kfree -> 209 cycles
10000 times kmalloc(8192) -> 361 cycles kfree -> 265 cycles
10000 times kmalloc(16384) -> 597 cycles kfree -> 286 cycles

2. Kmalloc: alloc/free test
10000 times kmalloc(8)/kfree -> 114 cycles
10000 times kmalloc(16)/kfree -> 115 cycles
10000 times kmalloc(32)/kfree -> 117 cycles
10000 times kmalloc(64)/kfree -> 115 cycles
10000 times kmalloc(128)/kfree -> 111 cycles
10000 times kmalloc(256)/kfree -> 116 cycles
10000 times kmalloc(512)/kfree -> 110 cycles
10000 times kmalloc(1024)/kfree -> 114 cycles
10000 times kmalloc(2048)/kfree -> 110 cycles
10000 times kmalloc(4096)/kfree -> 107 cycles
10000 times kmalloc(8192)/kfree -> 108 cycles
10000 times kmalloc(16384)/kfree -> 706 cycles


After:


Single thread testing
1. Kmalloc: Repeatedly allocate then free test
10000 times kmalloc(8) -> 41 cycles kfree -> 81 cycles
10000 times kmalloc(16) -> 47 cycles kfree -> 88 cycles
10000 times kmalloc(32) -> 48 cycles kfree -> 93 cycles
10000 times kmalloc(64) -> 58 cycles kfree -> 89 cycles
10000 times kmalloc(128) -> 84 cycles kfree -> 104 cycles
10000 times kmalloc(256) -> 92 cycles kfree -> 125 cycles
10000 times kmalloc(512) -> 86 cycles kfree -> 129 cycles
10000 times kmalloc(1024) -> 88 cycles kfree -> 125 cycles
10000 times kmalloc(2048) -> 120 cycles kfree -> 159 cycles
10000 times kmalloc(4096) -> 176 cycles kfree -> 183 cycles
10000 times kmalloc(8192) -> 294 cycles kfree -> 233 cycles
10000 times kmalloc(16384) -> 585 cycles kfree -> 291 cycles

2. Kmalloc: alloc/free test
10000 times kmalloc(8)/kfree -> 100 cycles
10000 times kmalloc(16)/kfree -> 108 cycles
10000 times kmalloc(32)/kfree -> 101 cycles
10000 times kmalloc(64)/kfree -> 109 cycles
10000 times kmalloc(128)/kfree -> 125 cycles
10000 times kmalloc(256)/kfree -> 60 cycles
10000 times kmalloc(512)/kfree -> 60 cycles
10000 times kmalloc(1024)/kfree -> 67 cycles
10000 times kmalloc(2048)/kfree -> 60 cycles
10000 times kmalloc(4096)/kfree -> 65 cycles
10000 times kmalloc(8192)/kfree -> 60 cycles
10000 times kmalloc(16384)/kfree -> 686 cycles

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
