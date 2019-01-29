Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A277C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 17:47:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49BFE214DA
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 17:47:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49BFE214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8CCC8E0005; Tue, 29 Jan 2019 12:47:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E3D998E0001; Tue, 29 Jan 2019 12:47:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDFF08E0005; Tue, 29 Jan 2019 12:47:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9D6108E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 12:47:47 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id y27so22485608qkj.21
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 09:47:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AnAd/qqNQuLsEqhueFCN4TriXeuQ14Ot5LqO5HoQXJc=;
        b=pC4IIsQW0pm/jqoANUmoay98F2lJg9wgIsWQeIFC6hcCH/NMv2M1rAZ3lw20ZPggm+
         L8E1IBzFXhGvL2zPqxGWo2riptxrttG39uM4sEHFWIlmQzblE1G8aQlKK035G0D8LoHD
         LaP2TgA403tK4+mu3DdXUj3rz/8qmP2Vkf54R+GHo8ivmO/5z95Ccv5NuFl6iY6ku2qp
         vyW9o6kXssPtyhBFWDX4bTrEd6ntPg/ZwV7E78V6DXnwOSSgNXrDiKh561oavDjrOhB1
         tj09oPMV4cdPdJmwYRE2XNqkvJAaZG9KiEscu6jW4B7nsPzyes0WWYa9PLYoW2c1IUcs
         U0Ag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukeSzQuHo/FgDVc1kZDVXZGif7yS1XxuJNvNjS7ZwUHO2u7NY5o0
	zyUqp/b1B/ExLAP4S3BoTVl/iXwSnwmKC7srX7OdAnKq/XY6DYjSDzBINwd7LVh5QqAOgkyKQjy
	vXjHSCRWroCZWMMjoELG5H9ZAb53As43kTlnck9EkXQ4IYqDNdFu9YoXhcGWa68L6sg==
X-Received: by 2002:a37:8c04:: with SMTP id o4mr23493402qkd.165.1548784067397;
        Tue, 29 Jan 2019 09:47:47 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7cFVc2Akl6Zsm++Df9z3XB5ECvoJCqkqa5OMNgs97b9UGJb6Itg+Sw4sd+yxcSWTSNYMPZ
X-Received: by 2002:a37:8c04:: with SMTP id o4mr23493380qkd.165.1548784066827;
        Tue, 29 Jan 2019 09:47:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548784066; cv=none;
        d=google.com; s=arc-20160816;
        b=smkUJCxWja5wHvZODaEa26G9uxVIKceqH7DenK0P215R3uKFbUUSughBJ/VjhEuHGr
         HwjBFOj2q+LUqbwd/OApita0ut31lx2L4d37B832YLIurR5hkifPuVH0ntbe6Saj1fYw
         n8H5XeRz1Om7YCReXOs1fI9vRpwTB6G5OXN/rd8AAdtMY47m/8ckbv3q8bnyOaTSkHjw
         Gn7qfEGgyCSpWV72PkZI3fhGLtw87TqqL0OGQD5qjvwoLr7y/PrqOodJ8XScL83yYM5o
         +jVJic9Z11mIKWlNYVZzx4wd63RKqD1kbqDbTrvtrdHF9XoHp6LCFP4r46h7nCkR5nb8
         U26A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=AnAd/qqNQuLsEqhueFCN4TriXeuQ14Ot5LqO5HoQXJc=;
        b=C+Y6I6mA7PcSfYKjo3a4lhGATt0km5HXqH1sZJi3L09FEo4a4X8GBCbr4fD6cXH5n6
         Q3T30JsyQhl03eEdyZcAjmoh5d/WTScGk7ly6mVC3W2Mum4GNAmyGbfsVgTO17ST5NXY
         5ChImvelFnSQqG8Wajm16Mqu9WQo4Imv4dRKnOyJ+26nIgFSEwQ9b5AgwurXxnGXTFah
         +nZopvs09nc5xZaYTTXrVxzunqQJuuvwHhc/6ECojDBcaAwqi2LCORzjBlDJN3xVPDE8
         RAKsFvU4ZD3fduOZW2V+hfFuhWC5qHrTx41+V90DP1QEMH/7tbqPnoijtAoBBoV18Qft
         LC4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v5si5803993qka.83.2019.01.29.09.47.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 09:47:46 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 92F9FC073D6F;
	Tue, 29 Jan 2019 17:47:45 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 93F8318A75;
	Tue, 29 Jan 2019 17:47:42 +0000 (UTC)
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
Subject: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device vma
Date: Tue, 29 Jan 2019 12:47:26 -0500
Message-Id: <20190129174728.6430-4-jglisse@redhat.com>
In-Reply-To: <20190129174728.6430-1-jglisse@redhat.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Tue, 29 Jan 2019 17:47:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Allow mmap of device file to export device memory to peer to peer
devices. This will allow for instance a network device to access a
GPU memory or to access a storage device queue directly.

