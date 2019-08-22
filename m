Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24089C3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 10:27:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E532323402
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 10:27:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E532323402
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9206F6B0301; Thu, 22 Aug 2019 06:27:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D10F6B0302; Thu, 22 Aug 2019 06:27:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C5A76B0303; Thu, 22 Aug 2019 06:27:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0044.hostedemail.com [216.40.44.44])
	by kanga.kvack.org (Postfix) with ESMTP id 522D16B0301
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 06:27:04 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 1738F181AC9B4
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 10:27:04 +0000 (UTC)
X-FDA: 75849685968.11.pipe52_5abdf51aeca4a
X-HE-Tag: pipe52_5abdf51aeca4a
X-Filterd-Recvd-Size: 4738
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 10:27:03 +0000 (UTC)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7MAMc7h008347
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 06:27:02 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2uhqy33byu-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 06:27:02 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Thu, 22 Aug 2019 11:26:59 +0100
Received: from b06avi18626390.portsmouth.uk.ibm.com (9.149.26.192)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 22 Aug 2019 11:26:56 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06avi18626390.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7MAQY5d42270978
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 22 Aug 2019 10:26:34 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id ABC14AE059;
	Thu, 22 Aug 2019 10:26:54 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id EE236AE058;
	Thu, 22 Aug 2019 10:26:51 +0000 (GMT)
Received: from bharata.ibmuc.com (unknown [9.199.57.57])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Thu, 22 Aug 2019 10:26:51 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, hch@lst.de,
        Anshuman Khandual <khandual@linux.vnet.ibm.com>,
        Bharata B Rao <bharata@linux.ibm.com>
Subject: [PATCH v7 7/7] KVM: PPC: Ultravisor: Add PPC_UV config option
Date: Thu, 22 Aug 2019 15:56:20 +0530
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190822102620.21897-1-bharata@linux.ibm.com>
References: <20190822102620.21897-1-bharata@linux.ibm.com>
MIME-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19082210-4275-0000-0000-0000035BD40F
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19082210-4276-0000-0000-0000386DF9CA
Message-Id: <20190822102620.21897-8-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-22_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908220112
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Anshuman Khandual <khandual@linux.vnet.ibm.com>

CONFIG_PPC_UV adds support for ultravisor.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Signed-off-by: Bharata B Rao <bharata@linux.ibm.com>
Signed-off-by: Ram Pai <linuxram@us.ibm.com>
[ Update config help and commit message ]
Signed-off-by: Claudio Carvalho <cclaudio@linux.ibm.com>
---
 arch/powerpc/Kconfig | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index d8dcd8820369..044838794112 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -448,6 +448,23 @@ config PPC_TRANSACTIONAL_MEM
 	help
 	  Support user-mode Transactional Memory on POWERPC.
=20
+config PPC_UV
+	bool "Ultravisor support"
+	depends on KVM_BOOK3S_HV_POSSIBLE
+	select ZONE_DEVICE
+	select DEV_PAGEMAP_OPS
+	select DEVICE_PRIVATE
+	select MEMORY_HOTPLUG
+	select MEMORY_HOTREMOVE
+	default n
+	help
+	  This option paravirtualizes the kernel to run in POWER platforms that
+	  supports the Protected Execution Facility (PEF). On such platforms,
+	  the ultravisor firmware runs at a privilege level above the
+	  hypervisor.
+
+	  If unsure, say "N".
+
 config LD_HEAD_STUB_CATCH
 	bool "Reserve 256 bytes to cope with linker stubs in HEAD text" if EXPE=
RT
 	depends on PPC64
--=20
2.21.0


