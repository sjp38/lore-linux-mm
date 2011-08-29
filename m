Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id B0F39900137
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 08:28:01 -0400 (EDT)
Subject: Re: [PATCH 1/2] mm: convert k{un}map_atomic(p, KM_type) to
 k{un}map_atomic(p)
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 29 Aug 2011 14:27:45 +0200
In-Reply-To: <20110826124239.fc503491.akpm@linux-foundation.org>
References: <1314346676.6486.25.camel@minggr.sh.intel.com>
	 <1314349096.26922.21.camel@twins>
	 <20110826124239.fc503491.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1314620865.2816.14.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lin Ming <ming.m.lin@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, herbert@gondor.apana.org.au, David Miller <davem@davemloft.net>, linux-crypto@vger.kernel.org, drbd-dev@lists.linbit.com, cjb@laptop.org

On Fri, 2011-08-26 at 12:42 -0700, Andrew Morton wrote:
> Perhaps you could dust off your old patch and we'll bring it up to date?

most of it would be doing what mlin just did, so I took his patch and
went from there, the resulting delta is something like the below.

Completely untested...  crypto much improved since I last looked at it.

---
Whoever wrote aesni-intel_glue.c should be flogged, it did 3
kmap_atomic()s on the same km_type.. it works with the stacked kmap but
still we should not nest 3 kmaps, that's just wrong.

Crypto: mostly cleanup of the out/in_softirq() km_type selection and
cleanup of some of the scatterwalk stuff that had superfluous arguments
etc..

drbd: cleaned up more, could probably be sanitized even further but will
leave that to the maintainers.

mmc: looks like mlin made a boo-boo there, but it also looks like
tmio_mmc_kmap_atomic and co can be somewhat improved..

cassini: removal of useless cas_page_map/unmap wrappers

fc: removed some pointless km_type passing around

rtl8192u: again, someone should be flogged, private (slightly
'improved') copy of scatterwalk.[ch].

zram: removed put/get_ptr_atomic foo

bio: git grep __bio_kmap_atomic/kunmap_atomic turned up empty

---
 arch/x86/crypto/aesni-intel_glue.c               |   24 +++++-----
 crypto/ahash.c                                   |    4 -
 crypto/blkcipher.c                               |    8 +--
 crypto/ccm.c                                     |    4 -
 crypto/scatterwalk.c                             |    9 +--
 crypto/shash.c                                   |    8 +--
 drivers/block/drbd/drbd_bitmap.c                 |   40 ++++++-----------
 drivers/mmc/host/tmio_mmc_dma.c                  |    4 -
 drivers/mmc/host/tmio_mmc_pio.c                  |    8 +--
 drivers/net/cassini.c                            |   26 +++++------
 drivers/scsi/libfc/fc_fcp.c                      |    4 -
 drivers/scsi/libfc/fc_libfc.c                    |    2=20
 drivers/scsi/libfc/fc_lport.c                    |    2=20
 drivers/staging/rtl8192u/ieee80211/cipher.c      |    4 -
 drivers/staging/rtl8192u/ieee80211/digest.c      |    8 +--
 drivers/staging/rtl8192u/ieee80211/internal.h    |   18 -------
 drivers/staging/rtl8192u/ieee80211/scatterwalk.c |   10 ++--
 drivers/staging/rtl8192u/ieee80211/scatterwalk.h |    2=20
 drivers/staging/zram/xvmalloc.c                  |   54 ++++++------------=
-----
 include/crypto/scatterwalk.h                     |   29 ------------
 include/linux/bio.h                              |   12 -----
 21 files changed, 94 insertions(+), 186 deletions(-)

