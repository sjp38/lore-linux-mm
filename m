Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 120C56B0044
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 14:04:46 -0500 (EST)
Date: Wed, 16 Dec 2009 21:04:32 +0200
From: Izik Eidus <ieidus@redhat.com>
Subject: RFC: change swap_map to be 32bits varible instead of 16
Message-ID: <20091216210432.33de4e98@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@redhat.com>, Izik Eidus <ieidus@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

When i backported Hugh patches into the rhel6 kernel today, I noticed
during my testing that at very high load of swap tests i get the
following error:


Dec 16 17:06:25 dhcp-1-211 kernel: swap_dup: swap entry overflow
Dec 16 17:06:25 dhcp-1-211 kernel: swap_dup: swap entry overflow
Dec 16 17:06:25 dhcp-1-211 kernel: swap_dup: swap entry overflow
Dec 16 17:06:25 dhcp-1-211 kernel: swap_dup: swap entry overflow


The problem probably happen due to the swap_map limitation of being
able to address just ~128mb of memory, and with the zero_page mapped
when using ksm much more than this amount of memory it was triggered

There may be many soultions to this problem, and I send for RFC the
easiest one (just increase the map_count to be unsiged int and allow
~8terabyte of memory)

Thanks.


=46rom 9c661a87c6583531560aaac6a4724df254a6e49b Mon Sep 17 00:00:00 2001
From: Izik Eidus <ieidus@redhat.com>
Date: Wed, 16 Dec 2009 19:48:43 +0200
Subject: [PATCH] RFC: change swap_map to be 32bits varible instead of 16

Right now after 15bits of usage ~128mb the swap_map will overflow.

While it might never been a problem before with KSM it might just happen
due to pages such the zero_page that can be mapped many times.

This patch address this problem by increasing the swap_map to be 32bits
and effectivly allow usage of 31bits of that varible (allow ~8Terabyte)

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 include/linux/swap.h |    8 ++++----
 mm/swapfile.c        |   14 +++++++-------
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 4ec9001..34ac29a 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -151,9 +151,9 @@ enum {
=20
 #define SWAP_CLUSTER_MAX 32
=20
-#define SWAP_MAP_MAX	0x7ffe
-#define SWAP_MAP_BAD	0x7fff
-#define SWAP_HAS_CACHE  0x8000		/* There is a swap cache
of entry. */ +#define SWAP_MAP_MAX	0x7ffffffe
+#define SWAP_MAP_BAD	0x7fffffff
+#define SWAP_HAS_CACHE  0x80000000	/* There is a swap cache of
entry. */ #define SWAP_COUNT_MASK (~SWAP_HAS_CACHE)
 /*
  * The in-memory structure used to track swap areas.
@@ -166,7 +166,7 @@ struct swap_info_struct {
 	struct block_device *bdev;
 	struct list_head extent_list;
 	struct swap_extent *curr_swap_extent;
-	unsigned short *swap_map;
+	unsigned int *swap_map;
 	unsigned int lowest_bit;
 	unsigned int highest_bit;
 	unsigned int lowest_alloc;	/* while preparing discard
cluster */ diff --git a/mm/swapfile.c b/mm/swapfile.c
index c6d5bfd..b6e9b8b 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -61,19 +61,19 @@ enum {
 	SWAP_CACHE,	/* ops for reference from swap cache */
 };
=20
-static inline int swap_count(unsigned short ent)
+static inline int swap_count(unsigned int ent)
 {
 	return ent & SWAP_COUNT_MASK;
 }
=20
-static inline bool swap_has_cache(unsigned short ent)
+static inline bool swap_has_cache(unsigned int ent)
 {
 	return !!(ent & SWAP_HAS_CACHE);
 }
=20
-static inline unsigned short encode_swapmap(int count, bool has_cache)
+static inline unsigned int encode_swapmap(unsigned int count, bool
has_cache) {
-	unsigned short ret =3D count;
+	unsigned int ret =3D count;
=20
 	if (has_cache)
 		return SWAP_HAS_CACHE | ret;
@@ -1519,7 +1519,7 @@ out:
 SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 {
 	struct swap_info_struct * p =3D NULL;
-	unsigned short *swap_map;
+	unsigned int *swap_map;
 	struct file *swap_file, *victim;
 	struct address_space *mapping;
 	struct inode *inode;
@@ -1941,13 +1941,13 @@ SYSCALL_DEFINE2(swapon, const char __user *,
specialfile, int, swap_flags) goto bad_swap;
=20
 	/* OK, set up the swap map and apply the bad block list */
-	swap_map =3D vmalloc(maxpages * sizeof(short));
+	swap_map =3D vmalloc(maxpages * sizeof(unsigned int));
 	if (!swap_map) {
 		error =3D -ENOMEM;
 		goto bad_swap;
 	}
=20
-	memset(swap_map, 0, maxpages * sizeof(short));
+	memset(swap_map, 0, maxpages * sizeof(unsigned int));
 	for (i =3D 0; i < swap_header->info.nr_badpages; i++) {
 		int page_nr =3D swap_header->info.badpages[i];
 		if (page_nr <=3D 0 || page_nr >=3D
swap_header->info.last_page) {
--=20
1.6.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
