Message-ID: <43419686.60600@colorfullife.com>
Date: Mon, 03 Oct 2005 22:37:26 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [PATCH] per-page SLAB freeing (only dcache for now)
References: <20050930193754.GB16812@xeon.cnet> <Pine.LNX.4.62.0509301934390.31011@schroedinger.engr.sgi.com> <20051001215254.GA19736@xeon.cnet> <Pine.LNX.4.62.0510030823420.7812@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0510030823420.7812@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Marcelo <marcelo.tosatti@cyclades.com>, linux-mm@kvack.org, akpm@osdl.org, dgc@sgi.com, dipankar@in.ibm.com, mbligh@mbligh.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:

>On Sat, 1 Oct 2005, Marcelo wrote:
>
>  
>
>>I thought about having a mini-API for this such as "struct slab_reclaim_ops" 
>>implemented by each reclaimable cache, invoked by a generic SLAB function.
>>
>>    
>>
Which functions would be needed?
- lock_cache(): No more alive/dead changes
- objp_is_alive()
- objp_is_killable()
- objp_kill()

I think it would be simpler if the caller must mark the objects as 
alive/dead before/after calling kmem_cache_alloc/free: I don't think 
it's a good idea to add special case code and branches to the normal 
kmem_cache_alloc codepath. And especially: It would mean that 
kmem_cache_alloc must perform a slab lookup  in each alloc call, this 
could be slow.
The slab users could store the alive status somewhere in the object. And 
they could set the flag early, e.g. disable alive as soon as an object 
is put on the rcu aging list.

The tricky part is lock_cache: is it actually possible to really lock 
the dentry cache, or could RCU cause changes at any time.

--
    Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
