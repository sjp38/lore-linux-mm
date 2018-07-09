Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 667496B0310
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 13:53:30 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id 17-v6so1142661qkz.15
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 10:53:30 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id m188-v6si389760qkd.89.2018.07.09.10.53.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 10:53:29 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v4 0/3] sparse_init rewrite
Date: Mon,  9 Jul 2018 13:53:09 -0400
Message-Id: <20180709175312.11155-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net, pasha.tatashin@oracle.com

Changelog:
v4 - v3
	- Addressed comments from Dave Hansen
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

Pavel Tatashin (3):
  mm/sparse: add sparse_init_nid()
  mm/sparse: start using sparse_init_nid(), and remove old code
  mm/sparse: refactor sparse vmemmap buffer allocations

 include/linux/mm.h  |  13 +-
 mm/sparse-vmemmap.c | 111 ++++++++++-------
 mm/sparse.c         | 281 +++++++++++++++-----------------------------
 3 files changed, 170 insertions(+), 235 deletions(-)

-- 
2.18.0
