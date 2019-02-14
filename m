Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91E1BC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 16:00:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5097C222DD
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 16:00:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5097C222DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7CB88E0006; Thu, 14 Feb 2019 10:59:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0B6F8E0001; Thu, 14 Feb 2019 10:59:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C83398E0006; Thu, 14 Feb 2019 10:59:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8A6E48E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 10:59:58 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id h70so5083116pfd.11
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 07:59:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=c0/yCleC0+cRKs0NWxaObUZpUHrjkCQzoZuwDL4hADQ=;
        b=JMptApM7HKSnwizYnTM1yFijNJFh2CohLmPMNMfHZelD7SE/AP+NCf/6qSrrLAGb8c
         oQvGU4S10dvAuLGi/Huzler2BzXbFRBGFwOJ1BAzEV5G2S0Rc5AcQmQB97rGBmjjtNDn
         h1tcsGiLStJUxktIhqGKI0xAqzk6UAlLKfVLqQA0Swxw/QmtF+2CTRmwgJNG+RI/A6f1
         jmDxB/XBYots0xser1+003Mb119QzMGQsgxuSzZHJWOJV0c8lFPLkaizGDNbaFDuitKW
         AF4rRR42Rb0imljI26p/qrazpUmfW24xjqtwnI1ORipjPXVMfzRymvXUlxvVDCfc0Veb
         uD3Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuZmO6tFM3/9je9Zjc68MuwhFiKCxvJ+E8xY9F7lHkwnXmjuCfa+
	bvOT5roINsc0Uz56aHFUFpHIh2+ZuhPoGyJasE+r+NrXHuHFeCFobti4EYh4/d/NG8fSGV87goJ
	+f9DZWLuFTOKzcKCkgxmDbE4SwyCqAHbs5jfCr6r6N23tUFN0UNnps8CpjmZWn2b0hg==
X-Received: by 2002:a17:902:820f:: with SMTP id x15mr4774222pln.224.1550159998255;
        Thu, 14 Feb 2019 07:59:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZa01QFSCmWoxh64iuib9zAhUTnFVRkMOqySRV0xWpHJR/T7laFWn8XNSolZjlSPFH9dyW+
X-Received: by 2002:a17:902:820f:: with SMTP id x15mr4774179pln.224.1550159997571;
        Thu, 14 Feb 2019 07:59:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550159997; cv=none;
        d=google.com; s=arc-20160816;
        b=hVHGy05cs+KFxJ80CEsMxvyK94hsc6FYmtV65TpnOwwpTlVwVWJcQPMcQDkSbSjsG0
         y1LzNSl2aGmbzw0yDHVh2fjh2//gIYUmnM05Gwkrolk77XF71uENVxpoD+myPf1UWYZa
         T5GT3SAXHunPnp+SV+F6ERqzbVRqpKu9dlVz5qcGUBJzAbPIXW8FW8wNZD+riyllmEN7
         uV4lhyX8nsvWSf4f18RyTpg4ggpEpTEKxiMGdKMjfAsVbzA8xuKtJS1ktFTyToGvHV0L
         7GtB8TuuU3PJzPGD2sbMAKa5x8WLqegl8fGgF9vp3M22xCQLl9NBKxozP9QfTdrdpqcI
         J9ZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=c0/yCleC0+cRKs0NWxaObUZpUHrjkCQzoZuwDL4hADQ=;
        b=pduQXq5YIDR5s+pP3xfq9iB7uPE/sSIFpHQBxk2SMfZDF+DXT0FKqNnRahIyHZX7Br
         mQh1GQGsHuvFwxbMqHNi2me2DTSHHn8TUZw5zoFsstmMWfWJgAij1yhHNh9f0IXx/Ikf
         N7SVhVzqQMgjnQaH8mLu+NTnQLxfsbqEWDv+KLObt7zJ0YKKPPVkpOEMIZX6x9eCLHGy
         fnV9a0q0tZrWyqLfwOwGNtQc/SyyGRJ3UaS82C5jjcr1ZNcX62WvIVl7mlulaXhlvpX8
         M0FETlyMFwSNfmHcDC9jwqFtNREGXn1wVQPx3eodsthkpX+EV7Aj1gY0dxIJuItDyUI8
         gAZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c12si2633459pgh.257.2019.02.14.07.59.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 07:59:57 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1EFi1lX053770
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 10:59:57 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qnb3b1n33-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 10:59:56 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 14 Feb 2019 15:59:54 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 14 Feb 2019 15:59:51 -0000
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1EFxo6f48759004
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 15:59:50 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 696F752054;
	Thu, 14 Feb 2019 15:59:50 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id 987E052052;
	Thu, 14 Feb 2019 15:59:48 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Thu, 14 Feb 2019 17:59:48 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Palmer Dabbelt <palmer@sifive.com>,
        Richard Kuo <rkuo@codeaurora.org>, linux-arch@vger.kernel.org,
        linux-hexagon@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-riscv@lists.infradead.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 4/4] riscv: switch over to generic free_initmem()
Date: Thu, 14 Feb 2019 17:59:37 +0200
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1550159977-8949-1-git-send-email-rppt@linux.ibm.com>
References: <1550159977-8949-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19021415-0016-0000-0000-000002567B00
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021415-0017-0000-0000-000032B0AC03
Message-Id: <1550159977-8949-5-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-14_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=752 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902140109
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The riscv version of free_initmem() differs from the generic one only in
that it sets the freed memory to zero.

Make ricsv use the generic version and poison the freed memory.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/riscv/mm/init.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/arch/riscv/mm/init.c b/arch/riscv/mm/init.c
index 658ebf6..2af0010 100644
--- a/arch/riscv/mm/init.c
+++ b/arch/riscv/mm/init.c
@@ -60,11 +60,6 @@ void __init mem_init(void)
 	mem_init_print_info(NULL);
 }
 
-void free_initmem(void)
-{
-	free_initmem_default(0);
-}
-
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-- 
2.7.4

