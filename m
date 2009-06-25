Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A07126B0055
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 09:57:22 -0400 (EDT)
Message-ID: <4A4382A9.8070300@trash.net>
Date: Thu, 25 Jun 2009 15:59:05 +0200
From: Patrick McHardy <kaber@trash.net>
MIME-Version: 1.0
Subject: Re: [PATCH v2 10/10] nf_conntrack: Use rcu_barrier() and	fix	kmem_cache_create
 flags
References: <20090623150330.22490.87327.stgit@localhost>	 <20090623150444.22490.27931.stgit@localhost>  <4A410185.3090706@trash.net>	 <1245834139.6695.31.camel@localhost.localdomain>	 <1245836409.6695.35.camel@localhost.localdomain> <4A423108.60109@trash.net> <1245922153.24921.56.camel@localhost.localdomain>
In-Reply-To: <1245922153.24921.56.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: jdb@comx.dk
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, dougthompson@xmission.com, bluesmoke-devel@lists.sourceforge.net, axboe@kernel.dk, christine.caulfield@googlemail.com, Trond.Myklebust@netapp.com, linux-wireless@vger.kernel.org, johannes@sipsolutions.net, yoshfuji@linux-ipv6.org, shemminger@linux-foundation.org, linux-nfs@vger.kernel.org, bfields@fieldses.org, neilb@suse.de, linux-ext4@vger.kernel.org, tytso@mit.edu, adilger@sun.com, netfilter-devel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Jesper Dangaard Brouer wrote:
> On Wed, 2009-06-24 at 15:58 +0200, Patrick McHardy wrote:
>> Jesper Dangaard Brouer wrote:
>>> Adjusting SLAB_DESTROY_BY_RCU flags.
>>>
>>>  kmem_cache_create("nf_conntrack", ...) does not need the
>>>  SLAB_DESTROY_BY_RCU flag.
>> It does need it. We're using it instead of call_rcu() for conntracks.
>>
>>>  But the
>>>  kmem_cache_create("nf_conntrack_expect", ...) should use the
>>>  SLAB_DESTROY_BY_RCU flag, because it uses a call_rcu() callback to
>>>  invoke kmem_cache_free().
>> No, using call_rcu() means we don't need SLAB_DESTROY_BY_RCU.
>> Please see the note in include/linux/slab.h.
> 
> Oh, I see.  The description is some what cryptic, but I think I got it,
> after reading through the code.
> 
> BUT this still means that we need to do rcu_barrier() if the
> SLAB_DESTROY_BY_RCU is NOT set and we do call_rcu() our self.

Correct, in that case its necessary.

> My understanding for the code is (please feel free to correct me): that
> if SLAB_DESTROY_BY_RCU _is_ set, then the __cache_shrink() call will
> call drain_freelist(), which calls slab_destroy().
> 
> If SLAB_DESTROY_BY_RCU _is_ set, then slab_destroy() will then start a
> call_rcu() callback to kmem_rcu_free() which calls kmem_cache_free().
> Given that the callback code kmem_rcu_free() is not removed, we are not
> worried about unloading the module at this point.

Yep, thats my understanding as well.

> I'm a bit worried about what happens if __kmem_cache_destroy() is
> invoked and there is still callbacks for kmem_rcu_free() in flight?
> The synchronize_rcu() between __cache_shrink() and
> __kmem_cache_destroy() should perhaps be changed to rcu_barrier()?
> 
> But I'm sure that the SLAB/MM guys will tell me that this case is
> handled (and something about its unlinked from the appropiate
> lists)??? ;-)

I'll leave that question to the MM guys :)

>>> RCU barriers, rcu_barrier(), is inserted two places.
>>>
>>>  In nf_conntrack_expect.c nf_conntrack_expect_fini() before the
>>>  kmem_cache_destroy(), even though the use of the SLAB_DESTROY_BY_RCU
>>>  flag, because slub does not (currently) handle rcu sync correctly.
>> I think that should be fixed in slub then.
> 
> I don't think so, we/I'm are talking about "nf_conntrack_expect" and not
> "nf_conntrack" slab.  Clearly the slab "nf_conntrack" is handled
> correcly (according to description above). 
> 
> We still need to make sure the callbacks for "nf_conntrack_expect", are
> done before unloading/removing the code they are about to call.

Yes, my response was referring to potential sl*b bugs, but
you're correct, we do need rcu_barrier() for expectations.

>>>  And in nf_conntrack_extend.c nf_ct_extend_unregister(), inorder to
>>>  wait for completion of callbacks to __nf_ct_ext_free_rcu(), which is
>>>  invoked by __nf_ct_ext_add().  It might be more efficient to call
>>>  rcu_barrier() in nf_conntrack_core.c nf_conntrack_cleanup_net(), but
>>>  thats make it more difficult to read the code (as the callback code
>>>  in located in nf_conntrack_extend.c).
>> This one looks fine.
> 
> Should I make two different patchs?

Either way is fine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
