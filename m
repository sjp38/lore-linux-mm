Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 053FC6B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 12:50:58 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e9so7180371pfn.16
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 09:50:57 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i2si2082291pgn.226.2018.04.10.09.50.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 10 Apr 2018 09:50:56 -0700 (PDT)
Date: Tue, 10 Apr 2018 09:50:54 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/2] slab: __GFP_ZERO is incompatible with a constructor
Message-ID: <20180410165054.GC3614@bombadil.infradead.org>
References: <20180410125351.15837-1-willy@infradead.org>
 <fee8a8bc-3db5-a66a-33cb-0729143ba615@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fee8a8bc-3db5-a66a-33cb-0729143ba615@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, stable@vger.kernel.org

On Tue, Apr 10, 2018 at 06:53:04AM -0700, Eric Dumazet wrote:
> On 04/10/2018 05:53 AM, Matthew Wilcox wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > __GFP_ZERO requests that the object be initialised to all-zeroes,
> > while the purpose of a constructor is to initialise an object to a
> > particular pattern.  We cannot do both.  Add a warning to catch any
> > users who mistakenly pass a __GFP_ZERO flag when allocating a slab with
> > a constructor.
> > 
> > Fixes: d07dbea46405 ("Slab allocators: support __GFP_ZERO in all allocators")
> > Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> > Cc: stable@vger.kernel.org
> 
> Since there are probably no bug to fix, what about adding the extra check
> only for some DEBUG option ?
> 
> How many caches are still using ctor these days ?

That's a really good question, and strangely hard to find out.  I settled
on "git grep -A4 kmem_cache_alloc" and then searching the 'less' output
with '[^L]);'.

