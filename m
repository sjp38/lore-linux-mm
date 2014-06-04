Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 090796B0031
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 05:47:54 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id q8so4116061lbi.40
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 02:47:54 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id m3si4512633lba.41.2014.06.04.02.47.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jun 2014 02:47:53 -0700 (PDT)
Date: Wed, 4 Jun 2014 13:47:33 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 7/8] slub: make dead caches discard free slabs
 immediately
Message-ID: <20140604094730.GH6013@esperanza>
References: <cover.1401457502.git.vdavydov@parallels.com>
 <5d2fbc894a2c62597e7196bb1ebb8357b15529ab.1401457502.git.vdavydov@parallels.com>
 <alpine.DEB.2.10.1405300955120.11943@gentwo.org>
 <20140531110456.GC25076@esperanza>
 <20140602042435.GA17964@js1304-P5Q-DELUXE>
 <20140602114741.GA1039@esperanza>
 <CAAmzW4P=kUAJwozBPPos+uUewzSDnE43P6NcGYKNpBjjfv1EWA@mail.gmail.com>
 <20140603081655.GA6013@esperanza>
 <CAAmzW4O-tAw9t=gEHhbKiG+vfDsuCsOB1dyB_2iwO1qeFjtYmQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAAmzW4O-tAw9t=gEHhbKiG+vfDsuCsOB1dyB_2iwO1qeFjtYmQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@gentwo.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Jun 04, 2014 at 05:53:29PM +0900, Joonsoo Kim wrote:
> Consider __slab_free(). After put_cpu_partial() in __slab_free() is called,
> we attempt to update stat. There is possibility that this operation could be
> use-after-free with your solution. Until now, we have just stat operation, but
> it could be more. I don't like to impose this constraint to the slab free path.

We can move stats update before object free I guess, but I admit this is
not going to be a flexible solution, because every future modifications
to slab_free should be done with great care then, otherwise it may break
things.

> So IMHO, it is better that we should defer to destroy kmem_cache
> until last kfree() caller returns. Is it fair enough? :)

Actually, I was thinking about it (even discussed with Christoph), but
the problem is that there is currently no way to wait for all currently
executing kfree's to complete, because SLUB's version can be preempted
at any time.

One way to solve this is to make slab_free non-preemptable and call
synchronize_sched before kmem_cache_destroy (or use call_rcu_sched).
When I started to implement this approach I found the resulting code a
bit ugly. Also, Christoph had some concerns about it (see
https://lkml.org/lkml/2014/5/23/524). That's why I tried to go with this
patch set first, but that doesn't mean that I'm 100% sure in it :-) I'll
send the implementations of the other approach (with prempt_disable)
soon.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
