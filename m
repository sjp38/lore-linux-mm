Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id BAD848D0039
	for <linux-mm@kvack.org>; Sat, 12 Feb 2011 21:05:40 -0500 (EST)
Received: by iwc10 with SMTP id 10so3751312iwc.14
        for <linux-mm@kvack.org>; Sat, 12 Feb 2011 18:05:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110207032508.GA27432@ca-server1.us.oracle.com>
References: <20110207032508.GA27432@ca-server1.us.oracle.com>
Date: Sun, 13 Feb 2011 11:05:35 +0900
Message-ID: <AANLkTimN0DYUbdPrVb+HvQC=HksVMngwqB=tFSV0reYA@mail.gmail.com>
Subject: Re: [PATCH V2 1/3] drivers/staging: zcache: in-kernel tmem code
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: gregkh@suse.de, chris.mason@oracle.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, kurt.hackel@oracle.com, npiggin@kernel.dk, riel@redhat.com, konrad.wilk@oracle.com, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, sfr@canb.auug.org.au, wfg@mail.ustc.edu.cn, tytso@mit.edu, viro@zeniv.linux.org.uk, hughd@google.com, hannes@cmpxchg.org

Hi Dan,

On Mon, Feb 7, 2011 at 12:25 PM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
> [PATCH V2 1/3] drivers/staging: zcache: in-kernel tmem code
>
> Transcendent memory ("tmem") is a clean API/ABI that provides
> for an efficient address translation and a set of highly
> concurrent access methods to copy data between a page-oriented
> data source (e.g. cleancache or frontswap) and a page-addressable
> memory ("PAM") data store. =C2=A0Of critical importance, the PAM data
> store is of unknown (and possibly varying) size so any individual
> access may succeed or fail as defined by the API/ABI.
>
> Tmem exports a basic set of access methods (e.g. put, get,
> flush, flush object, new pool, and destroy pool) which are
> normally called from a "host" (e.g. zcache).
>
> To be functional, two sets of "ops" must be registered by the
> host, one to provide "host services" (memory allocation) and
> one to provide page-addressable memory ("PAM") hooks.
>
> Tmem supports one or more "clients", each which can provide
> a set of "pools" to partition pages. =C2=A0Each pool contains
> a set of "objects"; each object holds pointers to some number
> of PAM page descriptors ("pampd"), indexed by an "index" number.
> This triple <pool id, object id, index> is sometimes referred
> to as a "handle". =C2=A0Tmem's primary function is to essentially
> provide address translation of handles into pampds and move
> data appropriately.
>
> As an example, for cleancache, a pool maps to a filesystem,
> an object maps to a file, and the index is the page offset
> into the file. =C2=A0And in this patch, zcache is the host and
> each PAM descriptor points to a compressed page of data.
>
> Tmem supports two kinds of pages: "ephemeral" and "persistent".
> Ephemeral pages may be asynchronously reclaimed "bottoms up"
> so the data structures and concurrency model must allow for
> this. =C2=A0For example, each pampd must retain sufficient information
> to invalidate tmem's handle-to-pampd translation.
> its containing object so that, on reclaim, all tmem data
> structures can be made consistent.
>
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
>
> ---
>
> Diffstat:
> =C2=A0drivers/staging/zcache/tmem.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0| =C2=A0710 +++++++++++++++++++++
> =C2=A0drivers/staging/zcache/tmem.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0| =C2=A0195 +++++
> =C2=A02 files changed, 905 insertions(+)
> --- linux-2.6.37/drivers/staging/zcache/tmem.c =C2=A01969-12-31 17:00:00.=
000000000 -0700
> +++ linux-2.6.37-zcache/drivers/staging/zcache/tmem.c =C2=A0 2011-02-05 1=
5:44:19.000000000 -0700
> @@ -0,0 +1,710 @@
> +/*
> + * In-kernel transcendent memory (generic implementation)
> + *
> + * Copyright (c) 2009-2011, Dan Magenheimer, Oracle Corp.
> + *
> + * The primary purpose of Transcedent Memory ("tmem") is to map object-o=
riented
> + * "handles" (triples containing a pool id, and object id, and an index)=
, to
> + * pages in a page-accessible memory (PAM). =C2=A0Tmem references the PA=
M pages via
> + * an abstract "pampd" (PAM page-descriptor), which can be operated on b=
y a
> + * set of functions (pamops). =C2=A0Each pampd contains some representat=
ion of
> + * PAGE_SIZE bytes worth of data. Tmem must support potentially millions=
 of
> + * pages and must be able to insert, find, and delete these pages at a
> + * potential frequency of thousands per second concurrently across many =
CPUs,
> + * (and, if used with KVM, across many vcpus across many guests).
> + * Tmem is tracked with a hierarchy of data structures, organized by
> + * the elements in a handle-tuple: pool_id, object_id, and page index.
> + * One or more "clients" (e.g. guests) each provide one or more tmem_poo=
ls.
> + * Each pool, contains a hash table of rb_trees of tmem_objs. =C2=A0Each
> + * tmem_obj contains a radix-tree-like tree of pointers, with intermedia=
te
> + * nodes called tmem_objnodes. =C2=A0Each leaf pointer in this tree poin=
ts to
> + * a pampd, which is accessible only through a small set of callbacks
> + * registered by the PAM implementation (see tmem_register_pamops). Tmem
> + * does all memory allocation via a set of callbacks registered by the t=
mem
> + * host implementation (e.g. see tmem_register_hostops).
> + */
> +
> +#include <linux/list.h>
> +#include <linux/spinlock.h>
> +#include <linux/atomic.h>
> +
> +#include "tmem.h"
> +
> +/* data structure sentinels used for debugging... see tmem.h */
> +#define POOL_SENTINEL 0x87658765
> +#define OBJ_SENTINEL 0x12345678
> +#define OBJNODE_SENTINEL 0xfedcba09
> +
> +/*
> + * A tmem host implementation must use this function to register callbac=
ks
> + * for memory allocation.
> + */

I think it would better to use "object management(ex, allocation,
free) " rather than vague "memory allocation".

