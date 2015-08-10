Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id DEAB56B0255
	for <linux-mm@kvack.org>; Sun,  9 Aug 2015 20:48:36 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so93820758pab.0
        for <linux-mm@kvack.org>; Sun, 09 Aug 2015 17:48:36 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id bp6si30283482pac.217.2015.08.09.17.48.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Aug 2015 17:48:36 -0700 (PDT)
Received: by pawu10 with SMTP id u10so127494261paw.1
        for <linux-mm@kvack.org>; Sun, 09 Aug 2015 17:48:35 -0700 (PDT)
Date: Mon, 10 Aug 2015 09:49:12 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 2/3] zswap: dynamic pool creation
Message-ID: <20150810004912.GB645@swordfish>
References: <1438782403-29496-1-git-send-email-ddstreet@ieee.org>
 <1438782403-29496-3-git-send-email-ddstreet@ieee.org>
 <20150807063056.GG1891@swordfish>
 <CALZtONATwf7EbWo1RhoNzeYnacCk6A__9Jrtr4UZvV9W-seX7g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONATwf7EbWo1RhoNzeYnacCk6A__9Jrtr4UZvV9W-seX7g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Hello,

On (08/07/15 10:24), Dan Streetman wrote:
> > On (08/05/15 09:46), Dan Streetman wrote:
> > [..]
> >> -enum comp_op {
> >> -     ZSWAP_COMPOP_COMPRESS,
> >> -     ZSWAP_COMPOP_DECOMPRESS
> >> +struct zswap_pool {
> >> +     struct zpool *zpool;
> >> +     struct kref kref;
> >> +     struct list_head list;
> >> +     struct rcu_head rcu_head;
> >> +     struct notifier_block notifier;
> >> +     char tfm_name[CRYPTO_MAX_ALG_NAME];
> >
> > do you need to keep a second CRYPTO_MAX_ALG_NAME copy? shouldn't it
> > be `tfm->__crt_alg->cra_name`, which is what
> >         crypto_tfm_alg_name(struct crypto_tfm *tfm)
> > does?
> 
> well, we don't absolutely have to keep a copy of tfm_name.  However,
> ->tfm is a __percpu variable, so each time we want to check the pool's
> tfm name, we would need to do:
> crypto_comp_name(this_cpu_ptr(pool->tfm))
> 
> nothing wrong with that really, just adds a bit more code each time we
> want to check the tfm name.  I'll send a patch to change it.
> 
> >
> >> +     struct crypto_comp * __percpu *tfm;
> >>  };
> >
> > ->tfm will be access pretty often, right? did you intentionally put it
> > at the bottom offset of `struct zswap_pool'?
> 
> no it wasn't intentional; does moving it up provide a benefit?

well, I just prefer to keep 'read mostly' pointers together. all
those cache lines, etc.

gcc 5.1, x86_64

 struct zswap_pool {
        struct zpool *zpool;
+       struct crypto_comp * __percpu *tfm;
        struct kref kref;
        struct list_head list;
        struct rcu_head rcu_head;
        struct notifier_block notifier;
        char tfm_name[CRYPTO_MAX_ALG_NAME];
-       struct crypto_comp * __percpu *tfm;
 };

../scripts/bloat-o-meter zswap.o.old zswap.o
add/remove: 0/0 grow/shrink: 0/6 up/down: 0/-27 (-27)
function                                     old     new   delta
zswap_writeback_entry                        659     656      -3
zswap_frontswap_store                       1445    1442      -3
zswap_frontswap_load                         417     414      -3
zswap_pool_create                            438     432      -6
__zswap_cpu_comp_notifier.part               152     146      -6
__zswap_cpu_comp_notifier                    122     116      -6


you know it better ;-)


[..]
> > this one seems to be used only once. do you want to replace
> > that single usage (well, if it's really needed)
> 
> it's actually used twice, in __zswap_pool_empty() and
> __zswap_param_set().  The next patch adds __zswap_param_set().

Aha, sorry, didn't read the next patch in advance.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
