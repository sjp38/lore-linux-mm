Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 53AD76B00D1
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 10:27:36 -0500 (EST)
Date: Tue, 17 Jan 2012 09:27:31 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Hung task when calling clone() due to netfilter/slab
In-Reply-To: <1326813630.2259.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Message-ID: <alpine.DEB.2.00.1201170927020.4800@router.home>
References: <1326558605.19951.7.camel@lappy>   <1326561043.5287.24.camel@edumazet-laptop>  <1326632384.11711.3.camel@lappy> <1326648305.5287.78.camel@edumazet-laptop>  <alpine.DEB.2.00.1201170910130.4800@router.home>
 <1326813630.2259.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, Dave Jones <davej@redhat.com>, davem <davem@davemloft.net>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, kaber@trash.net, pablo@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>

On Tue, 17 Jan 2012, Eric Dumazet wrote:

> Buggy patch, since "goto err;" is going to up_write(&slub_lock) again.
>
> Also Christoph, you forgot to add the very much needed :
>
> Reported-by: Sasha Levin <levinsasha928@gmail.com>


Subject: slub: Do not hold slub_lock when calling sysfs_slab_add()

sysfs_slab_add() calls various sysfs functions that actually may
end up in userspace doing all sorts of things.

Release the slub_lock after adding the kmem_cache structure to the list.
At that point the address of the kmem_cache is not known so we are
guaranteed exlusive access to the following modifications to the
kmem_cache structure.

If the sysfs_slab_add fails then reacquire the slub_lock to
remove the kmem_cache structure from the list.

Reported-by: Sasha Levin <levinsasha928@gmail.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2012-01-17 03:07:11.140010438 -0600
+++ linux-2.6/mm/slub.c	2012-01-17 03:26:06.799986908 -0600
@@ -3929,13 +3929,14 @@ struct kmem_cache *kmem_cache_create(con
 		if (kmem_cache_open(s, n,
 				size, align, flags, ctor)) {
 			list_add(&s->list, &slab_caches);
+			up_write(&slub_lock);
 			if (sysfs_slab_add(s)) {
+				down_write(&slub_lock);
 				list_del(&s->list);
 				kfree(n);
 				kfree(s);
 				goto err;
 			}
-			up_write(&slub_lock);
 			return s;
 		}
 		kfree(n);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
