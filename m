Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8900AC28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:13:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D6FB262F6
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:13:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D6FB262F6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D57636B0269; Thu, 30 May 2019 19:13:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D07B46B0281; Thu, 30 May 2019 19:13:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF6DC6B0282; Thu, 30 May 2019 19:13:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8476B6B0269
	for <linux-mm@kvack.org>; Thu, 30 May 2019 19:13:17 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g5so5710178pfb.20
        for <linux-mm@kvack.org>; Thu, 30 May 2019 16:13:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=sQXI2+z5AuqKuGAGnDh+LIj6CV4drR2itzY1Fbq1HsE=;
        b=FZjZtR2Bei7yjvvtykP9uHvf8ujRgy71OSKbu03LvLboRU8jkdzemuCoW7qWvLOzCM
         dd6OucsCdB7om5Iz+41rvCaFytGNznaGHa5vmN6yeFdLLtpwaXil5mb2CPOwFSUfDM7D
         1TBbCC9IBR4jxTnqXLLZRO3KtFMItrn+2aoTFlXOzQ2i75kmSzqZeh6qsj3sbhEaQduD
         x8vrMFRLBs9l3r9MJ8Cn6WtNSs2HNlemyS9fv5k0YRU2iOjzA/JGiqcbPKbvUBxm2fA1
         k8tKkRUud5aKTBzmxT6jwYZTM235xHaZCghrTlRfzp3kZia7PmWkRnvqUTNDe9JDLIL/
         nTBA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVmbefD3jthVIo5pZfOwBBLYLrJLkCz9G1RLjsGilVPrf1spSV3
	8Nv5Ink3iuax0FLQbLhvEQg6zltnSq93TgaNjpgspxTmAhJvPfA0m8xPtf69DLUeJdyd/lo3mnF
	R3deL+UjBxFUtSLT/SUYOkCFAXz748c7wR/g28HmvQ2qvgj2ulJq7cJPn93UmVDrIxg==
X-Received: by 2002:a17:902:b490:: with SMTP id y16mr5852910plr.161.1559257997101;
        Thu, 30 May 2019 16:13:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx816+0z+1qk+g7vvDuJUA5LgWeXocAbWGgIIHJhlShyw+lib8YZJffxTPhQ/JWzj4Qpr65
X-Received: by 2002:a17:902:b490:: with SMTP id y16mr5852864plr.161.1559257996410;
        Thu, 30 May 2019 16:13:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559257996; cv=none;
        d=google.com; s=arc-20160816;
        b=VViRQRBIl5LvimDLjKYU8MbfXiEA4dzAxtd1nubaYzG1Xq24Y3ZAr9yPOdO/A6C6Hg
         1smEtKoOeNRk4WOdY+AM3Xj5JY4bC+iF4Icld3R8jZp81D6Ddzgu8d7gP2npNOMsc0e0
         lOin73qQoW36CSQGZkrTKo4nx4FXGl5D2Z3A6vgJw2eEfIJ2znWN9Frccxt31Q6kSEps
         aTeX5/Roc7aBfIw8IS63Y0zytNP6hMYRjNgg5B3jzrzXCTVWiGP5/Vy0XsRawZglGA6G
         tppfGunq0k6llgVGO0ZGuMKBVibvDpv1zr/ezftL7EZ+MaVjwX1pRGejC5suNSZYBdRj
         DbDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=sQXI2+z5AuqKuGAGnDh+LIj6CV4drR2itzY1Fbq1HsE=;
        b=TLE+QlQ6WH5mcPPcr9j8GYJqeGXIVj4/cG9SQTQoHOx3d09SSvihAGZAwBD8hr3mBT
         O3+Neg3ntT1Au1XAkdftcIP1D5TvfRxoa4U2Mby0/ZYolkrjWv9oVeeo7k9S2fZ0s9ok
         e3R/DmPovnr656jH1UtxbVAguns87I8Nl/HuEFLBh5zQHBOi+ggDyls6m1Vc6pIgHfEq
         Vzu6H5U9p3G3xOTXOsy1V82l8XbiRTLjMXHoeISF124IGRndd3DF/hE1CItHjHIm/Fw4
         fMoUjL5aHGW+yf5S7J/mTlyQwoT1wLJv1UEZHWW2d8ZQERsgeMeHH/QuEnS4Tkv+pCiC
         atEg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id k1si3552810pjw.56.2019.05.30.16.13.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 16:13:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 May 2019 16:13:15 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga004.jf.intel.com with ESMTP; 30 May 2019 16:13:15 -0700
