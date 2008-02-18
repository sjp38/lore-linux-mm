Received: by rv-out-0910.google.com with SMTP id f1so1181118rvb.26
        for <linux-mm@kvack.org>; Mon, 18 Feb 2008 09:18:21 -0800 (PST)
Message-ID: <84144f020802180918h6fb4d52fw4c592407a16b19c0@mail.gmail.com>
Date: Mon, 18 Feb 2008 19:18:20 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: Slab initialisation problems on MN10300
In-Reply-To: <16085.1203350863@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <16085.1203350863@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: clameter@sgi.com, mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi David,

What kernel version is this?

On Feb 18, 2008 6:07 PM, David Howells <dhowells@redhat.com> wrote:
>	(gdb) bt
>	#0  0x90258041 in setup_cpu_cache (cachep=0x93c00130) at mm/slab.c:2103
>	#1  0x900977d7 in kmem_cache_create (name=0x9026de9d "size-64",
size=64, align=16, flags=270336,
>              ctor=0) at mm/slab.c:2384
>	#2  0x9029e959 in kmem_cache_init () at mm/slab.c:1548

So we've already set up caches for struct arraycache_init (INDEX_AC)
and struct kmem_list3 (INDEX_L3) here and trying to initialize rest of
the caches.

On Feb 18, 2008 6:07 PM, David Howells <dhowells@redhat.com> wrote:
>	#3  0x902987aa in start_kernel () at init/main.c:618
>	#4  0x9000122f in __no_parameters () at arch/mn10300/kernel/head.S:209
>	#5  0x9000122f in __no_parameters () at arch/mn10300/kernel/head.S:209

But then:

On Feb 18, 2008 6:07 PM, David Howells <dhowells@redhat.com> wrote:
> and sizeof(struct kmem_list3) is 52, which is going to get rounded up to 64 by
> kmalloc_node().  This means that it's going to attempt to allocate out of the
> 64-byte kmalloc slab, which is what the kernel is currently setting up, so the
> allocation fails.

doesn't make any sense as we should have already initialized the cache
for sizeof(struct kmem_list3) (denoted by INDEX_L3).

Also:

On Feb 18, 2008 6:07 PM, David Howells <dhowells@redhat.com> wrote:
> Perhaps it's no longer 24, but something bigger.  The first pass through
> setup_cpu_cache() is done for the 32-byte kmalloc slab, with g_cpucache_up set
> to NONE.  The second pass is done for the 64-byte kmalloc slab with
> g_cpucache_up set to PARTIAL_L3.  It is the second pass that fails.

If you didn't see PARTIAL_AC state at all, SLAB thinks INDEX_AC and
INDEX_L3 are equal. However,

On Feb 18, 2008 6:07 PM, David Howells <dhowells@redhat.com> wrote:
> The second pass calls kmalloc() on sizeof(struct arraycache_init), which is 20
> and succeeds.  It then calls kmalloc_node() on sizeof(struct kmem_list3),
> which is 52 and fails.

would put struct arraycache_init to kmalloc-32 and struct kmem_list3
to kmalloc-64. So are INDEX_AC and INDEX_L3 really equivalent? To
which cache do they refer to?

And if this broke recently, you might want to try and see if commit
556a169dab38b5100df6f4a45b655dddd3db94c1 ("slab: fix bootstrap on
memoryless node") is at fault here by reverting it.

				Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
