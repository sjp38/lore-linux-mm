Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 5952A900117
	for <linux-mm@kvack.org>; Sat, 25 Jun 2011 20:21:07 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <cc182d60-216c-4ab5-8fcd-b61cedc4fbd4@default>
Date: Sat, 25 Jun 2011 17:20:45 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH] drivers/staging/zcache: support multiple clients, prep for
 RAMster and KVM
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@suse.de>, devel@linuxdriverproject.org
Cc: linux-mm <linux-mm@kvack.org>, Konrad Wilk <konrad.wilk@oracle.com>, kvm@vger.kernel.org, Nitin Gupta <ngupta@vflare.org>

(GregKH -- Assuming no negative reviews and sufficient time,
I'm hoping you will push this into linux-next and into the
3.1 merge window.  I can/will provide a git branch if that
would be helpful.  Since this is my first update to a
staging driver, apologies in advance if I am failing to follow
proper protocol.... guidance appreciated!)

This patch adds support to the in-kernel transcendent memory
("tmem") code and the zcache driver for multiple clients, which
will be needed for both RAMster and KVM support.  It also adds
additional tmem callbacks to support RAMster and corresponding
no-op stubs in the zcache driver.

The patch applies to linux-3.0-rc4.

drivers/staging/zcache/tmem.c   |  100 ++++++++--
drivers/staging/zcache/tmem.h   |   23 +-
drivers/staging/zcache/zcache.c |  287 ++++++++++++++++++++++--------
3 files changed, 309 insertions(+), 101 deletions(-)

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

