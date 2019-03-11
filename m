Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DBA0C10F06
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 13:54:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16E4C2087C
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 13:54:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16E4C2087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=metux.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A37238E0003; Mon, 11 Mar 2019 09:54:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CA4E8E0002; Mon, 11 Mar 2019 09:54:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B83C8E0003; Mon, 11 Mar 2019 09:54:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3680D8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 09:54:11 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id b9so2731990wrw.14
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 06:54:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=Qiu0KMlFT5eaek3nig1Zzpm6rk81HOuTnBnEZlkUuCc=;
        b=CLDEN3gHcyiop+MZwVW3XzDzId1wELyFdSObiZtewgzyrwG+JWQm0P3Y3EUsULMXgR
         zR86Y27uqVjQzsLNZo1jg+TBPk3RYETsw4Z+mSr6JJ+l+0+s4wGK923RsFtd52ZD2d/S
         ds73Sq7iVR8mT2nEj1LQnSYpe2Zpg6U0WX00FtB4AgAnm+wEbKFKqQpod00zPBHGXvAD
         9WwFLNn3UOy6h3JMgRT2cDfCRs4St8fE6SF8/jor4cLou/KtjKBNlL968VeDCIqX+zPe
         ueKQJqqtd0wM2cQu6H/bo9vosm7uh8rRnRB0OPVQ7JAapAsXwx4hBeQmvYYrRWczZK1s
         N8wg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 212.227.17.10 is neither permitted nor denied by best guess record for domain of info@metux.net) smtp.mailfrom=info@metux.net
X-Gm-Message-State: APjAAAWh4PuIRZmH7t1fO3eBt8+5VUIqz6ci6MY6BpQaniOz8r73V7bl
	iwh41ThXBuYImqqP8InlLUxDORrHEo6tRyQsRvLH7bYw8Kztf1nwY3ayXgtlGE9NfyfXKj8hHqK
	eq7Zmd7ts0WdwSBnv/zThoCMg96bY4IO8CK3V7uWN0AieoRU7Yg44yuIfaGdjxMg=
X-Received: by 2002:a1c:a756:: with SMTP id q83mr17300202wme.8.1552312450392;
        Mon, 11 Mar 2019 06:54:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7nM+keS7FYv+9ug5p2NkVdQOIUUbCYWqYIT3xpHw9Es7JLACn72OkVDABRZhlppSwjyRr
X-Received: by 2002:a1c:a756:: with SMTP id q83mr17300123wme.8.1552312448430;
        Mon, 11 Mar 2019 06:54:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552312448; cv=none;
        d=google.com; s=arc-20160816;
        b=luy/AKrPoX51GkPawlIEjg38RgnCPLYzdba2rjjhRcAGzBv+v4aOohFqOOPDwRS6K9
         kWd2GgAxc0sAJYjkZfLQOZNEWYcqsupVOvvqvbUMqunNiptoKatcTejDbGSgfFZxgteT
         dpUP4OtvQs35yjeK7o0k5MdsUzXbswiduQjqM+rAKsTpdXtfsMWoGUCPGPSthhoUelVs
         HfPBEDQLoMK08Y+E3oTg7m/iAKHShLZNNFik0Bea5VWKbWrEOBxDQEQfodYWlCJztpEs
         CD1+vkmVygnDGmzF65CkQUeLMUPqBKq88PfD7I5YSX8D/uMQSKneHai7NGYoscM0hgpX
         1Xug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=Qiu0KMlFT5eaek3nig1Zzpm6rk81HOuTnBnEZlkUuCc=;
        b=up3ntBfK35QsMT3zXCaSFfQOywU+/nYi0JyzFiCHf9jXSnQ8YMSuKGFuPETJp7mowb
         IYmfqBdswAO1fjXklnqQ4yq35KJKj7VRR8Ar4PIoXi3QlR/6BtUUG8sT19UbudFsLWRB
         27h8jJPHYQh5Fv6fRRIhZnEatL/UQ/UQxbUDZcZ6X3dhTvBdZh8h1Lvblx3q3Il3nPJW
         vx2pyFtJ22ycnh2oHOQmMEdJ+jolos+Bg9I22M4XV18b5nbsl69m0GIDTqIWzmYMVDg1
         DsOssaL99gvH/wumjhJ+CrzHfBcZncNw5GJzgiBVwMe4UJ0/7dBmOl0KNLtkG5Us7QTl
         eN+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 212.227.17.10 is neither permitted nor denied by best guess record for domain of info@metux.net) smtp.mailfrom=info@metux.net
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.10])
        by mx.google.com with ESMTPS id t18si3519040wrm.268.2019.03.11.06.54.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 06:54:08 -0700 (PDT)