And I am not sure it's good that support allocation flexibility.
(The flexibility is rather limited since user should implement it as
considering rb tree. We don't need to export policy to user)
I think we can implement general obj/objnode allocation in tmem to
hide it from host.
It can make client simple to use tmem but lost flexibility.
Do we really need the flexibility?

> +static struct tmem_hostops tmem_hostops;
> +
> +static void tmem_objnode_tree_init(void);
> +
> +void tmem_register_hostops(struct tmem_hostops *m)
> +{
> + =C2=A0 =C2=A0 =C2=A0 tmem_objnode_tree_init();
> + =C2=A0 =C2=A0 =C2=A0 tmem_hostops =3D *m;
> +}
> +
> +/*
> + * A tmem host implementation must use this function to register
> + * callbacks for a page-accessible memory (PAM) implementation
> + */

You said tmem_hostops is for memory allocation.
But said tmem_pamops is for PAM implementation?
It's not same level explanation.
I hope you write down it more clearly by same level.
(Ex, is for add/delete/get the page into PAM)

> +static struct tmem_pamops tmem_pamops;
> +
> +void tmem_register_pamops(struct tmem_pamops *m)
> +{
> + =C2=A0 =C2=A0 =C2=A0 tmem_pamops =3D *m;
> +}
> +
> +/*
> + * Oid's are potentially very sparse and tmem_objs may have an indetermi=
nately
> + * short life, being added and deleted at a relatively high frequency.
> + * So an rb_tree is an ideal data structure to manage tmem_objs. =C2=A0B=
ut because
> + * of the potentially huge number of tmem_objs, each pool manages a hash=
table
> + * of rb_trees to reduce search, insert, delete, and rebalancing time.
> + * Each hashbucket also has a lock to manage concurrent access.
> + *
> + * The following routines manage tmem_objs. =C2=A0When any tmem_obj is a=
ccessed,
> + * the hashbucket lock must be held.
> + */
> +
> +/* searches for object=3D=3Doid in pool, returns locked object if found =
*/

Returns locked object if found?
I can't find it in the code and merge the comment above, not separate phras=
e.

> +static struct tmem_obj *tmem_obj_find(struct tmem_hashbucket *hb,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct tmem_=
oid *oidp)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct rb_node *rbnode;
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_obj *obj;
> +
> + =C2=A0 =C2=A0 =C2=A0 rbnode =3D hb->obj_rb_root.rb_node;
> + =C2=A0 =C2=A0 =C2=A0 while (rbnode) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(RB_EMPTY_NODE(r=
bnode));
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 obj =3D rb_entry(rbnod=
e, struct tmem_obj, rb_tree_node);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 switch (tmem_oid_compa=
re(oidp, &obj->oid)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 case 0: /* equal */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 case -1:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 rbnode =3D rbnode->rb_left;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 case 1:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 rbnode =3D rbnode->rb_right;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 obj =3D NULL;
> +out:
> + =C2=A0 =C2=A0 =C2=A0 return obj;
> +}
> +
> +static void tmem_pampd_destroy_all_in_obj(struct tmem_obj *);
> +
> +/* free an object that has no more pampds in it */
> +static void tmem_obj_free(struct tmem_obj *obj, struct tmem_hashbucket *=
hb)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_pool *pool;
> +
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(obj =3D=3D NULL);

We don't need this BUG_ON. If obj is NULL, obj->pool is crashed then
we can know it.

> + =C2=A0 =C2=A0 =C2=A0 ASSERT_SENTINEL(obj, OBJ);
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(obj->pampd_count > 0);
> + =C2=A0 =C2=A0 =C2=A0 pool =3D obj->pool;
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(pool =3D=3D NULL);

Ditto. it is crashed at pool->obj_count.

> + =C2=A0 =C2=A0 =C2=A0 if (obj->objnode_tree_root !=3D NULL) /* may be "s=
tump" with no leaves */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tmem_pampd_destroy_all=
_in_obj(obj);
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(obj->objnode_tree_root !=3D NULL);
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON((long)obj->objnode_count !=3D 0);
> + =C2=A0 =C2=A0 =C2=A0 atomic_dec(&pool->obj_count);

Does we really need the atomic operation?
It seems it's protected by hash bucket lock.

Another topic.
I think hb->lock is very coarse-grained.
Maybe we need more fine-grained lock design to emphasis on your
concurrent benefit.

> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(atomic_read(&pool->obj_count) < 0);
> + =C2=A0 =C2=A0 =C2=A0 INVERT_SENTINEL(obj, OBJ);
> + =C2=A0 =C2=A0 =C2=A0 obj->pool =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 tmem_oid_set_invalid(&obj->oid);
> + =C2=A0 =C2=A0 =C2=A0 rb_erase(&obj->rb_tree_node, &hb->obj_rb_root);

For example, we can remove obj in rb tree and then we can clean up the obje=
ct.
It can reduce lock hold time.

> +}
> +
> +/*
> + * initialize, and insert an tmem_object_root (called only if find faile=
d)
> + */
> +static void tmem_obj_init(struct tmem_obj *obj, struct tmem_hashbucket *=
hb,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct tmem_=
pool *pool,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct tmem_=
oid *oidp)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct rb_root *root =3D &hb->obj_rb_root;
> + =C2=A0 =C2=A0 =C2=A0 struct rb_node **new =3D &(root->rb_node), *parent=
 =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_obj *this;
> +
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(pool =3D=3D NULL);
> + =C2=A0 =C2=A0 =C2=A0 atomic_inc(&pool->obj_count);
> + =C2=A0 =C2=A0 =C2=A0 obj->objnode_tree_height =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 obj->objnode_tree_root =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 obj->pool =3D pool;
> + =C2=A0 =C2=A0 =C2=A0 obj->oid =3D *oidp;
> + =C2=A0 =C2=A0 =C2=A0 obj->objnode_count =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 obj->pampd_count =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 SET_SENTINEL(obj, OBJ);
> + =C2=A0 =C2=A0 =C2=A0 while (*new) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(RB_EMPTY_NODE(*=
new));
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 this =3D rb_entry(*new=
, struct tmem_obj, rb_tree_node);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 parent =3D *new;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 switch (tmem_oid_compa=
re(oidp, &this->oid)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 case 0:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 BUG(); /* already present; should never happen! */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 case -1:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 new =3D &(*new)->rb_left;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 case 1:
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 new =3D &(*new)->rb_right;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 break;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 rb_link_node(&obj->rb_tree_node, parent, new);
> + =C2=A0 =C2=A0 =C2=A0 rb_insert_color(&obj->rb_tree_node, root);
> +}
> +
> +/*
> + * Tmem is managed as a set of tmem_pools with certain attributes, such =
as
> + * "ephemeral" vs "persistent". =C2=A0These attributes apply to all tmem=
_objs
> + * and all pampds that belong to a tmem_pool. =C2=A0A tmem_pool is creat=
ed
> + * or deleted relatively rarely (for example, when a filesystem is
> + * mounted or unmounted.

Although it's rare, it might take a long time to clear all object.
We can use cond_resched when it doesn't hold spin_lock.

> + */
> +
> +/* flush all data from a pool and, optionally, free it */

