Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3C8656B026A
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 11:53:35 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id a2so7233570pgn.7
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 08:53:35 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id b15si1305734pfh.30.2018.02.12.08.53.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 08:53:33 -0800 (PST)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [RFC PATCH v16 0/6] mm: security: ro protection for dynamic data
Date: Mon, 12 Feb 2018 18:52:55 +0200
Message-ID: <20180212165301.17933-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, rdunlap@infradead.org, corbet@lwn.net, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, jglisse@redhat.com, hch@infradead.org
Cc: cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

This patch-set introduces the possibility of protecting memory that has
been allocated dynamically.

The memory is managed in pools: when a memory pool is turned into R/O,
all the memory that is part of it, will become R/O.

A R/O pool can be destroyed, to recover its memory, but it cannot be
turned back into R/W mode.

This is intentional. This feature is meant for data that doesn't need
further modifications after initialization.

However the data might need to be released, for example as part of module
unloading.
To do this, the memory must first be freed, then the pool can be destroyed.

An example is provided, in the form of self-testing.

Changes since v15:
[http://www.openwall.com/lists/kernel-hardening/2018/02/11/4]

- Fixed remaining broken comments
- Fixed remaining broken "Returns" instead of "Return:" in kernel-doc
- Converted "Return:" values to lists
- Fixed SPDX license statements

Igor Stoppa (6):
  genalloc: track beginning of allocations
  genalloc: selftest
  struct page: add field for vm_struct
  Protectable Memory
  Pmalloc: self-test
  Documentation for Pmalloc

 Documentation/core-api/index.rst   |   1 +
 Documentation/core-api/pmalloc.rst | 114 +++++++
 include/linux/genalloc-selftest.h  |  26 ++
 include/linux/genalloc.h           |   7 +-
 include/linux/mm_types.h           |   1 +
 include/linux/pmalloc.h            | 242 ++++++++++++++
 include/linux/vmalloc.h            |   1 +
 init/main.c                        |   2 +
 lib/Kconfig                        |  15 +
 lib/Makefile                       |   1 +
 lib/genalloc-selftest.c            | 400 ++++++++++++++++++++++
 lib/genalloc.c                     | 658 +++++++++++++++++++++++++++----------
 mm/Kconfig                         |  15 +
 mm/Makefile                        |   2 +
 mm/pmalloc-selftest.c              |  64 ++++
 mm/pmalloc-selftest.h              |  24 ++
 mm/pmalloc.c                       | 501 ++++++++++++++++++++++++++++
 mm/usercopy.c                      |  33 ++
 mm/vmalloc.c                       |  18 +-
 19 files changed, 1950 insertions(+), 175 deletions(-)
 create mode 100644 Documentation/core-api/pmalloc.rst
 create mode 100644 include/linux/genalloc-selftest.h
 create mode 100644 include/linux/pmalloc.h
 create mode 100644 lib/genalloc-selftest.c
 create mode 100644 mm/pmalloc-selftest.c
 create mode 100644 mm/pmalloc-selftest.h
 create mode 100644 mm/pmalloc.c

-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
