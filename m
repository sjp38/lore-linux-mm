Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id A77ED6B0088
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 09:52:28 -0400 (EDT)
Received: by mail-qg0-f50.google.com with SMTP id z60so8735861qgd.23
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 06:52:28 -0700 (PDT)
Received: from qmta05.emeryville.ca.mail.comcast.net (qmta05.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:48])
        by mx.google.com with ESMTP id a1si23712455qab.72.2014.06.09.06.52.27
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 06:52:27 -0700 (PDT)
Date: Mon, 9 Jun 2014 08:52:24 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH -mm v2 5/8] slub: make slab_free non-preemptable
In-Reply-To: <20140609125211.GA32192@esperanza>
Message-ID: <alpine.DEB.2.10.1406090850070.22191@gentwo.org>
References: <cover.1402060096.git.vdavydov@parallels.com> <7cd6784a36ed997cc6631615d98e11e02e811b1b.1402060096.git.vdavydov@parallels.com> <alpine.DEB.2.10.1406060942160.32229@gentwo.org> <20140609125211.GA32192@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 9 Jun 2014, Vladimir Davydov wrote:

> The whole function (unfreeze_partials) is currently called with irqs
> off, so this is effectively a no-op. I guess we can restore irqs here
> though.

We could move the local_irq_save from put_cpu_partial() into
unfreeze_partials().

> If we just freed the last slab of the cache and then get preempted
> (suppose we restored irqs above), nothing will prevent the cache from
> destruction, which may result in use-after-free below. We need to be
> more cautious if we want to call for page allocator with preemption and
> irqs on.

Hmmm. Ok.
>
> However, I still don't understand what's the point in it. We *already*
> call discard_slab with irqs disabled, which is harder, and it haven't
> caused any problems AFAIK. Moreover, even if we enabled preemption/irqs,
> it wouldn't guarantee that discard_slab would always be called with
> preemption/irqs on, because the whole function - I mean kmem_cache_free
> - can be called with preemption/irqs disabled.
>
> So my point it would only complicate the code.

Ok.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
