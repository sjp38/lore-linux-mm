Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 370716B01F0
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 05:01:41 -0400 (EDT)
Received: by fxm24 with SMTP id 24so42201fxm.6
        for <linux-mm@kvack.org>; Tue, 30 Mar 2010 02:01:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1003271940190.8399@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com>
	 <20100226155755.GE16335@basil.fritz.box>
	 <alpine.DEB.2.00.1002261123520.7719@router.home>
	 <alpine.DEB.2.00.1002261555030.32111@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.1003010224170.26824@chino.kir.corp.google.com>
	 <20100305062002.GV8653@laptop>
	 <alpine.DEB.2.00.1003081502400.30456@chino.kir.corp.google.com>
	 <20100309134633.GM8653@laptop>
	 <alpine.DEB.2.00.1003271849260.7249@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.1003271940190.8399@chino.kir.corp.google.com>
Date: Tue, 30 Mar 2010 12:01:40 +0300
Message-ID: <84144f021003300201x563c72vb41cc9de359cc7d0@mail.gmail.com>
Subject: Re: [patch v2] slab: add memory hotplug support
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Sun, Mar 28, 2010 at 5:40 AM, David Rientjes <rientjes@google.com> wrote=
:
> Slab lacks any memory hotplug support for nodes that are hotplugged
> without cpus being hotplugged. =A0This is possible at least on x86
> CONFIG_MEMORY_HOTPLUG_SPARSE kernels where SRAT entries are marked
> ACPI_SRAT_MEM_HOT_PLUGGABLE and the regions of RAM represent a seperate
> node. =A0It can also be done manually by writing the start address to
> /sys/devices/system/memory/probe for kernels that have
> CONFIG_ARCH_MEMORY_PROBE set, which is how this patch was tested, and
> then onlining the new memory region.
>
> When a node is hotadded, a nodelist for that node is allocated and
> initialized for each slab cache. =A0If this isn't completed due to a lack
> of memory, the hotadd is aborted: we have a reasonable expectation that
> kmalloc_node(nid) will work for all caches if nid is online and memory is
> available.
>
> Since nodelists must be allocated and initialized prior to the new node's
> memory actually being online, the struct kmem_list3 is allocated off-node
> due to kmalloc_node()'s fallback.
>
> When an entire node would be offlined, its nodelists are subsequently
> drained. =A0If slab objects still exist and cannot be freed, the offline =
is
> aborted. =A0It is possible that objects will be allocated between this
> drain and page isolation, so it's still possible that the offline will
> still fail, however.
>
> Signed-off-by: David Rientjes <rientjes@google.com>

Nick, Christoph, lets make a a deal: you ACK, I merge. How does that
sound to you?

