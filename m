Date: Sun, 8 Oct 2006 14:51:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: mm section mismatches
In-Reply-To: <Pine.LNX.4.64.0610081030100.2562@sbz-30.cs.Helsinki.FI>
Message-ID: <Pine.LNX.4.64.0610081444010.23640@schroedinger.engr.sgi.com>
References: <20061006184930.855d0f0b.akpm@google.com>
 <Pine.LNX.4.64.0610081030100.2562@sbz-30.cs.Helsinki.FI>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: Andrew Morton <akpm@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 8 Oct 2006, Pekka J Enberg wrote:

> setup_cpu_cache is a non-init function that calls set_up_list3s which is 
> init.  However, due to g_cpucache_up, we will never hit the branch in 
> setup_cpu_cache that calls set_up_list3s.

It hits that code during bootstrap. Note that g_cpucache_up is NONE on 
startup and thus we will be hitting that function from kmem_init().

> No idea how to fix the warning. Due to g_cpucache_up, we need some entry 
> point that calls both init and non-init functions... Christoph?

To tell you the truth on of the crappy issues about the 
current slab is the mindboogling way of complexity of the bootstrap. 
Which is due to the inability to statically define a kmem_cache 
structure because we seem to have made an early decision to only work with 
kmem_cache_t handles so that the data structures are opaque from the 
outside.

To fix: Revert the change that made set_up_lists3s non init.
In 2.6.18-mm3 this set_up_list3s is not init.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
