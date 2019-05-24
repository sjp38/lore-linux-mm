Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74625C282E1
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 08:13:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 388152184B
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 08:13:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 388152184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C01926B000C; Fri, 24 May 2019 04:13:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB0CE6B000D; Fri, 24 May 2019 04:13:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A50C56B000E; Fri, 24 May 2019 04:13:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7AD776B000C
	for <linux-mm@kvack.org>; Fri, 24 May 2019 04:13:15 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id x27so4133753ote.6
        for <linux-mm@kvack.org>; Fri, 24 May 2019 01:13:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=n9srHPDVBP4VTzg82Kr5crrs8DkwIQG+abHb+DSGfoA=;
        b=uVMw6AI5HmPjq3ej6xHRq6KpmQCtZaVWXMDgFLKCq6GgelZG99WoMOQ8X57nKTj0vc
         3VwS1jsKrCVSfKTItwI90qNprapJNP+qgfg1L9Jprxn2bE/HodspBSYzIS3pWol/jeB+
         JxvxmHnTJEdRtQBW9JMdIXNhvjQlOoD+aQx635hmTq8HAaME3ShvjmujQNFVoqcn5Z4P
         hmrwo1TN/beNaOQyGDe1JQvX4xXnvpzjhMyqNNARDOu4xXzCbXO70ZHOgM1QgtVOJ+c2
         vC4NMrk+rnHvRO3QeoZpnEQZiA0cED3FvViKN3tKIDqxSvZh9x4QRx//X+DzIXhwEChz
         nB1Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWBvwMvOXYKzV52wxVTpkPglNrkg1qC08cDFd88W5scUy1qc33u
	BoGMNaqR+FmJifLEqV/oImsc1HSVAyTQtxwrLJFl0OVQijZC2UlvmcyZt7bU6YxoVz05ebNYDKE
	LrhzBpX4ClM7dwNTbKl54xHzuLfaFzH5PItEcfOQficvtph+MngTfnI6UI90tO+Kygg==
X-Received: by 2002:aca:4202:: with SMTP id p2mr5534582oia.85.1558685595033;
        Fri, 24 May 2019 01:13:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1PNjThOiSSXPEwV2zvgsJHimX+qvgF5QksomE56j6vvChg6KNcgv344HpUmAeVwd0Mlju
X-Received: by 2002:aca:4202:: with SMTP id p2mr5534544oia.85.1558685593730;
        Fri, 24 May 2019 01:13:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558685593; cv=none;
        d=google.com; s=arc-20160816;
        b=zSvheKizbU+owQrYsp+ZhfQgr/qHOBbt0ZAspacb2YTCmSvHfpvtqOdbMCbVogtMn7
         hbd1uS5GZuE1tvjAGHhU872/czkUMQOX7ir6ctK951GVw966A3v2oeAZ9gg8hzmFRo1u
         mDerAA1xSsLiZ8yM/z/Xx93kYBmkb6FUwkQD+Fpf6yVWmw/1PviZo5yddrP+zsTSmQll
         vqoW6KPnav0jTU3PsojJOm43t1ekUTWElNVl1U5jP5NZQNDLEITuUr+11bAya/PUx72B
         RJqqsnuWGrOFCld8lVPmLhL+lKZajtQTt3oe4MF+59378/IqbjJ+Mzik+nrQlr60VbnW
         Z6ig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=n9srHPDVBP4VTzg82Kr5crrs8DkwIQG+abHb+DSGfoA=;
        b=FEPjS4YRoBPDc3x64Zlk0hbKHNoJ0mmdwkwu4oui72oqKPWe2qI4WaXVGMHqmdS/mE
         DFIzViT6MHhNRXwpWYjuotXTpESdjOnnSkwkSa7OSfVYr92yzYtJQ4MWynVA0kye5gf7
         N5L24wG/b3/YAP0LUEyvp670833n/YMOy1tAw2qWlvEZZ2Cvp0Ca9vqFvl+878ZOPBG1
         /UmIA0gxw/aW0P3Zog1f5GZh/lAOrjq+RnhYCc6JHXSROl+zuc+2Hb1oQKoQvkFrXqdT
         dRnxwrwcIkJjuLdaQxmNuqLD0GXDqbEI+edzBXrVT4anv39Y1wRlmhHnC2dt+XroEdDA
         Ni3w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w185si1274481oib.117.2019.05.24.01.13.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 01:13:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B85B23082263;
	Fri, 24 May 2019 08:13:08 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id EC31219724;
	Fri, 24 May 2019 08:13:02 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com,
	jasowang@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	peterx@redhat.com,
	James.Bottomley@hansenpartnership.com,
	hch@infradead.org,
	davem@davemloft.net,
	jglisse@redhat.com,
	linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux-parisc@vger.kernel.org,
	christophe.de.dinechin@gmail.com,
	jrdr.linux@gmail.com
