Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E267AC10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:35:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0A872084B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 10:35:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0A872084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3ECF56B0283; Thu, 25 Apr 2019 06:35:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39BAC6B0284; Thu, 25 Apr 2019 06:35:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28B6A6B0285; Thu, 25 Apr 2019 06:35:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 091116B0283
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 06:35:44 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id i203so16982508ywa.5
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 03:35:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=Yr3JYa8dA/Ihr6gaI+B4EHrIoHpzW04FGLodGEdGgio=;
        b=e9OCI8/meRv/x9D/2neDccx6jE6zZ/l1F5cCrHgH4R9IUzg/AFbtn4CVzxN4Agt6nM
         oJtcI57ogIWB8htI/J9JsmHhlyZwhaTkXzU9Fg9N+SHrT3BlEuODF8KjVBNoxsneYUTr
         aqqHbdy6snlYwQVyVuQxDtqdrKVSjHTquotrYoPSNp8AQ4hIil+MZ6uJ3o8P08umJpH1
         Yx5/VrRAmY6Ni2fzurVyNLmNscrjSkgBHlwzsT+O+q9Er+x1Z/ZQM/ML0MXffzMN9RQG
         8rb0yi1TVNQDm7bgxe/bsNceVyP8kYiUElbR0EJSPEbZSXAcBvMbAXE9BT/N5oab8HnE
         Q1Ew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUkh+jmCunC06S1z6IdVQTtt5dfdVlO2ysLi9yaIArpvxyuXQbX
	iZmsVtonkhvtjnI1OApvZx+CVEKI0KpQuvOI0TZT4vJQP7WPcyauwex2KVVERED2yB4qYuX9rgi
	JoggE7VuANh7V+kZEAc1slHzqkLr5CRRCA4xORaEO3ZWsAaAGOVE2YYuMgxO8zOzc0g==
X-Received: by 2002:a81:9211:: with SMTP id j17mr23353333ywg.31.1556188543691;
        Thu, 25 Apr 2019 03:35:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyn5/huwaTQdGtc+7X8MFo4wCpfxsp/zGBn2lq3XelTSrDdMrFM63/xNwgggPXj3+LqZKHC
X-Received: by 2002:a81:9211:: with SMTP id j17mr23353232ywg.31.1556188542326;
        Thu, 25 Apr 2019 03:35:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556188542; cv=none;
        d=google.com; s=arc-20160816;
        b=n09JEaDXZ/28M86C+5O+SAj4Hsdxux6nrxqMZIFjzFGHWmR2varbsozXUi/R23EVzH
         3yIrbmeHC+YV0SmKb0zAlIJ8XTvXelboEGLpS5dEjbD6ysK6C7A/zgfg1gkRCzDbuLsD
         1R+WShd6L6tzzyhmMf/+4Q3KadLqB0kqnTBB6U1CqMEvSzxD/S6JC0T+geBxLeRN0Jso
         9LhqFx5N8sZPKsmhDzLUtKbUoviSOuSi7UMHzofKlV4NOOpL2QeexHubIFXabC5OBHYP
         k7gYZ+E9mv8iIwWKlFx796CHzqjjODC3w+aVeEyd6LY0vVBg1WcHYXNVbuiAeuiIpOZ+
         Y69g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=Yr3JYa8dA/Ihr6gaI+B4EHrIoHpzW04FGLodGEdGgio=;
        b=qgzhhMRmg0oOTQW+7ppwGKJVlVoUzQh6zY/xiuBwgPa2iMqg/+P++0FTBcqCIv90md
         azAsaq3JMBqwlZc/P8VL01ofwRQpC9FxkVHBjwvFZUoDraAZoC8La3W2hRO8+WeXzFvK
         F05Ll8uueSmLugckffeik6GDYk8RvBOVZ0bPxfj0kmdxDUHTaO3up999SYlgz1hbxlol
         rYKVbHsKeipXjFeApC7LFo3y0zjhCpIfLtExaOmV4O6mxtraDV7Ns0aIKjc8ITChiLJG
         0ki+4/5ylfMUVSR7qz5+9ZcwOWgAOHCJuutdWotCa598IKqo7ETqSWs8BJm8+kUIjYz5
         DO6w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x60si16923407ybh.387.2019.04.25.03.35.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 03:35:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3PAPYsC135574
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 06:35:41 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s3b4hgcgx-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 06:35:41 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 25 Apr 2019 11:35:40 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 25 Apr 2019 11:35:37 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3PAZahC49676394
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Apr 2019 10:35:36 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 05C94A4059;
	Thu, 25 Apr 2019 10:35:36 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 85E66A4053;
	Thu, 25 Apr 2019 10:35:34 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.17])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 25 Apr 2019 10:35:34 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Thu, 25 Apr 2019 13:35:33 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH] mm/Kconfig: update "Memory Model" help text
