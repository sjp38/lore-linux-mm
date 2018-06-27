Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A35C36B0269
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 18:03:49 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id t139-v6so3269208wmt.6
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 15:03:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b9-v6sor2594605wrj.27.2018.06.27.15.03.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Jun 2018 15:03:48 -0700 (PDT)
MIME-Version: 1.0
References: <20180627204139.225988-1-shakeelb@google.com> <f08b2e2c-d4c6-7a80-10d9-104c0aab593b@gmail.com>
In-Reply-To: <f08b2e2c-d4c6-7a80-10d9-104c0aab593b@gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 27 Jun 2018 15:03:35 -0700
Message-ID: <CALvZod4JTY8T19L-q+E1LLFVGFso6ea1MACKdFsed8dM-3AvYQ@mail.gmail.com>
Subject: Re: [RFC PATCH] net, mm: account sock objects to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: eric.dumazet@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Roman Gushchin <guro@fb.com>, davem@davemloft.net, Eric Dumazet <edumazet@google.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org, Linux MM <linux-mm@kvack.org>

On Wed, Jun 27, 2018 at 2:51 PM Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>
>
> On 06/27/2018 01:41 PM, Shakeel Butt wrote:
> > Currently the kernel accounts the memory for network traffic through
> > mem_cgroup_[un]charge_skmem() interface. However the memory accounted
> > only includes the truesize of sk_buff which does not include the size of
> > sock objects. In our production environment, with opt-out kmem
> > accounting, the sock kmem caches (TCP[v6], UDP[v6], RAW[v6], UNIX) are
> > among the top most charged kmem caches and consume a significant amount
> > of memory which can not be left as system overhead. So, this patch
> > converts the kmem caches of more important sock objects to SLAB_ACCOUNT.
> >
> > Signed-off-by: Shakeel Butt <shakeelb@google.com>
> > ---
> >  net/ipv4/raw.c      | 1 +
> >  net/ipv4/tcp_ipv4.c | 2 +-
> >  net/ipv4/udp.c      | 1 +
> >  net/ipv6/raw.c      | 1 +
> >  net/ipv6/tcp_ipv6.c | 2 +-
> >  net/ipv6/udp.c      | 1 +
> >  net/unix/af_unix.c  | 1 +
> >  7 files changed, 7 insertions(+), 2 deletions(-)
>
>
> Hey, you just disclosed we do not use DCCP ;)
>

Oops.

>
> Joke aside, what about simply factorizing this stuff ?
>

This will opt-in all the sock kmem_caches which I think is better and
much smaller change. Should I resend this or do you want to send the
patch?

> diff --git a/net/core/sock.c b/net/core/sock.c
> index bcc41829a16d50714bdd3c25c976c0b7296fab84..b6714f8d7e9ba313723a6f619799c56230ff5fd4 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -3243,7 +3243,8 @@ static int req_prot_init(const struct proto *prot)
>
>         rsk_prot->slab = kmem_cache_create(rsk_prot->slab_name,
>                                            rsk_prot->obj_size, 0,
> -                                          prot->slab_flags, NULL);
> +                                          SLAB_ACCOUNT | prot->slab_flags,
> +                                          NULL);
>
>         if (!rsk_prot->slab) {
>                 pr_crit("%s: Can't create request sock SLAB cache!\n",
> @@ -3258,7 +3259,8 @@ int proto_register(struct proto *prot, int alloc_slab)
>         if (alloc_slab) {
>                 prot->slab = kmem_cache_create_usercopy(prot->name,
>                                         prot->obj_size, 0,
> -                                       SLAB_HWCACHE_ALIGN | prot->slab_flags,
> +                                       SLAB_HWCACHE_ALIGN | SLAB_ACCOUNT |
> +                                       prot->slab_flags,
>                                         prot->useroffset, prot->usersize,
>                                         NULL);
>
>

Shakeel
