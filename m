Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6ED8A6B0010
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 17:51:19 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l2-v6so1632664pff.3
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 14:51:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b1-v6sor1294928pgb.171.2018.06.27.14.51.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Jun 2018 14:51:18 -0700 (PDT)
Subject: Re: [RFC PATCH] net, mm: account sock objects to kmemcg
References: <20180627204139.225988-1-shakeelb@google.com>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <f08b2e2c-d4c6-7a80-10d9-104c0aab593b@gmail.com>
Date: Wed, 27 Jun 2018 14:51:15 -0700
MIME-Version: 1.0
In-Reply-To: <20180627204139.225988-1-shakeelb@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Roman Gushchin <guro@fb.com>, "David S . Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org



On 06/27/2018 01:41 PM, Shakeel Butt wrote:
> Currently the kernel accounts the memory for network traffic through
> mem_cgroup_[un]charge_skmem() interface. However the memory accounted
> only includes the truesize of sk_buff which does not include the size of
> sock objects. In our production environment, with opt-out kmem
> accounting, the sock kmem caches (TCP[v6], UDP[v6], RAW[v6], UNIX) are
> among the top most charged kmem caches and consume a significant amount
> of memory which can not be left as system overhead. So, this patch
> converts the kmem caches of more important sock objects to SLAB_ACCOUNT.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---
>  net/ipv4/raw.c      | 1 +
>  net/ipv4/tcp_ipv4.c | 2 +-
>  net/ipv4/udp.c      | 1 +
>  net/ipv6/raw.c      | 1 +
>  net/ipv6/tcp_ipv6.c | 2 +-
>  net/ipv6/udp.c      | 1 +
>  net/unix/af_unix.c  | 1 +
>  7 files changed, 7 insertions(+), 2 deletions(-)


Hey, you just disclosed we do not use DCCP ;)

Joke aside, what about simply factorizing this stuff ?

diff --git a/net/core/sock.c b/net/core/sock.c
index bcc41829a16d50714bdd3c25c976c0b7296fab84..b6714f8d7e9ba313723a6f619799c56230ff5fd4 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -3243,7 +3243,8 @@ static int req_prot_init(const struct proto *prot)
 
        rsk_prot->slab = kmem_cache_create(rsk_prot->slab_name,
                                           rsk_prot->obj_size, 0,
-                                          prot->slab_flags, NULL);
+                                          SLAB_ACCOUNT | prot->slab_flags,
+                                          NULL);
 
        if (!rsk_prot->slab) {
                pr_crit("%s: Can't create request sock SLAB cache!\n",
@@ -3258,7 +3259,8 @@ int proto_register(struct proto *prot, int alloc_slab)
        if (alloc_slab) {
                prot->slab = kmem_cache_create_usercopy(prot->name,
                                        prot->obj_size, 0,
-                                       SLAB_HWCACHE_ALIGN | prot->slab_flags,
+                                       SLAB_HWCACHE_ALIGN | SLAB_ACCOUNT |
+                                       prot->slab_flags,
                                        prot->useroffset, prot->usersize,
                                        NULL);
 
