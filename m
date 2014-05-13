Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6FB536B0039
	for <linux-mm@kvack.org>; Tue, 13 May 2014 09:48:59 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id p9so293621lbv.7
        for <linux-mm@kvack.org>; Tue, 13 May 2014 06:48:58 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id v20si4153854laz.84.2014.05.13.06.48.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 May 2014 06:48:57 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 0/3] kmemcg slab reparenting
Date: Tue, 13 May 2014 17:48:50 +0400
Message-ID: <cover.1399982635.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz, cl@linux-foundation.org
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Johannes, Michal, Christoph,

Recently I posted my thoughts on how we can handle kmem caches of dead
memcgs:

https://lkml.org/lkml/2014/4/20/38

The only feedback I got then was from Johannes who voted for migrating
slabs of such caches to the parent memcg's cache (so called
reparenting), so in this RFC I'd like to propose a draft of possible
implementation of slab reparenting. I'd appreciate if you could look
through it and post if it's worth developing in this direction or not.

The implementation of reparenting is given in patch 3, which is the most
important part of this set. Patch 1 just makes slub keep full slabs on
list, and patch 2 a bit extends percpu-refcnt interface.

NOTE the implementation is given only for slub, though it should be easy
to implement the same hack for slab.

Thanks,

Vladimir Davydov (3):
  slub: keep full slabs on list for per memcg caches
  percpu-refcount: allow to get dead reference
  slub: reparent memcg caches' slabs on memcg offline

 include/linux/memcontrol.h      |    4 +-
 include/linux/percpu-refcount.h |   11 +-
 include/linux/slab.h            |    7 +-
 mm/memcontrol.c                 |   54 ++++---
 mm/slab.h                       |    7 +-
 mm/slub.c                       |  299 ++++++++++++++++++++++++++++++++++-----
 6 files changed, 318 insertions(+), 64 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