I think it would be better to use term "object" rather than "data".

> +static void tmem_pool_flush(struct tmem_pool *pool, bool destroy)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct rb_node *rbnode;
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_obj *obj;
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_hashbucket *hb =3D &pool->hashbucket[0=
];
> + =C2=A0 =C2=A0 =C2=A0 int i;
> +
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(pool =3D=3D NULL);
> + =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < TMEM_HASH_BUCKETS; i++, hb++) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock(&hb->lock);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rbnode =3D rb_first(&h=
b->obj_rb_root);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 while (rbnode !=3D NUL=
L) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 obj =3D rb_entry(rbnode, struct tmem_obj, rb_tree_node);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 rbnode =3D rb_next(rbnode);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 tmem_pampd_destroy_all_in_obj(obj);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 tmem_obj_free(obj, hb);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 (*tmem_hostops.obj_free)(obj, pool);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock(&hb->lock)=
;
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 if (destroy)

I don't see any use case of not-destroy.
What do you have in your mind?

> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_del(&pool->pool_l=
ist);
> +}
> +
> +/*
> + * A tmem_obj contains a radix-tree-like tree in which the intermediate
> + * nodes are called tmem_objnodes. =C2=A0(The kernel lib/radix-tree.c im=
plementation
> + * is very specialized and tuned for specific uses and is not particular=
ly
> + * suited for use from this code, though some code from the core algorit=
hms has
> + * been reused, thus the copyright notices below). =C2=A0Each tmem_objno=
de contains
> + * a set of pointers which point to either a set of intermediate tmem_ob=
jnodes
> + * or a set of of pampds.

I remember you sent the patch which point out current radix-tree problem.
Sorry for not follow that.

Anyway, I think it would be better to separate this patch into another
tmem-radix-tree.c and write down the description in the patch why we
need new radix-tree in detail.
Sorry for bothering you.

> + *
> + * Portions Copyright (C) 2001 Momchil Velikov
> + * Portions Copyright (C) 2001 Christoph Hellwig
> + * Portions Copyright (C) 2005 SGI, Christoph Lameter <clameter@sgi.com>
> + */
> +
> +struct tmem_objnode_tree_path {
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_objnode *objnode;
> + =C2=A0 =C2=A0 =C2=A0 int offset;
> +};
> +
> +/* objnode height_to_maxindex translation */
> +static unsigned long tmem_objnode_tree_h2max[OBJNODE_TREE_MAX_PATH + 1];
> +
> +static void tmem_objnode_tree_init(void)
> +{
> + =C2=A0 =C2=A0 =C2=A0 unsigned int ht, tmp;
> +
> + =C2=A0 =C2=A0 =C2=A0 for (ht =3D 0; ht < ARRAY_SIZE(tmem_objnode_tree_h=
2max); ht++) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tmp =3D ht * OBJNODE_T=
REE_MAP_SHIFT;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (tmp >=3D OBJNODE_T=
REE_INDEX_BITS)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 tmem_objnode_tree_h2max[ht] =3D ~0UL;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 tmem_objnode_tree_h2max[ht] =3D
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 (~0UL >> (OBJNODE_TREE_INDEX_BITS - tmp - 1)) >> 1;
> + =C2=A0 =C2=A0 =C2=A0 }
> +}
> +
> +static struct tmem_objnode *tmem_objnode_alloc(struct tmem_obj *obj)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_objnode *objnode;
> +
> + =C2=A0 =C2=A0 =C2=A0 ASSERT_SENTINEL(obj, OBJ);
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(obj->pool =3D=3D NULL);
> + =C2=A0 =C2=A0 =C2=A0 ASSERT_SENTINEL(obj->pool, POOL);
> + =C2=A0 =C2=A0 =C2=A0 objnode =3D (*tmem_hostops.objnode_alloc)(obj->poo=
l);
> + =C2=A0 =C2=A0 =C2=A0 if (unlikely(objnode =3D=3D NULL))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 objnode->obj =3D obj;
> + =C2=A0 =C2=A0 =C2=A0 SET_SENTINEL(objnode, OBJNODE);
> + =C2=A0 =C2=A0 =C2=A0 memset(&objnode->slots, 0, sizeof(objnode->slots))=
;
> + =C2=A0 =C2=A0 =C2=A0 objnode->slots_in_use =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 obj->objnode_count++;
> +out:
> + =C2=A0 =C2=A0 =C2=A0 return objnode;
> +}
> +
> +static void tmem_objnode_free(struct tmem_objnode *objnode)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_pool *pool;
> + =C2=A0 =C2=A0 =C2=A0 int i;
> +
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(objnode =3D=3D NULL);
> + =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < OBJNODE_TREE_MAP_SIZE; i++)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(objnode->slots[=
i] !=3D NULL);
> + =C2=A0 =C2=A0 =C2=A0 ASSERT_SENTINEL(objnode, OBJNODE);
> + =C2=A0 =C2=A0 =C2=A0 INVERT_SENTINEL(objnode, OBJNODE);
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(objnode->obj =3D=3D NULL);
> + =C2=A0 =C2=A0 =C2=A0 ASSERT_SENTINEL(objnode->obj, OBJ);
> + =C2=A0 =C2=A0 =C2=A0 pool =3D objnode->obj->pool;
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(pool =3D=3D NULL);
> + =C2=A0 =C2=A0 =C2=A0 ASSERT_SENTINEL(pool, POOL);
> + =C2=A0 =C2=A0 =C2=A0 objnode->obj->objnode_count--;
> + =C2=A0 =C2=A0 =C2=A0 objnode->obj =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 (*tmem_hostops.objnode_free)(objnode, pool);
> +}
> +
> +/*
> + * lookup index in object and return associated pampd (or NULL if not fo=
und)
> + */
> +static void *tmem_pampd_lookup_in_obj(struct tmem_obj *obj, uint32_t ind=
ex)
> +{
> + =C2=A0 =C2=A0 =C2=A0 unsigned int height, shift;
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_objnode **slot =3D NULL;
> +
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(obj =3D=3D NULL);
> + =C2=A0 =C2=A0 =C2=A0 ASSERT_SENTINEL(obj, OBJ);
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(obj->pool =3D=3D NULL);
> + =C2=A0 =C2=A0 =C2=A0 ASSERT_SENTINEL(obj->pool, POOL);
> +
> + =C2=A0 =C2=A0 =C2=A0 height =3D obj->objnode_tree_height;
> + =C2=A0 =C2=A0 =C2=A0 if (index > tmem_objnode_tree_h2max[obj->objnode_t=
ree_height])
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 if (height =3D=3D 0 && obj->objnode_tree_root) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 slot =3D &obj->objnode=
_tree_root;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 shift =3D (height-1) * OBJNODE_TREE_MAP_SHIFT;
> + =C2=A0 =C2=A0 =C2=A0 slot =3D &obj->objnode_tree_root;
> + =C2=A0 =C2=A0 =C2=A0 while (height > 0) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (*slot =3D=3D NULL)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 slot =3D (struct tmem_=
objnode **)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 ((*slot)->slots +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0((index >> shift) & OBJNODE_TREE_MAP_MASK));
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 shift -=3D OBJNODE_TRE=
E_MAP_SHIFT;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 height--;
> + =C2=A0 =C2=A0 =C2=A0 }
> +out:
> + =C2=A0 =C2=A0 =C2=A0 return slot !=3D NULL ? *slot : NULL;
> +}
> +
> +static int tmem_pampd_add_to_obj(struct tmem_obj *obj, uint32_t index,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 void *pampd)
> +{
> + =C2=A0 =C2=A0 =C2=A0 int ret =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_objnode *objnode =3D NULL, *newnode, *=
slot;
> + =C2=A0 =C2=A0 =C2=A0 unsigned int height, shift;
> + =C2=A0 =C2=A0 =C2=A0 int offset =3D 0;
> +
> + =C2=A0 =C2=A0 =C2=A0 /* if necessary, extend the tree to be higher =C2=
=A0*/
> + =C2=A0 =C2=A0 =C2=A0 if (index > tmem_objnode_tree_h2max[obj->objnode_t=
ree_height]) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 height =3D obj->objnod=
e_tree_height + 1;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (index > tmem_objno=
de_tree_h2max[height])
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 while (index > tmem_objnode_tree_h2max[height])
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 height++;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (obj->objnode_tree_=
root =3D=3D NULL) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 obj->objnode_tree_height =3D height;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto insert;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 do {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 newnode =3D tmem_objnode_alloc(obj);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (!newnode) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D -ENOMEM;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 newnode->slots[0] =3D obj->objnode_tree_root;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 newnode->slots_in_use =3D 1;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 obj->objnode_tree_root =3D newnode;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 obj->objnode_tree_height++;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } while (height > obj-=
>objnode_tree_height);
> + =C2=A0 =C2=A0 =C2=A0 }
> +insert:
> + =C2=A0 =C2=A0 =C2=A0 slot =3D obj->objnode_tree_root;
> + =C2=A0 =C2=A0 =C2=A0 height =3D obj->objnode_tree_height;
> + =C2=A0 =C2=A0 =C2=A0 shift =3D (height-1) * OBJNODE_TREE_MAP_SHIFT;
> + =C2=A0 =C2=A0 =C2=A0 while (height > 0) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (slot =3D=3D NULL) =
{
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 /* add a child objnode. =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 slot =3D tmem_objnode_alloc(obj);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (!slot) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D -ENOMEM;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (objnode) {
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 objnode->slots[offset] =3D slot;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 objnode->slots_in_use++;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 } else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 obj->objnode_tree_root =3D slot;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* go down a level */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 offset =3D (index >> s=
hift) & OBJNODE_TREE_MAP_MASK;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 objnode =3D slot;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 slot =3D objnode->slot=
s[offset];
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 shift -=3D OBJNODE_TRE=
E_MAP_SHIFT;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 height--;
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(slot !=3D NULL);
> + =C2=A0 =C2=A0 =C2=A0 if (objnode) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 objnode->slots_in_use+=
+;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 objnode->slots[offset]=
 =3D pampd;
> + =C2=A0 =C2=A0 =C2=A0 } else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 obj->objnode_tree_root=
 =3D pampd;
