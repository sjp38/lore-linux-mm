Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E92E6B0008
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 13:36:37 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id k21-v6so13506950qtj.23
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 10:36:37 -0700 (PDT)
Received: from a9-112.smtp-out.amazonses.com (a9-112.smtp-out.amazonses.com. [54.240.9.112])
        by mx.google.com with ESMTPS id s187-v6si897563qkb.15.2018.07.31.10.36.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 31 Jul 2018 10:36:36 -0700 (PDT)
Date: Tue, 31 Jul 2018 17:36:36 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4
 13/17] khwasan: add hooks implementation)
In-Reply-To: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
Message-ID: <01000164f169bc6b-c73a8353-d7d9-47ec-a782-90aadcb86bfb-000000@email.amazonses.com>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, David Airlie <airlied@linux.ie>, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, Eric Dumazet <edumazet@google.com>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Ursula Braun <ubraun@linux.ibm.com>, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, 31 Jul 2018, Andrey Ryabinin wrote:

> Guys, it seems that we have a lot of code using SLAB_TYPESAFE_BY_RCU cache without constructor.
> I think it's nearly impossible to use that combination without having bugs.
> It's either you don't really need the SLAB_TYPESAFE_BY_RCU, or you need to have a constructor in kmem_cache.
>
> Could you guys, please, verify your code if it's really need SLAB_TYPSAFE or constructor?
>
> E.g. the netlink code look extremely suspicious:
>
> 	/*
> 	 * Do not use kmem_cache_zalloc(), as this cache uses
> 	 * SLAB_TYPESAFE_BY_RCU.
> 	 */
> 	ct = kmem_cache_alloc(nf_conntrack_cachep, gfp);
> 	if (ct == NULL)
> 		goto out;
>
> 	spin_lock_init(&ct->lock);
>
> If nf_conntrack_cachep objects really used in rcu typesafe manner, than 'ct' returned by kmem_cache_alloc might still be
> in use by another cpu. So we just reinitialize spin_lock used by someone else?

ct may still be read by another cpu in a RCU section but the object was
freed elsewhere so no other processor may modify the object.

The lock must have been released before freeing the slab object and thus
the initialization of the spinlock is unnecessary if it was
initialized in ctor.

If there is refcounting going on then why use SLAB_TYPESAFE_BY_RCU?
