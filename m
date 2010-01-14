Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9CA076B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 16:31:56 -0500 (EST)
Message-ID: <4B4F8D35.5050203@cs.helsinki.fi>
Date: Thu, 14 Jan 2010 23:31:33 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
References: <20100113002923.GF2985@ldl.fc.hp.com> <alpine.DEB.2.00.1001140917110.14164@router.home> <20100114182214.GB4545@ldl.fc.hp.com> <84144f021001141117o6271244cmbe9ba790f9616b2c@mail.gmail.com> <20100114203221.GI4545@ldl.fc.hp.com> <alpine.DEB.2.00.1001141457250.19915@router.home> <20100114212933.GK4545@ldl.fc.hp.com>
In-Reply-To: <20100114212933.GK4545@ldl.fc.hp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alex Chiang <achiang@hp.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alex Chiang wrote:
> * Christoph Lameter <cl@linux-foundation.org>:
>> On Thu, 14 Jan 2010, Alex Chiang wrote:
>>
>>> coffee0:/usr/src/linux-2.6 # addr2line 0xa0000001001add60 -e vmlinux
>>> /usr/src/linux-2.6/include/linux/mm.h:543
>>>
>>>  538 #ifdef NODE_NOT_IN_PAGE_FLAGS
>>>  539 extern int page_to_nid(struct page *page);
>>>  540 #else
>>>  541 static inline int page_to_nid(struct page *page)
>>>  542 {
>>>  543         return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
>>>  544 }
>>>  545 #endif
>> That may mean that early_kmem_node_alloc gets a screwy page number from
>> the page allocator? ????
>>
>> Can you print the address of page returned from new_slab() in
>> early_kmem_cache_node_alloc()?
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 9e86e6b..2909cc4 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2062,7 +2062,7 @@ init_kmem_cache_node(struct kmem_cache_node *n, struct kme
> m_cache *s)
>  #endif
>  }
>  
> -static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[SLUB_PAGE_SHIFT]);
> +static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[KMALLOC_CACHES]);
>  
>  static inline int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
>  {
> @@ -2100,6 +2100,7 @@ static void early_kmem_cache_node_alloc(gfp_t gfpflags, in
> t node)
>         BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
>  
>         page = new_slab(kmalloc_caches, gfpflags, node);
> +       printk("page from new_slab() %#llx\n", page);
>  
>         BUG_ON(!page);
>         if (page_to_nid(page) != node) {
> 
> Memory: 66849344k/66910528k available (8033k code, 110720k reserved, 10805k data, 1984k init)
> page from new_slab() 0xa07fffffff900000
> page from new_slab() 0xa07fffffe39000e0
> SLUB: Unable to allocate memory from node 2
> SLUB: Allocating a useless per node structure in order to be able to continue
> SLUB: Genslabs=18, HWalign=128, Order=0-3, MinObjects=0, CPUs=16, Nodes=1024
> 
> [...]
> 
> Unable to handle kernel paging request at virtual address a07ffffe5a7838a8
> modprobe[6043]: Oops 8813272891392 [1]
> Modules linked in: sr_mod(+) sg container(+) button usbhid ohci_hcd ehci_hcd usbcore fan thermal processor thermal_sys
> 
> Pid: 6043, CPU 9, comm:             modprobe
> psr : 0000101008526010 ifs : 8000000000000b1d ip  : [<a0000001001add60>]    Not tainted (2.6.33-rc3-next-20100111-dirty)
> ip is at kmem_cache_open+0x420/0xb40
> 

Christoph, we've seen similar issue on s390:

http://git.kernel.org/?p=linux/kernel/git/penberg/slab-2.6.git;a=commitdiff;h=ff64d6c42abaffdb8686c77930eafb4da5b676f5

Maybe your changes are trigger a latent bug with DEFINE_PER_CPU handling 
in SLUB?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