The common case will be a vma created by userspace device driver
that is then share to another userspace device driver which call
in its kernel device driver to map that vma.

The vma does not need to have any valid CPU mapping so that only
peer to peer device might access its content. Or it could have
valid CPU mapping too in that case it should point to same memory
for consistency.

Note that peer to peer mapping is highly platform and device
dependent and it might not work in all the cases. However we do
expect supports for this to grow on more hardware platform.

This patch only adds new call backs to vm_operations_struct bulk
of code light within common bus driver (like pci) and device
driver (both the exporting and importing device).

Current design mandate that the importer must obey mmu_notifier
and invalidate any peer to peer mapping anytime a notification
of invalidation happens for a range that have been peer to peer
mapped. This allows exporter device to easily invalidate mapping
for any importer device.

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
 include/linux/mm.h | 38 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 38 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80bb6408fe73..1bd60a90e575 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -429,6 +429,44 @@ struct vm_operations_struct {
 			pgoff_t start_pgoff, pgoff_t end_pgoff);
 	unsigned long (*pagesize)(struct vm_area_struct * area);
 
+	/*
+	 * Optional for device driver that want to allow peer to peer (p2p)
+	 * mapping of their vma (which can be back by some device memory) to
+	 * another device.
+	 *
+	 * Note that the exporting device driver might not have map anything
+	 * inside the vma for the CPU but might still want to allow a peer
+	 * device to access the range of memory corresponding to a range in
+	 * that vma.
+	 *
+	 * FOR PREDICTABILITY IF DRIVER SUCCESSFULY MAP A RANGE ONCE FOR A
+	 * DEVICE THEN FURTHER MAPPING OF THE SAME IF THE VMA IS STILL VALID
+	 * SHOULD ALSO BE SUCCESSFUL. Following this rule allow the importing
+	 * device to map once during setup and report any failure at that time
+	 * to the userspace. Further mapping of the same range might happen
+	 * after mmu notifier invalidation over the range. The exporting device
+	 * can use this to move things around (defrag BAR space for instance)
+	 * or do other similar task.
+	 *
+	 * IMPORTER MUST OBEY mmu_notifier NOTIFICATION AND CALL p2p_unmap()
+	 * WHEN A NOTIFIER IS CALL FOR THE RANGE ! THIS CAN HAPPEN AT ANY
+	 * POINT IN TIME WITH NO LOCK HELD.
+	 *
+	 * In below function, the device argument is the importing device,
+	 * the exporting device is the device to which the vma belongs.
+	 */
+	long (*p2p_map)(struct vm_area_struct *vma,
+			struct device *device,
+			unsigned long start,
+			unsigned long end,
+			dma_addr_t *pa,
+			bool write);
+	long (*p2p_unmap)(struct vm_area_struct *vma,
+			  struct device *device,
+			  unsigned long start,
+			  unsigned long end,
+			  dma_addr_t *pa);
+
 	/* notification that a previously read-only page is about to become
 	 * writable, if an error is returned it will cause a SIGBUS */
 	vm_fault_t (*page_mkwrite)(struct vm_fault *vmf);
-- 
2.17.2