> ---
> =A0mm/slab.c | =A0157 ++++++++++++++++++++++++++++++++++++++++++++++++---=
---------
> =A01 files changed, 125 insertions(+), 32 deletions(-)
>
> diff --git a/mm/slab.c b/mm/slab.c
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -115,6 +115,7 @@
> =A0#include =A0 =A0 =A0 <linux/reciprocal_div.h>
> =A0#include =A0 =A0 =A0 <linux/debugobjects.h>
> =A0#include =A0 =A0 =A0 <linux/kmemcheck.h>
> +#include =A0 =A0 =A0 <linux/memory.h>
>
> =A0#include =A0 =A0 =A0 <asm/cacheflush.h>
> =A0#include =A0 =A0 =A0 <asm/tlbflush.h>
> @@ -1102,6 +1103,52 @@ static inline int cache_free_alien(struct kmem_cac=
he *cachep, void *objp)
> =A0}
> =A0#endif
>
> +/*
> + * Allocates and initializes nodelists for a node on each slab cache, us=
ed for
> + * either memory or cpu hotplug. =A0If memory is being hot-added, the km=
em_list3
> + * will be allocated off-node since memory is not yet online for the new=
 node.
> + * When hotplugging memory or a cpu, existing nodelists are not replaced=
 if
> + * already in use.
> + *
> + * Must hold cache_chain_mutex.
> + */
> +static int init_cache_nodelists_node(int node)
> +{
> + =A0 =A0 =A0 struct kmem_cache *cachep;
> + =A0 =A0 =A0 struct kmem_list3 *l3;
> + =A0 =A0 =A0 const int memsize =3D sizeof(struct kmem_list3);
> +
> + =A0 =A0 =A0 list_for_each_entry(cachep, &cache_chain, next) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Set up the size64 kmemlist for cpu bef=
ore we can
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* begin anything. Make sure some other c=
pu on this
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* node has not already allocated this
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!cachep->nodelists[node]) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 l3 =3D kmalloc_node(memsize=
, GFP_KERNEL, node);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!l3)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENO=
MEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kmem_list3_init(l3);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 l3->next_reap =3D jiffies +=
 REAPTIMEOUT_LIST3 +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ((unsigned long)cac=
hep) % REAPTIMEOUT_LIST3;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* The l3s don't come and=
 go as CPUs come and
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* go. =A0cache_chain_mut=
ex is sufficient
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* protection here.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cachep->nodelists[node] =3D=
 l3;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irq(&cachep->nodelists[node]->lis=
t_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cachep->nodelists[node]->free_limit =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 + nr_cpus_node(node)) *
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cachep->batchcount + cachep=
->num;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irq(&cachep->nodelists[node]->l=
ist_lock);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return 0;
> +}
> +
> =A0static void __cpuinit cpuup_canceled(long cpu)
> =A0{
> =A0 =A0 =A0 =A0struct kmem_cache *cachep;
> @@ -1172,7 +1219,7 @@ static int __cpuinit cpuup_prepare(long cpu)
> =A0 =A0 =A0 =A0struct kmem_cache *cachep;
> =A0 =A0 =A0 =A0struct kmem_list3 *l3 =3D NULL;
> =A0 =A0 =A0 =A0int node =3D cpu_to_node(cpu);
> - =A0 =A0 =A0 const int memsize =3D sizeof(struct kmem_list3);
> + =A0 =A0 =A0 int err;
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * We need to do this right in the beginning since
> @@ -1180,35 +1227,9 @@ static int __cpuinit cpuup_prepare(long cpu)
> =A0 =A0 =A0 =A0 * kmalloc_node allows us to add the slab to the right
> =A0 =A0 =A0 =A0 * kmem_list3 and not this cpu's kmem_list3
> =A0 =A0 =A0 =A0 */
> -
> - =A0 =A0 =A0 list_for_each_entry(cachep, &cache_chain, next) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Set up the size64 kmemlist for cpu bef=
ore we can
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* begin anything. Make sure some other c=
pu on this
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* node has not already allocated this
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!cachep->nodelists[node]) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 l3 =3D kmalloc_node(memsize=
, GFP_KERNEL, node);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!l3)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto bad;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kmem_list3_init(l3);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 l3->next_reap =3D jiffies +=
 REAPTIMEOUT_LIST3 +
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ((unsigned long)cac=
hep) % REAPTIMEOUT_LIST3;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* The l3s don't come and=
 go as CPUs come and
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* go. =A0cache_chain_mut=
ex is sufficient
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* protection here.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cachep->nodelists[node] =3D=
 l3;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irq(&cachep->nodelists[node]->lis=
t_lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 cachep->nodelists[node]->free_limit =3D
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (1 + nr_cpus_node(node)) *
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cachep->batchcount + cachep=
->num;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irq(&cachep->nodelists[node]->l=
ist_lock);
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 err =3D init_cache_nodelists_node(node);
> + =A0 =A0 =A0 if (err < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto bad;
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Now we can go ahead with allocating the shared arrays a=
nd
> @@ -1331,11 +1352,75 @@ static struct notifier_block __cpuinitdata cpucac=
he_notifier =3D {
> =A0 =A0 =A0 =A0&cpuup_callback, NULL, 0
> =A0};
>
> +#if defined(CONFIG_NUMA) && defined(CONFIG_MEMORY_HOTPLUG)
> +/*
> + * Drains freelist for a node on each slab cache, used for memory hot-re=
move.
> + * Returns -EBUSY if all objects cannot be drained so that the node is n=
ot
> + * removed.
> + *
> + * Must hold cache_chain_mutex.
> + */
> +static int __meminit drain_cache_nodelists_node(int node)
> +{
> + =A0 =A0 =A0 struct kmem_cache *cachep;
> + =A0 =A0 =A0 int ret =3D 0;
> +
> + =A0 =A0 =A0 list_for_each_entry(cachep, &cache_chain, next) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct kmem_list3 *l3;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 l3 =3D cachep->nodelists[node];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!l3)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 drain_freelist(cachep, l3, l3->free_objects=
);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!list_empty(&l3->slabs_full) ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !list_empty(&l3->slabs_partial)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -EBUSY;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return ret;
> +}
> +
> +static int __meminit slab_memory_callback(struct notifier_block *self,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 unsigned long action, void *arg)
> +{
> + =A0 =A0 =A0 struct memory_notify *mnb =3D arg;
> + =A0 =A0 =A0 int ret =3D 0;
> + =A0 =A0 =A0 int nid;
> +
> + =A0 =A0 =A0 nid =3D mnb->status_change_nid;
> + =A0 =A0 =A0 if (nid < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> + =A0 =A0 =A0 switch (action) {
> + =A0 =A0 =A0 case MEM_GOING_ONLINE:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_lock(&cache_chain_mutex);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D init_cache_nodelists_node(nid);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&cache_chain_mutex);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 case MEM_GOING_OFFLINE:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_lock(&cache_chain_mutex);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D drain_cache_nodelists_node(nid);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&cache_chain_mutex);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 case MEM_ONLINE:
> + =A0 =A0 =A0 case MEM_OFFLINE:
> + =A0 =A0 =A0 case MEM_CANCEL_ONLINE:
> + =A0 =A0 =A0 case MEM_CANCEL_OFFLINE:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 }
> +out:
> + =A0 =A0 =A0 return ret ? notifier_from_errno(ret) : NOTIFY_OK;
> +}
> +#endif /* CONFIG_NUMA && CONFIG_MEMORY_HOTPLUG */
> +
> =A0/*
> =A0* swap the static kmem_list3 with kmalloced memory
> =A0*/
> -static void init_list(struct kmem_cache *cachep, struct kmem_list3 *list=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int nodeid)
> +static void __init init_list(struct kmem_cache *cachep, struct kmem_list=
3 *list,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int nodeid)
> =A0{
> =A0 =A0 =A0 =A0struct kmem_list3 *ptr;
>
> @@ -1580,6 +1665,14 @@ void __init kmem_cache_init_late(void)
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0register_cpu_notifier(&cpucache_notifier);
>
> +#ifdef CONFIG_NUMA
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Register a memory hotplug callback that initializes an=
d frees
> + =A0 =A0 =A0 =A0* nodelists.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 hotplug_memory_notifier(slab_memory_callback, SLAB_CALLBACK=
_PRI);
> +#endif
> +
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * The reap timers are started later, with a module init c=
all: That part
> =A0 =A0 =A0 =A0 * of the kernel is not yet operational.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