Index: linux-2.6/arch/x86/crypto/aesni-intel_glue.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/arch/x86/crypto/aesni-intel_glue.c
+++ linux-2.6/arch/x86/crypto/aesni-intel_glue.c
@@ -1106,12 +1106,12 @@ static int __driver_rfc4106_encrypt(stru
 		one_entry_in_sg =3D 1;
 		scatterwalk_start(&src_sg_walk, req->src);
 		scatterwalk_start(&assoc_sg_walk, req->assoc);
-		src =3D scatterwalk_map(&src_sg_walk, 0);
-		assoc =3D scatterwalk_map(&assoc_sg_walk, 0);
+		src =3D scatterwalk_map(&src_sg_walk);
+		assoc =3D scatterwalk_map(&assoc_sg_walk);
 		dst =3D src;
 		if (unlikely(req->src !=3D req->dst)) {
 			scatterwalk_start(&dst_sg_walk, req->dst);
-			dst =3D scatterwalk_map(&dst_sg_walk, 0);
+			dst =3D scatterwalk_map(&dst_sg_walk);
 		}
=20
 	} else {
@@ -1135,11 +1135,11 @@ static int __driver_rfc4106_encrypt(stru
 	 * back to the packet. */
 	if (one_entry_in_sg) {
 		if (unlikely(req->src !=3D req->dst)) {
-			scatterwalk_unmap(dst, 0);
+			kunmap_atomic(dst);
 			scatterwalk_done(&dst_sg_walk, 0, 0);
 		}
-		scatterwalk_unmap(src, 0);
-		scatterwalk_unmap(assoc, 0);
+		kunmap_atomic(src);
+		kunmap_atomic(assoc);
 		scatterwalk_done(&src_sg_walk, 0, 0);
 		scatterwalk_done(&assoc_sg_walk, 0, 0);
 	} else {
@@ -1188,12 +1188,12 @@ static int __driver_rfc4106_decrypt(stru
 		one_entry_in_sg =3D 1;
 		scatterwalk_start(&src_sg_walk, req->src);
 		scatterwalk_start(&assoc_sg_walk, req->assoc);
-		src =3D scatterwalk_map(&src_sg_walk, 0);
-		assoc =3D scatterwalk_map(&assoc_sg_walk, 0);
+		src =3D scatterwalk_map(&src_sg_walk);
+		assoc =3D scatterwalk_map(&assoc_sg_walk);
 		dst =3D src;
 		if (unlikely(req->src !=3D req->dst)) {
 			scatterwalk_start(&dst_sg_walk, req->dst);
-			dst =3D scatterwalk_map(&dst_sg_walk, 0);
+			dst =3D scatterwalk_map(&dst_sg_walk);
 		}
=20
 	} else {
@@ -1218,11 +1218,11 @@ static int __driver_rfc4106_decrypt(stru
=20
 	if (one_entry_in_sg) {
 		if (unlikely(req->src !=3D req->dst)) {
-			scatterwalk_unmap(dst, 0);
+			kunmap_atomic(dst);
 			scatterwalk_done(&dst_sg_walk, 0, 0);
 		}
-		scatterwalk_unmap(src, 0);
-		scatterwalk_unmap(assoc, 0);
+		kunmap_atomic(src);
+		kunmap_atomic(assoc);
 		scatterwalk_done(&src_sg_walk, 0, 0);
 		scatterwalk_done(&assoc_sg_walk, 0, 0);
 	} else {
Index: linux-2.6/crypto/ahash.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/crypto/ahash.c
+++ linux-2.6/crypto/ahash.c
@@ -44,7 +44,7 @@ static int hash_walk_next(struct crypto_
 	unsigned int nbytes =3D min(walk->entrylen,
 				  ((unsigned int)(PAGE_SIZE)) - offset);
=20
-	walk->data =3D crypto_kmap(walk->pg, 0);
+	walk->data =3D kmap_atomic(walk->pg);
 	walk->data +=3D offset;
=20
 	if (offset & alignmask) {
@@ -91,7 +91,7 @@ int crypto_hash_walk_done(struct crypto_
 		return nbytes;
 	}
=20
-	crypto_kunmap(walk->data, 0);
+	kunmap_atomic(walk->data);
 	crypto_yield(walk->flags);
=20
 	if (err)
Index: linux-2.6/crypto/blkcipher.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/crypto/blkcipher.c
+++ linux-2.6/crypto/blkcipher.c
@@ -41,22 +41,22 @@ static int blkcipher_walk_first(struct b
=20
 static inline void blkcipher_map_src(struct blkcipher_walk *walk)
 {
-	walk->src.virt.addr =3D scatterwalk_map(&walk->in, 0);
+	walk->src.virt.addr =3D scatterwalk_map(&walk->in);
 }
=20
 static inline void blkcipher_map_dst(struct blkcipher_walk *walk)
 {
-	walk->dst.virt.addr =3D scatterwalk_map(&walk->out, 1);
+	walk->dst.virt.addr =3D scatterwalk_map(&walk->out);
 }
=20
 static inline void blkcipher_unmap_src(struct blkcipher_walk *walk)
 {
-	scatterwalk_unmap(walk->src.virt.addr, 0);
+	kunmap_atomic(walk->src.virt.addr);
 }
=20
 static inline void blkcipher_unmap_dst(struct blkcipher_walk *walk)
 {
-	scatterwalk_unmap(walk->dst.virt.addr, 1);
+	kunmap_atomic(walk->dst.virt.addr);
 }
=20
 /* Get a spot of the specified length that does not straddle a page.
Index: linux-2.6/crypto/ccm.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/crypto/ccm.c
+++ linux-2.6/crypto/ccm.c
@@ -216,12 +216,12 @@ static void get_data_to_compute(struct c
 			scatterwalk_start(&walk, sg_next(walk.sg));
 			n =3D scatterwalk_clamp(&walk, len);
 		}
-		data_src =3D scatterwalk_map(&walk, 0);
+		data_src =3D scatterwalk_map(&walk);
=20
 		compute_mac(tfm, data_src, n, pctx);
 		len -=3D n;
=20
-		scatterwalk_unmap(data_src, 0);
+		kunmap_atomic(data_src);
 		scatterwalk_advance(&walk, n);
 		scatterwalk_done(&walk, 0, len);
 		if (len)
Index: linux-2.6/crypto/scatterwalk.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/crypto/scatterwalk.c
+++ linux-2.6/crypto/scatterwalk.c
@@ -40,10 +40,9 @@ void scatterwalk_start(struct scatter_wa
 }
 EXPORT_SYMBOL_GPL(scatterwalk_start);
=20
-void *scatterwalk_map(struct scatter_walk *walk, int out)
+void *scatterwalk_map(struct scatter_walk *walk)
 {
-	return crypto_kmap(scatterwalk_page(walk), out) +
-	       offset_in_page(walk->offset);
+	return kmap_atomic(scatterwalk_page(walk)) + offset_in_page(walk->offset)=
;
 }
 EXPORT_SYMBOL_GPL(scatterwalk_map);
=20
@@ -83,9 +82,9 @@ void scatterwalk_copychunks(void *buf, s
 		if (len_this_page > nbytes)
 			len_this_page =3D nbytes;
=20
-		vaddr =3D scatterwalk_map(walk, out);
+		vaddr =3D scatterwalk_map(walk);
 		memcpy_dir(buf, vaddr, len_this_page, out);
-		scatterwalk_unmap(vaddr, out);
+		kunmap_atomic(vaddr);
=20
 		scatterwalk_advance(walk, len_this_page);
=20
Index: linux-2.6/crypto/shash.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/crypto/shash.c
+++ linux-2.6/crypto/shash.c
@@ -279,10 +279,10 @@ int shash_ahash_digest(struct ahash_requ
 	if (nbytes < min(sg->length, ((unsigned int)(PAGE_SIZE)) - offset)) {
 		void *data;
=20
-		data =3D crypto_kmap(sg_page(sg), 0);
+		data =3D kmap_atomic(sg_page(sg));
 		err =3D crypto_shash_digest(desc, data + offset, nbytes,
 					  req->result);
-		crypto_kunmap(data, 0);
+		kunmap_atomic(data);
 		crypto_yield(desc->flags);
 	} else
 		err =3D crypto_shash_init(desc) ?:
@@ -418,9 +418,9 @@ static int shash_compat_digest(struct ha
=20
 		desc->flags =3D hdesc->flags;
=20
-		data =3D crypto_kmap(sg_page(sg), 0);
+		data =3D kmap_atomic(sg_page(sg));
 		err =3D crypto_shash_digest(desc, data + offset, nbytes, out);
-		crypto_kunmap(data, 0);
+		kunmap_atomic(data);
 		crypto_yield(desc->flags);
 		goto out;
 	}
Index: linux-2.6/drivers/block/drbd/drbd_bitmap.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/drivers/block/drbd/drbd_bitmap.c
+++ linux-2.6/drivers/block/drbd/drbd_bitmap.c
@@ -289,25 +289,15 @@ static unsigned int bm_bit_to_page_idx(s
 	return page_nr;
 }
=20
-static unsigned long *__bm_map_pidx(struct drbd_bitmap *b, unsigned int id=
x, const enum km_type km)
+static unsigned long *bm_map_pidx(struct drbd_bitmap *b, unsigned int idx)
 {
 	struct page *page =3D b->bm_pages[idx];
 	return (unsigned long *) kmap_atomic(page);
 }
=20
-static unsigned long *bm_map_pidx(struct drbd_bitmap *b, unsigned int idx)
-{
-	return __bm_map_pidx(b, idx, KM_IRQ1);
-}
-
-static void __bm_unmap(unsigned long *p_addr, const enum km_type km)
-{
-	kunmap_atomic(p_addr);
-};
-
 static void bm_unmap(unsigned long *p_addr)
 {
-	return __bm_unmap(p_addr, KM_IRQ1);
+	kunmap_atomic(p_addr);
 }
=20
 /* long word offset of _bitmap_ sector */
@@ -544,15 +534,15 @@ static unsigned long bm_count_bits(struc
=20
 	/* all but last page */
 	for (idx =3D 0; idx < b->bm_number_of_pages - 1; idx++) {
-		p_addr =3D __bm_map_pidx(b, idx, KM_USER0);
+		p_addr =3D bm_map_pidx(b, idx);
 		for (i =3D 0; i < LWPP; i++)
 			bits +=3D hweight_long(p_addr[i]);
-		__bm_unmap(p_addr, KM_USER0);
+		bm_unmap(p_addr);
 		cond_resched();
 	}
 	/* last (or only) page */
 	last_word =3D ((b->bm_bits - 1) & BITS_PER_PAGE_MASK) >> LN2_BPL;
-	p_addr =3D __bm_map_pidx(b, idx, KM_USER0);
+	p_addr =3D bm_map_pidx(b, idx);
 	for (i =3D 0; i < last_word; i++)
 		bits +=3D hweight_long(p_addr[i]);
 	p_addr[last_word] &=3D cpu_to_lel(mask);
@@ -560,7 +550,7 @@ static unsigned long bm_count_bits(struc
 	/* 32bit arch, may have an unused padding long */
 	if (BITS_PER_LONG =3D=3D 32 && (last_word & 1) =3D=3D 0)
 		p_addr[last_word+1] =3D 0;
-	__bm_unmap(p_addr, KM_USER0);
+	bm_unmap(p_addr);
 	return bits;
 }
=20
@@ -1164,7 +1154,7 @@ int drbd_bm_write_page(struct drbd_conf
  * this returns a bit number, NOT a sector!
  */
 static unsigned long __bm_find_next(struct drbd_conf *mdev, unsigned long =
bm_fo,
-	const int find_zero_bit, const enum km_type km)
+	const int find_zero_bit)
 {
 	struct drbd_bitmap *b =3D mdev->bitmap;
 	unsigned long *p_addr;
@@ -1179,7 +1169,7 @@ static unsigned long __bm_find_next(stru
 		while (bm_fo < b->bm_bits) {
 			/* bit offset of the first bit in the page */
 			bit_offset =3D bm_fo & ~BITS_PER_PAGE_MASK;
-			p_addr =3D __bm_map_pidx(b, bm_bit_to_page_idx(b, bm_fo), km);
+			p_addr =3D bm_map_pidx(b, bm_bit_to_page_idx(b, bm_fo));
=20
 			if (find_zero_bit)
 				i =3D find_next_zero_bit_le(p_addr,
@@ -1188,7 +1178,7 @@ static unsigned long __bm_find_next(stru
 				i =3D find_next_bit_le(p_addr,
 						PAGE_SIZE*8, bm_fo & BITS_PER_PAGE_MASK);
=20
-			__bm_unmap(p_addr, km);
+			bm_unmap(p_addr);
 			if (i < PAGE_SIZE*8) {
 				bm_fo =3D bit_offset + i;
 				if (bm_fo >=3D b->bm_bits)
@@ -1216,7 +1206,7 @@ static unsigned long bm_find_next(struct
 	if (BM_DONT_TEST & b->bm_flags)
 		bm_print_lock_info(mdev);
=20
-	i =3D __bm_find_next(mdev, bm_fo, find_zero_bit, KM_IRQ1);
+	i =3D __bm_find_next(mdev, bm_fo, find_zero_bit);
=20
 	spin_unlock_irq(&b->bm_lock);
 	return i;
@@ -1240,13 +1230,13 @@ unsigned long drbd_bm_find_next_zero(str
 unsigned long _drbd_bm_find_next(struct drbd_conf *mdev, unsigned long bm_=
fo)
 {
 	/* WARN_ON(!(BM_DONT_SET & mdev->b->bm_flags)); */
-	return __bm_find_next(mdev, bm_fo, 0, KM_USER1);
+	return __bm_find_next(mdev, bm_fo, 0);
 }
=20
 unsigned long _drbd_bm_find_next_zero(struct drbd_conf *mdev, unsigned lon=
g bm_fo)
 {
 	/* WARN_ON(!(BM_DONT_SET & mdev->b->bm_flags)); */
-	return __bm_find_next(mdev, bm_fo, 1, KM_USER1);
+	return __bm_find_next(mdev, bm_fo, 1);
 }
=20
 /* returns number of bits actually changed.
@@ -1274,14 +1264,14 @@ static int __bm_change_bits_to(struct dr
 		unsigned int page_nr =3D bm_bit_to_page_idx(b, bitnr);
 		if (page_nr !=3D last_page_nr) {
 			if (p_addr)
-				__bm_unmap(p_addr, KM_IRQ1);
+				bm_unmap(p_addr);
 			if (c < 0)
 				bm_set_page_lazy_writeout(b->bm_pages[last_page_nr]);
 			else if (c > 0)
 				bm_set_page_need_writeout(b->bm_pages[last_page_nr]);
 			changed_total +=3D c;
 			c =3D 0;
-			p_addr =3D __bm_map_pidx(b, page_nr, KM_IRQ1);
+			p_addr =3D bm_map_pidx(b, page_nr);
 			last_page_nr =3D page_nr;
 		}
 		if (val)
@@ -1290,7 +1280,7 @@ static int __bm_change_bits_to(struct dr
 			c -=3D (0 !=3D __test_and_clear_bit_le(bitnr & BITS_PER_PAGE_MASK, p_ad=
dr));
 	}
 	if (p_addr)
-		__bm_unmap(p_addr, KM_IRQ1);
+		bm_unmap(p_addr);
 	if (c < 0)
 		bm_set_page_lazy_writeout(b->bm_pages[last_page_nr]);
 	else if (c > 0)
Index: linux-2.6/drivers/mmc/host/tmio_mmc_dma.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/drivers/mmc/host/tmio_mmc_dma.c
+++ linux-2.6/drivers/mmc/host/tmio_mmc_dma.c
@@ -147,10 +147,10 @@ static void tmio_mmc_start_dma_tx(struct
 	/* The only sg element can be unaligned, use our bounce buffer then */
 	if (!aligned) {
 		unsigned long flags;
-		void *sg_vaddr =3D tmio_mmc_kmap_atomic(sg);
+		void *sg_vaddr =3D tmio_mmc_kmap_atomic(sg, &flags);
 		sg_init_one(&host->bounce_sg, host->bounce_buf, sg->length);
 		memcpy(host->bounce_buf, sg_vaddr, host->bounce_sg.length);
-		tmio_mmc_kunmap_atomic(sg, &flags);
+		tmio_mmc_kunmap_atomic(sg, &flags, sg_vaddr);
 		host->sg_ptr =3D &host->bounce_sg;
 		sg =3D host->sg_ptr;
 	}
Index: linux-2.6/drivers/mmc/host/tmio_mmc_pio.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/drivers/mmc/host/tmio_mmc_pio.c
+++ linux-2.6/drivers/mmc/host/tmio_mmc_pio.c
@@ -362,7 +362,7 @@ static void tmio_mmc_pio_irq(struct tmio
 		return;
 	}
=20
-	sg_virt =3D tmio_mmc_kmap_atomic(host->sg_ptr);
+	sg_virt =3D tmio_mmc_kmap_atomic(host->sg_ptr, &flags);
 	buf =3D (unsigned short *)(sg_virt + host->sg_off);
=20
 	count =3D host->sg_ptr->length - host->sg_off;
@@ -380,7 +380,7 @@ static void tmio_mmc_pio_irq(struct tmio
=20
 	host->sg_off +=3D count;
=20
-	tmio_mmc_kunmap_atomic(host->sg_ptr, &flags);
+	tmio_mmc_kunmap_atomic(host->sg_ptr, &flags, sg_virt);
=20
 	if (host->sg_off =3D=3D host->sg_ptr->length)
 		tmio_mmc_next_sg(host);
@@ -392,9 +392,9 @@ static void tmio_mmc_check_bounce_buffer
 {
 	if (host->sg_ptr =3D=3D &host->bounce_sg) {
 		unsigned long flags;
-		void *sg_vaddr =3D tmio_mmc_kmap_atomic(host->sg_orig);
+		void *sg_vaddr =3D tmio_mmc_kmap_atomic(host->sg_orig, &flags);
 		memcpy(sg_vaddr, host->bounce_buf, host->bounce_sg.length);
-		tmio_mmc_kunmap_atomic(host->sg_orig, &flags);
+		tmio_mmc_kunmap_atomic(host->sg_orig, &flags, sg_vaddr);
 	}
 }
=20
Index: linux-2.6/drivers/net/cassini.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/drivers/net/cassini.c
+++ linux-2.6/drivers/net/cassini.c
@@ -104,8 +104,6 @@
 #include <asm/byteorder.h>
 #include <asm/uaccess.h>
=20
-#define cas_page_map(x)      kmap_atomic((x))
-#define cas_page_unmap(x)    kunmap_atomic((x))
 #define CAS_NCPUS            num_online_cpus()
=20
 #define cas_skb_release(x)  netif_rx(x)
@@ -1995,11 +1993,11 @@ static int cas_rx_process_pkt(struct cas
 			i +=3D cp->crc_size;
 		pci_dma_sync_single_for_cpu(cp->pdev, page->dma_addr + off, i,
 				    PCI_DMA_FROMDEVICE);
-		addr =3D cas_page_map(page->buffer);
+		addr =3D kmap_atomic(page->buffer);
 		memcpy(p, addr + off, i);
 		pci_dma_sync_single_for_device(cp->pdev, page->dma_addr + off, i,
 				    PCI_DMA_FROMDEVICE);
-		cas_page_unmap(addr);
+		kunmap_atomic(addr);
 		RX_USED_ADD(page, 0x100);
 		p +=3D hlen;
 		swivel =3D 0;
@@ -2030,11 +2028,11 @@ static int cas_rx_process_pkt(struct cas
 		/* make sure we always copy a header */
 		swivel =3D 0;
 		if (p =3D=3D (char *) skb->data) { /* not split */
-			addr =3D cas_page_map(page->buffer);
+			addr =3D kmap_atomic(page->buffer);
 			memcpy(p, addr + off, RX_COPY_MIN);
 			pci_dma_sync_single_for_device(cp->pdev, page->dma_addr + off, i,
 					PCI_DMA_FROMDEVICE);
-			cas_page_unmap(addr);
+			kunmap_atomic(addr);
 			off +=3D RX_COPY_MIN;
 			swivel =3D RX_COPY_MIN;
 			RX_USED_ADD(page, cp->mtu_stride);
@@ -2080,7 +2078,7 @@ static int cas_rx_process_pkt(struct cas
 		}
=20
 		if (cp->crc_size) {
-			addr =3D cas_page_map(page->buffer);
+			addr =3D kmap_atomic(page->buffer);
 			crcaddr  =3D addr + off + hlen;
 		}
=20
@@ -2104,11 +2102,11 @@ static int cas_rx_process_pkt(struct cas
 			i +=3D cp->crc_size;
 		pci_dma_sync_single_for_cpu(cp->pdev, page->dma_addr + off, i,
 				    PCI_DMA_FROMDEVICE);
-		addr =3D cas_page_map(page->buffer);
+		addr =3D kmap_atomic(page->buffer);
 		memcpy(p, addr + off, i);
 		pci_dma_sync_single_for_device(cp->pdev, page->dma_addr + off, i,
 				    PCI_DMA_FROMDEVICE);
-		cas_page_unmap(addr);
+		kunmap_atomic(addr);
 		if (p =3D=3D (char *) skb->data) /* not split */
 			RX_USED_ADD(page, cp->mtu_stride);
 		else
@@ -2122,12 +2120,12 @@ static int cas_rx_process_pkt(struct cas
 			pci_dma_sync_single_for_cpu(cp->pdev, page->dma_addr,
 					    dlen + cp->crc_size,
 					    PCI_DMA_FROMDEVICE);
-			addr =3D cas_page_map(page->buffer);
+			addr =3D kmap_atomic(page->buffer);
 			memcpy(p, addr, dlen + cp->crc_size);
 			pci_dma_sync_single_for_device(cp->pdev, page->dma_addr,
 					    dlen + cp->crc_size,
 					    PCI_DMA_FROMDEVICE);
-			cas_page_unmap(addr);
+			kunmap_atomic(addr);
 			RX_USED_ADD(page, dlen + cp->crc_size);
 		}
 end_copy_pkt:
@@ -2144,7 +2142,7 @@ static int cas_rx_process_pkt(struct cas
 		csum =3D csum_fold(csum_partial(crcaddr, cp->crc_size,
 					      csum_unfold(csum)));
 		if (addr)
-			cas_page_unmap(addr);
+			kunmap_atomic(addr);
 	}
 	skb->protocol =3D eth_type_trans(skb, cp->dev);
 	if (skb->protocol =3D=3D htons(ETH_P_IP)) {
@@ -2843,11 +2841,11 @@ static inline int cas_xmit_tx_ringN(stru
 				      ctrl, 0);
 			entry =3D TX_DESC_NEXT(ring, entry);
=20
-			addr =3D cas_page_map(fragp->page);
+			addr =3D kmap_atomic(fragp->page);
 			memcpy(tx_tiny_buf(cp, ring, entry),
 			       addr + fragp->page_offset + len - tabort,
 			       tabort);
-			cas_page_unmap(addr);
+			kunmap_atomic(addr);
 			mapping =3D tx_tiny_map(cp, ring, entry, tentry);
 			len     =3D tabort;
 		}
Index: linux-2.6/drivers/scsi/libfc/fc_fcp.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/drivers/scsi/libfc/fc_fcp.c
+++ linux-2.6/drivers/scsi/libfc/fc_fcp.c
@@ -484,11 +484,11 @@ static void fc_fcp_recv_data(struct fc_f
=20
 	if (!(fr_flags(fp) & FCPHF_CRC_UNCHECKED)) {
 		copy_len =3D fc_copy_buffer_to_sglist(buf, len, sg, &nents,
-						    &offset, KM_SOFTIRQ0, NULL);
+						    &offset, NULL);
 	} else {
 		crc =3D crc32(~0, (u8 *) fh, sizeof(*fh));
 		copy_len =3D fc_copy_buffer_to_sglist(buf, len, sg, &nents,
-						    &offset, KM_SOFTIRQ0, &crc);
+						    &offset, &crc);
 		buf =3D fc_frame_payload_get(fp, 0);
 		if (len % 4)
 			crc =3D crc32(crc, buf + len, 4 - (len % 4));
Index: linux-2.6/drivers/scsi/libfc/fc_libfc.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/drivers/scsi/libfc/fc_libfc.c
+++ linux-2.6/drivers/scsi/libfc/fc_libfc.c
@@ -111,7 +111,7 @@ module_exit(libfc_exit);
 u32 fc_copy_buffer_to_sglist(void *buf, size_t len,
 			     struct scatterlist *sg,
 			     u32 *nents, size_t *offset,
-			     enum km_type km_type, u32 *crc)
+			     u32 *crc)
 {
 	size_t remaining =3D len;
 	u32 copy_len =3D 0;
Index: linux-2.6/drivers/scsi/libfc/fc_lport.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/drivers/scsi/libfc/fc_lport.c
+++ linux-2.6/drivers/scsi/libfc/fc_lport.c
@@ -1687,7 +1687,7 @@ static void fc_lport_bsg_resp(struct fc_
=20
 	job->reply->reply_payload_rcv_len +=3D
 		fc_copy_buffer_to_sglist(buf, len, info->sg, &info->nents,
-					 &info->offset, KM_BIO_SRC_IRQ, NULL);
+					 &info->offset, NULL);
=20
 	if (fr_eof(fp) =3D=3D FC_EOF_T &&
 	    (ntoh24(fh->fh_f_ctl) & (FC_FC_LAST_SEQ | FC_FC_END_SEQ)) =3D=3D
Index: linux-2.6/drivers/staging/rtl8192u/ieee80211/cipher.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/drivers/staging/rtl8192u/ieee80211/cipher.c
+++ linux-2.6/drivers/staging/rtl8192u/ieee80211/cipher.c
@@ -71,8 +71,8 @@ static int crypt(struct crypto_tfm *tfm,
 		u8 *src_p, *dst_p;
 		int in_place;
=20
-		scatterwalk_map(&walk_in, 0);
-		scatterwalk_map(&walk_out, 1);
+		scatterwalk_map(&walk_in);
+		scatterwalk_map(&walk_out);
 		src_p =3D scatterwalk_whichbuf(&walk_in, bsize, tmp_src);
 		dst_p =3D scatterwalk_whichbuf(&walk_out, bsize, tmp_dst);
 		in_place =3D scatterwalk_samebuf(&walk_in, &walk_out,
Index: linux-2.6/drivers/staging/rtl8192u/ieee80211/digest.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/drivers/staging/rtl8192u/ieee80211/digest.c
+++ linux-2.6/drivers/staging/rtl8192u/ieee80211/digest.c
@@ -39,12 +39,12 @@ static void update(struct crypto_tfm *tf
 			unsigned int bytes_from_page =3D min(l, ((unsigned int)
 							   (PAGE_SIZE)) -
 							   offset);
-			char *p =3D crypto_kmap(pg, 0) + offset;
+			char *p =3D kmap_atomic(pg) + offset;
=20
 			tfm->__crt_alg->cra_digest.dia_update
 					(crypto_tfm_ctx(tfm), p,
 					 bytes_from_page);
-			crypto_kunmap(p, 0);
+			kunmap_atomic(p);
 			crypto_yield(tfm);
 			offset =3D 0;
 			pg++;
@@ -75,10 +75,10 @@ static void digest(struct crypto_tfm *tf
 	tfm->crt_digest.dit_init(tfm);
=20
 	for (i =3D 0; i < nsg; i++) {
-		char *p =3D crypto_kmap(sg[i].page, 0) + sg[i].offset;
+		char *p =3D kmap_atomic(sg[i].page) + sg[i].offset;
 		tfm->__crt_alg->cra_digest.dia_update(crypto_tfm_ctx(tfm),
 						      p, sg[i].length);
-		crypto_kunmap(p, 0);
+		kunmap_atomic(p);
 		crypto_yield(tfm);
 	}
 	crypto_digest_final(tfm, out);
Index: linux-2.6/drivers/staging/rtl8192u/ieee80211/internal.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/drivers/staging/rtl8192u/ieee80211/internal.h
+++ linux-2.6/drivers/staging/rtl8192u/ieee80211/internal.h
@@ -22,24 +22,6 @@
 #include <asm/softirq.h>
 #include <asm/kmap_types.h>
=20
-
-extern enum km_type crypto_km_types[];
-
-static inline enum km_type crypto_kmap_type(int out)
-{
-	return crypto_km_types[(in_softirq() ? 2 : 0) + out];
-}
-
-static inline void *crypto_kmap(struct page *page, int out)
-{
-	return kmap_atomic(page);
-}
-
-static inline void crypto_kunmap(void *vaddr, int out)
-{
-	kunmap_atomic(vaddr);
-}
-
 static inline void crypto_yield(struct crypto_tfm *tfm)
 {
 	if (!in_softirq())
Index: linux-2.6/drivers/staging/rtl8192u/ieee80211/scatterwalk.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/drivers/staging/rtl8192u/ieee80211/scatterwalk.c
+++ linux-2.6/drivers/staging/rtl8192u/ieee80211/scatterwalk.c
@@ -62,9 +62,9 @@ void scatterwalk_start(struct scatter_wa
 	walk->offset =3D sg->offset;
 }
=20
-void scatterwalk_map(struct scatter_walk *walk, int out)
+void scatterwalk_map(struct scatter_walk *walk)
 {
-	walk->data =3D crypto_kmap(walk->page, out) + walk->offset;
+	walk->data =3D kmap_atomic(walk->page) + walk->offset;
 }
=20
 static void scatterwalk_pagedone(struct scatter_walk *walk, int out,
@@ -93,7 +93,7 @@ static void scatterwalk_pagedone(struct
=20
 void scatterwalk_done(struct scatter_walk *walk, int out, int more)
 {
-	crypto_kunmap(walk->data, out);
+	kunmap_atomic(walk->data);
 	if (walk->len_this_page =3D=3D 0 || !more)
 		scatterwalk_pagedone(walk, out, more);
 }
@@ -111,9 +111,9 @@ int scatterwalk_copychunks(void *buf, st
 			buf +=3D walk->len_this_page;
 			nbytes -=3D walk->len_this_page;
=20
-			crypto_kunmap(walk->data, out);
+			kunmap_atomic(walk->data);
 			scatterwalk_pagedone(walk, out, 1);
-			scatterwalk_map(walk, out);
+			scatterwalk_map(walk);
 		}
=20
 		memcpy_dir(buf, walk->data, nbytes, out);
Index: linux-2.6/drivers/staging/rtl8192u/ieee80211/scatterwalk.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/drivers/staging/rtl8192u/ieee80211/scatterwalk.h
+++ linux-2.6/drivers/staging/rtl8192u/ieee80211/scatterwalk.h
@@ -45,7 +45,7 @@ static inline int scatterwalk_samebuf(st
 void *scatterwalk_whichbuf(struct scatter_walk *walk, unsigned int nbytes,=
 void *scratch);
 void scatterwalk_start(struct scatter_walk *walk, struct scatterlist *sg);
 int scatterwalk_copychunks(void *buf, struct scatter_walk *walk, size_t nb=
ytes, int out);
-void scatterwalk_map(struct scatter_walk *walk, int out);
+void scatterwalk_map(struct scatter_walk *walk);
 void scatterwalk_done(struct scatter_walk *walk, int out, int more);
=20
 #endif  /* _CRYPTO_SCATTERWALK_H */
Index: linux-2.6/include/crypto/scatterwalk.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/include/crypto/scatterwalk.h
+++ linux-2.6/include/crypto/scatterwalk.h
@@ -25,28 +25,6 @@
 #include <linux/scatterlist.h>
 #include <linux/sched.h>
=20
-static inline enum km_type crypto_kmap_type(int out)
-{
-	enum km_type type;
-
-	if (in_softirq())
-		type =3D out * (KM_SOFTIRQ1 - KM_SOFTIRQ0) + KM_SOFTIRQ0;
-	else
-		type =3D out * (KM_USER1 - KM_USER0) + KM_USER0;
-
-	return type;
-}
-
-static inline void *crypto_kmap(struct page *page, int out)
-{
-	return kmap_atomic(page);
-}
-
-static inline void crypto_kunmap(void *vaddr, int out)
-{
-	kunmap_atomic(vaddr);
-}
-
 static inline void crypto_yield(u32 flags)
 {
 	if (flags & CRYPTO_TFM_REQ_MAY_SLEEP)
@@ -121,15 +99,10 @@ static inline struct page *scatterwalk_p
 	return sg_page(walk->sg) + (walk->offset >> PAGE_SHIFT);
 }
=20
-static inline void scatterwalk_unmap(void *vaddr, int out)
-{
-	crypto_kunmap(vaddr, out);
-}
-
 void scatterwalk_start(struct scatter_walk *walk, struct scatterlist *sg);
 void scatterwalk_copychunks(void *buf, struct scatter_walk *walk,
 			    size_t nbytes, int out);
-void *scatterwalk_map(struct scatter_walk *walk, int out);
+void *scatterwalk_map(struct scatter_walk *walk);
 void scatterwalk_done(struct scatter_walk *walk, int out, int more);
=20
 void scatterwalk_map_and_copy(void *buf, struct scatterlist *sg,
Index: linux-2.6/drivers/staging/zram/xvmalloc.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/drivers/staging/zram/xvmalloc.c
+++ linux-2.6/drivers/staging/zram/xvmalloc.c
@@ -51,24 +51,6 @@ static void clear_flag(struct block_head
 	block->prev &=3D ~BIT(flag);
 }
=20
-/*
- * Given <page, offset> pair, provide a dereferencable pointer.
- * This is called from xv_malloc/xv_free path, so it
- * needs to be fast.
- */
-static void *get_ptr_atomic(struct page *page, u16 offset, enum km_type ty=
pe)
-{
-	unsigned char *base;
-
-	base =3D kmap_atomic(page);
-	return base + offset;
-}
-
-static void put_ptr_atomic(void *ptr, enum km_type type)
-{
-	kunmap_atomic(ptr);
-}
-
 static u32 get_blockprev(struct block_header *block)
 {
 	return block->prev & PREV_MASK;
@@ -201,11 +183,10 @@ static void insert_block(struct xv_pool
 	pool->freelist[slindex].offset =3D offset;
=20
 	if (block->link.next_page) {
-		nextblock =3D get_ptr_atomic(block->link.next_page,
-					block->link.next_offset, KM_USER1);
+		nextblock =3D kmap_atomic(block->link.next_page) + block->link.next_offs=
et;
 		nextblock->link.prev_page =3D page;
 		nextblock->link.prev_offset =3D offset;
-		put_ptr_atomic(nextblock, KM_USER1);
+		kunmap_atomic(nextblock);
 		/* If there was a next page then the free bits are set. */
 		return;
 	}
@@ -224,19 +205,17 @@ static void remove_block(struct xv_pool
 	struct block_header *tmpblock;
=20
 	if (block->link.prev_page) {
-		tmpblock =3D get_ptr_atomic(block->link.prev_page,
-				block->link.prev_offset, KM_USER1);
+		tmpblock =3D kmap_atomic(block->link.prev_page) + block->link.prev_offse=
t;
 		tmpblock->link.next_page =3D block->link.next_page;
 		tmpblock->link.next_offset =3D block->link.next_offset;
-		put_ptr_atomic(tmpblock, KM_USER1);
+		kunmap_atomic(tmpblock);
 	}
=20
 	if (block->link.next_page) {
-		tmpblock =3D get_ptr_atomic(block->link.next_page,
-				block->link.next_offset, KM_USER1);
+		tmpblock =3D kmap_atomic(block->link.next_page) + block->link.next_offse=
t;
 		tmpblock->link.prev_page =3D block->link.prev_page;
 		tmpblock->link.prev_offset =3D block->link.prev_offset;
-		put_ptr_atomic(tmpblock, KM_USER1);
+		kunmap_atomic(tmpblock);
 	}
=20
 	/* Is this block is at the head of the freelist? */
@@ -248,12 +227,11 @@ static void remove_block(struct xv_pool
=20
 		if (pool->freelist[slindex].page) {
 			struct block_header *tmpblock;
-			tmpblock =3D get_ptr_atomic(pool->freelist[slindex].page,
-					pool->freelist[slindex].offset,
-					KM_USER1);
+			tmpblock =3D kmap_atomic(pool->freelist[slindex].page) +
+						pool->freelist[slindex].offset;
 			tmpblock->link.prev_page =3D NULL;
 			tmpblock->link.prev_offset =3D 0;
-			put_ptr_atomic(tmpblock, KM_USER1);
+			kunmap_atomic(tmpblock);
 		} else {
 			/* This freelist bucket is empty */
 			__clear_bit(slindex % BITS_PER_LONG,
@@ -284,7 +262,7 @@ static int grow_pool(struct xv_pool *poo
 	stat_inc(&pool->total_pages);
=20
 	spin_lock(&pool->lock);
-	block =3D get_ptr_atomic(page, 0, KM_USER0);
+	block =3D kmap_atomic(page);
=20
 	block->size =3D PAGE_SIZE - XV_ALIGN;
 	set_flag(block, BLOCK_FREE);
@@ -293,7 +271,7 @@ static int grow_pool(struct xv_pool *poo
=20
 	insert_block(pool, page, 0, block);
=20
-	put_ptr_atomic(block, KM_USER0);
+	kunmap_atomic(block);
 	spin_unlock(&pool->lock);
=20
 	return 0;
@@ -375,7 +353,7 @@ int xv_malloc(struct xv_pool *pool, u32
 		return -ENOMEM;
 	}
=20
-	block =3D get_ptr_atomic(*page, *offset, KM_USER0);
+	block =3D kmap_atomic(*page) + *offset;
=20
 	remove_block(pool, *page, *offset, block, index);
=20
@@ -405,7 +383,7 @@ int xv_malloc(struct xv_pool *pool, u32
 	block->size =3D origsize;
 	clear_flag(block, BLOCK_FREE);
=20
-	put_ptr_atomic(block, KM_USER0);
+	kunmap_atomic(block);
 	spin_unlock(&pool->lock);
=20
 	*offset +=3D XV_ALIGN;
@@ -426,7 +404,7 @@ void xv_free(struct xv_pool *pool, struc
=20
 	spin_lock(&pool->lock);
=20
-	page_start =3D get_ptr_atomic(page, 0, KM_USER0);
+	page_start =3D kmap_atomic(page);
 	block =3D (struct block_header *)((char *)page_start + offset);
=20
 	/* Catch double free bugs */
@@ -468,7 +446,7 @@ void xv_free(struct xv_pool *pool, struc
=20
 	/* No used objects in this page. Free it. */
 	if (block->size =3D=3D PAGE_SIZE - XV_ALIGN) {
-		put_ptr_atomic(page_start, KM_USER0);
+		kunmap(page_start);
 		spin_unlock(&pool->lock);
=20
 		__free_page(page);
@@ -486,7 +464,7 @@ void xv_free(struct xv_pool *pool, struc
 		set_blockprev(tmpblock, offset);
 	}
=20
-	put_ptr_atomic(page_start, KM_USER0);
+	kunmap_atomic(page_start);
 	spin_unlock(&pool->lock);
 }
 EXPORT_SYMBOL_GPL(xv_free);
Index: linux-2.6/include/linux/bio.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/include/linux/bio.h
+++ linux-2.6/include/linux/bio.h
@@ -95,18 +95,6 @@ static inline int bio_has_allocated_vec(
 #define bvec_to_phys(bv)	(page_to_phys((bv)->bv_page) + (unsigned long) (b=
v)->bv_offset)
=20
 /*
- * queues that have highmem support enabled may still need to revert to
- * PIO transfers occasionally and thus map high pages temporarily. For
- * permanent PIO fall back, user is probably better off disabling highmem
- * I/O completely on that queue (see ide-dma for example)
- */
-#define __bio_kmap_atomic(bio, idx)				\
-	(kmap_atomic(bio_iovec_idx((bio), (idx))->bv_page) +	\
-		bio_iovec_idx((bio), (idx))->bv_offset)
-
-#define __bio_kunmap_atomic(addr, kmtype) kunmap_atomic(addr)
-
-/*
  * merge helpers etc
  */
=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
