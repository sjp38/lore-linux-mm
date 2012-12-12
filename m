Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 07BEF6B0092
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 19:22:49 -0500 (EST)
MIME-Version: 1.0
Message-ID: <3a344fcf-c256-42e9-87c3-66cd41d763f9@default>
Date: Tue, 11 Dec 2012 16:22:40 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: zram /proc/swaps accounting weirdness
References: <c8728036-07da-49ce-b4cb-c3d800790b53@default>
 <CAA_GA1eBR6=vasnoSDYZK9qvYQtzVS9q2CHC3M-qeVRRp1dhPg@mail.gmail.com>
In-Reply-To: <CAA_GA1eBR6=vasnoSDYZK9qvYQtzVS9q2CHC3M-qeVRRp1dhPg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org

> From: Bob Liu [mailto:lliubbo@gmail.com]
> Subject: Re: zram /proc/swaps accounting weirdness
>=20
> Hi Dan,
>=20
> On Sat, Dec 8, 2012 at 7:57 AM, Dan Magenheimer
> <dan.magenheimer@oracle.com> wrote:
> > While playing around with zcache+zram (see separate thread),
> > I was watching stats with "watch -d".
> >
> > It appears from the code that /sys/block/num_writes only
> > increases, never decreases.  In my test, num_writes got up
> > to 1863.  /sys/block/disksize is 104857600.
> >
> > I have two swap disks, one zram (pri=3D60), one real (pri=3D-1),
> > and as a I watched /proc/swaps, the "Used" field grew rapidly
> > and reached the Size (102396k) of the zram swap, and then
> > the second swap disk (a physical disk partition) started being
> > used.  Then for awhile, the Used field for both swap devices
> > was changing (up and down).
> >
> > Can you explain how this could happen if num_writes never
> > exceeded 1863?  This may be harmless in the case where
> > the only swap on the system is zram; or may indicate a bug
> > somewhere?
> >
>=20
> Sorry, I didn't get your idea here.
> In my opinion, num_writes is the count of request but not the size.
> I think the total size should be the sum of bio->bi_size,
> so if num_writes is 1863 the actual size may also exceed 102396k.

Hi Bob --

I added some debug code to record total bio_bi_size (and some
other things) to sysfs.  No, bio->bi_size appears to always
(or nearly always) be PAGE_SIZE.

Debug patch attached below in case you are interested.
(Applies to 3.7 final.)

> > It looks like num_writes is counting bio's not pages...
> > which would imply the bio's are potentially quite large
> > (and I'll guess they are of size SWAPFILE_CLUSTER which is
> > defined to be 256).  Do large clusters make sense with zram?
> >
> > Late on a Friday so sorry if I am incomprehensible...
> >
> > P.S. The corresponding stat for zcache indicates that
> > it failed 8852 stores, so I would have expected zram
> > to deal with no more than 8852 compressions.

diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_dr=
v.c
index 6edefde..9679b02 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -160,7 +160,7 @@ static void zram_free_page(struct zram *zram, size_t in=
dex)
=20
 =09zram_stat64_sub(zram, &zram->stats.compr_size,
 =09=09=09zram->table[index].size);
-=09zram_stat_dec(&zram->stats.pages_stored);
+=09zram_stat64_sub(zram, &zram->stats.pages_stored, -1);
=20
 =09zram->table[index].handle =3D 0;
 =09zram->table[index].size =3D 0;
@@ -371,7 +371,8 @@ static int zram_bvec_write(struct zram *zram, struct bi=
o_vec *bvec, u32 index,
=20
 =09/* Update stats */
 =09zram_stat64_add(zram, &zram->stats.compr_size, clen);
-=09zram_stat_inc(&zram->stats.pages_stored);
+=09zram_stat64_inc(zram, &zram->stats.pages_stored);
+=09zram_stat64_inc(zram, &zram->stats.cum_pages_stored);
 =09if (clen <=3D PAGE_SIZE / 2)
 =09=09zram_stat_inc(&zram->stats.good_compress);
=20
@@ -419,6 +420,8 @@ static void __zram_make_request(struct zram *zram, stru=
ct bio *bio, int rw)
 =09=09zram_stat64_inc(zram, &zram->stats.num_reads);
 =09=09break;
 =09case WRITE:
+=09=09zram_stat64_add(zram, &zram->stats.tot_bio_bi_size,
+=09=09=09=09bio->bi_size);
 =09=09zram_stat64_inc(zram, &zram->stats.num_writes);
 =09=09break;
 =09}
