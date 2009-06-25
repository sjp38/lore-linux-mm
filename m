Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5F28A6B004F
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 06:02:57 -0400 (EDT)
Subject: [PATCH v3 10/10] nf_conntrack: Use rcu_barrier()
From: Jesper Dangaard Brouer <jdb@comx.dk>
Reply-To: jdb@comx.dk
In-Reply-To: <1245922153.24921.56.camel@localhost.localdomain>
References: <20090623150330.22490.87327.stgit@localhost>
	 <20090623150444.22490.27931.stgit@localhost>  <4A410185.3090706@trash.net>
	 <1245834139.6695.31.camel@localhost.localdomain>
	 <1245836409.6695.35.camel@localhost.localdomain> <4A423108.60109@trash.net>
	 <1245922153.24921.56.camel@localhost.localdomain>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Thu, 25 Jun 2009 12:02:58 +0200
Message-Id: <1245924178.24921.61.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Patrick McHardy <kaber@trash.net>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, dougthompson@xmission.com, bluesmoke-devel@lists.sourceforge.net, axboe@kernel.dk, christine.caulfield@googlemail.com, Trond.Myklebust@netapp.com, linux-wireless@vger.kernel.org, johannes@sipsolutions.net, yoshfuji@linux-ipv6.org, shemminger@linux-foundation.org, linux-nfs@vger.kernel.org, bfields@fieldses.org, neilb@suse.de, linux-ext4@vger.kernel.org, tytso@mit.edu, adilger@sun.com, netfilter-devel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2009-06-25 at 11:29 +0200, Jesper Dangaard Brouer wrote:
> Should I make two different patchs?

Here is the single patch... Patrick tell me if you want it split up?


[PATCH v3 10/10] nf_conntrack: Use rcu_barrier()

From: Jesper Dangaard Brouer <hawk@comx.dk>

RCU barriers, rcu_barrier(), is inserted two places.

 In nf_conntrack_expect.c nf_conntrack_expect_fini() before the
 kmem_cache_destroy().  Firstly to make sure the callback to the
 nf_ct_expect_free_rcu() code is still around.  Secondly because I'm
 unsure about the consequence of having in flight
 nf_ct_expect_free_rcu/kmem_cache_free() calls while doing a
 kmem_cache_destroy() slab destroy.

 And in nf_conntrack_extend.c nf_ct_extend_unregister(), inorder to
 wait for completion of callbacks to __nf_ct_ext_free_rcu(), which is
 invoked by __nf_ct_ext_add().  It might be more efficient to call
 rcu_barrier() in nf_conntrack_core.c nf_conntrack_cleanup_net(), but
 thats make it more difficult to read the code (as the callback code
 in located in nf_conntrack_extend.c).

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 net/netfilter/nf_conntrack_expect.c |    4 +++-
 net/netfilter/nf_conntrack_extend.c |    2 +-
 2 files changed, 4 insertions(+), 2 deletions(-)


diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index afde8f9..2032dfe 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -617,8 +617,10 @@ err1:
 void nf_conntrack_expect_fini(struct net *net)
 {
 	exp_proc_remove(net);
-	if (net_eq(net, &init_net))
+	if (net_eq(net, &init_net)) {
+		rcu_barrier(); /* Wait for call_rcu() before destroy */
 		kmem_cache_destroy(nf_ct_expect_cachep);
+	}
 	nf_ct_free_hashtable(net->ct.expect_hash, net->ct.expect_vmalloc,
 			     nf_ct_expect_hsize);
 }
diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
index 4b2c769..fef95be 100644
--- a/net/netfilter/nf_conntrack_extend.c
+++ b/net/netfilter/nf_conntrack_extend.c
@@ -186,6 +186,6 @@ void nf_ct_extend_unregister(struct nf_ct_ext_type *type)
 	rcu_assign_pointer(nf_ct_ext_types[type->id], NULL);
 	update_alloc_size(type);
 	mutex_unlock(&nf_ct_ext_type_mutex);
-	synchronize_rcu();
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 EXPORT_SYMBOL_GPL(nf_ct_extend_unregister);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
