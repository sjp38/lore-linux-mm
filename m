Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5B1386B004F
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 10:32:49 -0400 (EDT)
Message-ID: <4A438AC8.3010907@trash.net>
Date: Thu, 25 Jun 2009 16:33:44 +0200
From: Patrick McHardy <kaber@trash.net>
MIME-Version: 1.0
Subject: Re: [PATCH v3 10/10] nf_conntrack: Use rcu_barrier()
References: <20090623150330.22490.87327.stgit@localhost>	 <20090623150444.22490.27931.stgit@localhost>  <4A410185.3090706@trash.net>	 <1245834139.6695.31.camel@localhost.localdomain>	 <1245836409.6695.35.camel@localhost.localdomain> <4A423108.60109@trash.net>	 <1245922153.24921.56.camel@localhost.localdomain> <1245924178.24921.61.camel@localhost.localdomain>
In-Reply-To: <1245924178.24921.61.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: jdb@comx.dk
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, dougthompson@xmission.com, bluesmoke-devel@lists.sourceforge.net, axboe@kernel.dk, christine.caulfield@googlemail.com, Trond.Myklebust@netapp.com, linux-wireless@vger.kernel.org, johannes@sipsolutions.net, yoshfuji@linux-ipv6.org, shemminger@linux-foundation.org, linux-nfs@vger.kernel.org, bfields@fieldses.org, neilb@suse.de, linux-ext4@vger.kernel.org, tytso@mit.edu, adilger@sun.com, netfilter-devel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Jesper Dangaard Brouer wrote:
> RCU barriers, rcu_barrier(), is inserted two places.
> 
>  In nf_conntrack_expect.c nf_conntrack_expect_fini() before the
>  kmem_cache_destroy().  Firstly to make sure the callback to the
>  nf_ct_expect_free_rcu() code is still around.  Secondly because I'm
>  unsure about the consequence of having in flight
>  nf_ct_expect_free_rcu/kmem_cache_free() calls while doing a
>  kmem_cache_destroy() slab destroy.
> 
>  And in nf_conntrack_extend.c nf_ct_extend_unregister(), inorder to
>  wait for completion of callbacks to __nf_ct_ext_free_rcu(), which is
>  invoked by __nf_ct_ext_add().  It might be more efficient to call
>  rcu_barrier() in nf_conntrack_core.c nf_conntrack_cleanup_net(), but
>  thats make it more difficult to read the code (as the callback code
>  in located in nf_conntrack_extend.c).

Applied, thanks Jesper.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
