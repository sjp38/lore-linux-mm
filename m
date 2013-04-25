Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 734586B0002
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 14:37:19 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id y8so3080330lbh.35
        for <linux-mm@kvack.org>; Thu, 25 Apr 2013 11:37:17 -0700 (PDT)
Subject: Re: page eviction from the buddy cache
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Alexey Lyahkov <alexey.lyashkov@gmail.com>
In-Reply-To: <20130425143056.GF2144@suse.de>
Date: Thu, 25 Apr 2013 21:37:07 +0300
Content-Transfer-Encoding: quoted-printable
Message-Id: <7398CEE9-AF68-4A2A-82E4-940FADF81F97@gmail.com>
References: <3C8EEEF8-C1EB-4E3D-8DE6-198AB1BEA8C0@gmail.com> <515CD665.9000300@gmail.com> <239AD30A-2A31-4346-A4C7-8A6EB8247990@gmail.com> <51730619.3030204@fastmail.fm> <20130420235718.GA28789@thunk.org> <5176785D.5030707@fastmail.fm> <20130423122708.GA31170@thunk.org> <alpine.LNX.2.00.1304231230340.12850@eggly.anvils> <20130423150008.046ee9351da4681128db0bf3@linux-foundation.org> <20130424142650.GA29097@thunk.org> <20130425143056.GF2144@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Theodore Ts'o <tytso@mit.edu>, Andrew Perepechko <anserper@ya.ru>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Bernd Schubert <bernd.schubert@fastmail.fm>, Will Huck <will.huckk@gmail.com>, linux-ext4@vger.kernel.org, linux-mm@kvack.org

Mel,


On Apr 25, 2013, at 17:30, Mel Gorman wrote:

> On Wed, Apr 24, 2013 at 10:26:50AM -0400, Theodore Ts'o wrote:
>> On Tue, Apr 23, 2013 at 03:00:08PM -0700, Andrew Morton wrote:
>>> That should fix things for now.  Although it might be better to just =
do
>>>=20
>>> 	mark_page_accessed(page);	/* to SetPageReferenced */
>>> 	lru_add_drain();		/* to SetPageLRU */
>>>=20
>>> Because a) this was too early to decide that the page is
>>> super-important and b) the second touch of this page should have a
>>> mark_page_accessed() in it already.
>>=20
>> The question is do we really want to put lru_add_drain() into the =
ext4
>> file system code?  That seems to pushing some fairly mm-specific
>> knowledge into file system code.  I'll do this if I have to do, but
>> wouldn't be better if this was pushed into mark_page_accessed(), or
>> some other new API was exported by the mm subsystem?
>>=20
>=20
> I don't think we want to push lru_add_drain() into the ext4 code. It's
> too specific of knowledge just to work around pagevecs. Before we =
rework
> how pagevecs select what LRU to place a page, can we make sure that =
fixing
> that will fix the problem?
>=20
what is "that"? puting lru_add_drain() in ext4 core? sure that is fixes =
problem with many small reads during large write.
originally i have put shake_page() in ext4 code, but that have call =
lru_add_drain_all() so to exaggerated.

Index: linux-stage/fs/ext4/mballoc.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-stage.orig/fs/ext4/mballoc.c	2013-03-19 10:55:52.000000000 =
+0200
+++ linux-stage/fs/ext4/mballoc.c	2013-03-19 10:59:02.000000000 =
+0200
@@ -900,8 +900,11 @@ static int ext4_mb_init_cache(struct pag
 			incore =3D data;
 		}
 	}
