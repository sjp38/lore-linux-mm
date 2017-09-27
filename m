Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 70B846B0266
	for <linux-mm@kvack.org>; Wed, 27 Sep 2017 09:35:55 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id u48so14397774qtc.3
        for <linux-mm@kvack.org>; Wed, 27 Sep 2017 06:35:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t2sor5330226qkd.133.2017.09.27.06.35.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Sep 2017 06:35:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170927094049.GC25746@quack2.suse.cz>
References: <1506496508-31715-1-git-send-email-zumeng.chen@gmail.com> <20170927094049.GC25746@quack2.suse.cz>
From: Zumeng Chen <zumeng.chen@gmail.com>
Date: Wed, 27 Sep 2017 21:35:53 +0800
Message-ID: <CA+Y31wftrH-TPzyQbLUNh1zK99yXQee+Sr_5SOJ5OB3VnZH2Mw@mail.gmail.com>
Subject: Re: [PATCH ] mm/backing-dev.c: remove a null kfree and fix a false
 kmemleak in backing-dev
Content-Type: multipart/alternative; boundary="94eb2c07e670f00dd7055a2bde7a"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, axboe@fb.com, tj@kernel.org, geliangtang@gmail.com

--94eb2c07e670f00dd7055a2bde7a
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

 On 2017=E5=B9=B409=E6=9C=8827=E6=97=A5 17:40, Jan Kara wrote:

On Wed 27-09-17 15:15:08, Zumeng Chen wrote:

It seems kfree(new_congested) does nothing since new_congested has already
been set null pointer before kfree, so remove it.

Meanwhile kmemleak reports the following memory leakage:

unreferenced object 0xcadbb440 (size 64):
comm "kworker/0:4", pid 1399, jiffies 4294946504 (age 808.290s)
hex dump (first 32 bytes):
  00 00 00 00 01 00 00 00 00 00 00 00 01 00 00 00  ................
  01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
backtrace:
  [<c028fb64>] kmem_cache_alloc_trace+0x2c4/0x3cc
  [<c025fe70>] wb_congested_get_create+0x9c/0x140
  [<c0260100>] wb_init+0x184/0x1f4
  [<c02601fc>] bdi_init+0x8c/0xd4
  [<c051f75c>] blk_alloc_queue_node+0x9c/0x2d8
  [<c05227e8>] blk_init_queue_node+0x2c/0x64
  [<c052283c>] blk_init_queue+0x1c/0x20
  [<c06c7b30>] __scsi_alloc_queue+0x28/0x44
  [<c06caf4c>] scsi_alloc_queue+0x24/0x80
  [<c06cc0b8>] scsi_alloc_sdev+0x21c/0x34c
  [<c06ccc00>] scsi_probe_and_add_lun+0x878/0xb04
  [<c06cd114>] __scsi_scan_target+0x288/0x59c
  [<c06cd4b0>] scsi_scan_channel+0x88/0x9c
  [<c06cd9b8>] scsi_scan_host_selected+0x118/0x130
  [<c06cda70>] do_scsi_scan_host+0xa0/0xa4
  [<c06cdbe4>] scsi_scan_host+0x170/0x1b4

wb_congested allocates memory for congested when wb_congested_get_create,
and release it when exit or failure by wb_congested_put.


The patch is just wrong. Think what will happen if we decide to allocate
new_congested but then loose a race with somebody creating the same congest=
ed
structure (so we find it in the rb-tree).

								Honza


Yes, indeed, the first caller has a chance to re-get a congested from rb
tree
when it has already gotten a kzalloc congested(At this time the lock has
been released)

So thanks Hon

Signed-off-by: Zumeng Chen <zumeng.chen@gmail.com> <zumeng.chen@gmail.com>
---
 mm/backing-dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index e19606b..d816b2a 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -457,6 +457,7 @@ wb_congested_get_create(struct backing_dev_info
*bdi, int blkcg_id, gfp_t gfp)

 	/* allocate storage for new one and retry */
 	new_congested =3D kzalloc(sizeof(*new_congested), gfp);
+	kmemleak_ignore(new_congested);
 	if (!new_congested)
 		return NULL;

@@ -468,7 +469,6 @@ wb_congested_get_create(struct backing_dev_info
*bdi, int blkcg_id, gfp_t gfp)
 found:
 	atomic_inc(&congested->refcnt);
 	spin_unlock_irqrestore(&cgwb_lock, flags);
-	kfree(new_congested);
 	return congested;
 }

--=20
2.7.4

