Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CA2106B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 17:36:47 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k18-v6so685000wrn.8
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 14:36:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w12-v6sor1732261wrs.4.2018.06.20.14.36.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Jun 2018 14:36:46 -0700 (PDT)
MIME-Version: 1.0
References: <20180619213352.71740-1-shakeelb@google.com> <3f61e143-e7b3-5517-fbaf-d663675f0e96@virtuozzo.com>
In-Reply-To: <3f61e143-e7b3-5517-fbaf-d663675f0e96@virtuozzo.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 20 Jun 2018 14:36:33 -0700
Message-ID: <CALvZod5z8_6KytDdoS26qE1iLVg3yoOT+BUYtxHX2XuN1UKkCg@mail.gmail.com>
Subject: Re: [PATCH] slub: fix __kmem_cache_empty for !CONFIG_SLUB_DEBUG
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: "Jason A . Donenfeld" <Jason@zx2c4.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Wed, Jun 20, 2018 at 5:08 AM Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>
>
>
> On 06/20/2018 12:33 AM, Shakeel Butt wrote:
> > For !CONFIG_SLUB_DEBUG, SLUB does not maintain the number of slabs
> > allocated per node for a kmem_cache. Thus, slabs_node() in
> > __kmem_cache_empty() will always return 0. So, in such situation, it is
> > required to check per-cpu slabs to make sure if a kmem_cache is empty or
> > not.
> >
> > Please note that __kmem_cache_shutdown() and __kmem_cache_shrink() are
> > not affected by !CONFIG_SLUB_DEBUG as they call flush_all() to clear
> > per-cpu slabs.
>
> So what? Yes, they call flush_all() and then check if there are non-empty slabs left.
> And that check doesn't work in case of disabled CONFIG_SLUB_DEBUG.
> How is flush_all() or per-cpu slabs even relevant here?
>

The flush_all() will move all cpu slabs and partials to node's partial
list and thus later check of node's partial list will handle non-empty
slabs situation. However what I missed is the 'full slabs' which are
not on any list for !CONFIG_SLUB_DEBUG. So, this patch is not the
complete solution. I think David's suggestion is the complete
solution. I will post a patch based on David's suggestion.