> + =C2=A0 =C2=A0 =C2=A0 obj->pampd_count++;
> +out:
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> +}
> +
> +static void *tmem_pampd_delete_from_obj(struct tmem_obj *obj, uint32_t i=
ndex)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_objnode_tree_path path[OBJNODE_TREE_MA=
X_PATH + 1];
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_objnode_tree_path *pathp =3D path;
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_objnode *slot =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 unsigned int height, shift;
> + =C2=A0 =C2=A0 =C2=A0 int offset;
> +
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(obj =3D=3D NULL);
> + =C2=A0 =C2=A0 =C2=A0 ASSERT_SENTINEL(obj, OBJ);
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(obj->pool =3D=3D NULL);
> + =C2=A0 =C2=A0 =C2=A0 ASSERT_SENTINEL(obj->pool, POOL);
> + =C2=A0 =C2=A0 =C2=A0 height =3D obj->objnode_tree_height;
> + =C2=A0 =C2=A0 =C2=A0 if (index > tmem_objnode_tree_h2max[height])
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 slot =3D obj->objnode_tree_root;
> + =C2=A0 =C2=A0 =C2=A0 if (height =3D=3D 0 && obj->objnode_tree_root) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 obj->objnode_tree_root=
 =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 shift =3D (height - 1) * OBJNODE_TREE_MAP_SHIFT;
