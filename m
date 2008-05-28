Date: Wed, 28 May 2008 17:32:05 -0300
From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: Subject: Slab allocators: Remove kmem_cache_name() to fix
	invalid frees
Message-ID: <20080528203205.GL30251@ghostprotocols.net>
References: <Pine.LNX.4.64.0805281032290.22637@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805281032290.22637@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, mpm@selenic.com, linux-mm@kvack.org, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Em Wed, May 28, 2008 at 10:40:39AM -0700, Christoph Lameter escreveu:
> kmem_cache_name() is used only by the networking subsystem in order to retrieve
> a char * pointer that was passed to kmem_cache_create(). The name of the 
> slab was created dynamically by the network subsystem and therefore there 
> is a need to free the name when the slab is no longer in use.
> 
> This use creates a dependency on the internal workings of the slab 
> allocator. It assumes that the slab allocator stores a pointer to the 
> string passed in at kmem_cache_create and that the pointer can be 
> retrieved later until the slab is destroyed.
> 
> SLUB does not follow that expectation for merged slabs. In that case the
> slab name passed to kmem_cache_create() may only be used to create a 
> symlink in /sys/kernel/slab. The "name" of the slab that will be returned 
> on kmem_cache_name() is the name of the first kmem_cache_create() that 
> caused a slab of a certain size to be created.
> 
> This can lead to double frees or the freeing of a string constant when
> a slab is destroyed by the network subsystem by the following action in 
> ccid_kmem_cache_destroy() (DCCP protocol) and in proto_unregister().
> 
> 1. Retrieving the slab name via kmem_cache_name()
> 2. Destroying the slab cache by calling kmem_cache_destroy().
> 3. Freeing the slab name via kfree().
> 
> It seems that it is rare to trigger invalid kfrees because the slabs 
> with the dynamic names are rarely created (at least on my systems) and 
> then destroyed. In many cases it seems that the first name is the actual 
> name of slab because of the uniqueness of the slab characteristics. I only 
> found these while testing with cpu_alloc patches that influenced the 
> sizes of these structures. But I am sure this can also be triggered under 
> other conditions.
> 
> Fix:
> 
> Create special fields in the networking structs to store a pointer to
> names of slab generated. The pointer is then used to free the name of
> the slab after the slab was destroyed.
> 
> Drop the support for kmem_cache_name from all slab allocators.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

I'm ok with this, thanks,

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
