Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89736C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 18:42:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53A60217D9
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 18:42:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53A60217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E89D78E0008; Mon, 18 Feb 2019 13:42:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E10288E0002; Mon, 18 Feb 2019 13:42:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C8A898E0008; Mon, 18 Feb 2019 13:42:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D3D68E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:42:07 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id w134so15510970qka.6
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 10:42:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:in-reply-to:references:message-id;
        bh=6UfCPPZllTEGGEKF29OGuMk2xjG0QrU1dWYvy6NrkGI=;
        b=F9+6tlPnxV/uJU7RABBA2D5emr3BLNmm9PZZvz2uvWVrwZYOb/ykI7RNeG9p5QSkdp
         kfjE5a8It/uXXoK9twwY9s9W7KH/TEQfiRF+lQG9j921ZDTnzxX7CsXKRs47pj/wdjxt
         Jv6ICVHUB1LS6/3/0IJAPg0otFucrshoZASE3APbk/mGWLjmGRrLjdfZMnr5mgXAyVeZ
         z/3GuQNTCfOxXhY8bKoCZxmSB1OGTaOuij9r9P3McrQG1NvNelmIuF8RnUbxtG+3LMqp
         uIB23v2FkGIC0m7Vqjb0Dnhu0Xpo4heI1CaFfJMTl/2WcaQaoFSL//5ggnPT7g5hpl0i
         fTkw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuY5TjljCCctVDbAZClTh3XP2BSGXNWXwDDv4zukEHqivjkB+u3F
	aV8aNZXMO83Xcs6/HkLJh9bG9ARLKGYfCqkzcVM224vfssLsbDmxhMKAPk54UlirRhKRhBaBM3L
	wJ07xyfPAGabw9DntYqi/3kCCyK3s8Gz5iFXReJ5dpgM9otIjCsOt2OVgB8QdGQbn9A==
X-Received: by 2002:a0c:d4ab:: with SMTP id u40mr18787561qvh.30.1550515327418;
        Mon, 18 Feb 2019 10:42:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZsCXLYkF5zTVtiQMPrLol9Fvbs3I8tGfoLtBouZFRkrn70VpKy0D2LJvlwViwx404cG1fk
X-Received: by 2002:a0c:d4ab:: with SMTP id u40mr18787522qvh.30.1550515326756;
        Mon, 18 Feb 2019 10:42:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550515326; cv=none;
        d=google.com; s=arc-20160816;
        b=BxukflfSkh8WaBcL0yfi7JWQ+OlAL78a4uKRBhdd+hsOaDJyRI579cVAI7oXY9SDOH
         zctQI+wG6/a9aOhNQWfamANqFM7tnGAFzl/EQdHQCQmgIeu3LNr+yJ0PveXFbYeuX/h5
         uV5/20k0drEj87klEnqVkRPjCkGL+s71514eguTwHsOTbyyvUpVO6UKc7P+iMa0P7OgJ
         Tk929fZAarpHfEVnGmuKOJbSeH6T03ANaJ5G+ZtDRJcbRsAro9FdZOyeUdfDgKBFKTTT
         VhvdYB6+uPtecPRAvihsmGxdbK8ESTjccZG+nEv+pqDE8hZfFU9p7KcCS0GParRkJ2Hf
         A7OA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:date:subject:cc:to:from;
        bh=6UfCPPZllTEGGEKF29OGuMk2xjG0QrU1dWYvy6NrkGI=;
        b=O4zz3x1YkiTWu/JEXu5umEjgu1A6LW5SRZDSCpVJwvcqWal0e7namaqS+52rTlcOX3
         WBOlFKGvoA/Ock9Aqv/AQQkEl2Cw4FCrVAuh1Dx/y5Lj4t7PFmSP/3f0kCnvK4sJknco
         0FZWpBk5lCItprAt9msNIlXC5vZM+w9ZUQ6XhzIII+7Xw4s0MOYTuO3nKyche4YcPzBm
         y8vxQpU1SFNsOsGGE2ma8pfZkCEtjDT724bhW8ArRwr5ExoyMOdXfjPAvsD3NL4fUVmV
         E3GfPuGzUJ7c+Blqo7IxZZOXgDSrL5rqCmKY0TDV/hdhLvR9hJAweD7H1LLuuHVNm6nq
         qOOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o17si3745739qve.102.2019.02.18.10.42.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 10:42:06 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1IIcqEu043780
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:42:06 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qqy19j7m2-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:42:05 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 18 Feb 2019 18:42:04 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 18 Feb 2019 18:42:00 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1IIfxAR26935366
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 18 Feb 2019 18:41:59 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2179E11C050;
	Mon, 18 Feb 2019 18:41:59 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 84BBC11C04C;
	Mon, 18 Feb 2019 18:41:56 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.207.239])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 18 Feb 2019 18:41:56 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Mon, 18 Feb 2019 20:41:53 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Palmer Dabbelt <palmer@sifive.com>,
        Richard Kuo <rkuo@codeaurora.org>, linux-arch@vger.kernel.org,
        linux-hexagon@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-riscv@lists.infradead.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH v2 4/4] riscv: switch over to generic free_initmem()
Date: Mon, 18 Feb 2019 20:41:25 +0200
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1550515285-17446-1-git-send-email-rppt@linux.ibm.com>
References: <1550515285-17446-1-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19021818-0012-0000-0000-000002F72E7B
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021818-0013-0000-0000-0000212EB8B6
Message-Id: <1550515285-17446-5-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-18_14:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=758 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902180138
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The riscv version of free_initmem() differs from the generic one only in
that it sets the freed memory to zero.

Make ricsv use the generic version and poison the freed memory.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
Reviewed-by: Palmer Dabbelt <palmer@sifive.com>
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