Date: Thu, 25 Apr 2019 13:35:31 +0300
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19042510-0012-0000-0000-000003146FF6
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042510-0013-0000-0000-0000214CC968
Message-Id: <1556188531-20728-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-25_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=935 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904250067
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The help describing the memory model selection is outdated. It still says
that SPARSEMEM is experimental and DISCONTIGMEM is a preferred over
SPARSEMEM.

Update the help text for the relevant options:
* add a generic help for the "Memory Model" prompt
* add description for FLATMEM
* reduce the description of DISCONTIGMEM and add a deprecation note
* prefer SPARSEMEM over DISCONTIGMEM

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 mm/Kconfig | 48 +++++++++++++++++++++++-------------------------
 1 file changed, 23 insertions(+), 25 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 25c71eb8a7db..8f7ae4d71b77 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -11,23 +11,24 @@ choice
 	default DISCONTIGMEM_MANUAL if ARCH_DISCONTIGMEM_DEFAULT
 	default SPARSEMEM_MANUAL if ARCH_SPARSEMEM_DEFAULT
 	default FLATMEM_MANUAL
+	help
+	  This option allows you to change some of the ways that
+	  Linux manages its memory internally. Most users will
+	  only have one option here selected by the architecture
+	  configuration. This is normal.
 
 config FLATMEM_MANUAL
 	bool "Flat Memory"
 	depends on !(ARCH_DISCONTIGMEM_ENABLE || ARCH_SPARSEMEM_ENABLE) || ARCH_FLATMEM_ENABLE
 	help
-	  This option allows you to change some of the ways that
-	  Linux manages its memory internally.  Most users will
-	  only have one option here: FLATMEM.  This is normal
-	  and a correct option.
-
-	  Some users of more advanced features like NUMA and
-	  memory hotplug may have different options here.
-	  DISCONTIGMEM is a more mature, better tested system,
-	  but is incompatible with memory hotplug and may suffer
-	  decreased performance over SPARSEMEM.  If unsure between
-	  "Sparse Memory" and "Discontiguous Memory", choose
-	  "Discontiguous Memory".
+	  This option is best suited for non-NUMA systems with
+	  flat address space. The FLATMEM is the most efficient
+	  system in terms of performance and resource consumption
+	  and it is the best option for smaller systems.
+
+	  For systems that have holes in their physical address
+	  spaces and for features like NUMA and memory hotplug,
+	  choose "Sparse Memory"
 
 	  If unsure, choose this option (Flat Memory) over any other.
 
@@ -38,29 +39,26 @@ config DISCONTIGMEM_MANUAL
 	  This option provides enhanced support for discontiguous
 	  memory systems, over FLATMEM.  These systems have holes
 	  in their physical address spaces, and this option provides
-	  more efficient handling of these holes.  However, the vast
-	  majority of hardware has quite flat address spaces, and
-	  can have degraded performance from the extra overhead that
-	  this option imposes.
+	  more efficient handling of these holes.
 
-	  Many NUMA configurations will have this as the only option.
+	  Although "Discontiguous Memory" is still used by several
+	  architectures, it is considered deprecated in favor of
+	  "Sparse Memory".
 
-	  If unsure, choose "Flat Memory" over this option.
+	  If unsure, choose "Sparse Memory" over this option.
 
 config SPARSEMEM_MANUAL
 	bool "Sparse Memory"
 	depends on ARCH_SPARSEMEM_ENABLE
 	help
 	  This will be the only option for some systems, including
-	  memory hotplug systems.  This is normal.
+	  memory hot-plug systems.  This is normal.
 
-	  For many other systems, this will be an alternative to
-	  "Discontiguous Memory".  This option provides some potential
-	  performance benefits, along with decreased code complexity,
-	  but it is newer, and more experimental.
+	  This option provides efficient support for systems with
+	  holes is their physical address space and allows memory
+	  hot-plug and hot-remove.
 
-	  If unsure, choose "Discontiguous Memory" or "Flat Memory"
-	  over this option.
+	  If unsure, choose "Flat Memory" over this option.
 
 endchoice
 
-- 
2.7.4

