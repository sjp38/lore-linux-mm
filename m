Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 0CDF06B0005
	for <linux-mm@kvack.org>; Thu, 28 Mar 2013 14:19:40 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <5f1504e7-8b07-4109-8271-b214b496ca61@default>
Date: Thu, 28 Mar 2013 11:19:12 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] mm: remove swapcache page early
References: <1364350932-12853-1-git-send-email-minchan@kernel.org>
 <alpine.LNX.2.00.1303271230210.29687@eggly.anvils>
 <433aaa17-7547-4e39-b472-7060ee15e85f@default>
 <20130328010706.GB22908@blaptop>
In-Reply-To: <20130328010706.GB22908@blaptop>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Shaohua Li <shli@kernel.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <bob.liu@oracle.com>

> From: Minchan Kim [mailto:minchan@kernel.org]
> Subject: Re: [RFC] mm: remove swapcache page early
>=20
> Hi Dan,
>=20
> On Wed, Mar 27, 2013 at 03:24:00PM -0700, Dan Magenheimer wrote:
> > > From: Hugh Dickins [mailto:hughd@google.com]
> > > Subject: Re: [RFC] mm: remove swapcache page early
> > >
> > > I believe the answer is for frontswap/zmem to invalidate the frontswa=
p
> > > copy of the page (to free up the compressed memory when possible) and
> > > SetPageDirty on the PageUptodate PageSwapCache page when swapping in
> > > (setting page dirty so nothing will later go to read it from the
> > > unfreed location on backing swap disk, which was never written).
> >
> > There are two duplication issues:  (1) When can the page be removed
> > from the swap cache after a call to frontswap_store; and (2) When
> > can the page be removed from the frontswap storage after it
> > has been brought back into memory via frontswap_load.
> >
> > This patch from Minchan addresses (1).  The issue you are raising
>=20
> No. I am addressing (2).
>=20
> > here is (2).  You may not know that (2) has recently been solved
> > in frontswap, at least for zcache.  See frontswap_exclusive_gets_enable=
d.
> > If this is enabled (and it is for zcache but not yet for zswap),
> > what you suggest (SetPageDirty) is what happens.
>=20
> I am blind on zcache so I didn't see it. Anyway, I'd like to address it
> on zram and zswap.

Zswap can enable it trivially by adding a function call in init_zswap.
(Note that it is not enabled by default for all frontswap backends
because it is another complicated tradeoff of cpu time vs memory space
that needs more study on a broad set of workloads.)

I wonder if something like this would have a similar result for zram?
(Completely untested... snippet stolen from swap_entry_free with
SetPageDirty added... doesn't compile yet, but should give you the idea.)

diff --git a/mm/page_io.c b/mm/page_io.c
index 56276fe..2d10988 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -81,7 +81,17 @@ void end_swap_bio_read(struct bio *bio, int err)
 =09=09=09=09iminor(bio->bi_bdev->bd_inode),
 =09=09=09=09(unsigned long long)bio->bi_sector);
 =09} else {
+=09=09struct swap_info_struct *sis;
+
 =09=09SetPageUptodate(page);
+=09=09sis =3D page_swap_info(page);
+=09=09if (sis->flags & SWP_BLKDEV) {
+=09=09=09struct gendisk *disk =3D sis->bdev->bd_disk;
+=09=09=09if (disk->fops->swap_slot_free_notify) {
+=09=09=09=09SetPageDirty(page);
+=09=09=09=09disk->fops->swap_slot_free_notify(sis->bdev,
+=09=09=09=09=09=09=09=09  offset);
+=09=09=09}
+=09=09}
 =09}
 =09unlock_page(page);
 =09bio_put(bio);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
