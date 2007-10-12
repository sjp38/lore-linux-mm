Date: Thu, 11 Oct 2007 21:09:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [Patch 002/002] Create/delete kmem_cache_node for SLUB on memory
 online callback
In-Reply-To: <20071012112801.B9A1.Y-GOTO@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0710112056300.1882@schroedinger.engr.sgi.com>
References: <20071012111008.B995.Y-GOTO@jp.fujitsu.com>
 <20071012112236.B99B.Y-GOTO@jp.fujitsu.com> <20071012112801.B9A1.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1700579579-1160731744-1192162146=:1882"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

---1700579579-1160731744-1192162146=:1882
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Fri, 12 Oct 2007, Yasunori Goto wrote:
=20
> If pages on the new node available, slub can use it before making
> new kmem_cache_nodes. So, this callback should be called
> BEFORE pages on the node are available.

If its called before pages on the node are available then it must=20
fallback and cannot use the pages.

> +#if defined(CONFIG_NUMA) && defined(CONFIG_MEMORY_HOTPLUG)
> +static int slab_mem_going_offline_callback(void *arg)
> +{
> +=09struct kmem_cache *s;
> +=09struct memory_notify *marg =3D arg;
> +=09int local_node, offline_node =3D marg->status_change_nid;
> +
> +=09if (offline_node < 0)
> +=09=09/* node has memory yet. nothing to do. */

Please clarify the comment. This seems to indicate that we should not
do anything because the node still has memory?

Doesnt the node always have memory before offlining?

> +=09=09return 0;
> +
> +=09down_read(&slub_lock);
> +=09list_for_each_entry(s, &slab_caches, list) {
> +=09=09local_node =3D page_to_nid(virt_to_page(s));
> +=09=09if (local_node =3D=3D offline_node)
> +=09=09=09/* This slub is on the offline node. */
> +=09=09=09return -EBUSY;
> +=09}
> +=09up_read(&slub_lock);

So this checks if the any kmem_cache structure is on the offlined node? If
so then we cannot offline the node?


> +=09kmem_cache_shrink_node(s, offline_node);

kmem_cache_shrink(s) would be okay here I would think. The function is
reasonably fast. Offlining is a rare event.

> +static void slab_mem_offline_callback(void *arg)

We call this after we have established that no kmem_cache structures are=20
on this and after we have shrunk the slabs. Is there any guarantee that
no slab operations have occurrent since then?

> +{
> +=09struct kmem_cache_node *n;
> +=09struct kmem_cache *s;
> +=09struct memory_notify *marg =3D arg;
> +=09int offline_node;
> +
> +=09offline_node =3D marg->status_change_nid;
> +
> +=09if (offline_node < 0)
> +=09=09/* node has memory yet. nothing to do. */
> +=09=09return;

Does this mean that the node still has memory?

> +=09down_read(&slub_lock);
> +=09list_for_each_entry(s, &slab_caches, list) {
> +=09=09n =3D get_node(s, offline_node);
> +=09=09if (n) {
> +=09=09=09/*
> +=09=09=09 * if n->nr_slabs > 0, offline_pages() must be fail,
> +=09=09=09 * because the node is used by slub yet.
> +=09=09=09 */

It may be clearer to say:

"If nr_slabs > 0 then slabs still exist on the node that is going down.
We were unable to free them so we must fail."

> +static int slab_mem_going_online_callback(void *arg)
> +{
> +=09struct kmem_cache_node *n;
> +=09struct kmem_cache *s;
> +=09struct memory_notify *marg =3D arg;
> +=09int nid =3D marg->status_change_nid;
> +
> +=09/* If the node already has memory, then nothing is necessary. */
> +=09if (nid < 0)
> +=09=09return 0;

The node must have memory???? Or we have already brought up the code?

> +=09/*
> +=09 * New memory will be onlined on the node which has no memory so far.
> +=09 * New kmem_cache_node is necssary for it.

"We are bringing a node online. No memory is available yet. We must=20
allocate a kmem_cache_node structure in order to bring the node online." ?

> +=09 */
> +=09down_read(&slub_lock);
> +=09list_for_each_entry(s, &slab_caches, list) {
> +  =09=09/*
> +=09=09 * XXX: The new node's memory can't be allocated yet,
> +=09=09 *      kmem_cache_node will be allocated other node.
> +  =09=09 */

"kmem_cache_alloc node will fallback to other nodes since memory is=20
not yet available from the node that is brought up.=A8 ?

> +=09=09n =3D kmem_cache_alloc(kmalloc_caches, GFP_KERNEL);
> +=09=09if (!n)
> +=09=09=09return -ENOMEM;
> +=09=09init_kmem_cache_node(n);
> +=09=09s->node[nid] =3D n;
> +  =09}
> +=09up_read(&slub_lock);
> +
> +  =09return 0;
> +}
---1700579579-1160731744-1192162146=:1882--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
