Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB5C0C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 17:47:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A876214DA
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 17:47:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A876214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4047C8E0003; Tue, 29 Jan 2019 12:47:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 38EA28E0001; Tue, 29 Jan 2019 12:47:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 254A88E0003; Tue, 29 Jan 2019 12:47:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE0018E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 12:47:41 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id t18so25706427qtj.3
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 09:47:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=9RSF3wYM68LRkU5/mjhuSa1XXoUTuAX+TG7X8cIVENc=;
        b=jP7+hrY4DMrtfcSv7/aa5rK1MQJehFoPv3Mm0Tzqz2OOMqdTr2gT6i2+upCt2txVGF
         dWn9JRnupnI453hLT1HtWvT5UVwWmdxiF8Lc16PzYT+eIeQk/oFnAExERHZgz6a2yKB/
         xHHQSU/gYb1i7R2G63VdQ89bqQwrCcPD+ze/RNLiWbbm4XKCcc6d7bZv3z5xnRMcU/hU
         BpOVmH9aF+C27BSrP639CncmERhg2HxNgCpwKRt17JCPVnWrAB2hz5O1ViaFVfDxKpc2
         z/4e8399UJYZX+1rATqBoN6zDNIiLxlz74Hb/3zwJEZW93d9hmo1+3pEGNKWhvsCychb
         hCqw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukcfnaDoeTPlLzwBg1e1M/gjvpC8mV4ty9shqEJQtVMRbJehLzDi
	Op6Cf+Kms7u8yFz75oYEaVIKr/qBli9wCPUzXIlNR0xW7jAdsAxecLy7FvtleokLEB8KMXpW/bl
	p6SrUbXHVQad+QQM5Imu6Wtkrx/6uvm5B2lkcI3sjYfoMD2NXe+hSSK0XAox1A53UPw==
X-Received: by 2002:a37:72c3:: with SMTP id n186mr23710460qkc.340.1548784061748;
        Tue, 29 Jan 2019 09:47:41 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6r0BG1n5G8lq9hLfa0aMzaXyJljHHhNU3gclOLazjI5xWSyDffVDHsagA6+zQKL+z4aewd
X-Received: by 2002:a37:72c3:: with SMTP id n186mr23710426qkc.340.1548784061223;
        Tue, 29 Jan 2019 09:47:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548784061; cv=none;
        d=google.com; s=arc-20160816;
        b=Qi3p903kYoG2MN1QkhVat9joEgmcRJV2ow3CM3DOkIz3P0O5NOYYDDacgrebqjieFS
         69qGee7GVC5TU4OPvVun+uNJGXMCTsUqFoBysO4DV2gO7Up749L6boH/0R3BPFnlNCo9
         VjpD4G6UquL+DKi/QFKpwKX4TQz7etgZljbQt/dSKO5QGn62tnxLMc4+fRrI19jAEjp9
         L5ZuIxU1/mDLJJiOcmmT9+59lF97cv7bI7Bx8XVwLQxoXS5A8N4nMcWrWEVQIeSLzPOk
         Q8WWTzWooQ82OarFkk/DKhXs5BxqouYLKm7EY8xEIVJze1ODVf+tarSQS02gvad1QHoS
         2sVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=9RSF3wYM68LRkU5/mjhuSa1XXoUTuAX+TG7X8cIVENc=;
        b=cvRLSfmjN9TBcHdU0sA7Q6Oca/kxF1XTbYUOaBWsjr2UjzSadqbx4V4jeW296JOzWz
         4WZrUlEMCiPBJY18LuYVrdFcqpW+tu3Vzuhk4eV80nQFFn+D6wIeKZiE8Zzyavm2WTTd
         2mIZopkgXf8CTs3AWVfZ5yQIsPhOZjwaPI/zVf3GMpBcn3RQBjc99uJJkE8byTG6/83o
         STJgLcJavNA9SeLI3pKqaiWBDn7n3YSkeaUiFdEjCkEgU+lepokfbQR1PDOuyvY3QSch
         7Oluj5LhlJZbOb4Ot+NO7iwVqkhpcD38+oYxPloZavO3zuZiudzjRgsDYarj2HzQp3Yp
         Rdig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a2si3077316qtg.254.2019.01.29.09.47.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 09:47:41 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 105AFA7885;
	Tue, 29 Jan 2019 17:47:40 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CC26B5D985;
	Tue, 29 Jan 2019 17:47:37 +0000 (UTC)
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
Subject: [RFC PATCH 1/5] pci/p2p: add a function to test peer to peer capability
Date: Tue, 29 Jan 2019 12:47:24 -0500
Message-Id: <20190129174728.6430-2-jglisse@redhat.com>
In-Reply-To: <20190129174728.6430-1-jglisse@redhat.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Tue, 29 Jan 2019 17:47:40 +0000 (UTC)
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
 drivers/pci/p2pdma.c       | 27 +++++++++++++++++++++++++++
 include/linux/pci-p2pdma.h |  6 ++++++
 2 files changed, 33 insertions(+)

diff --git a/drivers/pci/p2pdma.c b/drivers/pci/p2pdma.c
index c52298d76e64..620ac60babb5 100644
--- a/drivers/pci/p2pdma.c
+++ b/drivers/pci/p2pdma.c
@@ -797,3 +797,30 @@ ssize_t pci_p2pdma_enable_show(char *page, struct pci_dev *p2p_dev,
 	return sprintf(page, "%s\n", pci_name(p2p_dev));
 }
 EXPORT_SYMBOL_GPL(pci_p2pdma_enable_show);
+
+bool pci_test_p2p(struct device *devA, struct device *devB)
+{
+	struct pci_dev *pciA, *pciB;
+	bool ret;
+	int tmp;
+
+	/*
+	 * For now we only support PCIE peer to peer but other inter-connect
+	 * can be added.
+	 */
+	pciA = find_parent_pci_dev(devA);
+	pciB = find_parent_pci_dev(devB);
+	if (pciA == NULL || pciB == NULL) {
+		ret = false;
+		goto out;
+	}
+
+	tmp = upstream_bridge_distance(pciA, pciB, NULL);
+	ret = tmp < 0 ? false : true;
+
+out:
+	pci_dev_put(pciB);
+	pci_dev_put(pciA);
+	return false;
+}
+EXPORT_SYMBOL_GPL(pci_test_p2p);
diff --git a/include/linux/pci-p2pdma.h b/include/linux/pci-p2pdma.h
index bca9bc3e5be7..7671cc499a08 100644
--- a/include/linux/pci-p2pdma.h
+++ b/include/linux/pci-p2pdma.h
@@ -36,6 +36,7 @@ int pci_p2pdma_enable_store(const char *page, struct pci_dev **p2p_dev,
 			    bool *use_p2pdma);
 ssize_t pci_p2pdma_enable_show(char *page, struct pci_dev *p2p_dev,
 			       bool use_p2pdma);
+bool pci_test_p2p(struct device *devA, struct device *devB);
 #else /* CONFIG_PCI_P2PDMA */
 static inline int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar,
 		size_t size, u64 offset)
@@ -97,6 +98,11 @@ static inline ssize_t pci_p2pdma_enable_show(char *page,
 {
 	return sprintf(page, "none\n");
 }
+
+static inline bool pci_test_p2p(struct device *devA, struct device *devB)
+{
+	return false;
+}
 #endif /* CONFIG_PCI_P2PDMA */
 
 
-- 
2.17.2

