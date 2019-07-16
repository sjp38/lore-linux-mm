Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,INCLUDES_PULL_REQUEST,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC463C7618F
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 15:32:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D04E2054F
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 15:32:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D04E2054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 158718E000C; Tue, 16 Jul 2019 11:32:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 109F58E0006; Tue, 16 Jul 2019 11:32:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 01FBD8E000C; Tue, 16 Jul 2019 11:32:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id D6F748E0006
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 11:32:05 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id m198so17171003qke.22
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 08:32:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition;
        bh=ZoA0pfJr1FAcKH3cLYv5OlOngtqNc0JJBS5xvxqs13M=;
        b=DjQwLWVwxeO6ALsOhjRwShpXpLWdYLlF7d0j78RMoJKBl6t3uuUHV9/y8y7X9OXYd7
         BlEWzoEVFQd7oPaM5GA5AYjFsE6lYmlzCTDDqf8OwMNi/6gjhlT4GGeefcX0f5f4mkkh
         tL+MFnI1TK6d2eDnQUvjg08VSOnzqmALsHthobOwmroevy8x9AW7VQ5zQN/xaTR59A9C
         RdJhWl4wgcbBaIUvLYXNNskF4AQjAnv5XcXdcmIJyzlfcV1x53vongCOcuEIBc5ooRgJ
         Gcyild1bwKWYuChym13oaMVe8A+1yTJ8CRjzK7t/Txxx/eTofnWPLglsfzE4rjCuQW/L
         mcUA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWhXc1GEsJJknMla9w/112G7JVRa+4FVs2IcKMbkkJG+vtuN2+t
	8v6o885RQsNrJeVU4GsBAhBiZk6ktVRpmGoiQxUI935y4JN71VuRj6ji96DZTe8CJnn3cGucLm1
	v7MuWHKI1aSO6LGRvccILm5LaJVoBSVJRTrldXWzL21taLqFrykgiQZUrHEj21k7qfg==
X-Received: by 2002:ac8:152:: with SMTP id f18mr22895466qtg.84.1563291125621;
        Tue, 16 Jul 2019 08:32:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzy4Ze5/nOu8p0pydgUaXBsnWhsvcMNsaOY8QXRIacksghcoHNAwxn3KfwuefjRxSrloxSr
X-Received: by 2002:ac8:152:: with SMTP id f18mr22895361qtg.84.1563291124137;
        Tue, 16 Jul 2019 08:32:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563291124; cv=none;
        d=google.com; s=arc-20160816;
        b=aWyIIYcTeJgeZpOuosAPWgHcmDCH+ZpYX4KJRBsgC2qflr+OfeIs4wQ54ULLCpN3fR
         OrwqNsSmVjMdOMqwHWeXrjk7N157/ZW2UX/DnAu0lTAypWshhiZ8x2ppU4TfyEjN5kOH
         izBHUWIe5ncC0bN+pCDHXxzVoOFK+qh6ITfxnTwz0p4/UIdLTFNCU1ZSK5GMhR+r2v9Z
         L4EVpw0rTrMvUznqbN4T6cD/uAjwIK19kpokaYUQnVxnQ9KpsFWeRz/kpwXw4D82dgpo
         eDfzB6YN6Y4ff7lMo8HYcH+1oCqgyV0rMabPudOHR5uZAOEA3hE8M/rXhOVgBhf+5MT9
         ZvVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:message-id:subject:cc:to:from:date;
        bh=ZoA0pfJr1FAcKH3cLYv5OlOngtqNc0JJBS5xvxqs13M=;
        b=o1vApi6swpGH4IHZQiDgJ4zvoEVM7FZAyWWD/G2F6crnPZm+ErCNKwh8jSjHiLvhzo
         vfw70ZcQWcwHZ1ShDxHLOJK0JWbDjvTFEbVUOCehPPjhOnnFgai8XjfbkW0jDrWweBDi
         Mb3vJXC+PXlXyaJOd8k2uFzesz9dcqueL/FTNzqU37EsqK2Cc5dv+N+OxVVHZYFtPfUO
         3BKBYfGT3qLxe3WHdcSTyYnFJOggkAAhCB5nX1+qd0G0ErfqsNvLHlUKbU4zDtaondZz
         bFzfwwIx7LeuGemp2AF70UivUhKs7vt6qyDnj12gD0FdVH3DNfbCzwMJ/ISmvC0StsQu
         pnVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u40si14873559qvg.25.2019.07.16.08.32.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 08:32:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 020B52F8BCC;
	Tue, 16 Jul 2019 15:32:03 +0000 (UTC)
Received: from redhat.com (ovpn-122-108.rdu2.redhat.com [10.10.122.108])
	by smtp.corp.redhat.com (Postfix) with SMTP id 96BE15B681;
	Tue, 16 Jul 2019 15:31:52 +0000 (UTC)
