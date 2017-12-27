Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 092C36B0253
	for <linux-mm@kvack.org>; Wed, 27 Dec 2017 07:44:45 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id y10so2036433wrh.12
        for <linux-mm@kvack.org>; Wed, 27 Dec 2017 04:44:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d13sor13798243wre.53.2017.12.27.04.44.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Dec 2017 04:44:43 -0800 (PST)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH 0/5] kasan: detect invalid frees
Date: Wed, 27 Dec 2017 13:44:31 +0100
Message-Id: <cover.1514378558.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aryabinin@virtuozzo.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, Dmitry Vyukov <dvyukov@google.com>

KASAN detects double-frees, but does not detect invalid-frees
(when a pointer into a middle of heap object is passed to free).
We recently had a very unpleasant case in crypto code which freed
an inner object inside of a heap allocation. This left unnoticed
during free, but totally corrupted heap and later lead to a bunch
of random crashes all over kernel code.

Detect invalid frees.

Dmitry Vyukov (5):
  kasan: detect invalid frees for large objects
  kasan: don't use __builtin_return_address(1)
  kasan: detect invalid frees for large mempool objects
  kasan: unify code between kasan_slab_free() and kasan_poison_kfree()
  kasan: detect invalid frees

 include/linux/kasan.h | 13 ++++----
 lib/test_kasan.c      | 83 +++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/kasan/kasan.c      | 57 +++++++++++++++++++----------------
 mm/kasan/kasan.h      |  3 +-
 mm/kasan/report.c     |  5 ++--
 mm/mempool.c          |  6 ++--
 mm/slab.c             |  6 ++--
 mm/slub.c             | 10 +++----
 8 files changed, 135 insertions(+), 48 deletions(-)

-- 
2.15.1.620.gb9897f4670-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
