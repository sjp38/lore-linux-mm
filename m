Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 35A686B0006
	for <linux-mm@kvack.org>; Sun,  1 Jul 2018 22:04:32 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id n23-v6so3940995qtl.4
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 19:04:32 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id p15-v6si9011392qve.62.2018.07.01.19.04.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 19:04:31 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v3 0/2] sparse_init rewrite
Date: Sun,  1 Jul 2018 22:04:15 -0400
Message-Id: <20180702020417.21281-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net, pasha.tatashin@oracle.com

Changelog:
v3 - v1
	- Fixed two issues found by Baoquan He
v1 - v2
	- Addressed comments from Oscar Salvador

In sparse_init() we allocate two large buffers to temporary hold usemap and
memmap for the whole machine. However, we can avoid doing that if we
changed sparse_init() to operated on per-node bases instead of doing it on
the whole machine beforehand.

As shown by Baoquan
http://lkml.kernel.org/r/20180628062857.29658-1-bhe@redhat.com

The buffers are large enough to cause machine stop to boot on small memory
systems.

These patches should be applied on top of Baoquan's work, as
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER is removed in that work.

For the ease of review, I split this work so the first patch only adds new
interfaces, the second patch enables them, and removes the old ones.

Pavel Tatashin (2):
  mm/sparse: add sparse_init_nid()
  mm/sparse: start using sparse_init_nid(), and remove old code

 include/linux/mm.h  |   9 +-
 mm/sparse-vmemmap.c |  44 ++++---
 mm/sparse.c         | 279 +++++++++++++++-----------------------------
 3 files changed, 125 insertions(+), 207 deletions(-)

-- 
2.18.0