> + =C2=A0 =C2=A0 =C2=A0 pathp->objnode =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 do {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (slot =3D=3D NULL)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pathp++;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 offset =3D (index >> s=
hift) & OBJNODE_TREE_MAP_MASK;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pathp->offset =3D offs=
et;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pathp->objnode =3D slo=
t;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 slot =3D slot->slots[o=
ffset];
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 shift -=3D OBJNODE_TRE=
E_MAP_SHIFT;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 height--;
> + =C2=A0 =C2=A0 =C2=A0 } while (height > 0);
> + =C2=A0 =C2=A0 =C2=A0 if (slot =3D=3D NULL)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 while (pathp->objnode) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pathp->objnode->slots[=
pathp->offset] =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pathp->objnode->slots_=
in_use--;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (pathp->objnode->sl=
ots_in_use) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (pathp->objnode =3D=3D obj->objnode_tree_root) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 while (obj->objnode_tree_height > 0 &&
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 obj->objnode_tree_root->slots_in_=
use =3D=3D 1 &&
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 obj->objnode_tree_root->slots[0])=
 {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct tmem_=
objnode *to_free =3D
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 obj->objnode_tree_root;
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 obj->objnode=
_tree_root =3D
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 to_free->slots[0];
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 obj->objnode=
_tree_height--;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 to_free->slo=
ts[0] =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 to_free->slo=
ts_in_use =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tmem_objnode=
_free(to_free);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tmem_objnode_free(path=
p->objnode); /* 0 slots used, free it */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pathp--;
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 obj->objnode_tree_height =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 obj->objnode_tree_root =3D NULL;
> +
> +out:
> + =C2=A0 =C2=A0 =C2=A0 if (slot !=3D NULL)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 obj->pampd_count--;
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(obj->pampd_count < 0);
> + =C2=A0 =C2=A0 =C2=A0 return slot;
> +}
> +
> +/* recursively walk the objnode_tree destroying pampds and objnodes */
> +static void tmem_objnode_node_destroy(struct tmem_obj *obj,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct tmem_=
objnode *objnode,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned int=
 ht)
> +{
> + =C2=A0 =C2=A0 =C2=A0 int i;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (ht =3D=3D 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
> + =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < OBJNODE_TREE_MAP_SIZE; i++) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (objnode->slots[i])=
 {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (ht =3D=3D 1) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 obj->pampd_count--;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (*tmem_pamops.free)(objnode->slots[i],
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 o=
bj->pool);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 objnode->slots[i] =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 continue;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 tmem_objnode_node_destroy(obj, objnode->slots[i], ht-1);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 tmem_objnode_free(objnode->slots[i]);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 objnode->slots[i] =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 }
> +}
> +
> +static void tmem_pampd_destroy_all_in_obj(struct tmem_obj *obj)
> +{
> + =C2=A0 =C2=A0 =C2=A0 if (obj->objnode_tree_root =3D=3D NULL)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
> + =C2=A0 =C2=A0 =C2=A0 if (obj->objnode_tree_height =3D=3D 0) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 obj->pampd_count--;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (*tmem_pamops.free)(ob=
j->objnode_tree_root, obj->pool);
> + =C2=A0 =C2=A0 =C2=A0 } else {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tmem_objnode_node_dest=
roy(obj, obj->objnode_tree_root,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 obj->objnode=
_tree_height);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tmem_objnode_free(obj-=
>objnode_tree_root);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 obj->objnode_tree_heig=
ht =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 obj->objnode_tree_root =3D NULL;
> +}
> +
> +/*
> + * Tmem is operated on by a set of well-defined actions:
> + * "put", "get", "flush", "flush_object", "new pool" and "destroy pool".
> + * (The tmem ABI allows for subpages and exchanges but these operations
> + * are not included in this implementation.)
> + *
> + * These "tmem core" operations are implemented in the following functio=
ns.
> + */
> +
> +/*
> + * "Put" a page, e.g. copy a page from the kernel into newly allocated
> + * PAM space (if such space is available). =C2=A0Tmem_put is complicated=
 by
> + * a corner case: What if a page with matching handle already exists in
> + * tmem? =C2=A0To guarantee coherency, one of two actions is necessary: =
Either
> + * the data for the page must be overwritten, or the page must be
> + * "flushed" so that the data is not accessible to a subsequent "get".
> + * Since these "duplicate puts" are relatively rare, this implementation
> + * always flushes for simplicity.
> + */
> +int tmem_put(struct tmem_pool *pool, struct tmem_oid *oidp, uint32_t ind=
ex,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct page *page)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_obj *obj =3D NULL, *objfound =3D NULL,=
 *objnew =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 void *pampd =3D NULL, *pampd_del =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 int ret =3D -ENOMEM;
> + =C2=A0 =C2=A0 =C2=A0 bool ephemeral;
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_hashbucket *hb;
> +
> + =C2=A0 =C2=A0 =C2=A0 ephemeral =3D is_ephemeral(pool);
> + =C2=A0 =C2=A0 =C2=A0 hb =3D &pool->hashbucket[tmem_oid_hash(oidp)];
> + =C2=A0 =C2=A0 =C2=A0 spin_lock(&hb->lock);

This spin_lock means we can't call *put* in interrupt context.
But now we can call put_page in intrrupt context.
I see zcache_put_page checks irqs_disabled so now it's okay.
But zcache is just only one client of tmem. In future, another client
can call it in interrupt context.

Do you intent to limit calling it in only not-interrupt context by design?

