Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AB6F66B0055
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 05:28:23 -0400 (EDT)
Subject: Re: [PATCH v2 10/10] nf_conntrack: Use rcu_barrier() and
	fix	kmem_cache_create flags
From: Jesper Dangaard Brouer <jdb@comx.dk>
Reply-To: jdb@comx.dk
In-Reply-To: <4A423108.60109@trash.net>
References: <20090623150330.22490.87327.stgit@localhost>
	 <20090623150444.22490.27931.stgit@localhost>  <4A410185.3090706@trash.net>
	 <1245834139.6695.31.camel@localhost.localdomain>
	 <1245836409.6695.35.camel@localhost.localdomain> <4A423108.60109@trash.net>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Thu, 25 Jun 2009 11:29:13 +0200
Message-Id: <1245922153.24921.56.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Patrick McHardy <kaber@trash.net>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org
Cc: "David S. Miller" <davem@davemloft.net>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, dougthompson@xmission.com, bluesmoke-devel@lists.sourceforge.net, axboe@kernel.dk, christine.caulfield@googlemail.com, Trond.Myklebust@netapp.com, linux-wireless@vger.kernel.org, johannes@sipsolutions.net, yoshfuji@linux-ipv6.org, shemminger@linux-foundation.org, linux-nfs@vger.kernel.org, bfields@fieldses.org, neilb@suse.de, linux-ext4@vger.kernel.org, tytso@mit.edu, adilger@sun.com, netfilter-devel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Wed, 2009-06-24 at 15:58 +0200, Patrick McHardy wrote:
> Jesper Dangaard Brouer wrote:
> > Adjusting SLAB_DESTROY_BY_RCU flags.
> > 
> >  kmem_cache_create("nf_conntrack", ...) does not need the
> >  SLAB_DESTROY_BY_RCU flag.
> 
> It does need it. We're using it instead of call_rcu() for conntracks.
> 
> >  But the
> >  kmem_cache_create("nf_conntrack_expect", ...) should use the
> >  SLAB_DESTROY_BY_RCU flag, because it uses a call_rcu() callback to
> >  invoke kmem_cache_free().
> 
> No, using call_rcu() means we don't need SLAB_DESTROY_BY_RCU.
> Please see the note in include/linux/slab.h.

Oh, I see.  The description is some what cryptic, but I think I got it,
after reading through the code.

BUT this still means that we need to do rcu_barrier() if the
SLAB_DESTROY_BY_RCU is NOT set and we do call_rcu() our self.

Look at: slab.c kmem_cache_destroy()

void kmem_cache_destroy(struct kmem_cache *cachep)
{
	...<cut>...
	if (__cache_shrink(cachep)) {
		slab_error(cachep, "Can't free all objects");
		...<cut>...
		return;
	}

	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU))
		synchronize_rcu();

	__kmem_cache_destroy(cachep);
	...<cut>...
}

My understanding for the code is (please feel free to correct me): that
if SLAB_DESTROY_BY_RCU _is_ set, then the __cache_shrink() call will
call drain_freelist(), which calls slab_destroy().

If SLAB_DESTROY_BY_RCU _is_ set, then slab_destroy() will then start a
call_rcu() callback to kmem_rcu_free() which calls kmem_cache_free().
Given that the callback code kmem_rcu_free() is not removed, we are not
worried about unloading the module at this point.

I'm a bit worried about what happens if __kmem_cache_destroy() is
invoked and there is still callbacks for kmem_rcu_free() in flight?
The synchronize_rcu() between __cache_shrink() and
__kmem_cache_destroy() should perhaps be changed to rcu_barrier()?

But I'm sure that the SLAB/MM guys will tell me that this case is
handled (and something about its unlinked from the appropiate
lists)??? ;-)


> > RCU barriers, rcu_barrier(), is inserted two places.
> > 
> >  In nf_conntrack_expect.c nf_conntrack_expect_fini() before the
> >  kmem_cache_destroy(), even though the use of the SLAB_DESTROY_BY_RCU
> >  flag, because slub does not (currently) handle rcu sync correctly.
> 
> I think that should be fixed in slub then.