Date: Tue, 16 Jul 2019 11:31:51 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	aarcange@redhat.com, bharat.bhushan@nxp.com, bhelgaas@google.com,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-parisc@vger.kernel.org, davem@davemloft.net,
	eric.auger@redhat.com, gustavo@embeddedor.com, hch@infradead.org,
	ihor.matushchak@foobox.net, James.Bottomley@hansenpartnership.com,
	jasowang@redhat.com, jean-philippe.brucker@arm.com,
	jglisse@redhat.com, mst@redhat.com, natechancellor@gmail.com
Subject: [PULL] virtio, vhost: fixes, features, performance
Message-ID: <20190716113151-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
X-Mutt-Fcc: =sent
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 16 Jul 2019 15:32:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The following changes since commit c1ea02f15ab5efb3e93fc3144d895410bf79fcf2:

  vhost: scsi: add weight support (2019-05-27 11:08:23 -0400)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to 5e663f0410fa2f355042209154029842ba1abd43:

  virtio-mmio: add error check for platform_get_irq (2019-07-11 16:22:29 -0400)

----------------------------------------------------------------
virtio, vhost: fixes, features, performance

new iommu device
vhost guest memory access using vmap (just meta-data for now)
minor fixes

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Note: due to code driver changes the driver-core tree, the following
patch is needed when merging tree with commit 92ce7e83b4e5
("driver_find_device: Unify the match function with
class_find_device()") in the driver-core tree:

From: Nathan Chancellor <natechancellor@gmail.com>
Subject: [PATCH] iommu/virtio: Constify data parameter in viommu_match_node

After commit 92ce7e83b4e5 ("driver_find_device: Unify the match
function with class_find_device()") in the driver-core tree.

Signed-off-by: Nathan Chancellor <natechancellor@gmail.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---
 drivers/iommu/virtio-iommu.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/iommu/virtio-iommu.c b/drivers/iommu/virtio-iommu.c
index 4620dd221ffd..433f4d2ee956 100644
--- a/drivers/iommu/virtio-iommu.c
+++ b/drivers/iommu/virtio-iommu.c
@@ -839,7 +839,7 @@ static void viommu_put_resv_regions(struct device *dev, struct list_head *head)
 static struct iommu_ops viommu_ops;
 static struct virtio_driver virtio_iommu_drv;

-static int viommu_match_node(struct device *dev, void *data)
+static int viommu_match_node(struct device *dev, const void *data)
 {
 	return dev->parent->fwnode == data;
 }

----------------------------------------------------------------
Gustavo A. R. Silva (1):
      scsi: virtio_scsi: Use struct_size() helper

Ihor Matushchak (1):
      virtio-mmio: add error check for platform_get_irq

Jason Wang (6):
      vhost: generalize adding used elem
      vhost: fine grain userspace memory accessors
      vhost: rename vq_iotlb_prefetch() to vq_meta_prefetch()
      vhost: introduce helpers to get the size of metadata area
      vhost: factor out setting vring addr and num
      vhost: access vq metadata through kernel virtual address

Jean-Philippe Brucker (7):
      dt-bindings: virtio-mmio: Add IOMMU description
      dt-bindings: virtio: Add virtio-pci-iommu node
      of: Allow the iommu-map property to omit untranslated devices
      PCI: OF: Initialize dev->fwnode appropriately
      iommu: Add virtio-iommu driver
      iommu/virtio: Add probe request
      iommu/virtio: Add event queue

Michael S. Tsirkin (1):
      vhost: fix clang build warning

 Documentation/devicetree/bindings/virtio/iommu.txt |   66 ++
 Documentation/devicetree/bindings/virtio/mmio.txt  |   30 +
 MAINTAINERS                                        |    7 +
 drivers/iommu/Kconfig                              |   11 +
 drivers/iommu/Makefile                             |    1 +
 drivers/iommu/virtio-iommu.c                       | 1158 ++++++++++++++++++++
 drivers/of/base.c                                  |   10 +-
 drivers/pci/of.c                                   |    8 +
 drivers/scsi/virtio_scsi.c                         |    2 +-
 drivers/vhost/net.c                                |    4 +-
 drivers/vhost/vhost.c                              |  850 +++++++++++---
 drivers/vhost/vhost.h                              |   43 +-
 drivers/virtio/virtio_mmio.c                       |    7 +-
 include/uapi/linux/virtio_ids.h                    |    1 +
 include/uapi/linux/virtio_iommu.h                  |  161 +++
 15 files changed, 2228 insertions(+), 131 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/virtio/iommu.txt
 create mode 100644 drivers/iommu/virtio-iommu.c
 create mode 100644 include/uapi/linux/virtio_iommu.h