> + =C2=A0 =C2=A0 =C2=A0 obj =3D objfound =3D tmem_obj_find(hb, oidp);
> + =C2=A0 =C2=A0 =C2=A0 if (obj !=3D NULL) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pampd =3D tmem_pampd_l=
ookup_in_obj(objfound, index);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (pampd !=3D NULL) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 /* if found, is a dup put, flush the old one */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 pampd_del =3D tmem_pampd_delete_from_obj(obj, index);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 BUG_ON(pampd_del !=3D pampd);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 (*tmem_pamops.free)(pampd, pool);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (obj->pampd_count =3D=3D 0) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 objnew =3D obj;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 objfound =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 pampd =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 } else {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 obj =3D objnew =3D (*t=
mem_hostops.obj_alloc)(pool);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (unlikely(obj =3D=
=3D NULL)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 ret =3D -ENOMEM;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tmem_obj_init(obj, hb,=
 pool, oidp);
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(obj =3D=3D NULL);
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(((objnew !=3D obj) && (objfound !=3D obj)) =
|| (objnew =3D=3D objfound));
> + =C2=A0 =C2=A0 =C2=A0 pampd =3D (*tmem_pamops.create)(obj->pool, &obj->o=
id, index, page);
> + =C2=A0 =C2=A0 =C2=A0 if (unlikely(pampd =3D=3D NULL))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto free;
> + =C2=A0 =C2=A0 =C2=A0 ret =3D tmem_pampd_add_to_obj(obj, index, pampd);
> + =C2=A0 =C2=A0 =C2=A0 if (unlikely(ret =3D=3D -ENOMEM))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* may have partially =
built objnode tree ("stump") */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto delete_and_free;
> + =C2=A0 =C2=A0 =C2=A0 goto out;
> +
> +delete_and_free:
> + =C2=A0 =C2=A0 =C2=A0 (void)tmem_pampd_delete_from_obj(obj, index);
> +free:
> + =C2=A0 =C2=A0 =C2=A0 if (pampd)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (*tmem_pamops.free)(pa=
mpd, pool);
> + =C2=A0 =C2=A0 =C2=A0 if (objnew) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tmem_obj_free(objnew, =
hb);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (*tmem_hostops.obj_fre=
e)(objnew, pool);
> + =C2=A0 =C2=A0 =C2=A0 }
> +out:
> + =C2=A0 =C2=A0 =C2=A0 spin_unlock(&hb->lock);
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> +}
> +
> +/*
> + * "Get" a page, e.g. if one can be found, copy the tmem page with the
> + * matching handle from PAM space to the kernel. =C2=A0By tmem definitio=
n,
> + * when a "get" is successful on an ephemeral page, the page is "flushed=
",
> + * and when a "get" is successful on a persistent page, the page is reta=
ined
> + * in tmem. =C2=A0Note that to preserve
> + * coherency, "get" can never be skipped if tmem contains the data.
> + * That is, if a get is done with a certain handle and fails, any
> + * subsequent "get" must also fail (unless of course there is a
> + * "put" done with the same handle).
> +
> + */
> +int tmem_get(struct tmem_pool *pool, struct tmem_oid *oidp,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 uint32_t index, struct page *page)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_obj *obj;
> + =C2=A0 =C2=A0 =C2=A0 void *pampd;
> + =C2=A0 =C2=A0 =C2=A0 bool ephemeral =3D is_ephemeral(pool);
> + =C2=A0 =C2=A0 =C2=A0 uint32_t ret =3D -1;
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_hashbucket *hb;
> +
> + =C2=A0 =C2=A0 =C2=A0 hb =3D &pool->hashbucket[tmem_oid_hash(oidp)];
> + =C2=A0 =C2=A0 =C2=A0 spin_lock(&hb->lock);
> + =C2=A0 =C2=A0 =C2=A0 obj =3D tmem_obj_find(hb, oidp);
> + =C2=A0 =C2=A0 =C2=A0 if (obj =3D=3D NULL)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 ephemeral =3D is_ephemeral(pool);
> + =C2=A0 =C2=A0 =C2=A0 if (ephemeral)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pampd =3D tmem_pampd_d=
elete_from_obj(obj, index);

I hope you write down about this exclusive characteristic of ephemeral
in description.

> + =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pampd =3D tmem_pampd_l=
ookup_in_obj(obj, index);
> + =C2=A0 =C2=A0 =C2=A0 if (pampd =3D=3D NULL)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 ret =3D (*tmem_pamops.get_data)(page, pampd, pool)=
;
> + =C2=A0 =C2=A0 =C2=A0 if (ret < 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 if (ephemeral) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (*tmem_pamops.free)(pa=
mpd, pool);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (obj->pampd_count =
=3D=3D 0) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 tmem_obj_free(obj, hb);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 (*tmem_hostops.obj_free)(obj, pool);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 obj =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 ret =3D 0;
> +out:
> + =C2=A0 =C2=A0 =C2=A0 spin_unlock(&hb->lock);
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> +}
> +
> +/*
> + * If a page in tmem matches the handle, "flush" this page from tmem suc=
h
> + * that any subsequent "get" does not succeed (unless, of course, there
> + * was another "put" with the same handle).
> + */
> +int tmem_flush_page(struct tmem_pool *pool,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct tmem_oid *oidp, uint32_t index)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_obj *obj;
> + =C2=A0 =C2=A0 =C2=A0 void *pampd;
> + =C2=A0 =C2=A0 =C2=A0 int ret =3D -1;
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_hashbucket *hb;
> +
> + =C2=A0 =C2=A0 =C2=A0 hb =3D &pool->hashbucket[tmem_oid_hash(oidp)];
> + =C2=A0 =C2=A0 =C2=A0 spin_lock(&hb->lock);
> + =C2=A0 =C2=A0 =C2=A0 obj =3D tmem_obj_find(hb, oidp);
> + =C2=A0 =C2=A0 =C2=A0 if (obj =3D=3D NULL)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 pampd =3D tmem_pampd_delete_from_obj(obj, index);
> + =C2=A0 =C2=A0 =C2=A0 if (pampd =3D=3D NULL)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 (*tmem_pamops.free)(pampd, pool);
> + =C2=A0 =C2=A0 =C2=A0 if (obj->pampd_count =3D=3D 0) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 tmem_obj_free(obj, hb)=
;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (*tmem_hostops.obj_fre=
e)(obj, pool);
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 ret =3D 0;
> +
> +out:
> + =C2=A0 =C2=A0 =C2=A0 spin_unlock(&hb->lock);
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> +}
> +
> +/*
> + * "Flush" all pages in tmem matching this oid.
> + */
> +int tmem_flush_object(struct tmem_pool *pool, struct tmem_oid *oidp)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_obj *obj;
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_hashbucket *hb;
> + =C2=A0 =C2=A0 =C2=A0 int ret =3D -1;
> +
> + =C2=A0 =C2=A0 =C2=A0 hb =3D &pool->hashbucket[tmem_oid_hash(oidp)];
> + =C2=A0 =C2=A0 =C2=A0 spin_lock(&hb->lock);
> + =C2=A0 =C2=A0 =C2=A0 obj =3D tmem_obj_find(hb, oidp);
> + =C2=A0 =C2=A0 =C2=A0 if (obj =3D=3D NULL)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 tmem_pampd_destroy_all_in_obj(obj);
> + =C2=A0 =C2=A0 =C2=A0 tmem_obj_free(obj, hb);
> + =C2=A0 =C2=A0 =C2=A0 (*tmem_hostops.obj_free)(obj, pool);
> + =C2=A0 =C2=A0 =C2=A0 ret =3D 0;
> +
> +out:
> + =C2=A0 =C2=A0 =C2=A0 spin_unlock(&hb->lock);

Couldn't we make hb->lock by fine-grained with a new design?

spin_lock
obj =3D tmem_obj_find
tmem_obj_free
spin_unlock
tmem_pampd_destroy_all_in_obj
(*tmem_hostops.obj_free)