Received-SPF: neutral (google.com: 212.227.17.10 is neither permitted nor denied by best guess record for domain of info@metux.net) client-ip=212.227.17.10;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 212.227.17.10 is neither permitted nor denied by best guess record for domain of info@metux.net) smtp.mailfrom=info@metux.net
Received: from orion.localdomain ([95.115.159.19]) by mrelayeu.kundenserver.de
 (mreue106 [212.227.15.183]) with ESMTPSA (Nemesis) id
 1Md6AP-1gU0pI0x6Z-00aCVB; Mon, 11 Mar 2019 14:54:07 +0100
From: "Enrico Weigelt, metux IT consult" <info@metux.net>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Subject: [PATCH] mm: Kconfig: pedantic formatting
Date: Mon, 11 Mar 2019 14:54:04 +0100
Message-Id: <1552312444-24572-1-git-send-email-info@metux.net>
X-Mailer: git-send-email 1.9.1
X-Provags-ID: V03:K1:bafHJ2JVH9BUC2oLYNjgUVX5blGqKNn3Itah62vN4Gr3/ptUe0k
 qebJAoRDSi72UxJOCmkZ0bdFNiOzHftyMzvDSf2rtEx9IOqPfaxxU86mtKBPUrBuvIwCbTK
 g1P5kGyr7qFM8O0ba4ODc8aka8KlSRB00jY2ugGNHvrTBuwoOUs0uc87vPUOYzw+X2VrHNv
 ztsky/IjigjYYyC5RtM2Q==
X-UI-Out-Filterresults: notjunk:1;V03:K0:dXDytxCcq8A=:wx09j4PCzoyWeo3iJM25L/
 bohkfyPw61pjdGDM5coJ3n313KHY4mA9LUm1KbNoYx8sAiPI78yyztiVPhFSj6+P+T0yaCZdC
 7UEQ41BcKl4l31h5QIFWYjeSeuScLWkyzyx9wD6GkVgSzvpd6z8wEPs2XYHr/iw1zTxE8154v
 KAJq5DxznJSCLjHCGMagTwvXRHPghzGcAier7BZpn6xizdB4Z3FX458jdfkfwHVpXlfKIWecj
 /Mw7pEkAuu7jdTzFQ2rJbu/9nYdYvvobT3PZUn3EfIoI6GsXSag1hTjGb9y6AABuJFWo5OQem
 FOjtnPHX0oYQFiz8cjNxKaY0urh/d4EZFmmricao4DuVFYgifDUGCMAia7oMMZvMtHujIF4rM
 QqBFCyr8NkBaDMJGFmy5s5nERqaMzmwzq2tZ/TX+0zUORM+VBHL9pCUm46sdaVK7PeBT07OVS
 r7KkDuf4flatOKgzhcdm0YUH9BDFg2OPgNG+dhETANvZJUT6svATeF4oIvUh6YC+5FgHNfvDX
 rT6VLiSehx/lElhDsW5I2vnpwWY54PGqCIv87hJwlcDG+nTtkBEcPl3BrmBnxSbtx2H9qnHlZ
 8M9qlFHp2CVZH+y5BualavBCi+bLb0QOmUBpcOIB1woGOcnZkQF1DEoYYooVUIbfqetlIptTq
 6pldjBlXl1H0bMMpN5o4iSRLdK1uRsICMYLKyYPhEtZvotbmPV7xh30fG8psJ0d3s5XT16xSj
 qWar2KUMDSZhEoXQYU/AoJuzIGdE9l1hUHig+g==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Formatting of Kconfig files doesn't look so pretty, so let the