--94eb2c07e670f00dd7055a2bde7a
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">
 =20
   =20
 =20
  <div bgcolor=3D"#FFFFFF" text=3D"#000000">
    <div class=3D"m_-7686308329405470208moz-cite-prefix">On 2017=E5=B9=B409=
=E6=9C=8827=E6=97=A5 17:40, Jan Kara wrote:<br>
    </div>
    <blockquote type=3D"cite">
      <pre>On Wed 27-09-17 15:15:08, Zumeng Chen wrote:
</pre>
      <blockquote type=3D"cite">
        <pre>It seems kfree(new_congested) does nothing since new_congested=
 has already
been set null pointer before kfree, so remove it.

Meanwhile kmemleak reports the following memory leakage:

unreferenced object 0xcadbb440 (size 64):
comm &quot;kworker/0:4&quot;, pid 1399, jiffies 4294946504 (age 808.290s)
hex dump (first 32 bytes):
  00 00 00 00 01 00 00 00 00 00 00 00 01 00 00 00  ................
  01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
backtrace:
  [&lt;c028fb64&gt;] kmem_cache_alloc_trace+0x2c4/<wbr>0x3cc
  [&lt;c025fe70&gt;] wb_congested_get_create+0x9c/<wbr>0x140
  [&lt;c0260100&gt;] wb_init+0x184/0x1f4
  [&lt;c02601fc&gt;] bdi_init+0x8c/0xd4
  [&lt;c051f75c&gt;] blk_alloc_queue_node+0x9c/<wbr>0x2d8
  [&lt;c05227e8&gt;] blk_init_queue_node+0x2c/0x64
  [&lt;c052283c&gt;] blk_init_queue+0x1c/0x20
  [&lt;c06c7b30&gt;] __scsi_alloc_queue+0x28/0x44
  [&lt;c06caf4c&gt;] scsi_alloc_queue+0x24/0x80
  [&lt;c06cc0b8&gt;] scsi_alloc_sdev+0x21c/0x34c
  [&lt;c06ccc00&gt;] scsi_probe_and_add_lun+0x878/<wbr>0xb04
  [&lt;c06cd114&gt;] __scsi_scan_target+0x288/0x59c
  [&lt;c06cd4b0&gt;] scsi_scan_channel+0x88/0x9c
  [&lt;c06cd9b8&gt;] scsi_scan_host_selected+0x118/<wbr>0x130
  [&lt;c06cda70&gt;] do_scsi_scan_host+0xa0/0xa4
  [&lt;c06cdbe4&gt;] scsi_scan_host+0x170/0x1b4

wb_congested allocates memory for congested when wb_congested_get_create,
and release it when exit or failure by wb_congested_put.

</pre>
      </blockquote>
      <pre>The patch is just wrong. Think what will happen if we decide to =
allocate
new_congested but then loose a race with somebody creating the same congest=
ed
structure (so we find it in the rb-tree).

								Honza</pre>
    </blockquote>
    <br>
    Yes, indeed, the first caller has a chance to re-get a congested
    from rb tree <br>
    when it has already gotten a kzalloc congested(At this time the lock
    has<br>
    been released)<br>
    <br>
    So thanks Hon<br>
    <blockquote type=3D"cite">
      <pre></pre>
      <blockquote type=3D"cite">
        <pre>Signed-off-by: Zumeng Chen <a class=3D"m_-7686308329405470208m=
oz-txt-link-rfc2396E" href=3D"mailto:zumeng.chen@gmail.com" target=3D"_blan=
k">&lt;zumeng.chen@gmail.com&gt;</a>
---
 mm/backing-dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index e19606b..d816b2a 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -457,6 +457,7 @@ wb_congested_get_create(struct backing_dev_info *bdi, i=
nt blkcg_id, gfp_t gfp)
=20
 	/* allocate storage for new one and retry */
 	new_congested =3D kzalloc(sizeof(*new_congested)<wbr>, gfp);
+	kmemleak_ignore(new_congested)<wbr>;
 	if (!new_congested)
 		return NULL;
=20
@@ -468,7 +469,6 @@ wb_congested_get_create(struct backing_dev_info *bdi, i=
nt blkcg_id, gfp_t gfp)
 found:
 	atomic_inc(&amp;congested-&gt;refcnt)<wbr>;
 	spin_unlock_irqrestore(&amp;cgwb_<wbr>lock, flags);
-	kfree(new_congested);
 	return congested;
 }
=20
--=20
2.7.4

</pre>
      </blockquote>
    </blockquote>
    <p><br>
    </p>
  </div>

</div>

--94eb2c07e670f00dd7055a2bde7a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
