Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 922E86B0007
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 13:01:36 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id l23-v6so13661950qtp.1
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 10:01:36 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0135.outbound.protection.outlook.com. [104.47.1.135])
        by mx.google.com with ESMTPS id u62-v6si8109451qkb.403.2018.07.31.10.01.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 31 Jul 2018 10:01:35 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4 13/17]
 khwasan: add hooks implementation)
Message-ID: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
Date: Tue, 31 Jul 2018 20:01:30 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, "David S. Miller" <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, David Airlie <airlied@linux.ie>, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, Eric Dumazet <edumazet@google.com>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Ursula Braun <ubraun@linux.ibm.com>, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Linus Torvalds <torvalds@linux-foundation.org>


On 07/31/2018 07:04 PM, Andrey Ryabinin wrote:
>> Somewhat offtopic, but I can't understand how SLAB_TYPESAFE_BY_RCU
>> slabs can be useful without ctors or at least memset(0). Objects in
>> such slabs need to be type-stable, but I can't understand how it's
>> possible to establish type stability without a ctor... Are these bugs?
> 
> Yeah, I puzzled by this too. However, I think it's hard but possible to make it work, at least in theory.
> There must be an initializer, which consists of two parts:
> a) initilize objects fields
> b) expose object to the world (add it to list or something like that)
> 
> (a) part must somehow to be ok to race with another cpu which might already use the object.
> (b) part must must use e.g. barriers to make sure that racy users will see previously inilized fields.
> Racy users must have parring barrier of course.
> 
> But it sound fishy, and very easy to fuck up. I won't be surprised if every single one SLAB_TYPESAFE_BY_RCU user
> without ->ctor is bogus. It certainly would be better to convert those to use ->ctor.
> 
> Such caches seems used by networking subsystem in proto_register():
> 
> 		prot->slab = kmem_cache_create_usercopy(prot->name,
> 					prot->obj_size, 0,
> 					SLAB_HWCACHE_ALIGN | SLAB_ACCOUNT |
> 					prot->slab_flags,
> 					prot->useroffset, prot->usersize,
> 					NULL);
> 
> And certain protocols specify SLAB_TYPESAFE_BY_RCU in ->slab_flags, such as:
> llc_proto, smc_proto, smc_proto6, tcp_prot, tcpv6_prot, dccp_v6_prot, dccp_v4_prot.
> 
> 
> Also nf_conntrack_cachep, kernfs_node_cache, jbd2_journal_head_cache and i915_request cache.
> 


[+CC maintainer of the relevant code.]

Guys, it seems that we have a lot of code using SLAB_TYPESAFE_BY_RCU cache without constructor.
I think it's nearly impossible to use that combination without having bugs.
It's either you don't really need the SLAB_TYPESAFE_BY_RCU, or you need to have a constructor in kmem_cache.

Could you guys, please, verify your code if it's really need SLAB_TYPSAFE or constructor?

E.g. the netlink code look extremely suspicious:

	/*
	 * Do not use kmem_cache_zalloc(), as this cache uses
	 * SLAB_TYPESAFE_BY_RCU.
	 */
	ct = kmem_cache_alloc(nf_conntrack_cachep, gfp);
	if (ct == NULL)
		goto out;

	spin_lock_init(&ct->lock);

If nf_conntrack_cachep objects really used in rcu typesafe manner, than 'ct' returned by kmem_cache_alloc might still be
in use by another cpu. So we just reinitialize spin_lock used by someone else?
