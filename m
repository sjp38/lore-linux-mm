Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1DCE46B000D
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 02:30:44 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p9-v6so1529324wrm.22
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 23:30:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h3-v6sor1405312wmb.78.2018.06.20.23.30.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Jun 2018 23:30:42 -0700 (PDT)
MIME-Version: 1.0
References: <20180620224147.23777-1-shakeelb@google.com> <010001641fe92599-9006a895-d1ea-4881-a63c-f3749ff9b7b3-000000@email.amazonses.com>
In-Reply-To: <010001641fe92599-9006a895-d1ea-4881-a63c-f3749ff9b7b3-000000@email.amazonses.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 20 Jun 2018 23:30:29 -0700
Message-ID: <CALvZod7fgFYDY7nqE2S4a78TqoX19MC66YTFFrWqqR0h9F8iPA@mail.gmail.com>
Subject: Re: [PATCH] slub: track number of slabs irrespective of CONFIG_SLUB_DEBUG
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Jason A . Donenfeld" <Jason@zx2c4.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org

On Wed, Jun 20, 2018 at 6:15 PM Christopher Lameter <cl@linux.com> wrote:
>
> On Wed, 20 Jun 2018, Shakeel Butt wrote:
>
> > For !CONFIG_SLUB_DEBUG, SLUB does not maintain the number of slabs
> > allocated per node for a kmem_cache. Thus, slabs_node() in
> > __kmem_cache_empty(), __kmem_cache_shrink() and __kmem_cache_destroy()
> > will always return 0 for such config. This is wrong and can cause issues
> > for all users of these functions.
>
>
> CONFIG_SLUB_DEBUG is set by default on almost all builds. The only case
> where CONFIG_SLUB_DEBUG is switched off is when we absolutely need to use
> the minimum amount of memory (embedded or some such thing).
>
> > The right solution is to make slabs_node() work even for
> > !CONFIG_SLUB_DEBUG. The commit 0f389ec63077 ("slub: No need for per node
> > slab counters if !SLUB_DEBUG") had put the per node slab counter under
> > CONFIG_SLUB_DEBUG because it was only read through sysfs API and the
> > sysfs API was disabled on !CONFIG_SLUB_DEBUG. However the users of the
> > per node slab counter assumed that it will work in the absence of
> > CONFIG_SLUB_DEBUG. So, make the counter work for !CONFIG_SLUB_DEBUG.
>
> Please do not do this. Find a way to avoid these checks. The
> objective of a !CONFIG_SLUB_DEBUG configuration is to not compile in
> debuggin checks etc etc in order to reduce the code/data footprint to the
> minimum necessary while sacrificing debuggability etc etc.
>
> Maybe make it impossible to disable CONFIG_SLUB_DEBUG if CGROUPs are in
> use?
>

Copying from the other thread:

On Wed, Jun 20, 2018 at 6:22 PM Jason A. Donenfeld <Jason@zx2c4.com> wrote:
>
> On Thu, Jun 21, 2018 at 3:20 AM Christopher Lameter <cl@linux.com> wrote:
> >
> > NAK. Its easier to simply not allow !CONFIG_SLUB_DEBUG for cgroups based
> > configs because in that case you certainly have enough memory to include
> > the runtime debug code as well as the extended counters.
> >
>
> FWIW, I ran into issues with a combination of KASAN+CONFIG_SLUB
> without having CONFIG_SLUB_DEBUG, because KASAN was using functions
> that were broken without CONFIG_SLUB_DEBUG, so while you're at it with
> creating dependencies, you might want to also say KASAN+CONFIG_SLUB
> ==> CONFIG_SLUB_DEBUG.

KASAN is the only user of __kmem_cache_empty(). So, enforcing
KASAN+CONFIG_SLUB => CONFIG_SLUB_DEBUG makes sense but not sure about
cgroups or memcg. Though is it ok let __kmem_cache_shrink() &
__kmem_cache_shutdown() be broken for !CONFIG_SLUB_DEBUG?

For __kmem_cache_shutdown(), I can understand that shutting down a
kmem_cache when there are still objects allocated from it, is broken
and wrong. For __kmem_cache_shrink(), maybe wrong answer from it is
tolerable.

Shakeel
