Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2BE576B0005
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 15:11:59 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id c18so2309429pgv.8
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 12:11:59 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l10si380754pgf.460.2018.02.14.12.11.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Feb 2018 12:11:57 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v2 0/8] Add kvzalloc_struct to complement kvzalloc_array
Date: Wed, 14 Feb 2018 12:11:46 -0800
Message-Id: <20180214201154.10186-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Joe Perches <joe@perches.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

We all know the perils of multiplying a value provided from userspace
by a constant and then allocating the resulting number of bytes.  That's
why we have kvmalloc_array(), so we don't have to think about it.
This solves the same problem when we embed one of these arrays in a
struct like this:

struct {
        int n;
        unsigned long array[];
};

Using kvzalloc_struct() to allocate this will save precious thinking
time and reduce the possibilities of bugs.

v2: Minor fixes pointed out by Kees
    Added sample conversions

I added a few more sample conversions for demonstration purposes, and
one thing I noticed is that the kvmalloc family of functions live in
<linux/mm.h> which (contrary to popular belief) is not already
automatically included everywhere.

Should they be moved to slab.h to be with kmalloc, a new file
(malloc.h? kvmalloc.h?), or even kernel.h?

Matthew Wilcox (8):
  mm: Add kernel-doc for kvfree
  mm: Add kvmalloc_ab_c and kvzalloc_struct
  Convert virtio_console to kvzalloc_struct
  Convert dax device to kvzalloc_struct
  Convert infiniband uverbs to kvzalloc_struct
  Convert v4l2 event to kvzalloc_struct
  Convert vhost to kvzalloc_struct
  Convert jffs2 acl to kvzalloc_struct

 drivers/char/virtio_console.c        |  3 +--
 drivers/dax/device.c                 |  2 +-
 drivers/infiniband/core/uverbs_cmd.c |  4 +--
 drivers/media/v4l2-core/v4l2-event.c |  3 +--
 drivers/vhost/vhost.c                |  2 +-
 fs/jffs2/acl.c                       |  3 ++-
 fs/jffs2/acl.h                       |  1 +
 include/linux/mm.h                   | 51 ++++++++++++++++++++++++++++++++++++
 include/rdma/ib_verbs.h              |  5 +---
 mm/util.c                            | 10 +++++++
 10 files changed, 71 insertions(+), 13 deletions(-)

-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
