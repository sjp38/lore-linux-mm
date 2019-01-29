Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6783DC282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 17:47:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31CF9214DA
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 17:47:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31CF9214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 876EE8E0004; Tue, 29 Jan 2019 12:47:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 81FDE8E0001; Tue, 29 Jan 2019 12:47:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67CB48E0004; Tue, 29 Jan 2019 12:47:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3A6568E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 12:47:44 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id w28so22296658qkj.22
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 09:47:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PoGzAvv3e6DxlL080Riy/GDZsRCScs9tPJNjMYSpaMs=;
        b=b7bnmDCsYPhWQmg3oQWkx6uBX2DBAvFO95v9vLdJhFvLT3lIDJRULKrNC9Q6k0Up+G
         HsPK+xFRYr4wteNsvnGh+NApA+vV1J1BPhZvycKNvO2FaI5Ia4CmIS6+utd/cAFKa72/
         Eii9IRqQaL/5guEz6KbzKaV+4X1OCGCWTsiPl2PzOGc7Bj73tGdDVWHagMLjb4h5DrYd
         RWQ8xZjWr1pfC0wlLaEDCyzLOFWOi+VKQRIJwbzSmERpLLA2wBSvl4KaRDFFaBGQkiaP
         x5JbLFr0Ku6CZXgEEbFidwjLelTtn9mOrebVj9RfQX55xC6lRENqggri0pk1QfzI8NM1
         AalQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukc8WpKRxH8mvHQmEDBPtYIA79UU0PpEcWo1ZlSCzxpaOhDb85X+
	MniG8eDiDaR0epE+TbPUeo6ecfXXwCEwCfag5w2XVbQxHdQOZlORnTs0gHYhpx7Hlk9Re2ZYbnJ
	2SqJEYb5eYsJ1m2HQ8as3j9SJ5i8weFFtXmIY5j1YVnX5Zn+XQyHqt4dHUGJ543+ynw==
X-Received: by 2002:ac8:2276:: with SMTP id p51mr27427103qtp.200.1548784064020;
        Tue, 29 Jan 2019 09:47:44 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7uO6e8h9CB2LQ4viawjNAUDphxNAChg68RYoTcQCdSK1cBI1l7YpL/Q3Fo22O+9EOmDN3u
X-Received: by 2002:ac8:2276:: with SMTP id p51mr27427059qtp.200.1548784063419;
        Tue, 29 Jan 2019 09:47:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548784063; cv=none;
        d=google.com; s=arc-20160816;
        b=x3fA14HifSwreX7hLMEh93hob42joui+CPOoVBg6acc3fC24cKmRDSQxcwD53NsYJr
         nLYVOzL0ja5Wqt28YmcrWJrlYiTfPbwAXhFJjFhOMXw5z8fPET6uyHGP24hFkdz0gMpk
         FoGuCMhwBZHwbBSpGvT87HwLyJo7ihBtDht4WG4I5gGINOUw9W5lAmUI4ktDsv5jKMxY
         gR64kWzl1UizBjti/N3+CQYg3GO1ffUC4lmmn7T8n7ngSvTxTQYyxChSstYAcauucFcf
         uSFIAwSNdU3K1xobh1Fx3sTvyWvA0YznMvQ1FhhO40VvjnivlZuvp4tKn4N6mQNGFKpg
         XupQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=PoGzAvv3e6DxlL080Riy/GDZsRCScs9tPJNjMYSpaMs=;
        b=im7GBsGuoCa/kzIIuoU3JBg5uioFLBmwPMTptid9n2laxcCO57CHOEcPtR7ytCH/6Q
         7YPIDzpXYaMGIB2sPldr3CBUPgZxZlPjAbVSxVZk7m/yqQvSru0N/Ven8ReZQddwRtyW
         7/eBRH29yZBg6niI+nxLFoDK5wG5a3Ko624F+plbzhT+dyitid+GVdqSggevgFsnypLK
         PaBvPqP1NIj6iSSse/IWubd0e4NaZBDF0d0gTNa+0HkzAUEqCVPC6jjkaw/7HVHZK9li
         L4POnqUp6hZY61xa1S++HuRGt5pt1vvvl8FFhF7SjT/F9ZKi3blmnVRZBVSS2ugXhLFS
         OC6A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x74si8227588qka.175.2019.01.29.09.47.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 09:47:43 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4BDFEC0753CE;
	Tue, 29 Jan 2019 17:47:42 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 38BF05D98E;
	Tue, 29 Jan 2019 17:47:40 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	linux-pci@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Joerg Roedel <jroedel@suse.de>,
	iommu@lists.linux-foundation.org
Subject: [RFC PATCH 2/5] drivers/base: add a function to test peer to peer capability
Date: Tue, 29 Jan 2019 12:47:25 -0500
Message-Id: <20190129174728.6430-3-jglisse@redhat.com>
In-Reply-To: <20190129174728.6430-1-jglisse@redhat.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Tue, 29 Jan 2019 17:47:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

device_test_p2p() return true if two devices can peer to peer to
each other. We add a generic function as different inter-connect
can support peer to peer and we want to genericaly test this no
matter what the inter-connect might be. However this version only
support PCIE for now.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Rafael J. Wysocki <rafael@kernel.org>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Christian Koenig <christian.koenig@amd.com>
Cc: Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: linux-kernel@vger.kernel.org
Cc: linux-pci@vger.kernel.org
Cc: dri-devel@lists.freedesktop.org
Cc: Christoph Hellwig <hch@lst.de>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Robin Murphy <robin.murphy@arm.com>
Cc: Joerg Roedel <jroedel@suse.de>
Cc: iommu@lists.linux-foundation.org
---
 drivers/base/core.c    | 20 ++++++++++++++++++++
 include/linux/device.h |  1 +
 2 files changed, 21 insertions(+)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 0073b09bb99f..56023b00e108 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -26,6 +26,7 @@
 #include <linux/netdevice.h>
 #include <linux/sched/signal.h>
 #include <linux/sysfs.h>
+#include <linux/pci-p2pdma.h>
 
 #include "base.h"
 #include "power/power.h"
@@ -3167,3 +3168,22 @@ void device_set_of_node_from_dev(struct device *dev, const struct device *dev2)
 	dev->of_node_reused = true;
 }
 EXPORT_SYMBOL_GPL(device_set_of_node_from_dev);
+
+/**
+ * device_test_p2p - test if two device can peer to peer to each other
+ * @devA: device A
+ * @devB: device B
+ * Returns: true if device can peer to peer to each other, false otherwise
+ */
+bool device_test_p2p(struct device *devA, struct device *devB)
+{
+	/*
+	 * For now we only support PCIE peer to peer but other inter-connect
+	 * can be added.
+	 */
+	if (pci_test_p2p(devA, devB))
+		return true;
+
+	return false;
+}
+EXPORT_SYMBOL_GPL(device_test_p2p);
diff --git a/include/linux/device.h b/include/linux/device.h
index 6cb4640b6160..0d532d7f0779 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -1250,6 +1250,7 @@ extern int device_online(struct device *dev);
 extern void set_primary_fwnode(struct device *dev, struct fwnode_handle *fwnode);
 extern void set_secondary_fwnode(struct device *dev, struct fwnode_handle *fwnode);
 void device_set_of_node_from_dev(struct device *dev, const struct device *dev2);
+bool device_test_p2p(struct device *devA, struct device *devB);
 
 static inline int dev_num_vf(struct device *dev)
 {
-- 
2.17.2