> + =C2=A0 =C2=A0 =C2=A0 return ret;
> +}
> +
> +/*
> + * "Flush" all pages (and tmem_objs) from this tmem_pool and disable
> + * all subsequent access to this tmem_pool.
> + */
> +int tmem_destroy_pool(struct tmem_pool *pool)
> +{
> + =C2=A0 =C2=A0 =C2=A0 int ret =3D -1;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (pool =3D=3D NULL)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
> + =C2=A0 =C2=A0 =C2=A0 tmem_pool_flush(pool, 1);
> + =C2=A0 =C2=A0 =C2=A0 ret =3D 0;
> +out:
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> +}
> +
> +static LIST_HEAD(tmem_global_pool_list);
> +
> +/*
> + * Create a new tmem_pool with the provided flag and return
> + * a pool id provided by the tmem host implementation.
> + */
> +void tmem_new_pool(struct tmem_pool *pool, uint32_t flags)
> +{
> + =C2=A0 =C2=A0 =C2=A0 int persistent =3D flags & TMEM_POOL_PERSIST;
> + =C2=A0 =C2=A0 =C2=A0 int shared =3D flags & TMEM_POOL_SHARED;
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_hashbucket *hb =3D &pool->hashbucket[0=
];
> + =C2=A0 =C2=A0 =C2=A0 int i;
> +
> + =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < TMEM_HASH_BUCKETS; i++, hb++) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 hb->obj_rb_root =3D RB=
_ROOT;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock_init(&hb->lo=
ck);
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 INIT_LIST_HEAD(&pool->pool_list);
> + =C2=A0 =C2=A0 =C2=A0 atomic_set(&pool->obj_count, 0);
> + =C2=A0 =C2=A0 =C2=A0 SET_SENTINEL(pool, POOL);
> + =C2=A0 =C2=A0 =C2=A0 list_add_tail(&pool->pool_list, &tmem_global_pool_=
list);
> + =C2=A0 =C2=A0 =C2=A0 pool->persistent =3D persistent;
> + =C2=A0 =C2=A0 =C2=A0 pool->shared =3D shared;
> +}
> --- linux-2.6.37/drivers/staging/zcache/tmem.h =C2=A01969-12-31 17:00:00.=
000000000 -0700
> +++ linux-2.6.37-zcache/drivers/staging/zcache/tmem.h =C2=A0 2011-02-05 1=
5:44:19.000000000 -0700
> @@ -0,0 +1,195 @@
> +/*
> + * tmem.h
> + *
> + * Transcendent memory
> + *
> + * Copyright (c) 2009-2011, Dan Magenheimer, Oracle Corp.
> + */
> +
> +#ifndef _TMEM_H_
> +#define _TMEM_H_
> +
> +#include <linux/types.h>
> +#include <linux/highmem.h>
> +#include <linux/hash.h>
> +#include <linux/atomic.h>
> +
> +/*
> + * These are pre-defined by the Xen<->Linux ABI
> + */
> +#define TMEM_PUT_PAGE =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A04
> +#define TMEM_GET_PAGE =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A05
> +#define TMEM_FLUSH_PAGE =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A06
> +#define TMEM_FLUSH_OBJECT =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A07
> +#define TMEM_POOL_PERSIST =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A01
> +#define TMEM_POOL_SHARED =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 2
> +#define TMEM_POOL_PRECOMPRESSED =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A04
> +#define TMEM_POOL_PAGESIZE_SHIFT =C2=A0 =C2=A0 =C2=A0 4
> +#define TMEM_POOL_PAGESIZE_MASK =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A00xf
> +#define TMEM_POOL_RESERVED_BITS =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A00x00ffff00
> +
> +/*
> + * sentinels have proven very useful for debugging but can be removed
> + * or disabled before final merge.
> + */
> +#define SENTINELS
> +#ifdef SENTINELS
> +#define DECL_SENTINEL uint32_t sentinel;
> +#define SET_SENTINEL(_x, _y) (_x->sentinel =3D _y##_SENTINEL)
> +#define INVERT_SENTINEL(_x, _y) (_x->sentinel =3D ~_y##_SENTINEL)
> +#define ASSERT_SENTINEL(_x, _y) WARN_ON(_x->sentinel !=3D _y##_SENTINEL)
> +#define ASSERT_INVERTED_SENTINEL(_x, _y) WARN_ON(_x->sentinel !=3D ~_y##=
_SENTINEL)
> +#else
> +#define DECL_SENTINEL
> +#define SET_SENTINEL(_x, _y) do { } while (0)
> +#define INVERT_SENTINEL(_x, _y) do { } while (0)
> +#define ASSERT_SENTINEL(_x, _y) do { } while (0)
> +#define ASSERT_INVERTED_SENTINEL(_x, _y) do { } while (0)
> +#endif
> +
> +#define ASSERT_SPINLOCK(_l) =C2=A0 =C2=A0WARN_ON(!spin_is_locked(_l))
> +
> +/*
> + * A pool is the highest-level data structure managed by tmem and
> + * usually corresponds to a large independent set of pages such as
> + * a filesystem. =C2=A0Each pool has an id, and certain attributes and c=
ounters.
> + * It also contains a set of hash buckets, each of which contains an rbt=
ree
> + * of objects and a lock to manage concurrency within the pool.
> + */
> +
> +#define TMEM_HASH_BUCKET_BITS =C2=A08
> +#define TMEM_HASH_BUCKETS =C2=A0 =C2=A0 =C2=A0(1<<TMEM_HASH_BUCKET_BITS)
> +
> +struct tmem_hashbucket {
> + =C2=A0 =C2=A0 =C2=A0 struct rb_root obj_rb_root;
> + =C2=A0 =C2=A0 =C2=A0 spinlock_t lock;
> +};
> +
> +struct tmem_pool {
> + =C2=A0 =C2=A0 =C2=A0 void *client; /* "up" for some clients, avoids tab=
le lookup */
> + =C2=A0 =C2=A0 =C2=A0 struct list_head pool_list;
> + =C2=A0 =C2=A0 =C2=A0 uint32_t pool_id;
> + =C2=A0 =C2=A0 =C2=A0 bool persistent;
> + =C2=A0 =C2=A0 =C2=A0 bool shared;

Just nitpick.
Do we need two each variable for persist and shared?
Couldn't we merge it into just one "flag variable"?

> + =C2=A0 =C2=A0 =C2=A0 atomic_t obj_count;
> + =C2=A0 =C2=A0 =C2=A0 atomic_t refcount;
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_hashbucket hashbucket[TMEM_HASH_BUCKET=
S];
> + =C2=A0 =C2=A0 =C2=A0 DECL_SENTINEL
> +};
> +
> +#define is_persistent(_p) =C2=A0(_p->persistent)
> +#define is_ephemeral(_p) =C2=A0 (!(_p->persistent))
> +
> +/*
> + * An object id ("oid") is large: 192-bits (to ensure, for example, file=
s
> + * in a modern filesystem can be uniquely identified).
> + */
> +
> +struct tmem_oid {
> + =C2=A0 =C2=A0 =C2=A0 uint64_t oid[3];
> +};
> +
> +static inline void tmem_oid_set_invalid(struct tmem_oid *oidp)
> +{
> + =C2=A0 =C2=A0 =C2=A0 oidp->oid[0] =3D oidp->oid[1] =3D oidp->oid[2] =3D=
 -1UL;
> +}
> +
> +static inline bool tmem_oid_valid(struct tmem_oid *oidp)
> +{
> + =C2=A0 =C2=A0 =C2=A0 return oidp->oid[0] !=3D -1UL || oidp->oid[1] !=3D=
 -1UL ||
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 oidp->oid[2] !=3D -1UL=
;
> +}
> +
> +static inline int tmem_oid_compare(struct tmem_oid *left,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct tmem_=
oid *right)
> +{
> + =C2=A0 =C2=A0 =C2=A0 int ret;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (left->oid[2] =3D=3D right->oid[2]) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (left->oid[1] =3D=
=3D right->oid[1]) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (left->oid[0] =3D=3D right->oid[0])
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 else if (left->oid[0] < right->oid[0])
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D -1;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 1;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } else if (left->oid[1=
] < right->oid[1])
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 ret =3D -1;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 ret =3D 1;
> + =C2=A0 =C2=A0 =C2=A0 } else if (left->oid[2] < right->oid[2])
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D -1;
> + =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D 1;
> + =C2=A0 =C2=A0 =C2=A0 return ret;
> +}
> +
> +static inline unsigned tmem_oid_hash(struct tmem_oid *oidp)
> +{
> + =C2=A0 =C2=A0 =C2=A0 return hash_long(oidp->oid[0] ^ oidp->oid[1] ^ oid=
p->oid[2],
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 TMEM_HASH_BUCKET_BITS);
> +}
> +
> +/*
> + * A tmem_obj contains an identifier (oid), pointers to the parent
> + * pool and the rb_tree to which it belongs, counters, and an ordered
> + * set of pampds, structured in a radix-tree-like tree. =C2=A0The interm=
ediate
> + * nodes of the tree are called tmem_objnodes.
> + */
> +
> +struct tmem_objnode;
> +
> +struct tmem_obj {
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_oid oid;
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_pool *pool;
> + =C2=A0 =C2=A0 =C2=A0 struct rb_node rb_tree_node;
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_objnode *objnode_tree_root;
> + =C2=A0 =C2=A0 =C2=A0 unsigned int objnode_tree_height;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long objnode_count;
> + =C2=A0 =C2=A0 =C2=A0 long pampd_count;
> + =C2=A0 =C2=A0 =C2=A0 DECL_SENTINEL
> +};
> +
> +#define OBJNODE_TREE_MAP_SHIFT 6
> +#define OBJNODE_TREE_MAP_SIZE (1UL << OBJNODE_TREE_MAP_SHIFT)
> +#define OBJNODE_TREE_MAP_MASK (OBJNODE_TREE_MAP_SIZE-1)
> +#define OBJNODE_TREE_INDEX_BITS (8 /* CHAR_BIT */ * sizeof(unsigned long=
))
> +#define OBJNODE_TREE_MAX_PATH \
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (OBJNODE_TREE_INDEX_BI=
TS/OBJNODE_TREE_MAP_SHIFT + 2)
> +
> +struct tmem_objnode {
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_obj *obj;
> + =C2=A0 =C2=A0 =C2=A0 DECL_SENTINEL
> + =C2=A0 =C2=A0 =C2=A0 void *slots[OBJNODE_TREE_MAP_SIZE];
> + =C2=A0 =C2=A0 =C2=A0 unsigned int slots_in_use;
> +};
> +
> +/* pampd abstract datatype methods provided by the PAM implementation */
> +struct tmem_pamops {
> + =C2=A0 =C2=A0 =C2=A0 void *(*create)(struct tmem_pool *, struct tmem_oi=
d *, uint32_t,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 struct page *);
> + =C2=A0 =C2=A0 =C2=A0 int (*get_data)(struct page *, void *, struct tmem=
_pool *);
> + =C2=A0 =C2=A0 =C2=A0 void (*free)(void *, struct tmem_pool *);
> +};