Subject: [PATCH net-next 5/6] vhost: factor out setting vring addr and num
Date: Fri, 24 May 2019 04:12:17 -0400
Message-Id: <20190524081218.2502-6-jasowang@redhat.com>
In-Reply-To: <20190524081218.2502-1-jasowang@redhat.com>
References: <20190524081218.2502-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Fri, 24 May 2019 08:13:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Factoring vring address and num setting which needs special care for
accelerating vq metadata accessing.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/vhost.c | 177 ++++++++++++++++++++++++------------------
 1 file changed, 103 insertions(+), 74 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 8605e44a7001..8bbda1777c61 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1468,6 +1468,104 @@ static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
 	return -EFAULT;
 }
 
+static long vhost_vring_set_num(struct vhost_dev *d,
+				struct vhost_virtqueue *vq,
+				void __user *argp)
+{
+	struct vhost_vring_state s;
+
+	/* Resizing ring with an active backend?
+	 * You don't want to do that. */
+	if (vq->private_data)
+		return -EBUSY;
+
+	if (copy_from_user(&s, argp, sizeof s))
+		return -EFAULT;
+
+	if (!s.num || s.num > 0xffff || (s.num & (s.num - 1)))
+		return -EINVAL;
+	vq->num = s.num;
+
+	return 0;
+}
+
+static long vhost_vring_set_addr(struct vhost_dev *d,
+				 struct vhost_virtqueue *vq,
+				 void __user *argp)
+{
+	struct vhost_vring_addr a;
+
+	if (copy_from_user(&a, argp, sizeof a))
+		return -EFAULT;
+	if (a.flags & ~(0x1 << VHOST_VRING_F_LOG))
+		return -EOPNOTSUPP;
+
+	/* For 32bit, verify that the top 32bits of the user
+	   data are set to zero. */
+	if ((u64)(unsigned long)a.desc_user_addr != a.desc_user_addr ||
+	    (u64)(unsigned long)a.used_user_addr != a.used_user_addr ||
+	    (u64)(unsigned long)a.avail_user_addr != a.avail_user_addr)
+		return -EFAULT;
+
+	/* Make sure it's safe to cast pointers to vring types. */
+	BUILD_BUG_ON(__alignof__ *vq->avail > VRING_AVAIL_ALIGN_SIZE);
+	BUILD_BUG_ON(__alignof__ *vq->used > VRING_USED_ALIGN_SIZE);
+	if ((a.avail_user_addr & (VRING_AVAIL_ALIGN_SIZE - 1)) ||
+	    (a.used_user_addr & (VRING_USED_ALIGN_SIZE - 1)) ||
+	    (a.log_guest_addr & (VRING_USED_ALIGN_SIZE - 1)))
+		return -EINVAL;
+
+	/* We only verify access here if backend is configured.
+	 * If it is not, we don't as size might not have been setup.
+	 * We will verify when backend is configured. */
+	if (vq->private_data) {
+		if (!vq_access_ok(vq, vq->num,
+			(void __user *)(unsigned long)a.desc_user_addr,
+			(void __user *)(unsigned long)a.avail_user_addr,
+			(void __user *)(unsigned long)a.used_user_addr))
+			return -EINVAL;
+
+		/* Also validate log access for used ring if enabled. */
+		if ((a.flags & (0x1 << VHOST_VRING_F_LOG)) &&
+			!log_access_ok(vq->log_base, a.log_guest_addr,
+				sizeof *vq->used +
+				vq->num * sizeof *vq->used->ring))
+			return -EINVAL;
+	}
+
+	vq->log_used = !!(a.flags & (0x1 << VHOST_VRING_F_LOG));
+	vq->desc = (void __user *)(unsigned long)a.desc_user_addr;
+	vq->avail = (void __user *)(unsigned long)a.avail_user_addr;
+	vq->log_addr = a.log_guest_addr;
+	vq->used = (void __user *)(unsigned long)a.used_user_addr;
+
+	return 0;
+}
+
+static long vhost_vring_set_num_addr(struct vhost_dev *d,
+				     struct vhost_virtqueue *vq,
+				     unsigned int ioctl,
+				     void __user *argp)
+{
+	long r;
+
+	mutex_lock(&vq->mutex);
+
+	switch (ioctl) {
+	case VHOST_SET_VRING_NUM:
+		r = vhost_vring_set_num(d, vq, argp);
+		break;
+	case VHOST_SET_VRING_ADDR:
+		r = vhost_vring_set_addr(d, vq, argp);
+		break;
+	default:
+		BUG();
+	}
+
+	mutex_unlock(&vq->mutex);
+
+	return r;
+}
 long vhost_vring_ioctl(struct vhost_dev *d, unsigned int ioctl, void __user *argp)
 {
 	struct file *eventfp, *filep = NULL;
@@ -1477,7 +1575,6 @@ long vhost_vring_ioctl(struct vhost_dev *d, unsigned int ioctl, void __user *arg
 	struct vhost_virtqueue *vq;
 	struct vhost_vring_state s;
 	struct vhost_vring_file f;
-	struct vhost_vring_addr a;
 	u32 idx;
 	long r;
 
@@ -1490,26 +1587,14 @@ long vhost_vring_ioctl(struct vhost_dev *d, unsigned int ioctl, void __user *arg
 	idx = array_index_nospec(idx, d->nvqs);
 	vq = d->vqs[idx];
 
+	if (ioctl == VHOST_SET_VRING_NUM ||
+	    ioctl == VHOST_SET_VRING_ADDR) {
+		return vhost_vring_set_num_addr(d, vq, ioctl, argp);
+	}
+
 	mutex_lock(&vq->mutex);
 
 	switch (ioctl) {
-	case VHOST_SET_VRING_NUM:
-		/* Resizing ring with an active backend?
-		 * You don't want to do that. */
-		if (vq->private_data) {
-			r = -EBUSY;
-			break;
-		}
-		if (copy_from_user(&s, argp, sizeof s)) {
-			r = -EFAULT;
-			break;
-		}
-		if (!s.num || s.num > 0xffff || (s.num & (s.num - 1))) {
-			r = -EINVAL;
-			break;
-		}
-		vq->num = s.num;
-		break;
 	case VHOST_SET_VRING_BASE:
 		/* Moving base with an active backend?
 		 * You don't want to do that. */
@@ -1535,62 +1620,6 @@ long vhost_vring_ioctl(struct vhost_dev *d, unsigned int ioctl, void __user *arg
 		if (copy_to_user(argp, &s, sizeof s))
 			r = -EFAULT;
 		break;
-	case VHOST_SET_VRING_ADDR:
-		if (copy_from_user(&a, argp, sizeof a)) {
-			r = -EFAULT;
-			break;
-		}
-		if (a.flags & ~(0x1 << VHOST_VRING_F_LOG)) {
-			r = -EOPNOTSUPP;
-			break;
-		}
-		/* For 32bit, verify that the top 32bits of the user
-		   data are set to zero. */
-		if ((u64)(unsigned long)a.desc_user_addr != a.desc_user_addr ||
-		    (u64)(unsigned long)a.used_user_addr != a.used_user_addr ||
-		    (u64)(unsigned long)a.avail_user_addr != a.avail_user_addr) {
-			r = -EFAULT;
-			break;
-		}
-
-		/* Make sure it's safe to cast pointers to vring types. */
-		BUILD_BUG_ON(__alignof__ *vq->avail > VRING_AVAIL_ALIGN_SIZE);
-		BUILD_BUG_ON(__alignof__ *vq->used > VRING_USED_ALIGN_SIZE);
-		if ((a.avail_user_addr & (VRING_AVAIL_ALIGN_SIZE - 1)) ||
-		    (a.used_user_addr & (VRING_USED_ALIGN_SIZE - 1)) ||
-		    (a.log_guest_addr & (VRING_USED_ALIGN_SIZE - 1))) {
-			r = -EINVAL;
-			break;
-		}
-
-		/* We only verify access here if backend is configured.
-		 * If it is not, we don't as size might not have been setup.
-		 * We will verify when backend is configured. */
-		if (vq->private_data) {
-			if (!vq_access_ok(vq, vq->num,
-				(void __user *)(unsigned long)a.desc_user_addr,
-				(void __user *)(unsigned long)a.avail_user_addr,
-				(void __user *)(unsigned long)a.used_user_addr)) {
-				r = -EINVAL;
-				break;
-			}
-
-			/* Also validate log access for used ring if enabled. */
-			if ((a.flags & (0x1 << VHOST_VRING_F_LOG)) &&
-			    !log_access_ok(vq->log_base, a.log_guest_addr,
-					   sizeof *vq->used +
-					   vq->num * sizeof *vq->used->ring)) {
-				r = -EINVAL;
-				break;
-			}
-		}
-
-		vq->log_used = !!(a.flags & (0x1 << VHOST_VRING_F_LOG));
-		vq->desc = (void __user *)(unsigned long)a.desc_user_addr;
-		vq->avail = (void __user *)(unsigned long)a.avail_user_addr;
-		vq->log_addr = a.log_guest_addr;
-		vq->used = (void __user *)(unsigned long)a.used_user_addr;
-		break;
 	case VHOST_SET_VRING_KICK:
 		if (copy_from_user(&f, argp, sizeof f)) {
 			r = -EFAULT;
-- 
2.18.1