Subject: [PATCH v2 1/8] acpi: Drop drivers/acpi/hmat/ directory
From: Dan Williams <dan.j.williams@intel.com>
To: linux-efi@vger.kernel.org
Cc: Len Brown <lenb@kernel.org>, Keith Busch <keith.busch@intel.com>,
 "Rafael J. Wysocki" <rjw@rjwysocki.net>, vishal.l.verma@intel.com,
 ard.biesheuvel@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 x86@kernel.org, linux-nvdimm@lists.01.org
Date: Thu, 30 May 2019 15:59:27 -0700
Message-ID: <155925716783.3775979.13301455166290564145.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

As a single source file object there is no need for the hmat enabling to
have its own directory.

Cc: Len Brown <lenb@kernel.org>
Cc: Keith Busch <keith.busch@intel.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/acpi/Kconfig       |   12 +++++++++++-
 drivers/acpi/Makefile      |    2 +-
 drivers/acpi/hmat.c        |    0 
 drivers/acpi/hmat/Kconfig  |   11 -----------
 drivers/acpi/hmat/Makefile |    2 --
 5 files changed, 12 insertions(+), 15 deletions(-)
 rename drivers/acpi/{hmat/hmat.c => hmat.c} (100%)
 delete mode 100644 drivers/acpi/hmat/Kconfig
 delete mode 100644 drivers/acpi/hmat/Makefile

diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
index 283ee94224c6..ec8691e4152f 100644
--- a/drivers/acpi/Kconfig
+++ b/drivers/acpi/Kconfig
@@ -475,7 +475,17 @@ config ACPI_REDUCED_HARDWARE_ONLY
 	  If you are unsure what to do, do not enable this option.
 
 source "drivers/acpi/nfit/Kconfig"
-source "drivers/acpi/hmat/Kconfig"
+
+config ACPI_HMAT
+	bool "ACPI Heterogeneous Memory Attribute Table Support"
+	depends on ACPI_NUMA
+	select HMEM_REPORTING
+	help
+	 If set, this option has the kernel parse and report the
+	 platform's ACPI HMAT (Heterogeneous Memory Attributes Table),
+	 register memory initiators with their targets, and export
+	 performance attributes through the node's sysfs device if
+	 provided.
 
 source "drivers/acpi/apei/Kconfig"
 source "drivers/acpi/dptf/Kconfig"
diff --git a/drivers/acpi/Makefile b/drivers/acpi/Makefile
index 5d361e4e3405..fc89686498dd 100644
--- a/drivers/acpi/Makefile
+++ b/drivers/acpi/Makefile
@@ -80,7 +80,7 @@ obj-$(CONFIG_ACPI_PROCESSOR)	+= processor.o
 obj-$(CONFIG_ACPI)		+= container.o
 obj-$(CONFIG_ACPI_THERMAL)	+= thermal.o
 obj-$(CONFIG_ACPI_NFIT)		+= nfit/
-obj-$(CONFIG_ACPI_HMAT)		+= hmat/
+obj-$(CONFIG_ACPI_HMAT)		+= hmat.o
 obj-$(CONFIG_ACPI)		+= acpi_memhotplug.o
 obj-$(CONFIG_ACPI_HOTPLUG_IOAPIC) += ioapic.o
 obj-$(CONFIG_ACPI_BATTERY)	+= battery.o
diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat.c
similarity index 100%
rename from drivers/acpi/hmat/hmat.c
rename to drivers/acpi/hmat.c
diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
deleted file mode 100644
index 95a29964dbea..000000000000
--- a/drivers/acpi/hmat/Kconfig
+++ /dev/null
@@ -1,11 +0,0 @@
-# SPDX-License-Identifier: GPL-2.0
-config ACPI_HMAT
-	bool "ACPI Heterogeneous Memory Attribute Table Support"
-	depends on ACPI_NUMA
-	select HMEM_REPORTING
-	help
-	 If set, this option has the kernel parse and report the
-	 platform's ACPI HMAT (Heterogeneous Memory Attributes Table),
-	 register memory initiators with their targets, and export
-	 performance attributes through the node's sysfs device if
-	 provided.
diff --git a/drivers/acpi/hmat/Makefile b/drivers/acpi/hmat/Makefile
deleted file mode 100644
index 1c20ef36a385..000000000000
--- a/drivers/acpi/hmat/Makefile
+++ /dev/null
@@ -1,2 +0,0 @@
-# SPDX-License-Identifier: GPL-2.0-only
-obj-$(CONFIG_ACPI_HMAT) := hmat.o

