Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id F3DA26B002D
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 21:20:28 -0400 (EDT)
Date: Tue, 1 Nov 2011 02:20:17 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
Message-ID: <20111101012017.GJ3466@redhat.com>
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org>
 <1319785956.3235.7.camel@lappy>
 <CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.comCAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default20111031181651.GF3466@redhat.com>
 <60592afd-97aa-4eaf-b86b-f6695d31c7f1@default20111031223717.GI3466@redhat.com>
 <1b2e4f74-7058-4712-85a7-84198723e3ee@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1b2e4f74-7058-4712-85a7-84198723e3ee@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

On Mon, Oct 31, 2011 at 04:36:04PM -0700, Dan Magenheimer wrote:
> Do you see code doing this?  I am pretty sure zcache is
> NOT doing an extra copy, it is compressing from the source
> page.  And I am pretty sure Xen tmem is not doing the
> extra copy either.

So below you describe put as a copy of a page from the kernel into the
newly allocated PAM space... I guess there's some improvement needed
for the documentation at least, a compression is done sometime instead
of a copy... I thought you always had to copy first sorry.

 * "Put" a page, e.g. copy a page from the kernel into newly allocated
 * PAM space (if such space is available).  Tmem_put is complicated by
 * a corner case: What if a page with matching handle already exists in
 * tmem?  To guarantee coherency, one of two actions is necessary: Either
 * the data for the page must be overwritten, or the page must be
 * "flushed" so that the data is not accessible to a subsequent "get".
 * Since these "duplicate puts" are relatively rare, this implementation
 * always flushes for simplicity.
 */
