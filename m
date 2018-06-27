Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9475F6B000A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 18:16:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j25-v6so1649849pfi.20
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 15:16:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b35-v6sor1665532plh.58.2018.06.27.15.16.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Jun 2018 15:16:58 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH v2] net, mm: account sock objects to kmemcg
Date: Wed, 27 Jun 2018 15:16:42 -0700
Message-Id: <20180627221642.247448-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Roman Gushchin <guro@fb.com>, "David S . Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, Shakeel Butt <shakeelb@google.com>

Currently the kernel accounts the memory for network traffic through
mem_cgroup_[un]charge_skmem() interface. However the memory accounted
only includes the truesize of sk_buff which does not include the size of
sock objects. In our production environment, with opt-out kmem
accounting, the sock kmem caches (TCP[v6], UDP[v6], RAW[v6], UNIX) are
among the top most charged kmem caches and consume a significant amount
of memory which can not be left as system overhead. So, this patch
converts the kmem caches of all sock objects to SLAB_ACCOUNT.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
Suggested-by: Eric Dumazet <edumazet@google.com>
---
Changelog since v1:
- Instead of specific sock kmem_caches, convert all sock kmem_caches to
  use SLAB_ACCOUNT.

 net/core/sock.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index bcc41829a16d..9e8f65585b81 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -3243,7 +3243,8 @@ static int req_prot_init(const struct proto *prot)
 
 	rsk_prot->slab = kmem_cache_create(rsk_prot->slab_name,
 					   rsk_prot->obj_size, 0,
-					   prot->slab_flags, NULL);
+					   SLAB_ACCOUNT | prot->slab_flags,
+					   NULL);
 
 	if (!rsk_prot->slab) {
 		pr_crit("%s: Can't create request sock SLAB cache!\n",
@@ -3258,7 +3259,8 @@ int proto_register(struct proto *prot, int alloc_slab)
 	if (alloc_slab) {
 		prot->slab = kmem_cache_create_usercopy(prot->name,
 					prot->obj_size, 0,
-					SLAB_HWCACHE_ALIGN | prot->slab_flags,
+					SLAB_HWCACHE_ALIGN | SLAB_ACCOUNT |
+					prot->slab_flags,
 					prot->useroffset, prot->usersize,
 					NULL);
 
@@ -3281,6 +3283,7 @@ int proto_register(struct proto *prot, int alloc_slab)
 				kmem_cache_create(prot->twsk_prot->twsk_slab_name,
 						  prot->twsk_prot->twsk_obj_size,
 						  0,
+						  SLAB_ACCOUNT |
 						  prot->slab_flags,
 						  NULL);
 			if (prot->twsk_prot->twsk_slab == NULL)
-- 
2.18.0.rc2.346.g013aa6912e-goog
