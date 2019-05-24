Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 593C2C282E3
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 08:12:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F9432184B
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 08:12:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F9432184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C26FB6B0008; Fri, 24 May 2019 04:12:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD6EF6B000A; Fri, 24 May 2019 04:12:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9F136B000C; Fri, 24 May 2019 04:12:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7FE8A6B0008
	for <linux-mm@kvack.org>; Fri, 24 May 2019 04:12:58 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id v16so4124176otp.17
        for <linux-mm@kvack.org>; Fri, 24 May 2019 01:12:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=4Rl5lDKbaY3RNqz1r+a26UzztQrfNaFSiQ/pob2EKMg=;
        b=sbphttNeDx8P2aPT/kE0083AnkMFuFe2SIPAJAy+4+wB/Dcxd7LLRUf2Agke7pcfjY
         G3DEiIWjkxhiUs6nFGmyKIRtUpz+/XNChwaQ5GC/zWLIJZAi7o2c9AHbnfgXr8mASql+
         qxVZ0LdNsQPwkltZNpI/b0sZ/68rjGtbIWwFGyo5WeQZ9XSg1/qauNjFx+Bmm/mt/M53
         ilNYZ/B1sfAfFkuQ8+UaXn4UHhaTl4QrDz10ynDIa049MjILJMrNFGX5ckRhoSFsYogK
         bNXS/SmJZyPCStJiUE3gxWPt2s5wCl6Q5ttajtGq/GaV4ktlf6lLamJSrbTpMZMzBVTi
         tHSQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVjLr06bT2WLrA0zvWmzByi1p18eTx90oqx27pUXrmR+MMQjsB+
	trFaRbENJMHuBsN1pY5Zrb/TlRieTPDYSKbu7KeG6r75E8hNwByzN/MYzP5/ShTumbZZF9PQbT+
	1oOTYZH2txZ/vphzpcARrztQO8sUMI/pidvkOZTHi7+d7RNlb/a0Qc5rtW7s0MezcNg==
X-Received: by 2002:aca:bb07:: with SMTP id l7mr421756oif.124.1558685578139;
        Fri, 24 May 2019 01:12:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvRRSI2fWe6uB3e+s57I29u9RU1BWej6dZfPaU18c3p8rD/0lsZ1ERYANOLIPevQ+EL3wV
X-Received: by 2002:aca:bb07:: with SMTP id l7mr421729oif.124.1558685577387;
        Fri, 24 May 2019 01:12:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558685577; cv=none;
        d=google.com; s=arc-20160816;
        b=nnHs+hzU8KPPyRuKJml03kkRdmLiFtPRH7KRF45m8GZJQ7NIX8pAaxAocR3sHXHA7w
         XBa0t9b6UdKMVRfNZnDerW+2chDpu1hoHaWuR4lZf5PqKZXWZYCLEY6gufFDb9hEQAAi
         KchNwyAb3T1iHfzEhb2Nf0S1xq8rVDKtT/dfCFZYh+C4q3Mt8zgYAAXNeuwsaWKw9ZLa
         JiLBDJTQnDEPH1Z5OLvlN6P0D30QEf/DBpEWPAbd9SAJn36HVz6PWfw9hHzTvV68B7sx
         57wBZoNUqB14FMA2P7hxVO+a5ouPv3QTEpsfvWHnefN41C4+0+CAUMIVMQ8Cj7quzg74
         U3vA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=4Rl5lDKbaY3RNqz1r+a26UzztQrfNaFSiQ/pob2EKMg=;
        b=pxnbAHZushofghR/2rAPv0azQI4ARF0u+V/Inpg4LpytHioXV3NYgh0pUvLA6hvuhw
         nowKG4jMPKRK3SA5wE8mctrhiJzaMUysjBgzKEG1DGcSL2JrpHCU1givmgwje6rtQ57r
         g4VpCoY3CH/gb5OH210m1LM0pP6tBW/fUKAdgeg18tziO8gO8QWdiEwl1nyyTat+Fumg
         nMZ2rWdLeyxFiQw/jJbya//58mFp85FhUAXDgD9UXYdu05KhaojAqe+dw0AHBnN1s/qc
         jxdVN2IqJ5XMHvGKKOtYumCUP4BdmSrNhdoj9xk9WakUoPY/ZcTmUITrPXGW6M/+GiTf
         QTzA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s8si1001575otp.321.2019.05.24.01.12.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 01:12:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A98B03082B6B;
	Fri, 24 May 2019 08:12:56 +0000 (UTC)
Received: from hp-dl380pg8-01.lab.eng.pek2.redhat.com (hp-dl380pg8-01.lab.eng.pek2.redhat.com [10.73.8.10])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8589E19C4F;
	Fri, 24 May 2019 08:12:45 +0000 (UTC)
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
Subject: [PATCH net-next 3/6] vhost: rename vq_iotlb_prefetch() to vq_meta_prefetch()
Date: Fri, 24 May 2019 04:12:15 -0400
Message-Id: <20190524081218.2502-4-jasowang@redhat.com>
In-Reply-To: <20190524081218.2502-1-jasowang@redhat.com>
References: <20190524081218.2502-1-jasowang@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Fri, 24 May 2019 08:12:56 +0000 (UTC)
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
index e78c195448f0..b353a00094aa 100644
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

