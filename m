Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id DC4276B0005
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 17:12:48 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id p2so201547757vkg.2
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 14:12:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v55si9985467qtb.4.2016.07.22.14.12.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jul 2016 14:12:48 -0700 (PDT)
Date: Fri, 22 Jul 2016 17:12:46 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH 2/2] mm: optimize copy_page_to/from_iter_iovec
In-Reply-To: <alpine.LRH.2.02.1607221656530.4818@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.LRH.2.02.1607221711410.4818@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1607221656530.4818@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

The functions copy_page_to_iter_iovec and copy_page_from_iter_iovec copy some
data to userspace or from userspace. These functions have a fast path where they
map a page using kmap_atomic and a slow path where they use kmap.

kmap is slower than kmap_atomic, so the fast path is preferred.

However, on kernels without highmem support, kmap just calls page_address, so
there is no need to avoid kmap. On kernels without highmem support, the fast
path just increases code size (and cache footprint) and it doesn't improve
copy performance in any way.

This patch enables the fast path only if CONFIG_HIGHMEM is defined.

Code size reduced by this patch:
x86 (without highmem)	928
x86-64			960
sparc64			848
alpha			1136
pa-risc			1200

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 lib/iov_iter.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

Index: linux-4.7-rc7/lib/iov_iter.c
===================================================================
--- linux-4.7-rc7.orig/lib/iov_iter.c	2016-05-30 17:34:37.000000000 +0200
+++ linux-4.7-rc7/lib/iov_iter.c	2016-07-11 17:14:03.000000000 +0200
@@ -159,6 +159,7 @@ static size_t copy_page_to_iter_iovec(st
 	buf = iov->iov_base + skip;
 	copy = min(bytes, iov->iov_len - skip);
 
+#ifdef CONFIG_HIGHMEM
 	if (!fault_in_pages_writeable(buf, copy)) {
 		kaddr = kmap_atomic(page);
 		from = kaddr + offset;
@@ -190,6 +191,8 @@ static size_t copy_page_to_iter_iovec(st
 		copy = min(bytes, iov->iov_len - skip);
 	}
 	/* Too bad - revert to non-atomic kmap */
+#endif
+
 	kaddr = kmap(page);
 	from = kaddr + offset;
 	left = __copy_to_user(buf, from, copy);
@@ -208,7 +211,10 @@ static size_t copy_page_to_iter_iovec(st
 		bytes -= copy;
 	}
 	kunmap(page);
+
+#ifdef CONFIG_HIGHMEM
 done:
+#endif
 	if (skip == iov->iov_len) {
 		iov++;
 		skip = 0;
@@ -240,6 +246,7 @@ static size_t copy_page_from_iter_iovec(
 	buf = iov->iov_base + skip;
 	copy = min(bytes, iov->iov_len - skip);
 
+#ifdef CONFIG_HIGHMEM
 	if (!fault_in_pages_readable(buf, copy)) {
 		kaddr = kmap_atomic(page);
 		to = kaddr + offset;
@@ -271,6 +278,8 @@ static size_t copy_page_from_iter_iovec(
 		copy = min(bytes, iov->iov_len - skip);
 	}
 	/* Too bad - revert to non-atomic kmap */
+#endif
+
 	kaddr = kmap(page);
 	to = kaddr + offset;
 	left = __copy_from_user(to, buf, copy);
@@ -289,7 +298,10 @@ static size_t copy_page_from_iter_iovec(
 		bytes -= copy;
 	}
 	kunmap(page);
+
+#ifdef CONFIG_HIGHMEM
 done:
+#endif
 	if (skip == iov->iov_len) {
 		iov++;
 		skip = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
