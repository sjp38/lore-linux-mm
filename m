Date: Tue, 8 May 2007 14:04:21 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: The last slab destructor .....
Message-ID: <Pine.LNX.4.64.0705081358560.14107@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

As far as I can tell: We will soon have only a single slab destructor 
still in use in the kernel (after the quicklist migrations have finished 
upstream). I wonder how difficult it would be to remove it? If we have no 
destructors anymore then maybe we could remove destructor support from the 
slab allocators? Or are there valid reason to keep them around? It seems 
they were mainly used for list management which required them to take a 
spinlock. Taking a spinlock in a destructor is a bit risky since the slab 
allocators may run the destructors anytime they decide a slab is no longer 
needed.

The last one is in

arch/mm/pmb.c:

static void pmb_cache_ctor(void *pmb, struct kmem_cache *cachep, unsigned 
long flags)
{
        struct pmb_entry *pmbe = pmb;

        memset(pmb, 0, sizeof(struct pmb_entry));

        spin_lock_irq(&pmb_list_lock);

        pmbe->entry = PMB_NO_ENTRY;
        pmb_list_add(pmbe);

        spin_unlock_irq(&pmb_list_lock);
}

static void pmb_cache_dtor(void *pmb, struct kmem_cache *cachep, unsigned 
long flags)
{
        spin_lock_irq(&pmb_list_lock);
        pmb_list_del(pmb);
        spin_unlock_irq(&pmb_list_lock);
}

static int __init pmb_init(void)
{
        unsigned int nr_entries = ARRAY_SIZE(pmb_init_map);
        unsigned int entry;

        BUG_ON(unlikely(nr_entries >= NR_PMB_ENTRIES));

        pmb_cache = kmem_cache_create("pmb", sizeof(struct pmb_entry), 0,
                                      SLAB_PANIC, pmb_cache_ctor,
                                      pmb_cache_dtor);

        jump_to_P2();

        /*
         * Ordering is important, P2 must be mapped in the PMB before we
         * can set PMB.SE, and P1 must be mapped before we jump back to
         * P1 space.
         */
        for (entry = 0; entry < nr_entries; entry++) {
                struct pmb_entry *pmbe = pmb_init_map + entry;

                __set_pmb_entry(pmbe->vpn, pmbe->ppn, pmbe->flags, 
&entry);
        }

        ctrl_outl(0, PMB_IRMCR);

        /* PMB.SE and UB[7] */
        ctrl_outl((1 << 31) | (1 << 7), PMB_PASCR);

        back_to_P1();

        return 0;
}
arch_initcall(pmb_init);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
