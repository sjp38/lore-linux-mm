Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id A31F96B0003
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 16:04:22 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u74-v6so17800692oie.16
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 13:04:22 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j133-v6si12637818oif.430.2018.08.01.13.04.20
        for <linux-mm@kvack.org>;
        Wed, 01 Aug 2018 13:04:21 -0700 (PDT)
From: Jeremy Linton <jeremy.linton@arm.com>
Subject: [RFC 0/2] harden alloc_pages against bogus nid
Date: Wed,  1 Aug 2018 15:04:16 -0500
Message-Id: <20180801200418.1325826-1-jeremy.linton@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, Punit.Agrawal@arm.com, Lorenzo.Pieralisi@arm.com, linux-arm-kernel@lists.infradead.org, bhelgaas@google.com, linux-kernel@vger.kernel.org, Jeremy Linton <jeremy.linton@arm.com>

The thread "avoid alloc memory on offline node"

https://lkml.org/lkml/2018/6/7/251

Asked at one point why the kzalloc_node was crashing rather than
returning memory from a valid node. The thread ended up fixing
the immediate causes of the crash but left open the case of bad
proximity values being in DSDT tables without corrisponding
SRAT/SLIT entries as is happening on another machine.

Its also easy to fix that, but we should also harden the allocator
sufficiently that it doesn't crash when passed an invalid node id.
There are a couple possible ways to do this, and i've attached two
separate patches which individually fix that problem.

The first detects the offline node before calling
the new_slab code path when it becomes apparent that the allocation isn't
going to succeed. The second actually hardens node_zonelist() and
prepare_alloc_pages() in the face of NODE_DATA(nid) returning a NULL
zonelist. This latter case happens if the node has never been initialized
or is possibly out of range. There are other places (NODE_DATA &
online_node) which should be checking if the node id's are > MAX_NUMNODES.

Jeremy Linton (2):
  slub: Avoid trying to allocate memory on offline nodes
  mm: harden alloc_pages code paths against bogus nodes

 include/linux/gfp.h | 2 ++
 mm/page_alloc.c     | 2 ++
 mm/slub.c           | 2 ++
 3 files changed, 6 insertions(+)

-- 
2.14.3
