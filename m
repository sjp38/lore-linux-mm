Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 166D3C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 13:14:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D488020842
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 13:14:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D488020842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7031C6B000A; Mon, 12 Aug 2019 09:14:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B8596B000C; Mon, 12 Aug 2019 09:14:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52D3F6B000D; Mon, 12 Aug 2019 09:14:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0003.hostedemail.com [216.40.44.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2F81B6B000A
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 09:14:12 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id DD0AB180AD7C3
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 13:14:11 +0000 (UTC)
X-FDA: 75813819102.01.books11_5ed00a59ad734
X-HE-Tag: books11_5ed00a59ad734
X-Filterd-Recvd-Size: 5473
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 13:14:11 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6CA2B970F6;
	Mon, 12 Aug 2019 13:14:10 +0000 (UTC)
Received: from virtlab605.virt.lab.eng.bos.redhat.com (virtlab605.virt.lab.eng.bos.redhat.com [10.19.152.201])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7CB4A1000321;
	Mon, 12 Aug 2019 13:14:08 +0000 (UTC)
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	virtio-dev@lists.oasis-open.org,
	pbonzini@redhat.com,
	lcapitulino@redhat.com,
	pagupta@redhat.com,
	wei.w.wang@intel.com,
	yang.zhang.wz@gmail.com,
	riel@surriel.com,
	david@redhat.com,
	mst@redhat.com,
	dodgen@google.com,
	konrad.wilk@oracle.com,
	dhildenb@redhat.com,
	aarcange@redhat.com,
	alexander.duyck@gmail.com,
	john.starks@microsoft.com,
	dave.hansen@intel.com,
	mhocko@suse.com,
	cohuck@redhat.com
Subject: [QEMU Patch 2/2] virtio-balloon: support for handling page reporting
Date: Mon, 12 Aug 2019 09:13:57 -0400
Message-Id: <20190812131357.27312-2-nitesh@redhat.com>
In-Reply-To: <20190812131357.27312-1-nitesh@redhat.com>
References: <20190812131235.27244-1-nitesh@redhat.com>
 <20190812131357.27312-1-nitesh@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Mon, 12 Aug 2019 13:14:10 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Page reporting is a feature which enables the virtual machine to report
chunk of free pages to the hypervisor.
This patch enables QEMU to process these reports from the VM and discard =
the
unused memory range.

Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
---
 hw/virtio/virtio-balloon.c         | 41 ++++++++++++++++++++++++++++++
 include/hw/virtio/virtio-balloon.h |  2 +-
 2 files changed, 42 insertions(+), 1 deletion(-)

diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
index 25de154307..1132e47ee0 100644
--- a/hw/virtio/virtio-balloon.c
+++ b/hw/virtio/virtio-balloon.c
@@ -320,6 +320,39 @@ static void balloon_stats_set_poll_interval(Object *=
obj, Visitor *v,
     balloon_stats_change_timer(s, 0);
 }
=20
+static void virtio_balloon_handle_reporting(VirtIODevice *vdev, VirtQueu=
e *vq)
+{
+    VirtQueueElement *elem;
+
+    while ((elem =3D virtqueue_pop(vq, sizeof(VirtQueueElement)))) {
+        unsigned int i;
+
+        for (i =3D 0; i < elem->in_num; i++) {
+            void *gaddr =3D elem->in_sg[i].iov_base;
+            size_t size =3D elem->in_sg[i].iov_len;
+            ram_addr_t ram_offset;
+            size_t rb_page_size;
+	    RAMBlock *rb;
+
+            if (qemu_balloon_is_inhibited())
+                continue;
+
+            rb =3D qemu_ram_block_from_host(gaddr, false, &ram_offset);
+            rb_page_size =3D qemu_ram_pagesize(rb);
+
+            /* For now we will simply ignore unaligned memory regions */
+            if ((ram_offset | size) & (rb_page_size - 1))
+                continue;
+
+            ram_block_discard_range(rb, ram_offset, size);
+        }
+
+        virtqueue_push(vq, elem, 0);
+        virtio_notify(vdev, vq);
+        g_free(elem);
+    }
+}
+
 static void virtio_balloon_handle_output(VirtIODevice *vdev, VirtQueue *=
vq)
 {
     VirtIOBalloon *s =3D VIRTIO_BALLOON(vdev);
@@ -792,6 +825,12 @@ static void virtio_balloon_device_realize(DeviceStat=
e *dev, Error **errp)
     s->dvq =3D virtio_add_queue(vdev, 128, virtio_balloon_handle_output)=
;
     s->svq =3D virtio_add_queue(vdev, 128, virtio_balloon_receive_stats)=
;
=20
+    if (virtio_has_feature(s->host_features,
+                           VIRTIO_BALLOON_F_REPORTING)) {
+        s->reporting_vq =3D virtio_add_queue(vdev, 16,
+					   virtio_balloon_handle_reporting);
+    }
+
     if (virtio_has_feature(s->host_features,
                            VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
         s->free_page_vq =3D virtio_add_queue(vdev, VIRTQUEUE_MAX_SIZE,
@@ -912,6 +951,8 @@ static Property virtio_balloon_properties[] =3D {
      * is disabled, resulting in QEMU 3.1 migration incompatibility.  Th=
is
      * property retains this quirk for QEMU 4.1 machine types.
      */
+    DEFINE_PROP_BIT("free-page-reporting", VirtIOBalloon, host_features,
+                    VIRTIO_BALLOON_F_REPORTING, true),
     DEFINE_PROP_BOOL("qemu-4-0-config-size", VirtIOBalloon,
                      qemu_4_0_config_size, false),
     DEFINE_PROP_LINK("iothread", VirtIOBalloon, iothread, TYPE_IOTHREAD,
diff --git a/include/hw/virtio/virtio-balloon.h b/include/hw/virtio/virti=
o-balloon.h
index d1c968d237..15a05e6435 100644
--- a/include/hw/virtio/virtio-balloon.h
+++ b/include/hw/virtio/virtio-balloon.h
@@ -42,7 +42,7 @@ enum virtio_balloon_free_page_report_status {
=20
 typedef struct VirtIOBalloon {
     VirtIODevice parent_obj;
-    VirtQueue *ivq, *dvq, *svq, *free_page_vq;
+    VirtQueue *ivq, *dvq, *svq, *free_page_vq, *reporting_vq;
     uint32_t free_page_report_status;
     uint32_t num_pages;
     uint32_t actual;
--=20
2.21.0


