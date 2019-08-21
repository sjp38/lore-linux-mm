Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBF1FC3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 14:53:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CD7B22D6D
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 14:53:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CD7B22D6D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2061D6B02C7; Wed, 21 Aug 2019 10:53:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 190036B02C8; Wed, 21 Aug 2019 10:53:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 008ED6B02C9; Wed, 21 Aug 2019 10:53:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0163.hostedemail.com [216.40.44.163])
	by kanga.kvack.org (Postfix) with ESMTP id C9E486B02C7
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 10:53:25 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 70A1F55F9D
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:53:25 +0000 (UTC)
X-FDA: 75846728370.20.patch00_1dd2461aa750b
X-HE-Tag: patch00_1dd2461aa750b
X-Filterd-Recvd-Size: 3129
Received: from huawei.com (szxga05-in.huawei.com [45.249.212.191])
	by imf36.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:53:24 +0000 (UTC)
Received: from DGGEMS407-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id CBE1B946D84C55FF265F;
	Wed, 21 Aug 2019 22:53:21 +0800 (CST)
Received: from lhrphicprd00229.huawei.com (10.123.41.22) by
 DGGEMS407-HUB.china.huawei.com (10.3.19.207) with Microsoft SMTP Server id
 14.3.439.0; Wed, 21 Aug 2019 22:53:11 +0800
From: Jonathan Cameron <Jonathan.Cameron@huawei.com>
To: <linux-mm@kvack.org>, <linux-acpi@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>
CC: Keith Busch <keith.busch@intel.com>, <jglisse@redhat.com>, "Rafael J .
 Wysocki" <rjw@rjwysocki.net>, <linuxarm@huawei.com>, Andrew Morton
	<akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>
Subject: [PATCH 4/4] ACPI: Let ACPI know we support Generic Initiator Affinity Structures
Date: Wed, 21 Aug 2019 22:52:42 +0800
Message-ID: <20190821145242.2330-5-Jonathan.Cameron@huawei.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190821145242.2330-1-Jonathan.Cameron@huawei.com>
References: <20190821145242.2330-1-Jonathan.Cameron@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
X-Originating-IP: [10.123.41.22]
X-CFilter-Loop: Reflected
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Until we tell ACPI that we support generic initiators, it will have
to operate in fall back domain mode and all _PXM entries should
be on existing non GI domains.

This patch sets the relevant OSC bit to make that happen.

Note that this currently doesn't take into account whether we have the re=
levant
setup code for a given architecture.  Do we want to make this optional, o=
r
should the initial patch set just enable it for all ACPI supporting archi=
tectures?

Signed-off-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
---
 drivers/acpi/bus.c   | 1 +
 include/linux/acpi.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/acpi/bus.c b/drivers/acpi/bus.c
index 48bc96d45bab..9d40e465232f 100644
--- a/drivers/acpi/bus.c
+++ b/drivers/acpi/bus.c
@@ -302,6 +302,7 @@ static void acpi_bus_osc_support(void)
=20
 	capbuf[OSC_SUPPORT_DWORD] |=3D OSC_SB_HOTPLUG_OST_SUPPORT;
 	capbuf[OSC_SUPPORT_DWORD] |=3D OSC_SB_PCLPI_SUPPORT;
+	capbuf[OSC_SUPPORT_DWORD] |=3D OSC_SB_GENERIC_INITIATOR_SUPPORT;
=20
 #ifdef CONFIG_X86
 	if (boot_cpu_has(X86_FEATURE_HWP)) {
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 9426b9aaed86..cfa3a48f0c81 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -505,6 +505,7 @@ acpi_status acpi_run_osc(acpi_handle handle, struct a=
cpi_osc_context *context);
 #define OSC_SB_PCLPI_SUPPORT			0x00000080
 #define OSC_SB_OSLPI_SUPPORT			0x00000100
 #define OSC_SB_CPC_DIVERSE_HIGH_SUPPORT		0x00001000
+#define OSC_SB_GENERIC_INITIATOR_SUPPORT	0x00002000
=20
 extern bool osc_sb_apei_support_acked;
 extern bool osc_pc_lpi_support_confirmed;
--=20
2.20.1