int tmem_put(struct tmem_pool *pool, struct tmem_oid *oidp, uint32_t index,
		char *data, size_t size, bool raw, bool ephemeral)
{
	struct tmem_obj *obj = NULL, *objfound = NULL, *objnew = NULL;
	void *pampd = NULL, *pampd_del = NULL;
	int ret = -ENOMEM;
	struct tmem_hashbucket *hb;

	hb = &pool->hashbucket[tmem_oid_hash(oidp)];
	spin_lock(&hb->lock);
	obj = objfound = tmem_obj_find(hb, oidp);
	if (obj != NULL) {
		pampd = tmem_pampd_lookup_in_obj(objfound, index);
		if (pampd != NULL) {
			/* if found, is a dup put, flush the old one */
			pampd_del = tmem_pampd_delete_from_obj(obj, index);
			BUG_ON(pampd_del != pampd);
			(*tmem_pamops.free)(pampd, pool, oidp, index);
			if (obj->pampd_count == 0) {
				objnew = obj;
				objfound = NULL;
			}
			pampd = NULL;
		}
	} else {
		obj = objnew = (*tmem_hostops.obj_alloc)(pool);
		if (unlikely(obj == NULL)) {
			ret = -ENOMEM;
			goto out;
		}
		tmem_obj_init(obj, hb, pool, oidp);
	}
	BUG_ON(obj == NULL);
	BUG_ON(((objnew != obj) && (objfound != obj)) || (objnew == objfound));
	pampd = (*tmem_pamops.create)(data, size, raw, ephemeral,
					obj->pool, &obj->oid, index);

So then .create is calls zcache_pampd_create... 

static void *zcache_pampd_create(char *data, size_t size, bool raw, int eph,
       	    			 ^^^^^^^^^^
				struct tmem_pool *pool, struct tmem_oid *oid,
				 uint32_t index)
{
	void *pampd = NULL, *cdata;
	size_t clen;
	int ret;
	unsigned long count;
	struct page *page = (struct page *)(data);
	^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	struct zcache_client *cli = pool->client;
	uint16_t client_id = get_client_id_from_client(cli);
	unsigned long zv_mean_zsize;
	unsigned long curr_pers_pampd_count;
	u64 total_zsize;

	if (eph) {
		ret = zcache_compress(page, &cdata, &clen);


zcache_compress then does:

static int zcache_compress(struct page *from, void **out_va, size_t *out_len)
{
	int ret = 0;
	unsigned char *dmem = __get_cpu_var(zcache_dstmem);
	unsigned char *wmem = __get_cpu_var(zcache_workmem);
	char *from_va;

	BUG_ON(!irqs_disabled());
	if (unlikely(dmem == NULL || wmem == NULL))
		goto out;  /* no buffer, so can't compress */
	from_va = kmap_atomic(from, KM_USER0);
	mb();
	ret = lzo1x_1_compress(from_va, PAGE_SIZE, dmem, out_len, wmem);
	      				^^^^^^^^^

tmem is called from frontswap_put_page.

+int __frontswap_put_page(struct page *page)
+{
+       int ret = -1, dup = 0;
+       swp_entry_t entry = { .val = page_private(page), };
+       int type = swp_type(entry);
+       struct swap_info_struct *sis = swap_info[type];
+       pgoff_t offset = swp_offset(entry);
+
+       BUG_ON(!PageLocked(page));
+       BUG_ON(sis == NULL);
+       if (frontswap_test(sis, offset))
+               dup = 1;
+       ret = (*frontswap_ops.put_page)(type, offset, page);

In turn called by swap_writepage:

@@ -98,6 +99,12 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
                unlock_page(page);
                goto out;
        }
+       if (frontswap_put_page(page) == 0) {
+               set_page_writeback(page);
+               unlock_page(page);
+               end_page_writeback(page);
+               goto out;
+       }
        bio = get_swap_bio(GFP_NOIO, page, end_swap_bio_write);
        if (bio == NULL) {
                set_page_dirty(page);


And zcache-main.c has #ifdef for both frontswap and cleancache, and
the above frontswap_ops.put_page points to the below
zcache_frontswap_put_page which even shows a local_irq_save() for the
whole time of the compression... did you ever check irq latency with
zcache+frontswap? Wonder what the RT folks will say about
zcache+frontswap considering local_irq_save is a blocker for preempt-RT.

#ifdef CONFIG_CLEANCACHE
#include <linux/cleancache.h>
#endif
#ifdef CONFIG_FRONTSWAP
#include <linux/frontswap.h>
#endif

#ifdef CONFIG_FRONTSWAP
/* a single tmem poolid is used for all frontswap "types" (swapfiles) */
static int zcache_frontswap_poolid = -1;

/*
 * Swizzling increases objects per swaptype, increasing tmem concurrency
 * for heavy swaploads.  Later, larger nr_cpus -> larger SWIZ_BITS
 */
#define SWIZ_BITS		4
#define SWIZ_MASK		((1 << SWIZ_BITS) - 1)
#define _oswiz(_type, _ind)	((_type << SWIZ_BITS) | (_ind & SWIZ_MASK))
#define iswiz(_ind)		(_ind >> SWIZ_BITS)

static inline struct tmem_oid oswiz(unsigned type, u32 ind)
{
	struct tmem_oid oid = { .oid = { 0 } };
	oid.oid[0] = _oswiz(type, ind);
	return oid;
}

static int zcache_frontswap_put_page(unsigned type, pgoff_t offset,
				   struct page *page)
{
	u64 ind64 = (u64)offset;
	u32 ind = (u32)offset;
	struct tmem_oid oid = oswiz(type, ind);
	int ret = -1;
	unsigned long flags;

	BUG_ON(!PageLocked(page));
	if (likely(ind64 == ind)) {
		local_irq_save(flags);
		ret = zcache_put_page(LOCAL_CLIENT, zcache_frontswap_poolid,
					&oid, iswiz(ind), page);
		local_irq_restore(flags);
	}
	return ret;
}

/* returns 0 if the page was successfully gotten from frontswap, -1 if
 * was not present (should never happen!) */
static int zcache_frontswap_get_page(unsigned type, pgoff_t offset,
				   struct page *page)
{
	u64 ind64 = (u64)offset;
	u32 ind = (u32)offset;
	struct tmem_oid oid = oswiz(type, ind);
	int ret = -1;

	BUG_ON(!PageLocked(page));
	if (likely(ind64 == ind))
		ret = zcache_get_page(LOCAL_CLIENT, zcache_frontswap_poolid,
					&oid, iswiz(ind), page);
	return ret;
}

/* flush a single page from frontswap */
static void zcache_frontswap_flush_page(unsigned type, pgoff_t offset)
{
	u64 ind64 = (u64)offset;
	u32 ind = (u32)offset;
	struct tmem_oid oid = oswiz(type, ind);

	if (likely(ind64 == ind))
		(void)zcache_flush_page(LOCAL_CLIENT, zcache_frontswap_poolid,
					&oid, iswiz(ind));
}

/* flush all pages from the passed swaptype */
static void zcache_frontswap_flush_area(unsigned type)
{
	struct tmem_oid oid;
	int ind;

	for (ind = SWIZ_MASK; ind >= 0; ind--) {
		oid = oswiz(type, ind);
		(void)zcache_flush_object(LOCAL_CLIENT,
						zcache_frontswap_poolid, &oid);
	}
}

static void zcache_frontswap_init(unsigned ignored)
{
	/* a single tmem poolid is used for all frontswap "types" (swapfiles) */
	if (zcache_frontswap_poolid < 0)
		zcache_frontswap_poolid =
			zcache_new_pool(LOCAL_CLIENT, TMEM_POOL_PERSIST);
}

static struct frontswap_ops zcache_frontswap_ops = {
	.put_page = zcache_frontswap_put_page,
	.get_page = zcache_frontswap_get_page,
	.flush_page = zcache_frontswap_flush_page,
	.flush_area = zcache_frontswap_flush_area,
	.init = zcache_frontswap_init
};

struct frontswap_ops zcache_frontswap_register_ops(void)
{
	struct frontswap_ops old_ops =
		frontswap_register_ops(&zcache_frontswap_ops);

	return old_ops;
}
#endif

#ifdef CONFIG_CLEANCACHE
static void zcache_cleancache_put_page(int pool_id,
					struct cleancache_filekey key,
					pgoff_t index, struct page *page)
{
	u32 ind = (u32) index;
	struct tmem_oid oid = *(struct tmem_oid *)&key;

	if (likely(ind == index))
		(void)zcache_put_page(LOCAL_CLIENT, pool_id, &oid, index, page);
}

static int zcache_cleancache_get_page(int pool_id,
					struct cleancache_filekey key,
					pgoff_t index, struct page *page)
{
	u32 ind = (u32) index;
	struct tmem_oid oid = *(struct tmem_oid *)&key;
	int ret = -1;

	if (likely(ind == index))
		ret = zcache_get_page(LOCAL_CLIENT, pool_id, &oid, index, page);
	return ret;
}

static void zcache_cleancache_flush_page(int pool_id,
					struct cleancache_filekey key,
					pgoff_t index)
{
	u32 ind = (u32) index;
	struct tmem_oid oid = *(struct tmem_oid *)&key;

	if (likely(ind == index))
		(void)zcache_flush_page(LOCAL_CLIENT, pool_id, &oid, ind);
}

static void zcache_cleancache_flush_inode(int pool_id,
					struct cleancache_filekey key)
{
	struct tmem_oid oid = *(struct tmem_oid *)&key;

	(void)zcache_flush_object(LOCAL_CLIENT, pool_id, &oid);
}

static void zcache_cleancache_flush_fs(int pool_id)
{
	if (pool_id >= 0)
		(void)zcache_destroy_pool(LOCAL_CLIENT, pool_id);
}

static int zcache_cleancache_init_fs(size_t pagesize)
{
	BUG_ON(sizeof(struct cleancache_filekey) !=
				sizeof(struct tmem_oid));
	BUG_ON(pagesize != PAGE_SIZE);
	return zcache_new_pool(LOCAL_CLIENT, 0);
}

static int zcache_cleancache_init_shared_fs(char *uuid, size_t pagesize)
{
	/* shared pools are unsupported and map to private */
	BUG_ON(sizeof(struct cleancache_filekey) !=
				sizeof(struct tmem_oid));
	BUG_ON(pagesize != PAGE_SIZE);
	return zcache_new_pool(LOCAL_CLIENT, 0);
}

static struct cleancache_ops zcache_cleancache_ops = {
	.put_page = zcache_cleancache_put_page,
	.get_page = zcache_cleancache_get_page,
	.flush_page = zcache_cleancache_flush_page,
	.flush_inode = zcache_cleancache_flush_inode,
	.flush_fs = zcache_cleancache_flush_fs,
	.init_shared_fs = zcache_cleancache_init_shared_fs,
	.init_fs = zcache_cleancache_init_fs
};

struct cleancache_ops zcache_cleancache_register_ops(void)
{
	struct cleancache_ops old_ops =
		cleancache_register_ops(&zcache_cleancache_ops);

	return old_ops;
}
#endif

This zcache functionality is all but pluggable if you've to create a
new zcache slightly different implementation for each user
(frontswap/cleancache etc...). And the cast of the page when it enters
tmem to char:

static int zcache_put_page(int cli_id, int pool_id, struct tmem_oid *oidp,
				uint32_t index, struct page *page)
{
	struct tmem_pool *pool;
	int ret = -1;

	BUG_ON(!irqs_disabled());
	pool = zcache_get_pool_by_id(cli_id, pool_id);
	if (unlikely(pool == NULL))
		goto out;
	if (!zcache_freeze && zcache_do_preload(pool) == 0) {
		/* preload does preempt_disable on success */
		ret = tmem_put(pool, oidp, index, (char *)(page),
				PAGE_SIZE, 0, is_ephemeral(pool));

Is so weird... and then it returns a page when it exits tmem and
enters zcache again in zcache_pampd_create.

And the "len" get lost at some point inside zcache but I guess that's
fixable and not part of the API at least.... but the whole thing looks
an exercise to pass through tmem. I don't really understand why one
page must become a char at some point and what benefit it would ever
provide.

I also don't understand how you plan to ever swap the compressed data
considering it's hold outside of the kernel not anymore in a struct
page. If swap compression was done right, the on-disk data should be
stored in the compressed format in a compact way so you spend the CPU
once and you also gain disk speed by writing less. How do you plan to
achieve this with this design?

I like the failing when the size of the compressed data is bigger than
the uncompressed one, only in that case the data should go to swap
uncompressed of course. That's something in software we can handle and
hardware can't handle so well and that's why some older hardware
compression for RAM probably didn't takeoff.

I've an hard time to be convinced this is the best way to do swap
compression especially not seeing how it will ever reach swap on
disk. But yes it's not doing an additional copy unlike the tmem_put
comment would imply (it's disabling irqs for the whole duration of the
compression though).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