@@ -428,6 +431,11 @@ static void __zram_make_request(struct zram *zram, str=
uct bio *bio, int rw)
=20
 =09bio_for_each_segment(bvec, bio, i) {
 =09=09int max_transfer_size =3D PAGE_SIZE - offset;
+=09=09switch (rw) {
+=09=09case WRITE:
+=09=09=09zram_stat64_inc(zram, &zram->stats.num_segments);
+=09=09break;
+=09=09}
=20
 =09=09if (bvec->bv_len > max_transfer_size) {
 =09=09=09/*
diff --git a/drivers/staging/zram/zram_drv.h b/drivers/staging/zram/zram_dr=
v.h
index 572c0b1..c40fe50 100644
--- a/drivers/staging/zram/zram_drv.h
+++ b/drivers/staging/zram/zram_drv.h
@@ -76,12 +76,15 @@ struct zram_stats {
 =09u64 compr_size;=09=09/* compressed size of pages stored */
 =09u64 num_reads;=09=09/* failed + successful */
 =09u64 num_writes;=09=09/* --do-- */
+=09u64 tot_bio_bi_size;=09=09/* --do-- */
+=09u64 num_segments;=09=09/* --do-- */
 =09u64 failed_reads;=09/* should NEVER! happen */
 =09u64 failed_writes;=09/* can happen when memory is too low */
 =09u64 invalid_io;=09=09/* non-page-aligned I/O requests */
 =09u64 notify_free;=09/* no. of swap slot free notifications */
 =09u32 pages_zero;=09=09/* no. of zero filled pages */
-=09u32 pages_stored;=09/* no. of pages currently stored */
+=09u64 pages_stored;=09/* no. of pages currently stored */
+=09u64 cum_pages_stored;=09/* pages cumulatively stored */
 =09u32 good_compress;=09/* % of pages with compression ratio<=3D50% */
 =09u32 bad_compress;=09/* % of pages with compression ratio>=3D75% */
 };
diff --git a/drivers/staging/zram/zram_sysfs.c b/drivers/staging/zram/zram_=
sysfs.c
index edb0ed4..2df62d4 100644
--- a/drivers/staging/zram/zram_sysfs.c
+++ b/drivers/staging/zram/zram_sysfs.c
@@ -136,6 +136,42 @@ static ssize_t num_writes_show(struct device *dev,
 =09=09zram_stat64_read(zram, &zram->stats.num_writes));
 }
=20
+static ssize_t tot_bio_bi_size_show(struct device *dev,
+=09=09struct device_attribute *attr, char *buf)
+{
+=09struct zram *zram =3D dev_to_zram(dev);
+
+=09return sprintf(buf, "%llu\n",
+=09=09zram_stat64_read(zram, &zram->stats.tot_bio_bi_size));
+}
+
+static ssize_t num_segments_show(struct device *dev,
+=09=09struct device_attribute *attr, char *buf)
+{
+=09struct zram *zram =3D dev_to_zram(dev);
+
+=09return sprintf(buf, "%llu\n",
+=09=09zram_stat64_read(zram, &zram->stats.num_segments));
+}
+
+static ssize_t pages_stored_show(struct device *dev,
+=09=09struct device_attribute *attr, char *buf)
+{
+=09struct zram *zram =3D dev_to_zram(dev);
+
+=09return sprintf(buf, "%llu\n",
+=09=09zram_stat64_read(zram, &zram->stats.pages_stored));
+}
+
+static ssize_t cum_pages_stored_show(struct device *dev,
+=09=09struct device_attribute *attr, char *buf)
+{
+=09struct zram *zram =3D dev_to_zram(dev);
+
+=09return sprintf(buf, "%llu\n",
+=09=09zram_stat64_read(zram, &zram->stats.cum_pages_stored));
+}
+
 static ssize_t invalid_io_show(struct device *dev,
 =09=09struct device_attribute *attr, char *buf)
 {
@@ -198,6 +234,10 @@ static DEVICE_ATTR(initstate, S_IRUGO, initstate_show,=
 NULL);
 static DEVICE_ATTR(reset, S_IWUSR, NULL, reset_store);
 static DEVICE_ATTR(num_reads, S_IRUGO, num_reads_show, NULL);
 static DEVICE_ATTR(num_writes, S_IRUGO, num_writes_show, NULL);
+static DEVICE_ATTR(tot_bio_bi_size, S_IRUGO, tot_bio_bi_size_show, NULL);
+static DEVICE_ATTR(num_segments, S_IRUGO, num_segments_show, NULL);
+static DEVICE_ATTR(pages_stored, S_IRUGO, pages_stored_show, NULL);
+static DEVICE_ATTR(cum_pages_stored, S_IRUGO, cum_pages_stored_show, NULL)=
;
 static DEVICE_ATTR(invalid_io, S_IRUGO, invalid_io_show, NULL);
 static DEVICE_ATTR(notify_free, S_IRUGO, notify_free_show, NULL);
 static DEVICE_ATTR(zero_pages, S_IRUGO, zero_pages_show, NULL);
@@ -211,6 +251,10 @@ static struct attribute *zram_disk_attrs[] =3D {
 =09&dev_attr_reset.attr,
 =09&dev_attr_num_reads.attr,
 =09&dev_attr_num_writes.attr,
+=09&dev_attr_tot_bio_bi_size.attr,
+=09&dev_attr_num_segments.attr,
+=09&dev_attr_pages_stored.attr,
+=09&dev_attr_cum_pages_stored.attr,
 =09&dev_attr_invalid_io.attr,
 =09&dev_attr_notify_free.attr,
 =09&dev_attr_zero_pages.attr,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