Great White Handkerchief come around and clean it up.

Signed-off-by: Enrico Weigelt, metux IT consult <info@metux.net>
---
 mm/Kconfig | 40 ++++++++++++++++++++--------------------
 1 file changed, 20 insertions(+), 20 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 25c71eb..9181eb2 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -123,9 +123,9 @@ config SPARSEMEM_VMEMMAP
 	depends on SPARSEMEM && SPARSEMEM_VMEMMAP_ENABLE
 	default y
 	help
-	 SPARSEMEM_VMEMMAP uses a virtually mapped memmap to optimise
-	 pfn_to_page and page_to_pfn operations.  This is the most
-	 efficient option when sufficient kernel resources are available.
+	  SPARSEMEM_VMEMMAP uses a virtually mapped memmap to optimise
+	  pfn_to_page and page_to_pfn operations.  This is the most
+	  efficient option when sufficient kernel resources are available.
 
 config HAVE_MEMBLOCK_NODE_MAP
 	bool
@@ -160,10 +160,10 @@ config MEMORY_HOTPLUG_SPARSE
 	depends on SPARSEMEM && MEMORY_HOTPLUG
 
 config MEMORY_HOTPLUG_DEFAULT_ONLINE
-        bool "Online the newly added memory blocks by default"
-        default n
-        depends on MEMORY_HOTPLUG
-        help
+	bool "Online the newly added memory blocks by default"
+	default n
+	depends on MEMORY_HOTPLUG
+	help
 	  This option sets the default policy setting for memory hotplug
 	  onlining policy (/sys/devices/system/memory/auto_online_blocks) which
 	  determines what happens to newly added memory regions. Policy setting
@@ -228,14 +228,14 @@ config COMPACTION
 	select MIGRATION
 	depends on MMU
 	help
-          Compaction is the only memory management component to form
-          high order (larger physically contiguous) memory blocks
-          reliably. The page allocator relies on compaction heavily and
-          the lack of the feature can lead to unexpected OOM killer
-          invocations for high order memory requests. You shouldn't
-          disable this option unless there really is a strong reason for
-          it and then we would be really interested to hear about that at
-          linux-mm@kvack.org.
+	  Compaction is the only memory management component to form
+	  high order (larger physically contiguous) memory blocks
+	  reliably. The page allocator relies on compaction heavily and
+	  the lack of the feature can lead to unexpected OOM killer
+	  invocations for high order memory requests. You shouldn't
+	  disable this option unless there really is a strong reason for
+	  it and then we would be really interested to hear about that at
+	  linux-mm@kvack.org.
 
 #
 # support for page migration
@@ -304,10 +304,10 @@ config KSM
 	  root has set /sys/kernel/mm/ksm/run to 1 (if CONFIG_SYSFS is set).
 
 config DEFAULT_MMAP_MIN_ADDR
-        int "Low address space to protect from user allocation"
+	int "Low address space to protect from user allocation"
 	depends on MMU
-        default 4096
-        help
+	default 4096
+	help
 	  This is the portion of low virtual memory which should be protected
 	  from userspace allocation.  Keeping a user from writing to low pages
 	  can help reduce the impact of kernel NULL pointer bugs.
@@ -400,7 +400,7 @@ choice
 	  benefit but it will work automatically for all applications.
 
 	config TRANSPARENT_HUGEPAGE_MADVISE
-		bool "madvise"
+	bool "madvise"
 	help
 	  Enabling Transparent Hugepage madvise, will only provide a
 	  performance improvement benefit to the applications using
@@ -410,7 +410,7 @@ choice
 endchoice
 
 config ARCH_WANTS_THP_SWAP
-       def_bool n
+	def_bool n
 
 config THP_SWAP
 	def_bool y
-- 
1.9.1