I don't think so, we/I'm are talking about "nf_conntrack_expect" and not
"nf_conntrack" slab.  Clearly the slab "nf_conntrack" is handled
correcly (according to description above). 

We still need to make sure the callbacks for "nf_conntrack_expect", are
done before unloading/removing the code they are about to call.


> >  And in nf_conntrack_extend.c nf_ct_extend_unregister(), inorder to
> >  wait for completion of callbacks to __nf_ct_ext_free_rcu(), which is
> >  invoked by __nf_ct_ext_add().  It might be more efficient to call
> >  rcu_barrier() in nf_conntrack_core.c nf_conntrack_cleanup_net(), but
> >  thats make it more difficult to read the code (as the callback code
> >  in located in nf_conntrack_extend.c).
> 
> This one looks fine.

Should I make two different patchs?


> > diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> > index 5f72b94..438ce84 100644
> > --- a/net/netfilter/nf_conntrack_core.c
> > +++ b/net/netfilter/nf_conntrack_core.c
> > @@ -1242,7 +1242,7 @@ static int nf_conntrack_init_init_net(void)
> >  
> >  	nf_conntrack_cachep = kmem_cache_create("nf_conntrack",
> >  						sizeof(struct nf_conn),
> > -						0, SLAB_DESTROY_BY_RCU, NULL);
> > +						0, 0, NULL);
> >  	if (!nf_conntrack_cachep) {
> >  		printk(KERN_ERR "Unable to create nf_conn slab cache\n");
> >  		ret = -ENOMEM;
> > diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
> > index afde8f9..56227c2 100644
> > --- a/net/netfilter/nf_conntrack_expect.c
> > +++ b/net/netfilter/nf_conntrack_expect.c
> > @@ -593,7 +593,7 @@ int nf_conntrack_expect_init(struct net *net)
> >  	if (net_eq(net, &init_net)) {
> >  		nf_ct_expect_cachep = kmem_cache_create("nf_conntrack_expect",
> >  					sizeof(struct nf_conntrack_expect),
> > -					0, 0, NULL);
> > +					0, SLAB_DESTROY_BY_RCU, NULL);
> >  		if (!nf_ct_expect_cachep)
> >  			goto err2;
> >  	}
> > @@ -617,8 +617,15 @@ err1:
> >  void nf_conntrack_expect_fini(struct net *net)
> >  {
> >  	exp_proc_remove(net);
> > -	if (net_eq(net, &init_net))
> > +	if (net_eq(net, &init_net)) {
> > +		/* hawk@comx.dk 2009-06-24: The rcu_barrier() can be
> > +		 * removed once the sl*b allocators has been fixed
> > +		 * regarding handling the SLAB_DESTROY_BY_RCU flag
> > +		 * correctly.
> > +		 */
> > +		rcu_barrier(); /* Wait for call_rcu() before destroy */
> >  		kmem_cache_destroy(nf_ct_expect_cachep);
> > +	}
> >  	nf_ct_free_hashtable(net->ct.expect_hash, net->ct.expect_vmalloc,
> >  			     nf_ct_expect_hsize);
> >  }
> > diff --git a/net/netfilter/nf_conntrack_extend.c b/net/netfilter/nf_conntrack_extend.c
> > index 4b2c769..fef95be 100644
> > --- a/net/netfilter/nf_conntrack_extend.c
> > +++ b/net/netfilter/nf_conntrack_extend.c
> > @@ -186,6 +186,6 @@ void nf_ct_extend_unregister(struct nf_ct_ext_type *type)
> >  	rcu_assign_pointer(nf_ct_ext_types[type->id], NULL);
> >  	update_alloc_size(type);
> >  	mutex_unlock(&nf_ct_ext_type_mutex);
> > -	synchronize_rcu();
> > +	rcu_barrier(); /* Wait for completion of call_rcu()'s */
> >  }
> >  EXPORT_SYMBOL_GPL(nf_ct_extend_unregister);
> > 
> 
-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