Hmm.. create/get_data/free isn't good naming, I think.
How about add/get/delete like page/swap cache operation?

> +extern void tmem_register_pamops(struct tmem_pamops *m);
> +
> +/* memory allocation methods provided by the host implementation */
> +struct tmem_hostops {
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_obj *(*obj_alloc)(struct tmem_pool *);
> + =C2=A0 =C2=A0 =C2=A0 void (*obj_free)(struct tmem_obj *, struct tmem_po=
ol *);
> + =C2=A0 =C2=A0 =C2=A0 struct tmem_objnode *(*objnode_alloc)(struct tmem_=
pool *);
> + =C2=A0 =C2=A0 =C2=A0 void (*objnode_free)(struct tmem_objnode *, struct=
 tmem_pool *);
> +};

As I said, I am not sure the benefit of hostop.
If we can do, I want to hide it from host.

> +extern void tmem_register_hostops(struct tmem_hostops *m);
> +
> +/* core tmem accessor functions */
> +extern int tmem_put(struct tmem_pool *, struct tmem_oid *, uint32_t inde=
x,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 struct page *page);
> +extern int tmem_get(struct tmem_pool *, struct tmem_oid *, uint32_t inde=
x,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 struct page *page);
> +extern int tmem_flush_page(struct tmem_pool *, struct tmem_oid *,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 uint32_t index);
> +extern int tmem_flush_object(struct tmem_pool *, struct tmem_oid *);
> +extern int tmem_destroy_pool(struct tmem_pool *);
> +extern void tmem_new_pool(struct tmem_pool *, uint32_t);
> +#endif /* _TMEM_H */
>


It's very quick review so maybe I miss your design/goal.
Sorry if I am doing such a thing.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
