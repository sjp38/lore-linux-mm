Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id C174F6B005A
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 11:01:00 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 4 Oct 2012 00:57:43 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q93EpBbr64618688
	for <linux-mm@kvack.org>; Thu, 4 Oct 2012 00:51:12 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q93F0rXO028735
	for <linux-mm@kvack.org>; Thu, 4 Oct 2012 01:00:53 +1000
Message-ID: <506C52FC.4040305@linux.vnet.ibm.com>
Date: Wed, 03 Oct 2012 20:30:12 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] mm, slab: release slab_mutex earlier in kmem_cache_destroy()
References: <alpine.LNX.2.00.1210021810350.23544@pobox.suse.cz> <20121002170149.GC2465@linux.vnet.ibm.com> <alpine.LNX.2.00.1210022324050.23544@pobox.suse.cz> <alpine.LNX.2.00.1210022331130.23544@pobox.suse.cz> <alpine.LNX.2.00.1210022356370.23544@pobox.suse.cz> <20121002233138.GD2465@linux.vnet.ibm.com> <alpine.LNX.2.00.1210030142570.23544@pobox.suse.cz> <20121003001530.GF2465@linux.vnet.ibm.com> <alpine.LNX.2.00.1210030227430.23544@pobox.suse.cz> <0000013a26fb253a-fb5df733-ad41-47c1-af1d-3d6739e417de-000000@email.amazonses.com> <alpine.LNX.2.00.1210031631150.23544@pobox.suse.cz>
In-Reply-To: <alpine.LNX.2.00.1210031631150.23544@pobox.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "Paul E. McKenney" <paul.mckenney@linaro.org>, Josh Triplett <josh@joshtriplett.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/03/2012 08:04 PM, Jiri Kosina wrote:
> On Wed, 3 Oct 2012, Christoph Lameter wrote:
> 
>>> How about the patch below? Pekka, Christoph, please?
>>
>> Looks fine for -stable. For upstream there is going to be a move to
>> slab_common coming in this merge period. We would need a fix against -next
>> or Pekka's tree too.
> 
> Thanks Christoph. Patch against Pekka's slab/for-linus branch below.
> 
> I have kept the Acked-by/Reviewed-by from the version of the patch against 
> current Linus' tree, if anyone object, please shout loudly. Ideally should 
> go in during this merge window to keep lockdep happy.
> 
> 
> 
> 
> 
> From: Jiri Kosina <jkosina@suse.cz>
> Subject: [PATCH] mm, slab: release slab_mutex earlier in kmem_cache_destroy()
> 
> Commit 1331e7a1bbe1 ("rcu: Remove _rcu_barrier() dependency on
> __stop_machine()") introduced slab_mutex -> cpu_hotplug.lock
> dependency through kmem_cache_destroy() -> rcu_barrier() ->
> _rcu_barrier() -> get_online_cpus().
> 
> Lockdep thinks that this might actually result in ABBA deadlock,
> and reports it as below:
> 
[...] 
> Reviewed-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
> Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Acked-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> ---
>  mm/slab_common.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 9c21725..90c3053 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -166,6 +166,7 @@ void kmem_cache_destroy(struct kmem_cache *s)
>  	s->refcount--;
>  	if (!s->refcount) {
>  		list_del(&s->list);
> +		mutex_unlock(&slab_mutex);
> 
>  		if (!__kmem_cache_shutdown(s)) {

__kmem_cache_shutdown() calls __cache_shrink(). And __cache_shrink() has this
comment over it:
/* Called with slab_mutex held to protect against cpu hotplug */

So, I guess the question is whether to modify your patch to hold the slab_mutex
while calling this function, or to update the comment on top of this function
saying that we are OK to call this function (even without slab_mutex) when we
are inside a get/put_online_cpus() section.

>  			if (s->flags & SLAB_DESTROY_BY_RCU)
> @@ -179,8 +180,9 @@ void kmem_cache_destroy(struct kmem_cache *s)
>  				s->name);
>  			dump_stack();

There is a list_add() before this dump_stack(). I assume we need to hold the
slab_mutex while calling it.

>  		}
> +	} else {
> +		mutex_unlock(&slab_mutex);
>  	}
> -	mutex_unlock(&slab_mutex);
>  	put_online_cpus();
>  }
>  EXPORT_SYMBOL(kmem_cache_destroy);
> 

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
