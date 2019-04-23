Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A874C282E3
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 05:54:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9BAA21738
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 05:54:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9BAA21738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FF8D6B000D; Tue, 23 Apr 2019 01:54:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AEE86B000E; Tue, 23 Apr 2019 01:54:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C5246B0010; Tue, 23 Apr 2019 01:54:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4E0786B000D
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 01:54:55 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id o34so13803324qte.5
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 22:54:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=p0LVi5P4xummSTVtr9ikiQ4kmmxsXBzgyT6m3PDySak=;
        b=Ww663fQJkCHEJUoZLeXRMVQkjy4FSGSTZwdnxVS2qYbjaPx+/4RaozC87tXaYOpsm5
         bSRYyhb26XGYQxy+W5u5WsM8OqwsnUMrK7nOJwc53rOAXG02PIPwNIgbnCHHFgAsS3AN
         4mhQ6ot0OVamyH7efxiM41pXmyJX6IVS2QKdDxXJeq/cWczvpkkvTdRV99V3OfPeTc2w
         Ewru2Lo2jmxH5aA8KDjwzXJiiJrDsAokX3um2Nn4ts2PzLwZmruy8jNWuMCwvGFcT+QT
         0XZynPN24vyTJm3u3NdGmS6tbRCaSgkAigWfPZuC3FnjVP1JH7wc3wJ82M8z17pGNhXT
         YoEw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXLcxSVN89RD7fh9mbR2GjNz3fDQisGL41oRXC1x6d5pwZ+0h7k
	5Ej4U+ycGV6a/qB7GdLVfB8r3VPyZqj0q6jMXyd4eK8dVvUQLpvKflxXavXOS+9N8sIpG1vt+xY
	/9YWHxUzUTg5EK11ewN3C7s6UFy/tlNo7qLZq0PmAm7Gm+icAUfTRJhN+/Z5InL2gnQ==
X-Received: by 2002:ac8:71c4:: with SMTP id i4mr18824549qtp.358.1555998895086;
        Mon, 22 Apr 2019 22:54:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6tpWV7P349pHN/Uw/IFwadoYHrr1Q2tfG5rO+vakuIzTjFckfd065Cly2GlfJJ8taE04T
X-Received: by 2002:ac8:71c4:: with SMTP id i4mr18824502qtp.358.1555998894014;
        Mon, 22 Apr 2019 22:54:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555998894; cv=none;
        d=google.com; s=arc-20160816;
        b=kNrnTbXz/BRzFn2bGWCgSpjfazBur47yrnIsiT7wjurZz9Vxl43Jdkey7Mzb3v9Lq+
         jIFlXNnoajTt3x1u0gfxKi1KaTQXfPp4MvDU4JLHOBDnhzDnp2AT6uuicZJmnct3Un39
         yOKkBevDmXNbJgiM0NhqnR5XYIXheLOpi14J16nrFs2C3xcDX6U0QZmDCmQw81r/JxdW
         iW2PhM50LVeKgyUF1ho3CvnT+yI3HwMeR7rAD7a8L6HApsUz5n9t43dA+Ps34yzOy3ng
         zejaKm+cu8YE21zDKGUqW2+xXTb17vVMJlQXNAZWUG0m386RkjIF8DakB9VdXYqqBI5G
         08dQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=p0LVi5P4xummSTVtr9ikiQ4kmmxsXBzgyT6m3PDySak=;
        b=hLISUodD7UDst1ac2V1lMINqYEtbIJiTeUAVywwxqQ21rq756+R9IOC2KYyqcmuqXa
         CgAxNFL/Pni77o+1AynTDHL2y+sfycn+e7VKh+foEFkNlozL8BFHNyoLlKVIaOo9Us7y
         fkY4t2nsC529ExXu3goqAm+E0v8wHs1fU4ndqnH+VpmmbwNEtggZZ7qp11ohrg5/GCNn
         ul/WGDAiajd56afj3Kybor7oUWs0WKuruHsTwDx3ztGzWB0KElg/grsrD9KOOlKCcEvR
         lkVuTah6TCwHsIFwzfoB/lkDtVhHLL1pQ7L0C+rOcjNO3KLVCwM1OqEXsjrNDw/E7NSm
         zfVA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c10si1171825qvt.162.2019.04.22.22.54.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 22:54:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2483BF74AC;
	Tue, 23 Apr 2019 05:54:53 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BD99D1A8F6;
	Tue, 23 Apr 2019 05:54:43 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	jasowang@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: peterx@redhat.com,
	aarcange@redhat.com,
	James.Bottomley@hansenpartnership.com,
	hch@infradead.org,
	davem@davemloft.net,
	jglisse@redhat.com,
	linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux-parisc@vger.kernel.org,
	christophe.de.dinechin@gmail.com,
	jrdr.linux@gmail.com
Subject: [RFC PATCH V3 3/6] vhost: rename vq_iotlb_prefetch() to vq_meta_prefetch()
Date: Tue, 23 Apr 2019 01:54:17 -0400
Message-Id: <20190423055420.26408-4-jasowang@redhat.com>
In-Reply-To: <20190423055420.26408-1-jasowang@redhat.com>
References: <20190423055420.26408-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 23 Apr 2019 05:54:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Rename the function to be more accurate since it actually tries to
prefetch vq metadata address in IOTLB. And this will be used by
following patch to prefetch metadata virtual addresses.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c   | 4 ++--
 drivers/vhost/vhost.c | 4 ++--
 drivers/vhost/vhost.h | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index df51a35cf537..bf55f995ebae 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -971,7 +971,7 @@ static void handle_tx(struct vhost_net *net)
 	if (!sock)
 		goto out;
 
-	if (!vq_iotlb_prefetch(vq))
+	if (!vq_meta_prefetch(vq))
 		goto out;
 
 	vhost_disable_notify(&net->dev, vq);
@@ -1140,7 +1140,7 @@ static void handle_rx(struct vhost_net *net)
 	if (!sock)
 		goto out;
 
-	if (!vq_iotlb_prefetch(vq))
+	if (!vq_meta_prefetch(vq))
 		goto out;
 
 	vhost_disable_notify(&net->dev, vq);
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 7335f2275ed3..bff4d586871d 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1313,7 +1313,7 @@ static bool iotlb_access_ok(struct vhost_virtqueue *vq,
 	return true;
 }
 
-int vq_iotlb_prefetch(struct vhost_virtqueue *vq)
+int vq_meta_prefetch(struct vhost_virtqueue *vq)
 {
 	size_t s = vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
 	unsigned int num = vq->num;
@@ -1332,7 +1332,7 @@ int vq_iotlb_prefetch(struct vhost_virtqueue *vq)
 			       num * sizeof(*vq->used->ring) + s,
 			       VHOST_ADDR_USED);
 }
-EXPORT_SYMBOL_GPL(vq_iotlb_prefetch);
+EXPORT_SYMBOL_GPL(vq_meta_prefetch);
 
 /* Can we log writes? */
 /* Caller should have device mutex but not vq mutex */
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 9490e7ddb340..7a7fc001265f 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -209,7 +209,7 @@ bool vhost_enable_notify(struct vhost_dev *, struct vhost_virtqueue *);
 int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 		    unsigned int log_num, u64 len,
 		    struct iovec *iov, int count);
-int vq_iotlb_prefetch(struct vhost_virtqueue *vq);
+int vq_meta_prefetch(struct vhost_virtqueue *vq);
 
 struct vhost_msg_node *vhost_new_msg(struct vhost_virtqueue *vq, int type);
 void vhost_enqueue_msg(struct vhost_dev *dev,
-- 
2.18.1