diff -Napur -X linux-3.0-rc1/Documentation/dontdiff linux-3.0-rc4/drivers/s=
taging/zcache/tmem.c linux-3.0-rc4-zcache/drivers/staging/zcache/tmem.c
--- linux-3.0-rc4/drivers/staging/zcache/tmem.c=092011-06-20 21:25:46.00000=
0000 -0600
+++ linux-3.0-rc4-zcache/drivers/staging/zcache/tmem.c=092011-06-25 15:44:5=
9.000140770 -0600
@@ -142,6 +142,7 @@ static void tmem_obj_init(struct tmem_ob
 =09obj->oid =3D *oidp;
 =09obj->objnode_count =3D 0;
 =09obj->pampd_count =3D 0;
+=09(*tmem_pamops.new_obj)(obj);
 =09SET_SENTINEL(obj, OBJ);
 =09while (*new) {
 =09=09BUG_ON(RB_EMPTY_NODE(*new));
@@ -274,7 +275,7 @@ static void tmem_objnode_free(struct tme
 /*
  * lookup index in object and return associated pampd (or NULL if not foun=
d)
  */
-static void *tmem_pampd_lookup_in_obj(struct tmem_obj *obj, uint32_t index=
)
+static void **__tmem_pampd_lookup_in_obj(struct tmem_obj *obj, uint32_t in=
dex)
 {
 =09unsigned int height, shift;
 =09struct tmem_objnode **slot =3D NULL;
@@ -303,9 +304,33 @@ static void *tmem_pampd_lookup_in_obj(st
 =09=09height--;
 =09}
 out:
+=09return slot !=3D NULL ? (void **)slot : NULL;
+}
+
+static void *tmem_pampd_lookup_in_obj(struct tmem_obj *obj, uint32_t index=
)
+{
+=09struct tmem_objnode **slot;
+
+=09slot =3D (struct tmem_objnode **)__tmem_pampd_lookup_in_obj(obj, index)=
;
 =09return slot !=3D NULL ? *slot : NULL;
 }
=20
+static void *tmem_pampd_replace_in_obj(struct tmem_obj *obj, uint32_t inde=
x,
+=09=09=09=09=09void *new_pampd)
+{
+=09struct tmem_objnode **slot;
+=09void *ret =3D NULL;
+
+=09slot =3D (struct tmem_objnode **)__tmem_pampd_lookup_in_obj(obj, index)=
;
+=09if ((slot !=3D NULL) && (*slot !=3D NULL)) {
+=09=09void *old_pampd =3D *(void **)slot;
+=09=09*(void **)slot =3D new_pampd;
+=09=09(*tmem_pamops.free)(old_pampd, obj->pool, NULL, 0);
+=09=09ret =3D new_pampd;
+=09}
+=09return ret;
+}
+
 static int tmem_pampd_add_to_obj(struct tmem_obj *obj, uint32_t index,
 =09=09=09=09=09void *pampd)
 {
@@ -456,7 +481,7 @@ static void tmem_objnode_node_destroy(st
 =09=09=09if (ht =3D=3D 1) {
 =09=09=09=09obj->pampd_count--;
 =09=09=09=09(*tmem_pamops.free)(objnode->slots[i],
-=09=09=09=09=09=09=09=09obj->pool);
+=09=09=09=09=09=09obj->pool, NULL, 0);
 =09=09=09=09objnode->slots[i] =3D NULL;
 =09=09=09=09continue;
 =09=09=09}
@@ -473,7 +498,7 @@ static void tmem_pampd_destroy_all_in_ob
 =09=09return;
 =09if (obj->objnode_tree_height =3D=3D 0) {
 =09=09obj->pampd_count--;
-=09=09(*tmem_pamops.free)(obj->objnode_tree_root, obj->pool);
+=09=09(*tmem_pamops.free)(obj->objnode_tree_root, obj->pool, NULL, 0);
 =09} else {
 =09=09tmem_objnode_node_destroy(obj, obj->objnode_tree_root,
 =09=09=09=09=09obj->objnode_tree_height);
@@ -481,6 +506,7 @@ static void tmem_pampd_destroy_all_in_ob
 =09=09obj->objnode_tree_height =3D 0;
 =09}
 =09obj->objnode_tree_root =3D NULL;
+=09(*tmem_pamops.free_obj)(obj->pool, obj);
 }
=20
 /*
@@ -503,15 +529,13 @@ static void tmem_pampd_destroy_all_in_ob
  * always flushes for simplicity.
  */
 int tmem_put(struct tmem_pool *pool, struct tmem_oid *oidp, uint32_t index=
,
-=09=09struct page *page)
+=09=09char *data, size_t size, bool raw, int ephemeral)
 {
 =09struct tmem_obj *obj =3D NULL, *objfound =3D NULL, *objnew =3D NULL;
 =09void *pampd =3D NULL, *pampd_del =3D NULL;
 =09int ret =3D -ENOMEM;
-=09bool ephemeral;
 =09struct tmem_hashbucket *hb;
=20
-=09ephemeral =3D is_ephemeral(pool);
 =09hb =3D &pool->hashbucket[tmem_oid_hash(oidp)];
 =09spin_lock(&hb->lock);
 =09obj =3D objfound =3D tmem_obj_find(hb, oidp);
@@ -521,7 +545,7 @@ int tmem_put(struct tmem_pool *pool, str
 =09=09=09/* if found, is a dup put, flush the old one */
 =09=09=09pampd_del =3D tmem_pampd_delete_from_obj(obj, index);
 =09=09=09BUG_ON(pampd_del !=3D pampd);
-=09=09=09(*tmem_pamops.free)(pampd, pool);
+=09=09=09(*tmem_pamops.free)(pampd, pool, oidp, index);
 =09=09=09if (obj->pampd_count =3D=3D 0) {
 =09=09=09=09objnew =3D obj;
 =09=09=09=09objfound =3D NULL;
@@ -538,7 +562,8 @@ int tmem_put(struct tmem_pool *pool, str
 =09}
 =09BUG_ON(obj =3D=3D NULL);
 =09BUG_ON(((objnew !=3D obj) && (objfound !=3D obj)) || (objnew =3D=3D obj=
found));
-=09pampd =3D (*tmem_pamops.create)(obj->pool, &obj->oid, index, page);
+=09pampd =3D (*tmem_pamops.create)(data, size, raw, ephemeral,
+=09=09=09=09=09obj->pool, &obj->oid, index);
 =09if (unlikely(pampd =3D=3D NULL))
 =09=09goto free;
 =09ret =3D tmem_pampd_add_to_obj(obj, index, pampd);
@@ -551,7 +576,7 @@ delete_and_free:
 =09(void)tmem_pampd_delete_from_obj(obj, index);
 free:
 =09if (pampd)
-=09=09(*tmem_pamops.free)(pampd, pool);
+=09=09(*tmem_pamops.free)(pampd, pool, NULL, 0);
 =09if (objnew) {
 =09=09tmem_obj_free(objnew, hb);
 =09=09(*tmem_hostops.obj_free)(objnew, pool);
@@ -573,41 +598,52 @@ out:
  * "put" done with the same handle).
=20
  */
-int tmem_get(struct tmem_pool *pool, struct tmem_oid *oidp,
-=09=09=09=09uint32_t index, struct page *page)
+int tmem_get(struct tmem_pool *pool, struct tmem_oid *oidp, uint32_t index=
,
+=09=09char *data, size_t *size, bool raw, int get_and_free)
 {
 =09struct tmem_obj *obj;
 =09void *pampd;
 =09bool ephemeral =3D is_ephemeral(pool);
 =09uint32_t ret =3D -1;
 =09struct tmem_hashbucket *hb;
+=09bool free =3D (get_and_free =3D=3D 1) || ((get_and_free =3D=3D 0) && ep=
hemeral);
+=09bool lock_held =3D 0;
=20
 =09hb =3D &pool->hashbucket[tmem_oid_hash(oidp)];
 =09spin_lock(&hb->lock);
+=09lock_held =3D 1;
 =09obj =3D tmem_obj_find(hb, oidp);
 =09if (obj =3D=3D NULL)
 =09=09goto out;
-=09ephemeral =3D is_ephemeral(pool);
-=09if (ephemeral)
+=09if (free)
 =09=09pampd =3D tmem_pampd_delete_from_obj(obj, index);
 =09else
 =09=09pampd =3D tmem_pampd_lookup_in_obj(obj, index);
 =09if (pampd =3D=3D NULL)
 =09=09goto out;
-=09ret =3D (*tmem_pamops.get_data)(page, pampd, pool);
-=09if (ret < 0)
-=09=09goto out;
-=09if (ephemeral) {
-=09=09(*tmem_pamops.free)(pampd, pool);
+=09if (free) {
 =09=09if (obj->pampd_count =3D=3D 0) {
 =09=09=09tmem_obj_free(obj, hb);
 =09=09=09(*tmem_hostops.obj_free)(obj, pool);
 =09=09=09obj =3D NULL;
 =09=09}
 =09}
+=09if (tmem_pamops.is_remote(pampd)) {
+=09=09lock_held =3D 0;
+=09=09spin_unlock(&hb->lock);
+=09}
+=09if (free)
+=09=09ret =3D (*tmem_pamops.get_data_and_free)(
+=09=09=09=09data, size, raw, pampd, pool, oidp, index);
+=09else
+=09=09ret =3D (*tmem_pamops.get_data)(
+=09=09=09=09data, size, raw, pampd, pool, oidp, index);
+=09if (ret < 0)
+=09=09goto out;
 =09ret =3D 0;
 out:
-=09spin_unlock(&hb->lock);
+=09if (lock_held)
+=09=09spin_unlock(&hb->lock);
 =09return ret;
 }
=20
@@ -632,7 +668,7 @@ int tmem_flush_page(struct tmem_pool *po
 =09pampd =3D tmem_pampd_delete_from_obj(obj, index);
 =09if (pampd =3D=3D NULL)
 =09=09goto out;
-=09(*tmem_pamops.free)(pampd, pool);
+=09(*tmem_pamops.free)(pampd, pool, oidp, index);
 =09if (obj->pampd_count =3D=3D 0) {
 =09=09tmem_obj_free(obj, hb);
 =09=09(*tmem_hostops.obj_free)(obj, pool);
@@ -645,6 +681,30 @@ out:
 }
=20
 /*
+ * If a page in tmem matches the handle, replace the page so that any
+ * subsequent "get" gets the new page.  Returns the new page if
+ * there was a page to replace, else returns NULL.
+ */
+int tmem_replace(struct tmem_pool *pool, struct tmem_oid *oidp,
+=09=09=09uint32_t index, void *new_pampd)
+{
+=09struct tmem_obj *obj;
+=09int ret =3D -1;
+=09struct tmem_hashbucket *hb;
+
+=09hb =3D &pool->hashbucket[tmem_oid_hash(oidp)];
+=09spin_lock(&hb->lock);
+=09obj =3D tmem_obj_find(hb, oidp);
+=09if (obj =3D=3D NULL)
+=09=09goto out;
+=09new_pampd =3D tmem_pampd_replace_in_obj(obj, index, new_pampd);
+=09ret =3D (*tmem_pamops.replace_in_obj)(new_pampd, obj);
+out:
+=09spin_unlock(&hb->lock);
+=09return ret;
+}
+
+/*
  * "Flush" all pages in tmem matching this oid.
  */
 int tmem_flush_object(struct tmem_pool *pool, struct tmem_oid *oidp)
diff -Napur -X linux-3.0-rc1/Documentation/dontdiff linux-3.0-rc4/drivers/s=
taging/zcache/tmem.h linux-3.0-rc4-zcache/drivers/staging/zcache/tmem.h
--- linux-3.0-rc4/drivers/staging/zcache/tmem.h=092011-06-20 21:25:46.00000=
0000 -0600
+++ linux-3.0-rc4-zcache/drivers/staging/zcache/tmem.h=092011-06-25 15:43:2=
0.236906477 -0600
@@ -147,6 +147,7 @@ struct tmem_obj {
 =09unsigned int objnode_tree_height;
 =09unsigned long objnode_count;
 =09long pampd_count;
+=09void *extra; /* for private use by pampd implementation */
 =09DECL_SENTINEL
 };
=20
@@ -166,10 +167,18 @@ struct tmem_objnode {
=20
 /* pampd abstract datatype methods provided by the PAM implementation */
 struct tmem_pamops {
-=09void *(*create)(struct tmem_pool *, struct tmem_oid *, uint32_t,
-=09=09=09struct page *);
-=09int (*get_data)(struct page *, void *, struct tmem_pool *);
-=09void (*free)(void *, struct tmem_pool *);
+=09void *(*create)(char *, size_t, bool, int,
+=09=09=09struct tmem_pool *, struct tmem_oid *, uint32_t);
+=09int (*get_data)(char *, size_t *, bool, void *, struct tmem_pool *,
+=09=09=09=09struct tmem_oid *, uint32_t);
+=09int (*get_data_and_free)(char *, size_t *, bool, void *,
+=09=09=09=09struct tmem_pool *, struct tmem_oid *,
+=09=09=09=09uint32_t);
+=09void (*free)(void *, struct tmem_pool *, struct tmem_oid *, uint32_t);
+=09void (*free_obj)(struct tmem_pool *, struct tmem_obj *);
+=09bool (*is_remote)(void *);
+=09void (*new_obj)(struct tmem_obj *);
+=09int (*replace_in_obj)(void *, struct tmem_obj *);
 };
 extern void tmem_register_pamops(struct tmem_pamops *m);
=20
@@ -184,9 +193,11 @@ extern void tmem_register_hostops(struct
=20
 /* core tmem accessor functions */
 extern int tmem_put(struct tmem_pool *, struct tmem_oid *, uint32_t index,
-=09=09=09struct page *page);
+=09=09=09char *, size_t, bool, int);
 extern int tmem_get(struct tmem_pool *, struct tmem_oid *, uint32_t index,
-=09=09=09struct page *page);
+=09=09=09char *, size_t *, bool, int);
+extern int tmem_replace(struct tmem_pool *, struct tmem_oid *, uint32_t in=
dex,
+=09=09=09void *);
 extern int tmem_flush_page(struct tmem_pool *, struct tmem_oid *,
 =09=09=09uint32_t index);
 extern int tmem_flush_object(struct tmem_pool *, struct tmem_oid *);
diff -Napur -X linux-3.0-rc1/Documentation/dontdiff linux-3.0-rc4/drivers/s=
taging/zcache/zcache.c linux-3.0-rc4-zcache/drivers/staging/zcache/zcache.c
--- linux-3.0-rc4/drivers/staging/zcache/zcache.c=092011-06-20 21:25:46.000=
000000 -0600
+++ linux-3.0-rc4-zcache/drivers/staging/zcache/zcache.c=092011-06-25 15:45=
:55.016705466 -0600
@@ -49,6 +49,32 @@
 =09(__GFP_FS | __GFP_NORETRY | __GFP_NOWARN | __GFP_NOMEMALLOC)
 #endif
=20
+#define MAX_POOLS_PER_CLIENT 16
+
+#define MAX_CLIENTS 16
+#define LOCAL_CLIENT ((uint16_t)-1)
+struct zcache_client {
+=09struct tmem_pool *tmem_pools[MAX_POOLS_PER_CLIENT];
+=09struct xv_pool *xvpool;
+=09bool allocated;
+=09atomic_t refcount;
+};
+
+static struct zcache_client zcache_host;
+static struct zcache_client zcache_clients[MAX_CLIENTS];
+
+static inline uint16_t get_client_id_from_client(struct zcache_client *cli=
)
+{
+=09if (cli =3D=3D &zcache_host)
+=09=09return LOCAL_CLIENT;
+=09return cli - &zcache_clients[0];
+}
+
+static inline bool is_local_client(struct zcache_client *cli)
+{
+=09return cli =3D=3D &zcache_host;
+}
+
 /**********
  * Compression buddies ("zbud") provides for packing two (or, possibly
  * in the future, more) compressed ephemeral pages into a single "raw"
@@ -72,7 +98,8 @@
 #define ZBUD_MAX_BUDS 2
=20
 struct zbud_hdr {
-=09uint32_t pool_id;
+=09uint16_t client_id;
+=09uint16_t pool_id;
 =09struct tmem_oid oid;
 =09uint32_t index;
 =09uint16_t size; /* compressed size in bytes, zero means unused */
@@ -294,7 +321,8 @@ static void zbud_free_and_delist(struct=20
 =09}
 }
=20
-static struct zbud_hdr *zbud_create(uint32_t pool_id, struct tmem_oid *oid=
,
+static struct zbud_hdr *zbud_create(uint16_t client_id, uint16_t pool_id,
+=09=09=09=09=09struct tmem_oid *oid,
 =09=09=09=09=09uint32_t index, struct page *page,
 =09=09=09=09=09void *cdata, unsigned size)
 {
@@ -353,6 +381,7 @@ init_zh:
 =09zh->index =3D index;
 =09zh->oid =3D *oid;
 =09zh->pool_id =3D pool_id;
+=09zh->client_id =3D client_id;
 =09/* can wait to copy the data until the list locks are dropped */
 =09spin_unlock(&zbud_budlists_spinlock);
=20
@@ -407,7 +436,8 @@ static unsigned long zcache_evicted_raw_
 static unsigned long zcache_evicted_buddied_pages;
 static unsigned long zcache_evicted_unbuddied_pages;
=20
-static struct tmem_pool *zcache_get_pool_by_id(uint32_t poolid);
+static struct tmem_pool *zcache_get_pool_by_id(uint16_t cli_id,
+=09=09=09=09=09=09uint16_t poolid);
 static void zcache_put_pool(struct tmem_pool *pool);
=20
 /*
@@ -417,7 +447,8 @@ static void zbud_evict_zbpg(struct zbud_
 {
 =09struct zbud_hdr *zh;
 =09int i, j;
-=09uint32_t pool_id[ZBUD_MAX_BUDS], index[ZBUD_MAX_BUDS];
+=09uint32_t pool_id[ZBUD_MAX_BUDS], client_id[ZBUD_MAX_BUDS];
+=09uint32_t index[ZBUD_MAX_BUDS];
 =09struct tmem_oid oid[ZBUD_MAX_BUDS];
 =09struct tmem_pool *pool;
=20
@@ -426,6 +457,7 @@ static void zbud_evict_zbpg(struct zbud_
 =09for (i =3D 0, j =3D 0; i < ZBUD_MAX_BUDS; i++) {
 =09=09zh =3D &zbpg->buddy[i];
 =09=09if (zh->size) {
+=09=09=09client_id[j] =3D zh->client_id;
 =09=09=09pool_id[j] =3D zh->pool_id;
 =09=09=09oid[j] =3D zh->oid;
 =09=09=09index[j] =3D zh->index;
@@ -435,7 +467,7 @@ static void zbud_evict_zbpg(struct zbud_
 =09}
 =09spin_unlock(&zbpg->lock);
 =09for (i =3D 0; i < j; i++) {
-=09=09pool =3D zcache_get_pool_by_id(pool_id[i]);
+=09=09pool =3D zcache_get_pool_by_id(client_id[i], pool_id[i]);
 =09=09if (pool !=3D NULL) {
 =09=09=09tmem_flush_page(pool, &oid[i], index[i]);
 =09=09=09zcache_put_pool(pool);
@@ -677,36 +709,70 @@ static unsigned long zcache_flobj_found;
 static unsigned long zcache_failed_eph_puts;
 static unsigned long zcache_failed_pers_puts;
=20
-#define MAX_POOLS_PER_CLIENT 16
-
-static struct {
-=09struct tmem_pool *tmem_pools[MAX_POOLS_PER_CLIENT];
-=09struct xv_pool *xvpool;
-} zcache_client;
-
 /*
  * Tmem operations assume the poolid implies the invoking client.
- * Zcache only has one client (the kernel itself), so translate
- * the poolid into the tmem_pool allocated for it.  A KVM version
+ * Zcache only has one client (the kernel itself): LOCAL_CLIENT.
+ * RAMster has each client numbered by cluster node, and a KVM version
  * of zcache would have one client per guest and each client might
  * have a poolid=3D=3DN.
  */
-static struct tmem_pool *zcache_get_pool_by_id(uint32_t poolid)
+static struct tmem_pool *zcache_get_pool_by_id(uint16_t cli_id, uint16_t p=
oolid)
 {
 =09struct tmem_pool *pool =3D NULL;
+=09struct zcache_client *cli =3D NULL;
=20
-=09if (poolid >=3D 0) {
-=09=09pool =3D zcache_client.tmem_pools[poolid];
+=09if (cli_id =3D=3D LOCAL_CLIENT)
+=09=09cli =3D &zcache_host;
+=09else {
+=09=09if (cli_id >=3D MAX_CLIENTS)
+=09=09=09goto out;
+=09=09cli =3D &zcache_clients[cli_id];
+=09=09if (cli =3D=3D NULL)
+=09=09=09goto out;
+=09=09atomic_inc(&cli->refcount);
+=09}
+=09if (poolid < MAX_POOLS_PER_CLIENT) {
+=09=09pool =3D cli->tmem_pools[poolid];
 =09=09if (pool !=3D NULL)
 =09=09=09atomic_inc(&pool->refcount);
 =09}
+out:
 =09return pool;
 }
=20
 static void zcache_put_pool(struct tmem_pool *pool)
 {
-=09if (pool !=3D NULL)
-=09=09atomic_dec(&pool->refcount);
+=09struct zcache_client *cli =3D NULL;
+
+=09if (pool =3D=3D NULL)
+=09=09BUG();
+=09cli =3D pool->client;
+=09atomic_dec(&pool->refcount);
+=09atomic_dec(&cli->refcount);
+}
+
+int zcache_new_client(uint16_t cli_id)
+{
+=09struct zcache_client *cli =3D NULL;
+=09int ret =3D -1;
+
+=09if (cli_id =3D=3D LOCAL_CLIENT)
+=09=09cli =3D &zcache_host;
+=09else if ((unsigned int)cli_id < MAX_CLIENTS)
+=09=09cli =3D &zcache_clients[cli_id];
+=09if (cli =3D=3D NULL)
+=09=09goto out;
+=09if (cli->allocated)
+=09=09goto out;
+=09cli->allocated =3D 1;
+#ifdef CONFIG_FRONTSWAP
+=09cli->xvpool =3D xv_create_pool();
+=09if (cli->xvpool =3D=3D NULL)
+=09=09goto out;
+#endif
+=09ret =3D 0;
+out:
+=09return ret;
 }
=20
 /* counters for debugging */
@@ -901,26 +967,28 @@ static unsigned long zcache_curr_pers_pa
 /* forward reference */
 static int zcache_compress(struct page *from, void **out_va, size_t *out_l=
en);
=20
-static void *zcache_pampd_create(struct tmem_pool *pool, struct tmem_oid *=
oid,
-=09=09=09=09 uint32_t index, struct page *page)
+static void *zcache_pampd_create(char *data, size_t size, bool raw, int ep=
h,
+=09=09=09=09struct tmem_pool *pool, struct tmem_oid *oid,
+=09=09=09=09 uint32_t index)
 {
 =09void *pampd =3D NULL, *cdata;
 =09size_t clen;
 =09int ret;
-=09bool ephemeral =3D is_ephemeral(pool);
 =09unsigned long count;
+=09struct page *page =3D virt_to_page(data);
+=09struct zcache_client *cli =3D pool->client;
+=09uint16_t client_id =3D get_client_id_from_client(cli);
=20
-=09if (ephemeral) {
+=09if (eph) {
 =09=09ret =3D zcache_compress(page, &cdata, &clen);
 =09=09if (ret =3D=3D 0)
-
 =09=09=09goto out;
 =09=09if (clen =3D=3D 0 || clen > zbud_max_buddy_size()) {
 =09=09=09zcache_compress_poor++;
 =09=09=09goto out;
 =09=09}
-=09=09pampd =3D (void *)zbud_create(pool->pool_id, oid, index,
-=09=09=09=09=09=09page, cdata, clen);
+=09=09pampd =3D (void *)zbud_create(client_id, pool->pool_id, oid,
+=09=09=09=09=09=09index, page, cdata, clen);
 =09=09if (pampd !=3D NULL) {
 =09=09=09count =3D atomic_inc_return(&zcache_curr_eph_pampd_count);
 =09=09=09if (count > zcache_curr_eph_pampd_count_max)
@@ -942,7 +1010,7 @@ static void *zcache_pampd_create(struct=20
 =09=09=09zcache_compress_poor++;
 =09=09=09goto out;
 =09=09}
-=09=09pampd =3D (void *)zv_create(zcache_client.xvpool, pool->pool_id,
+=09=09pampd =3D (void *)zv_create(cli->xvpool, pool->pool_id,
 =09=09=09=09=09=09oid, index, cdata, clen);
 =09=09if (pampd =3D=3D NULL)
 =09=09=09goto out;
@@ -958,15 +1026,31 @@ out:
  * fill the pageframe corresponding to the struct page with the data
  * from the passed pampd
  */
-static int zcache_pampd_get_data(struct page *page, void *pampd,
-=09=09=09=09=09=09struct tmem_pool *pool)
+static int zcache_pampd_get_data(char *data, size_t *bufsize, bool raw,
+=09=09=09=09=09void *pampd, struct tmem_pool *pool,
+=09=09=09=09=09struct tmem_oid *oid, uint32_t index)
 {
 =09int ret =3D 0;
=20
-=09if (is_ephemeral(pool))
-=09=09ret =3D zbud_decompress(page, pampd);
-=09else
-=09=09zv_decompress(page, pampd);
+=09BUG_ON(is_ephemeral(pool));
+=09zv_decompress(virt_to_page(data), pampd);
+=09return ret;
+}
+
+/*
+ * fill the pageframe corresponding to the struct page with the data
+ * from the passed pampd
+ */
+static int zcache_pampd_get_data_and_free(char *data, size_t *bufsize, boo=
l raw,
+=09=09=09=09=09void *pampd, struct tmem_pool *pool,
+=09=09=09=09=09struct tmem_oid *oid, uint32_t index)
+{
+=09int ret =3D 0;
+
+=09BUG_ON(!is_ephemeral(pool));
+=09zbud_decompress(virt_to_page(data), pampd);
+=09zbud_free_and_delist((struct zbud_hdr *)pampd);
+=09atomic_dec(&zcache_curr_eph_pampd_count);
 =09return ret;
 }
=20
@@ -974,23 +1058,49 @@ static int zcache_pampd_get_data(struct=20
  * free the pampd and remove it from any zcache lists
  * pampd must no longer be pointed to from any tmem data structures!
  */
-static void zcache_pampd_free(void *pampd, struct tmem_pool *pool)
+static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
+=09=09=09=09struct tmem_oid *oid, uint32_t index)
 {
+=09struct zcache_client *cli =3D pool->client;
+
 =09if (is_ephemeral(pool)) {
 =09=09zbud_free_and_delist((struct zbud_hdr *)pampd);
 =09=09atomic_dec(&zcache_curr_eph_pampd_count);
 =09=09BUG_ON(atomic_read(&zcache_curr_eph_pampd_count) < 0);
 =09} else {
-=09=09zv_free(zcache_client.xvpool, (struct zv_hdr *)pampd);
+=09=09zv_free(cli->xvpool, (struct zv_hdr *)pampd);
 =09=09atomic_dec(&zcache_curr_pers_pampd_count);
 =09=09BUG_ON(atomic_read(&zcache_curr_pers_pampd_count) < 0);
 =09}
 }
=20
+static void zcache_pampd_free_obj(struct tmem_pool *pool, struct tmem_obj =
*obj)
+{
+}
+
+static void zcache_pampd_new_obj(struct tmem_obj *obj)
+{
+}
+
+static int zcache_pampd_replace_in_obj(void *pampd, struct tmem_obj *obj)
+{
+=09return -1;
+}
+
+static bool zcache_pampd_is_remote(void *pampd)
+{
+=09return 0;
+}
+
 static struct tmem_pamops zcache_pamops =3D {
 =09.create =3D zcache_pampd_create,
 =09.get_data =3D zcache_pampd_get_data,
+=09.get_data_and_free =3D zcache_pampd_get_data_and_free,
 =09.free =3D zcache_pampd_free,
+=09.free_obj =3D zcache_pampd_free_obj,
+=09.new_obj =3D zcache_pampd_new_obj,
+=09.replace_in_obj =3D zcache_pampd_replace_in_obj,
+=09.is_remote =3D zcache_pampd_is_remote,
 };
=20
 /*
@@ -1212,19 +1322,20 @@ static struct shrinker zcache_shrinker =3D
  * zcache shims between cleancache/frontswap ops and tmem
  */
=20
-static int zcache_put_page(int pool_id, struct tmem_oid *oidp,
+static int zcache_put_page(int cli_id, int pool_id, struct tmem_oid *oidp,
 =09=09=09=09uint32_t index, struct page *page)
 {
 =09struct tmem_pool *pool;
 =09int ret =3D -1;
=20
 =09BUG_ON(!irqs_disabled());
-=09pool =3D zcache_get_pool_by_id(pool_id);
+=09pool =3D zcache_get_pool_by_id(cli_id, pool_id);
 =09if (unlikely(pool =3D=3D NULL))
 =09=09goto out;
 =09if (!zcache_freeze && zcache_do_preload(pool) =3D=3D 0) {
 =09=09/* preload does preempt_disable on success */
-=09=09ret =3D tmem_put(pool, oidp, index, page);
+=09=09ret =3D tmem_put(pool, oidp, index, page_address(page),
+=09=09=09=09PAGE_SIZE, 0, is_ephemeral(pool));
 =09=09if (ret < 0) {
 =09=09=09if (is_ephemeral(pool))
 =09=09=09=09zcache_failed_eph_puts++;
@@ -1244,25 +1355,28 @@ out:
 =09return ret;
 }
=20
-static int zcache_get_page(int pool_id, struct tmem_oid *oidp,
+static int zcache_get_page(int cli_id, int pool_id, struct tmem_oid *oidp,
 =09=09=09=09uint32_t index, struct page *page)
 {
 =09struct tmem_pool *pool;
 =09int ret =3D -1;
 =09unsigned long flags;
+=09size_t size =3D PAGE_SIZE;
=20
 =09local_irq_save(flags);
-=09pool =3D zcache_get_pool_by_id(pool_id);
+=09pool =3D zcache_get_pool_by_id(cli_id, pool_id);
 =09if (likely(pool !=3D NULL)) {
 =09=09if (atomic_read(&pool->obj_count) > 0)
-=09=09=09ret =3D tmem_get(pool, oidp, index, page);
+=09=09=09ret =3D tmem_get(pool, oidp, index, page_address(page),
+=09=09=09=09=09&size, 0, is_ephemeral(pool));
 =09=09zcache_put_pool(pool);
 =09}
 =09local_irq_restore(flags);
 =09return ret;
 }
=20
-static int zcache_flush_page(int pool_id, struct tmem_oid *oidp, uint32_t =
index)
+static int zcache_flush_page(int cli_id, int pool_id,
+=09=09=09=09struct tmem_oid *oidp, uint32_t index)
 {
 =09struct tmem_pool *pool;
 =09int ret =3D -1;
@@ -1270,7 +1384,7 @@ static int zcache_flush_page(int pool_id
=20
 =09local_irq_save(flags);
 =09zcache_flush_total++;
-=09pool =3D zcache_get_pool_by_id(pool_id);
+=09pool =3D zcache_get_pool_by_id(cli_id, pool_id);
 =09if (likely(pool !=3D NULL)) {
 =09=09if (atomic_read(&pool->obj_count) > 0)
 =09=09=09ret =3D tmem_flush_page(pool, oidp, index);
@@ -1282,7 +1396,8 @@ static int zcache_flush_page(int pool_id
 =09return ret;
 }
=20
-static int zcache_flush_object(int pool_id, struct tmem_oid *oidp)
+static int zcache_flush_object(int cli_id, int pool_id,
+=09=09=09=09struct tmem_oid *oidp)
 {
 =09struct tmem_pool *pool;
 =09int ret =3D -1;
@@ -1290,7 +1405,7 @@ static int zcache_flush_object(int pool_
=20
 =09local_irq_save(flags);
 =09zcache_flobj_total++;
-=09pool =3D zcache_get_pool_by_id(pool_id);
+=09pool =3D zcache_get_pool_by_id(cli_id, pool_id);
 =09if (likely(pool !=3D NULL)) {
 =09=09if (atomic_read(&pool->obj_count) > 0)
 =09=09=09ret =3D tmem_flush_object(pool, oidp);
@@ -1302,34 +1417,52 @@ static int zcache_flush_object(int pool_
 =09return ret;
 }
=20
-static int zcache_destroy_pool(int pool_id)
+static int zcache_destroy_pool(int cli_id, int pool_id)
 {
 =09struct tmem_pool *pool =3D NULL;
+=09struct zcache_client *cli =3D NULL;
 =09int ret =3D -1;
=20
 =09if (pool_id < 0)
 =09=09goto out;
-=09pool =3D zcache_client.tmem_pools[pool_id];
+=09if (cli_id =3D=3D LOCAL_CLIENT)
+=09=09cli =3D &zcache_host;
+=09else if ((unsigned int)cli_id < MAX_CLIENTS)
+=09=09cli =3D &zcache_clients[cli_id];
+=09if (cli =3D=3D NULL)
+=09=09goto out;
+=09atomic_inc(&cli->refcount);
+=09pool =3D cli->tmem_pools[pool_id];
 =09if (pool =3D=3D NULL)
 =09=09goto out;
-=09zcache_client.tmem_pools[pool_id] =3D NULL;
+=09cli->tmem_pools[pool_id] =3D NULL;
 =09/* wait for pool activity on other cpus to quiesce */
 =09while (atomic_read(&pool->refcount) !=3D 0)
 =09=09;
+=09atomic_dec(&cli->refcount);
 =09local_bh_disable();
 =09ret =3D tmem_destroy_pool(pool);
 =09local_bh_enable();
 =09kfree(pool);
-=09pr_info("zcache: destroyed pool id=3D%d\n", pool_id);
+=09pr_info("zcache: destroyed pool id=3D%d, cli_id=3D%d\n",
+=09=09=09pool_id, cli_id);
 out:
 =09return ret;
 }
=20
-static int zcache_new_pool(uint32_t flags)
+static int zcache_new_pool(uint16_t cli_id, uint32_t flags)
 {
 =09int poolid =3D -1;
 =09struct tmem_pool *pool;
+=09struct zcache_client *cli =3D NULL;
=20
+=09if (cli_id =3D=3D LOCAL_CLIENT)
+=09=09cli =3D &zcache_host;
+=09else if ((unsigned int)cli_id < MAX_CLIENTS)
+=09=09cli =3D &zcache_clients[cli_id];
+=09if (cli =3D=3D NULL)
+=09=09goto out;
+=09atomic_inc(&cli->refcount);
 =09pool =3D kmalloc(sizeof(struct tmem_pool), GFP_KERNEL);
 =09if (pool =3D=3D NULL) {
 =09=09pr_info("zcache: pool creation failed: out of memory\n");
@@ -1337,7 +1470,7 @@ static int zcache_new_pool(uint32_t flag
 =09}
=20
 =09for (poolid =3D 0; poolid < MAX_POOLS_PER_CLIENT; poolid++)
-=09=09if (zcache_client.tmem_pools[poolid] =3D=3D NULL)
+=09=09if (cli->tmem_pools[poolid] =3D=3D NULL)
 =09=09=09break;
 =09if (poolid >=3D MAX_POOLS_PER_CLIENT) {
 =09=09pr_info("zcache: pool creation failed: max exceeded\n");
@@ -1346,14 +1479,16 @@ static int zcache_new_pool(uint32_t flag
 =09=09goto out;
 =09}
 =09atomic_set(&pool->refcount, 0);
-=09pool->client =3D &zcache_client;
+=09pool->client =3D cli;
 =09pool->pool_id =3D poolid;
 =09tmem_new_pool(pool, flags);
-=09zcache_client.tmem_pools[poolid] =3D pool;
-=09pr_info("zcache: created %s tmem pool, id=3D%d\n",
+=09cli->tmem_pools[poolid] =3D pool;
+=09pr_info("zcache: created %s tmem pool, id=3D%d, client=3D%d\n",
 =09=09flags & TMEM_POOL_PERSIST ? "persistent" : "ephemeral",
-=09=09poolid);
+=09=09poolid, cli_id);
 out:
+=09if (cli !=3D NULL)
+=09=09atomic_dec(&cli->refcount);
 =09return poolid;
 }
=20
@@ -1374,7 +1509,7 @@ static void zcache_cleancache_put_page(i
 =09struct tmem_oid oid =3D *(struct tmem_oid *)&key;
=20
 =09if (likely(ind =3D=3D index))
-=09=09(void)zcache_put_page(pool_id, &oid, index, page);
+=09=09(void)zcache_put_page(LOCAL_CLIENT, pool_id, &oid, index, page);
 }
=20
 static int zcache_cleancache_get_page(int pool_id,
@@ -1386,7 +1521,7 @@ static int zcache_cleancache_get_page(in
 =09int ret =3D -1;
=20
 =09if (likely(ind =3D=3D index))
-=09=09ret =3D zcache_get_page(pool_id, &oid, index, page);
+=09=09ret =3D zcache_get_page(LOCAL_CLIENT, pool_id, &oid, index, page);
 =09return ret;
 }
=20
@@ -1398,7 +1533,7 @@ static void zcache_cleancache_flush_page
 =09struct tmem_oid oid =3D *(struct tmem_oid *)&key;
=20
 =09if (likely(ind =3D=3D index))
-=09=09(void)zcache_flush_page(pool_id, &oid, ind);
+=09=09(void)zcache_flush_page(LOCAL_CLIENT, pool_id, &oid, ind);
 }
=20
 static void zcache_cleancache_flush_inode(int pool_id,
@@ -1406,13 +1541,13 @@ static void zcache_cleancache_flush_inod
 {
 =09struct tmem_oid oid =3D *(struct tmem_oid *)&key;
=20
-=09(void)zcache_flush_object(pool_id, &oid);
+=09(void)zcache_flush_object(LOCAL_CLIENT, pool_id, &oid);
 }
=20
 static void zcache_cleancache_flush_fs(int pool_id)
 {
 =09if (pool_id >=3D 0)
-=09=09(void)zcache_destroy_pool(pool_id);
+=09=09(void)zcache_destroy_pool(LOCAL_CLIENT, pool_id);
 }
=20
 static int zcache_cleancache_init_fs(size_t pagesize)
@@ -1420,7 +1555,7 @@ static int zcache_cleancache_init_fs(siz
 =09BUG_ON(sizeof(struct cleancache_filekey) !=3D
 =09=09=09=09sizeof(struct tmem_oid));
 =09BUG_ON(pagesize !=3D PAGE_SIZE);
-=09return zcache_new_pool(0);
+=09return zcache_new_pool(LOCAL_CLIENT, 0);
 }
=20
 static int zcache_cleancache_init_shared_fs(char *uuid, size_t pagesize)
@@ -1429,7 +1564,7 @@ static int zcache_cleancache_init_shared
 =09BUG_ON(sizeof(struct cleancache_filekey) !=3D
 =09=09=09=09sizeof(struct tmem_oid));
 =09BUG_ON(pagesize !=3D PAGE_SIZE);
-=09return zcache_new_pool(0);
+=09return zcache_new_pool(LOCAL_CLIENT, 0);
 }
=20
 static struct cleancache_ops zcache_cleancache_ops =3D {
@@ -1483,8 +1618,8 @@ static int zcache_frontswap_put_page(uns
 =09BUG_ON(!PageLocked(page));
 =09if (likely(ind64 =3D=3D ind)) {
 =09=09local_irq_save(flags);
-=09=09ret =3D zcache_put_page(zcache_frontswap_poolid, &oid,
-=09=09=09=09=09iswiz(ind), page);
+=09=09ret =3D zcache_put_page(LOCAL_CLIENT, zcache_frontswap_poolid,
+=09=09=09=09=09&oid, iswiz(ind), page);
 =09=09local_irq_restore(flags);
 =09}
 =09return ret;
@@ -1502,8 +1637,8 @@ static int zcache_frontswap_get_page(uns
=20
 =09BUG_ON(!PageLocked(page));
 =09if (likely(ind64 =3D=3D ind))
-=09=09ret =3D zcache_get_page(zcache_frontswap_poolid, &oid,
-=09=09=09=09=09iswiz(ind), page);
+=09=09ret =3D zcache_get_page(LOCAL_CLIENT, zcache_frontswap_poolid,
+=09=09=09=09=09&oid, iswiz(ind), page);
 =09return ret;
 }
=20
@@ -1515,8 +1650,8 @@ static void zcache_frontswap_flush_page(
 =09struct tmem_oid oid =3D oswiz(type, ind);
=20
 =09if (likely(ind64 =3D=3D ind))
-=09=09(void)zcache_flush_page(zcache_frontswap_poolid, &oid,
-=09=09=09=09=09iswiz(ind));
+=09=09(void)zcache_flush_page(LOCAL_CLIENT, zcache_frontswap_poolid,
+=09=09=09=09=09&oid, iswiz(ind));
 }
=20
 /* flush all pages from the passed swaptype */
@@ -1527,7 +1662,8 @@ static void zcache_frontswap_flush_area(
=20
 =09for (ind =3D SWIZ_MASK; ind >=3D 0; ind--) {
 =09=09oid =3D oswiz(type, ind);
-=09=09(void)zcache_flush_object(zcache_frontswap_poolid, &oid);
+=09=09(void)zcache_flush_object(LOCAL_CLIENT,
+=09=09=09=09=09=09zcache_frontswap_poolid, &oid);
 =09}
 }
=20
@@ -1535,7 +1671,8 @@ static void zcache_frontswap_init(unsign
 {
 =09/* a single tmem poolid is used for all frontswap "types" (swapfiles) *=
/
 =09if (zcache_frontswap_poolid < 0)
-=09=09zcache_frontswap_poolid =3D zcache_new_pool(TMEM_POOL_PERSIST);
+=09=09zcache_frontswap_poolid =3D
+=09=09=09zcache_new_pool(LOCAL_CLIENT, TMEM_POOL_PERSIST);
 }
=20
 static struct frontswap_ops zcache_frontswap_ops =3D {
@@ -1624,6 +1761,11 @@ static int __init zcache_init(void)
 =09=09=09=09sizeof(struct tmem_objnode), 0, 0, NULL);
 =09zcache_obj_cache =3D kmem_cache_create("zcache_obj",
 =09=09=09=09sizeof(struct tmem_obj), 0, 0, NULL);
+=09ret =3D zcache_new_client(LOCAL_CLIENT);
+=09if (ret) {
+=09=09pr_err("zcache: can't create client\n");
+=09=09goto out;
+=09}
 #endif
 #ifdef CONFIG_CLEANCACHE
 =09if (zcache_enabled && use_cleancache) {
@@ -1642,11 +1784,6 @@ static int __init zcache_init(void)
 =09if (zcache_enabled && use_frontswap) {
 =09=09struct frontswap_ops old_ops;
=20
-=09=09zcache_client.xvpool =3D xv_create_pool();
-=09=09if (zcache_client.xvpool =3D=3D NULL) {
-=09=09=09pr_err("zcache: can't create xvpool\n");
-=09=09=09goto out;
-=09=09}
 =09=09old_ops =3D zcache_frontswap_register_ops();
 =09=09pr_info("zcache: frontswap enabled using kernel "
 =09=09=09"transcendent memory and xvmalloc\n");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
