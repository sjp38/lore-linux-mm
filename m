Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BD90C74A54
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:26:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBDE121019
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:26:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="UpGsaKxV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBDE121019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDBE08E00CC; Thu, 11 Jul 2019 10:26:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E648E8E00C4; Thu, 11 Jul 2019 10:26:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D071C8E00CC; Thu, 11 Jul 2019 10:26:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id A3C808E00C4
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:26:31 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id z19so6970763ioi.15
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:26:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=x/IjzSr0NJXbBWkc/GbWFGd8aRvvo+k/bAxRCg2smaA=;
        b=IYiDx+wxwvVYusXwOuWotZ3CeeOX2YXRapwvpukTN+dmuLtRMvUzlLIMRErFdAqo74
         MrKsefNCdKbp+2/vJgSds3lLVlAF8cnJJv84y61QRmffMXURBFWky3mrizLuHj0r1Uvs
         5cemMkyPnzadCuVoFNbh0QGmXGnnFUHb4rtonj/lNkXNIZkNXWrsUrq16We/velq5RMB
         15f83JffpuSnHz7k+ol5XR6U4uGfNpACZz9OEuzI7X/kaSzfUPO5j7O1GjFx2lwu8GFc
         HMFrQ7yE95ss/VtkX1ujjS2UwIna/cFhH8A0csFro6XMGYb31YU3RsiNT0WCfug4mPW5
         ZVow==
X-Gm-Message-State: APjAAAWtc+6XCJf8GKppbp0Zon+yyNM0KzdgojVMtFgJxqzh7NDK+TBq
	eg00ef8o0obj5ZZ1v0N6E8DjEbZiTkjoKWgRU9n/fji8MO6aJaqFce216x0PI3zZzpN8yQhdDgD
	2wQkFmBVoIN2w3qhcLj3kuCGWysGdCHSgMCiOgQm/oye+/WqKNemnS/ALhMxeItZRlQ==
X-Received: by 2002:a6b:b3c1:: with SMTP id c184mr4097540iof.222.1562855191487;
        Thu, 11 Jul 2019 07:26:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhOc2nQdfjOJX1g5BJ6PQIEImKrNU2FiTcnmtB6KD3UiTJJo8kzucMCLacFsPM+9/cnEGi
X-Received: by 2002:a6b:b3c1:: with SMTP id c184mr4097502iof.222.1562855190959;
        Thu, 11 Jul 2019 07:26:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562855190; cv=none;
        d=google.com; s=arc-20160816;
        b=LEf/yqclCkEg39r2t13n0YD80oOc618bIOUokvAaLGbeKGg+pvmNy3aLmiJQMxkAlL
         IC+rY4Dny0m9jxpOcl56yhKeldfvxDW6jsA3dcnoxUCoAvXoKesNfJDGpLk4EGcbeP1l
         srhg99a1M+irnoxqVIw2xsORdDDR3UoZMC+Irnb75+Ah8zZE2rMtN7rwJwkCORhT00sX
         1Q01sKWPiZEFZ1a5juKEq5p801aiB/tcqUJUq/ucbMuVBL6dpvam8ceJ1tuaol1yLvIf
         nOF1lO+JqMH9RmQZ6QyhGYwrKODn8ddAYUHmnIoWoQJ2GHOYq9DF8DuJEvNdvhyyem/8
         fE7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=x/IjzSr0NJXbBWkc/GbWFGd8aRvvo+k/bAxRCg2smaA=;
        b=z6IJI2A/fS63bMt7SnivdMQZ+ZXMo4T/xfUq1Ac/YdtBgYQ1mU0GgeO2qCu9CcKycF
         2vRwDr7ECCkTFWukouy2dTCKQ2FiFNq4jU/5ioa6Y3HubT+7/Vs8cuA4yNFuMHwLves1
         yV6tnNdrvYYZSy+SuQ/fB1U8oRqMLWMlVvoWfTRXapHf8cj0MPnSnxLSbBtY19hXZRGz
         FjR/LAPTqKBa5SkGg7+knOTWTiW+Fq23H1432UP0RhCsw65BcvTGZUtv9ubKPY7f7b/e
         fabIvEb42HHbrvIERPNjOQCQz5yaF5y1raexZcIx1bgwzthsNF7UgbAgOWGs2icW4zXb
         0jMg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=UpGsaKxV;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id r62si8988739iod.101.2019.07.11.07.26.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:26:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=UpGsaKxV;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BEOE8u013326;
	Thu, 11 Jul 2019 14:26:21 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=x/IjzSr0NJXbBWkc/GbWFGd8aRvvo+k/bAxRCg2smaA=;
 b=UpGsaKxVuo2eIaT3MIyMj6uwvZYdjod6xr9sIWH6GLVIiGJo5xv5khjwyLVyDDuy1GvG
 yfeeGSjBWTuaMV/ezPA0NULlZQYuPGQftx9frpdHWZCWGt6EzWWMYPjn5VPHT47SjUpI
 A1Zvxp/4R+waiK8CFltSblp1Oe52CtoJA0LD+OBZSfdqHFgWhRLUnvbf0i9N2AFU9yvt
 42HuhPrb/rYgNn3SpXtQLfgcHyAjGcS15pNxoiZQoNGdL0uAmA7B00OD3j6dk0aaUwQn
 KjZFUxYUuNzdESj/m6+MVakQNxN1UqdtuIgCsY0XLrDA5xHgNra+3zY3ilOMR4T3aYcQ vg== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2tjm9r0bpk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 14:26:21 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x6BEPcu2021444;
	Thu, 11 Jul 2019 14:26:12 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com,
        alexandre.chartre@oracle.com
Subject: [RFC v2 09/26] mm/asi: Helper functions to map module into ASI
Date: Thu, 11 Jul 2019 16:25:21 +0200
Message-Id: <1562855138-19507-10-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=896 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907110162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add helper functions to easily map a module into an ASI.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/include/asm/asi.h |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/asi.h b/arch/x86/include/asm/asi.h
index 19656aa..b5dbc49 100644
--- a/arch/x86/include/asm/asi.h
+++ b/arch/x86/include/asm/asi.h
@@ -6,6 +6,7 @@
 
 #ifndef __ASSEMBLY__
 
+#include <linux/module.h>
 #include <linux/spinlock.h>
 #include <asm/pgtable.h>
 #include <linux/xarray.h>
@@ -81,6 +82,26 @@ extern int asi_map_range(struct asi *asi, void *ptr, size_t size,
 extern int asi_map(struct asi *asi, void *ptr, unsigned long size);
 
 /*
+ * Copy the memory mapping for the current module. This is defined as a
+ * macro to ensure it is expanded in the module making the call so that
+ * THIS_MODULE has the correct value.
+ */
+#define ASI_MAP_THIS_MODULE(asi)			\
+	(asi_map(asi, THIS_MODULE->core_layout.base,	\
+		 THIS_MODULE->core_layout.size))
+
+static inline int asi_map_module(struct asi *asi, char *module_name)
+{
+	struct module *module;
+
+	module = find_module(module_name);
+	if (!module)
+		return -ESRCH;
+
+	return asi_map(asi, module->core_layout.base, module->core_layout.size);
+}
+
+/*
  * Function to exit the current isolation. This is used to abort isolation
  * when a task using isolation is scheduled out.
  */
-- 
1.7.1

