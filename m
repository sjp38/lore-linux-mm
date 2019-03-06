Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2F71C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 07:18:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7AF9C20675
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 07:18:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7AF9C20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AF4F8E0006; Wed,  6 Mar 2019 02:18:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 138EC8E0001; Wed,  6 Mar 2019 02:18:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0291F8E0006; Wed,  6 Mar 2019 02:18:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id C9EBF8E0001
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 02:18:36 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id k37so10672035qtb.20
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 23:18:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=OYPBbA6eAG3catNtSF1xNYKBcVS8MMZS2S/FHZ1OqKw=;
        b=PifkMOUSL5Xn/eWgzLtRyDkEtrIJeH8NJ0LaEGJ45FTzzN/L3s9BEozhcN5/zxhVtW
         Fz/LmBEQ1teXVpD0hZXlRHGDl9OAY/l2VdxqS3U8aTAn5noszzzyaCgLJKI7NmJ4QIxu
         i9rWsLJQopee/h6CXWNRFe0eeJPOVf8cYR1OfDmUJIVd864knCvyMcD3XkCkxS3D19aJ
         tmHFo6FlVWT7TydqGMcBD/rB40nyHa3/cUDYOkl5x+WeT6T2Fj7638H6xGLzFqvJwqUZ
         GCKr0ogS6KAzGSBfkeesNBI9j9PmSUqC2x3fhcF2fpM4B7o3aTiNr+XI8rYQEvEUA3e9
         iMJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUYASwuN6+eDyvuKjXAOAlpdEw734FY+sD6PJ07VVj+QdnuUbC+
	7JxgGG5d3QXSXD9lfyYJJ921DfeVUlYf1Dk1Kk1c6T34xCSCDFkHdSJeMuFFUF4HKwF6g8/GY8Z
	X/tx1kszVHgyiZZ/aReojBOVvMG1pR7FmbBcrpcRs5+4k+G7tTEURoXpYlL81Y1UGnQ==
X-Received: by 2002:ac8:3928:: with SMTP id s37mr4707909qtb.246.1551856716587;
        Tue, 05 Mar 2019 23:18:36 -0800 (PST)
X-Google-Smtp-Source: APXvYqzFdzGDvw+RY/leoSXXAux8i6x5uKM1lieu0dXXU8AHTXLFt/CrHSPm8lB/J5jUSd9jDy0x
X-Received: by 2002:ac8:3928:: with SMTP id s37mr4707849qtb.246.1551856715026;
        Tue, 05 Mar 2019 23:18:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551856715; cv=none;
        d=google.com; s=arc-20160816;
        b=TZq5js6AewKhVxVgYjxmUyxDk960jdRkjfXKCN2qDXmv7ZJIkckYXvGVI4AkN64VE1
         Sf94yvNXXuYt4tLSz+QpGNTvaL3UNP4IZNad/3m/1UIsj5pXdfR07pq5iewjWGfl7tDT
         N2H/P2tJi/tSAbmtYNZWeGkD4CdChdXUu5uE5+uS7zdeB50m2CovePDvgAQJ4DIke3n2
         3ilET0P28RulH4minQeJOZF/F82xn+7RSs6a/E2z1bEfqJWpdT3xAF//V/eNqjhLZHy5
         pi5/6+W8gypwYkesAeJLkB9VxJ9cLpcCT0Xx+YkOsXKKhBEVEHgTDIpjQHN9e9kzxGkG
         kTUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=OYPBbA6eAG3catNtSF1xNYKBcVS8MMZS2S/FHZ1OqKw=;
        b=Pq1d+Pb76p+goGFJqVWPBW0nYq0gieDZxpnynB5mMlDPMYqZYMwWfwH1GWWXLLUPCf
         J0zqAbP6Ze6o8r1i4d1veI8IF8tcjko/r0Pvt3yybsn8j/Ht2H2qfCmpSpSjOh/0977E
         8WCKpWgtGMWnhitLvDqdMX0mOTKmehupBHYFsrDOqU/gAvmaSLAMLYB+B85jLU1bYM5c
         n9RAKlpBaGq3XZ1G+fEYQIG5VYs7HdASeHlEnKfW7gAWYTXDOxgC1LFmIySzuhv8+Qyp
         XZM36sSW+RHH0DK+6iFqfsdr0KrnGvmLXpY1FhLavC5oO8HqWL/1ywdXckKFi4xYeO4i
         jVWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q49si488511qtj.90.2019.03.05.23.18.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 23:18:35 -0800 (PST)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3FE76300B915;
	Wed,  6 Mar 2019 07:18:34 +0000 (UTC)
Received: from hp-dl380pg8-02.lab.eng.pek2.redhat.com (hp-dl380pg8-02.lab.eng.pek2.redhat.com [10.73.8.12])
	by smtp.corp.redhat.com (Postfix) with ESMTP id AFFAE600C5;
	Wed,  6 Mar 2019 07:18:28 +0000 (UTC)
From: Jason Wang <jasowang@redhat.com>
To: jasowang@redhat.com,
	mst@redhat.com,
	kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Cc: peterx@redhat.com,
	linux-mm@kvack.org,
	aarcange@redhat.com
Subject: [RFC PATCH V2 3/5] vhost: rename vq_iotlb_prefetch() to vq_meta_prefetch()
Date: Wed,  6 Mar 2019 02:18:10 -0500
Message-Id: <1551856692-3384-4-git-send-email-jasowang@redhat.com>
In-Reply-To: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Wed, 06 Mar 2019 07:18:34 +0000 (UTC)
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
index df51a35..bf55f99 100644
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
index 29709e7..2025543 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -1309,7 +1309,7 @@ static bool iotlb_access_ok(struct vhost_virtqueue *vq,
 	return true;
 }
 
-int vq_iotlb_prefetch(struct vhost_virtqueue *vq)
+int vq_meta_prefetch(struct vhost_virtqueue *vq)
 {
 	size_t s = vhost_has_feature(vq, VIRTIO_RING_F_EVENT_IDX) ? 2 : 0;
 	unsigned int num = vq->num;
@@ -1328,7 +1328,7 @@ int vq_iotlb_prefetch(struct vhost_virtqueue *vq)
 			       num * sizeof(*vq->used->ring) + s,
 			       VHOST_ADDR_USED);
 }
-EXPORT_SYMBOL_GPL(vq_iotlb_prefetch);
+EXPORT_SYMBOL_GPL(vq_meta_prefetch);
 
 /* Can we log writes? */
 /* Caller should have device mutex but not vq mutex */
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 9490e7d..7a7fc00 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -209,7 +209,7 @@ void vhost_add_used_and_signal_n(struct vhost_dev *, struct vhost_virtqueue *,
 int vhost_log_write(struct vhost_virtqueue *vq, struct vhost_log *log,
 		    unsigned int log_num, u64 len,
 		    struct iovec *iov, int count);
-int vq_iotlb_prefetch(struct vhost_virtqueue *vq);
+int vq_meta_prefetch(struct vhost_virtqueue *vq);
 
 struct vhost_msg_node *vhost_new_msg(struct vhost_virtqueue *vq, int type);
 void vhost_enqueue_msg(struct vhost_dev *dev,
-- 
1.8.3.1

