Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id DC6F7900137
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 13:37:49 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <2ca31b06-eef9-49e4-beba-4959471b45d2@default>
Date: Tue, 13 Sep 2011 10:37:23 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [REVERT for 3.1-rc7] staging: zcache: revert "fix crash on high
 memory swap"
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Francis Moreau <francis.moro@gmail.com>, gregkh@suse.de, Seth Jennings <sjenning@linux.vnet.ibm.com>, devel@driverdev.osuosl.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org

Hi Greg --

Please revert the following commit, hopefully before 3.1 is released.
Although it fixes a crash in 32-bit systems with high memory,
the fix apparently *causes* crashes on 64-bit systems.  Not sure why
my testing didn't catch it before but it has now been observed in
the wild in 3.1-rc4 and I can reproduce it now fairly easily.
3.1-rc3 works fine, 3.1-rc4 fails, and 3.1-rc3 plus only this
commit fails.  Let's revert it before 3.1 and Seth and Nitin and I
will sort out a better fix later.

Reported-by: Francis Moreau <francis.moro@gmail.com>
Reproduced-by: Dan Magenheimer <dan.magenheimer@oracle.com>

Thanks,
Dan

commit c5f5c4db393837ebb2ae47bf061d70e498f48f8c
Author: Seth Jennings <sjenning@linux.vnet.ibm.com>
Date:   Wed Aug 10 12:56:49 2011 -0500

    staging: zcache: fix crash on high memory swap
   =20
    zcache_put_page() was modified to pass page_address(page) instead of th=
e
    actual page structure. In combination with the function signature chang=
es
    to tmem_put() and zcache_pampd_create(), zcache_pampd_create() tries to
    (re)derive the page structure from the virtual address.  However, if th=
e
    original page is a high memory page (or any unmapped page), this
    virt_to_page() fails because the page_address() in zcache_put_page()
    returned NULL.
   =20
    This patch changes zcache_put_page() and zcache_get_page() to pass
    the page structure instead of the page's virtual address, which
    may or may not exist.
   =20
    Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
    Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
    Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/=
zcache-main.c
index 855a5bb..a3f5162 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -1158,7 +1158,7 @@ static void *zcache_pampd_create(char *data, size_t s=
ize, bool raw, int eph,
 =09size_t clen;
 =09int ret;
 =09unsigned long count;
-=09struct page *page =3D virt_to_page(data);
+=09struct page *page =3D (struct page *)(data);
 =09struct zcache_client *cli =3D pool->client;
 =09uint16_t client_id =3D get_client_id_from_client(cli);
 =09unsigned long zv_mean_zsize;
@@ -1227,7 +1227,7 @@ static int zcache_pampd_get_data(char *data, size_t *=
bufsize, bool raw,
 =09int ret =3D 0;
=20
 =09BUG_ON(is_ephemeral(pool));
-=09zv_decompress(virt_to_page(data), pampd);
+=09zv_decompress((struct page *)(data), pampd);
 =09return ret;
 }
=20
@@ -1539,7 +1539,7 @@ static int zcache_put_page(int cli_id, int pool_id, s=
truct tmem_oid *oidp,
 =09=09goto out;
 =09if (!zcache_freeze && zcache_do_preload(pool) =3D=3D 0) {
 =09=09/* preload does preempt_disable on success */
-=09=09ret =3D tmem_put(pool, oidp, index, page_address(page),
+=09=09ret =3D tmem_put(pool, oidp, index, (char *)(page),
 =09=09=09=09PAGE_SIZE, 0, is_ephemeral(pool));
 =09=09if (ret < 0) {
 =09=09=09if (is_ephemeral(pool))
@@ -1572,7 +1572,7 @@ static int zcache_get_page(int cli_id, int pool_id, s=
truct tmem_oid *oidp,
 =09pool =3D zcache_get_pool_by_id(cli_id, pool_id);
 =09if (likely(pool !=3D NULL)) {
 =09=09if (atomic_read(&pool->obj_count) > 0)
-=09=09=09ret =3D tmem_get(pool, oidp, index, page_address(page),
+=09=09=09ret =3D tmem_get(pool, oidp, index, (char *)(page),
 =09=09=09=09=09&size, 0, is_ephemeral(pool));
 =09=09zcache_put_pool(pool);
 =09}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
