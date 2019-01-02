Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 833D58E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 10:51:13 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id w19so39495958qto.13
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 07:51:13 -0800 (PST)
Received: from a9-31.smtp-out.amazonses.com (a9-31.smtp-out.amazonses.com. [54.240.9.31])
        by mx.google.com with ESMTPS id a24si624776qvd.18.2019.01.02.07.51.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 02 Jan 2019 07:51:12 -0800 (PST)
Date: Wed, 2 Jan 2019 15:51:12 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 setup_kmem_cache_node
In-Reply-To: <CACT4Y+ZECp8Ymq=0QUNfwmfpQvWkBpoMgyUCuz0M=peehEeCHw@mail.gmail.com>
Message-ID: <010001680f42f192-82b4e12e-1565-4ee0-ae1f-1e98974906aa-000000@email.amazonses.com>
References: <0000000000000f35c6057e780d36@google.com> <CACT4Y+ZECp8Ymq=0QUNfwmfpQvWkBpoMgyUCuz0M=peehEeCHw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <syzbot+d6ed4ec679652b4fd4e4@syzkaller.appspotmail.com>, Dominique Martinet <asmadeus@codewreck.org>, David Miller <davem@davemloft.net>, Eric Van Hensbergen <ericvh@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Latchesar Ionkov <lucho@ionkov.net>, netdev <netdev@vger.kernel.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, v9fs-developer@lists.sourceforge.net, Linux-MM <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 2 Jan 2019, Dmitry Vyukov wrote:

> Am I missing something or __alloc_alien_cache misses check for
> kmalloc_node result?
>
> static struct alien_cache *__alloc_alien_cache(int node, int entries,
>                                                 int batch, gfp_t gfp)
> {
>         size_t memsize = sizeof(void *) * entries + sizeof(struct alien_cache);
>         struct alien_cache *alc = NULL;
>
>         alc = kmalloc_node(memsize, gfp, node);
>         init_arraycache(&alc->ac, entries, batch);
>         spin_lock_init(&alc->lock);
>         return alc;
> }
>


True _alloc_alien_cache() needs to check for NULL


From: Christoph Lameter <cl@linux.com>
Subject: slab: Alien caches must not be initialized if the allocation of the alien cache failed

Callers of __alloc_alien() check for NULL.
We must do the same check in __alloc_alien_cache to avoid NULL pointer dereferences
on allocation failures.

Signed-off-by: Christoph Lameter <cl@linux.com>


Index: linux/mm/slab.c
===================================================================
--- linux.orig/mm/slab.c
+++ linux/mm/slab.c
@@ -666,8 +666,10 @@ static struct alien_cache *__alloc_alien
 	struct alien_cache *alc = NULL;

 	alc = kmalloc_node(memsize, gfp, node);
-	init_arraycache(&alc->ac, entries, batch);
-	spin_lock_init(&alc->lock);
+	if (alc) {
+		init_arraycache(&alc->ac, entries, batch);
+		spin_lock_init(&alc->lock);
+	}
 	return alc;
 }
