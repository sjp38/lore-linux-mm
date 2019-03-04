Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41B30C10F03
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 15:52:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09A9A206B8
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 15:52:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09A9A206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FF638E0003; Mon,  4 Mar 2019 10:52:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 787F68E0001; Mon,  4 Mar 2019 10:52:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 653848E0003; Mon,  4 Mar 2019 10:52:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 35F4B8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 10:52:47 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id g6so8714358ywa.13
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 07:52:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=l8XM/6Y/1RM0fk66B54SBZQJ2FF4TGtw65Qh2TS+qYc=;
        b=hIr/24e7q5+FneIgD011SWiijsvX7NFJrT15J87prT9r5oOlWi54Ni0W9mNK1pdebG
         0teXvzu9haWithsQb1yMnqn1Rqmv5lKnbNxfglUID9yQUNRIopBwPwnpIopVRVZZpJHN
         eXILuV/AQy+mmXFptfG932ZboKAC9kIBHA55WrJCzfbJSor/bPqIhwpH7893RLfqgAyK
         /lRcOjwbZOOklEDXY3HJqaG6+jquAUa32CdvQN/GcdmAetT1DkFDz5iIcei34xMEKMMN
         Z37fch8CXMXxUt+/tl/EtayaIy6JkDL2uGF8Y70E3XizXqCjBrGOW23ddTo/poJZuk37
         +zEQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVceRYYMdnqjHFHQGbP2YLhIB5vhkDRLtOlMGiaI3r1dGJw/oaf
	cikgU6lKRdsMYIqtMfjPP16P2PO3AMRPLfB1WL7ZKs3RQytSw3sziMPM39slQCD3CRl2g744vqs
	BxaPmAXd+/xNhDE8gn8ABrAjWnaa5uKrT3WM2VSpdyE0c2mSv+IapCUdPYB+AM4SUUA==
X-Received: by 2002:a25:d20d:: with SMTP id j13mr15569388ybg.417.1551714766967;
        Mon, 04 Mar 2019 07:52:46 -0800 (PST)
X-Google-Smtp-Source: APXvYqybgtgou1lZKRMC8TyIfHB0BI+peiXHDVOhxT8FdrW3UwH8ut5D4TvtF88o0+DSM+so2792
X-Received: by 2002:a25:d20d:: with SMTP id j13mr15569324ybg.417.1551714765899;
        Mon, 04 Mar 2019 07:52:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551714765; cv=none;
        d=google.com; s=arc-20160816;
        b=Q9zdoRFxJO7Mu0vpMiqFxnDvdonLsXa2psrBmM5rN+uHeMWdjc9H0YFxZDCPAATBE+
         iQIWnab33zHCXfzZV9Tuh2HHOrMh9t/xaSzaPXvxRcBq6E9SozwHEO785Y6LoEZIGKtf
         +faWBW8JE/t0KSTU+tft9CRiG1dxjzMjjhuhJMm9PVpRkDAoBu+KSEWaXviRjI7bQEZx
         jzSMyEhbOk7gsGYQte7Mn7+QVCscw/VwupoHa3rUR/jU0OSVK0kqYlyna1M+2jSW89xf
         ZUAck8p2tqj5RrPIpS47O2xUpGe4LcaTPV/BxHeGXBuUGmUgLs7O8bW0meFVaBTcMQiE
         TjSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=l8XM/6Y/1RM0fk66B54SBZQJ2FF4TGtw65Qh2TS+qYc=;
        b=oblN3UVQLaMqtVVYgw34mAvZoVgMDseEOoPPG+yDDemL+t9+Rio58TPMQqcq7XtH6p
         4wcCEKfg4Yj1YNYNrhokOJg98qFuZs+myrebGF6Gq3jO4yH0DEPqC4SQOcqMV05Nut3E
         2qg2kvKe7QXQ+WhACXGU6QJjZaGfMpkJFEMgp9UHx3CllDjRpeMEFfLOfzUQftZUb4q8
         ukaDdkkzYI3abbTetLYy5+ypN8Ifax+gYMGJ89QhiMnMLoEVs9S16SKzpmIvvzw2eFO8
         jBCqrx3FtO09pxf+SaXcBiU+RPVnTfP5qYvFJJZOTF6dDYhxwiLBZjM1vr5l3rfcypby
         +R8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i11si3180225ybk.22.2019.03.04.07.52.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 07:52:45 -0800 (PST)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x24Fnbo5101945
	for <linux-mm@kvack.org>; Mon, 4 Mar 2019 10:52:45 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2r165raweq-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 04 Mar 2019 10:52:45 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Mon, 4 Mar 2019 15:52:43 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 4 Mar 2019 15:52:41 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x24FqeRa29687916
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 4 Mar 2019 15:52:41 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D11DA11C058;
	Mon,  4 Mar 2019 15:52:40 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6BE2811C04C;
	Mon,  4 Mar 2019 15:52:40 +0000 (GMT)
Received: from pomme.aus.stglabs.ibm.com (unknown [9.145.78.104])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Mon,  4 Mar 2019 15:52:40 +0000 (GMT)
From: Laurent Dufour <ldufour@linux.ibm.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH] mm/filemap: fix minor typo
Date: Mon,  4 Mar 2019 16:52:40 +0100
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19030415-4275-0000-0000-00000316BAE3
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19030415-4276-0000-0000-000038250B43
Message-Id: <20190304155240.19215-1-ldufour@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-04_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=773 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903040115
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Cc: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 mm/filemap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index cace3eb8069f..377cedaa3ae5 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1440,7 +1440,7 @@ pgoff_t page_cache_next_miss(struct address_space *mapping,
 EXPORT_SYMBOL(page_cache_next_miss);
 
 /**
- * page_cache_prev_miss() - Find the next gap in the page cache.
+ * page_cache_prev_miss() - Find the previous gap in the page cache.
  * @mapping: Mapping.
  * @index: Index.
  * @max_scan: Maximum range to search.
-- 
2.21.0