-	if (likely(err =3D=3D 0))
+	if (likely(err =3D=3D 0)) {
 		SetPageUptodate(page);
+		/* make sure it's in active list */
+		mark_page_accessed(page);
+	}
=20
 out:
 	if (bh) {
@@ -957,6 +960,8 @@ int ext4_mb_init_group(struct super_bloc
 	page =3D find_or_create_page(inode->i_mapping, pnum, GFP_NOFS);
 	if (page) {
 		BUG_ON(page->mapping !=3D inode->i_mapping);
+		/* move to lru - should be lru_add_drain() */
+		shake_page(page, 0);
 		ret =3D ext4_mb_init_cache(page, NULL);
 		if (ret) {
 			unlock_page(page);
@@ -986,6 +991,8 @@ int ext4_mb_init_group(struct super_bloc
 		unlock_page(page);
 	} else if (page) {
 		BUG_ON(page->mapping !=3D inode->i_mapping);
+		/* move to lru - should be lru_add_drain() */
+		shake_page(page, 0);
 		ret =3D ext4_mb_init_cache(page, bitmap);
 		if (ret) {
 			unlock_page(page);
@@ -1087,6 +1094,7 @@ repeat_load_buddy:
 		if (page) {
 			BUG_ON(page->mapping !=3D inode->i_mapping);
 			if (!PageUptodate(page)) {
+				shake_page(page, 0);
 				ret =3D ext4_mb_init_cache(page, NULL);
 				if (ret) {
 					unlock_page(page);
@@ -1118,6 +1126,7 @@ repeat_load_buddy:
 		if (page) {
 			BUG_ON(page->mapping !=3D inode->i_mapping);
 			if (!PageUptodate(page)) {
+				shake_page(page, 0);
 				ret =3D ext4_mb_init_cache(page, =
e4b->bd_bitmap);
 				if (ret) {
 					unlock_page(page);
@@ -2500,6 +2509,8 @@ static int ext4_mb_init_backend(struct s
 	 * not in the inode hash, so it should never be found by iget(), =
but
 	 * this will avoid confusion if it ever shows up during =
debugging. */
 	sbi->s_buddy_cache->i_ino =3D EXT4_BAD_INO;
+	sbi->s_buddy_cache->i_state =3D I_NEW;
+//	mapping_set_unevictable(sbi->s_buddy_cache->i_mapping);
 	EXT4_I(sbi->s_buddy_cache)->i_disksize =3D 0;
 	for (i =3D 0; i < ngroups; i++) {
 		desc =3D ext4_get_group_desc(sb, i, NULL);


additional i_state =3D I_NEW need to prevent kill page cache from sysctl =
-w vm.drop_caches=3D3

> Andrew, can you try the following patch please? Also, is there any =
chance
> you can describe in more detail what the workload does?
lustre OSS node + IOR with file size twice more then OSS memory.

> If it fails to boot,
> remove the second that calls lru_add_drain_all() and try again.
well, i will try.

>=20
> The patch looks deceptively simple, a downside from is is that =
workloads that
> call mark_page_accessed() frequently will contend more on the =
zone->lru_lock
> than it did previously. Moving lru_add_drain() to the ext4 could would
> suffer the same contention problem.
NO, isn't. we have call lru_add_drain() in new page allocation case, but =
mark_page_accessed called without differences - is page in page cache =
already or it's new allocated - so we have very small zone->lru_lock =
contention.


>=20
> Thanks.
>=20
> ---8<---
> mm: pagevec: Move inactive pages to active lists even if on a pagevec
>=20
> If a page is on a pagevec aimed at the inactive list then two =
subsequent
> calls to mark_page_acessed() will still not move it to the active =
list.
> This can cause a page to be reclaimed sooner than is expected. This
> patch detects if an inactive page is not on the LRU and drains the
> pagevec before promoting it.
>=20
> Not-signed-off
>=20
> diff --git a/mm/swap.c b/mm/swap.c
> index 8a529a0..eac64fe 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -437,7 +437,18 @@ void activate_page(struct page *page)
> void mark_page_accessed(struct page *page)
> {
> 	if (!PageActive(page) && !PageUnevictable(page) &&
> -			PageReferenced(page) && PageLRU(page)) {
> +			PageReferenced(page)) {
> +		/* Page could be in pagevec */
> +		if (!PageLRU(page))
> +			lru_add_drain();
> +
> +		/*
> +		 * Weeeee, using in_atomic() like this is a =
hand-grenade.
> +		 * Patch is for debugging purposes only, do not merge =
this.
> +		 */
> +		if (!PageLRU(page) && !in_atomic())
> +			lru_add_drain_all();
> +
> 		activate_page(page);
> 		ClearPageReferenced(page);
> 	} else if (!PageReferenced(page)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