--
arch/powerpc/kvm/book3s_64_mmu_radix.c: kvm_pte_cache = kmem_cache_create("kvm-pte", size, size, 0, pte_ctor);
--
arch/powerpc/mm/init-common.c:  new = kmem_cache_create(name, table_size, align, 0, ctor);
--
arch/powerpc/platforms/cell/spufs/inode.c:      spufs_inode_cache = kmem_cache_create("spufs_inode_cache",
arch/powerpc/platforms/cell/spufs/inode.c-                      sizeof(struct spufs_inode_info), 0,
arch/powerpc/platforms/cell/spufs/inode.c-                      SLAB_HWCACHE_ALIGN|SLAB_ACCOUNT, spufs_init_once);
--
arch/sh/mm/pgtable.c:   pgd_cachep = kmem_cache_create("pgd_cache",
arch/sh/mm/pgtable.c-                                  PTRS_PER_PGD * (1<<PTE_MAGNITUDE),
arch/sh/mm/pgtable.c-                                  PAGE_SIZE, SLAB_PANIC, pgd_ctor);
--
arch/sparc/mm/tsb.c:    pgtable_cache = kmem_cache_create("pgtable_cache",
arch/sparc/mm/tsb.c-                                      PAGE_SIZE, PAGE_SIZE,
arch/sparc/mm/tsb.c-                                      0,
arch/sparc/mm/tsb.c-                                      _clear_page);
--
drivers/dax/super.c:    dax_cache = kmem_cache_create("dax_cache", sizeof(struct
 dax_device), 0,
drivers/dax/super.c-                    (SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT
|
drivers/dax/super.c-                     SLAB_MEM_SPREAD|SLAB_ACCOUNT),
drivers/dax/super.c-                    init_once);
--
drivers/staging/ncpfs/inode.c:  ncp_inode_cachep = kmem_cache_create("ncp_inode_
cache",
drivers/staging/ncpfs/inode.c-                                       sizeof(stru
ct ncp_inode_info),
drivers/staging/ncpfs/inode.c-                                       0, (SLAB_RE
CLAIM_ACCOUNT|
drivers/staging/ncpfs/inode.c-                                          SLAB_MEM
_SPREAD|SLAB_ACCOUNT),
drivers/staging/ncpfs/inode.c-                                       init_once);
--
drivers/usb/mon/mon_text.c:     rp->e_slab = kmem_cache_create(rp->slab_name,
drivers/usb/mon/mon_text.c-         sizeof(struct mon_event_text), sizeof(long),
 0,
drivers/usb/mon/mon_text.c-         mon_text_ctor);
--
fs/9p/v9fs.c:   v9fs_inode_cache = kmem_cache_create("v9fs_inode_cache",
fs/9p/v9fs.c-                                     sizeof(struct v9fs_inode),
fs/9p/v9fs.c-                                     0, (SLAB_RECLAIM_ACCOUNT|
fs/9p/v9fs.c-                                         SLAB_MEM_SPREAD|SLAB_ACCOUNT),
fs/9p/v9fs.c-                                     v9fs_inode_init_once);
--
fs/adfs/super.c:        adfs_inode_cachep = kmem_cache_create("adfs_inode_cache",
fs/adfs/super.c-                                             sizeof(struct adfs_inode_info),
fs/adfs/super.c-                                             0, (SLAB_RECLAIM_ACCOUNT|
fs/adfs/super.c-                                                SLAB_MEM_SPREAD|SLAB_ACCOUNT),
fs/adfs/super.c-                                             init_once);
... snip a huge number of filesystems ...
--
ipc/mqueue.c:   mqueue_inode_cachep = kmem_cache_create("mqueue_inode_cache",
ipc/mqueue.c-                           sizeof(struct mqueue_inode_info), 0,
ipc/mqueue.c-                           SLAB_HWCACHE_ALIGN|SLAB_ACCOUNT, init_once);
--
kernel/fork.c:  sighand_cachep = kmem_cache_create("sighand_cache",
kernel/fork.c-                  sizeof(struct sighand_struct), 0,
kernel/fork.c-                  SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_TYPESAFE_BY_R
CU|
kernel/fork.c-                  SLAB_ACCOUNT, sighand_ctor);
--
lib/radix-tree.c:       radix_tree_node_cachep = kmem_cache_create("radix_tree_n
ode",
lib/radix-tree.c-                       sizeof(struct radix_tree_node), 0,
lib/radix-tree.c-                       SLAB_PANIC | SLAB_RECLAIM_ACCOUNT,
lib/radix-tree.c-                       radix_tree_node_ctor);
--
mm/rmap.c:      anon_vma_cachep = kmem_cache_create("anon_vma", sizeof(struct an
on_vma),
mm/rmap.c-                      0, SLAB_TYPESAFE_BY_RCU|SLAB_PANIC|SLAB_ACCOUNT,
mm/rmap.c-                      anon_vma_ctor);
--
mm/shmem.c:     shmem_inode_cachep = kmem_cache_create("shmem_inode_cache",
mm/shmem.c-                             sizeof(struct shmem_inode_info),
mm/shmem.c-                             0, SLAB_PANIC|SLAB_ACCOUNT, shmem_init_inode);
--
net/sunrpc/rpc_pipe.c:  rpc_inode_cachep = kmem_cache_create("rpc_inode_cache",
net/sunrpc/rpc_pipe.c-                          sizeof(struct rpc_inode),
net/sunrpc/rpc_pipe.c-                          0, (SLAB_HWCACHE_ALIGN|SLAB_RECL
AIM_ACCOUNT|
net/sunrpc/rpc_pipe.c-                                          SLAB_MEM_SPREAD|
SLAB_ACCOUNT),
net/sunrpc/rpc_pipe.c-                          init_once);
--
security/integrity/iint.c:          kmem_cache_create("iint_cache", sizeof(struc
t integrity_iint_cache),
security/integrity/iint.c-                            0, SLAB_PANIC, init_once);

So aside from the filesystems, about fourteen places use it in the kernel.

If we want to get rid of the concept of constructors, it's doable,
but somebody needs to do the work to show what the effects will be.

For example, I took a quick look at the sighand_struct in kernel/fork.c.
That initialises the spinlock and waitqueue head which are at the end
of sighand_struct.  The caller who allocates sighand_struct touches
the head of the struct.  So if we removed the ctor, we'd touch two
cachelines on allocation instead of one ... but we could rearrange the
sighand_struct to put all the initialised bits in the first cacheline
(and we probably should).
