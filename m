Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECD00C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:28:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 957932089E
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:28:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 957932089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 136548E0003; Thu,  1 Aug 2019 02:28:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E7B88E0001; Thu,  1 Aug 2019 02:28:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F178C8E0003; Thu,  1 Aug 2019 02:28:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id BDD758E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 02:28:26 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id q9so44424785pgv.17
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 23:28:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=8L704N+Nw28s6SgYptXIPDn52cC8Xd8qI65fMO6wZDk=;
        b=NZG8FV1jzCDSY305o7GQHA9wNOfJL3hn6J/Kzu6p9+z6jASNEYGAVhPp2XP9kKxd6n
         P+t0TottehHPo4+hFHrmG/gfRtYBZPMYTiLp/wmdyOhlKqNC4ubaDcbE7gjuVYLzOLpG
         N6JhRaQVUwWMus/NK+lxpMm45nlazoHhHLFY0/xYMsW3GgYplDyP9P9xpB7IAO5GtAeR
         NAyUyK+6Tf3KSbZ0s9nBb3fJH4dY/swUk+Uj8Qxo1DyDJtvMPoE43lRkpH/JE4jrHT6X
         4RQPvnx8IYD/p2XxhYd2l8Sw6JtEiU3ooiFL6b/5dJWzaZ/aaXXNkbyNv6d6nuXzOv9f
         vTcw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAV6pf7OUQkijQOAwJ1DAZNypc5QwmjYVtAjgykh36IlRiVgErHq
	o9h03U2ZNWp1lF6XvprKHC6Ev8DsGAbVeviA2W7qJ3CT4sKMh/Z0aRFYrTHnc4amquTVzZm8p1b
	FmT9HjOmNRI8e8pxyU4ceym+Iic3VOZGRNDlWNUBcpx0QCehiqhCjrQTPYnkNsdo/nw==
X-Received: by 2002:a65:57ca:: with SMTP id q10mr120812546pgr.52.1564640906181;
        Wed, 31 Jul 2019 23:28:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzpLSmmVxAl4LFAidArJdvWyM5kmrOrVbPPExZK3UhlUh8IaZSS/LpdxWjSsZa4tHftsRO8
X-Received: by 2002:a65:57ca:: with SMTP id q10mr120812496pgr.52.1564640905312;
        Wed, 31 Jul 2019 23:28:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564640905; cv=none;
        d=google.com; s=arc-20160816;
        b=eHzZqIC2VvdK+aMZ0Yttrbefx0LrZvXXHfIYQhVLyaC6DCJmhTGOhkDqjlHothq4Eo
         4av17mw6kHaRCCpN6hzFufnDFaLOg1QVNkEyQxFjgSCY9kIRDzJByMZMykNuAwLt1Dh3
         WzGRPnSjundL+360rbepL879CsPp7r7YFXopDlMwEas7PiwwWh5RV+pz/C+p7sXwMwli
         05PqKff0tM/6Rhc0P8683Bz0KFPcv6Br9YArWAgUN7SObTfubkG1Cpxho4FaGfUHgA/9
         ZMS+wz3orHH6bYuF88zR/o7D2fPvlxt9WnLIBQTAT8ygF88F9BpfteLSiMusZOiUDCzO
         Sn2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=8L704N+Nw28s6SgYptXIPDn52cC8Xd8qI65fMO6wZDk=;
        b=DaCsYIdPMLdCSH23FQ6XDCtDBP+fgI9yKOkdUx32yALiSl6hjZjxN0mT/9nWAh6a6h
         9iVySOFk4ZBCw9OO8DHg4qDyemfGLknvEbvmORv0HN+yn3NSwOVRw8eN30VHdWsS0BcW
         HTrENno5BQxwXWwi79RKjx4lK9uhV/2h0PYjHbLE2JovnHCJkfTu4M5KOIPYbm4hRKIL
         pF+UMMJ0mlMaaHRvfFvXNBt/H8VMxMaryifkX/7NPKrDkfwayJQE0yd7W4IsSH+XPia3
         BpMvETkjO9IbKwqolOY4irSoNjm+ccSawASKS8Wt/EYZo+VzrMuf/eF4cX9zohS9vgC1
         2tXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n19si33339030pgh.219.2019.07.31.23.28.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 23:28:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x716S0mw023992
	for <linux-mm@kvack.org>; Thu, 1 Aug 2019 02:28:24 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2u3s8skcv2-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Aug 2019 02:28:24 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 1 Aug 2019 07:28:21 +0100
Received: from b06avi18626390.portsmouth.uk.ibm.com (9.149.26.192)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 1 Aug 2019 07:28:20 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06avi18626390.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x716S2GR39190790
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 1 Aug 2019 06:28:03 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 75CAF11C050;
	Thu,  1 Aug 2019 06:28:19 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 1F54311C05C;
	Thu,  1 Aug 2019 06:28:18 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.168])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu,  1 Aug 2019 06:28:18 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Thu, 01 Aug 2019 09:28:17 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH] mm/madvise: reduce code duplication in error handling paths
Date: Thu,  1 Aug 2019 09:28:16 +0300
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19080106-0028-0000-0000-00000389E300
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19080106-0029-0000-0000-0000244A3637
Message-Id: <1564640896-1210-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-01_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=502 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908010063
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The madvise_behavior() function converts -ENOMEM to -EAGAIN in several
places using identical code.

Move that code to a common error handling path.

No functional changes.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 mm/madvise.c | 52 ++++++++++++++++------------------------------------
 1 file changed, 16 insertions(+), 36 deletions(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 968df3a..55d78fd 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -105,28 +105,14 @@ static long madvise_behavior(struct vm_area_struct *vma,
 	case MADV_MERGEABLE:
 	case MADV_UNMERGEABLE:
 		error = ksm_madvise(vma, start, end, behavior, &new_flags);
-		if (error) {
-			/*
-			 * madvise() returns EAGAIN if kernel resources, such as
-			 * slab, are temporarily unavailable.
-			 */
-			if (error == -ENOMEM)
-				error = -EAGAIN;
-			goto out;
-		}
+		if (error)
+			goto out_convert_errno;
 		break;
 	case MADV_HUGEPAGE:
 	case MADV_NOHUGEPAGE:
 		error = hugepage_madvise(vma, &new_flags, behavior);
-		if (error) {
-			/*
-			 * madvise() returns EAGAIN if kernel resources, such as
-			 * slab, are temporarily unavailable.
-			 */
-			if (error == -ENOMEM)
-				error = -EAGAIN;
-			goto out;
-		}
+		if (error)
+			goto out_convert_errno;
 		break;
 	}
 
@@ -152,15 +138,8 @@ static long madvise_behavior(struct vm_area_struct *vma,
 			goto out;
 		}
 		error = __split_vma(mm, vma, start, 1);
-		if (error) {
-			/*
-			 * madvise() returns EAGAIN if kernel resources, such as
-			 * slab, are temporarily unavailable.
-			 */
-			if (error == -ENOMEM)
-				error = -EAGAIN;
-			goto out;
-		}
+		if (error)
+			goto out_convert_errno;
 	}
 
 	if (end != vma->vm_end) {
@@ -169,15 +148,8 @@ static long madvise_behavior(struct vm_area_struct *vma,
 			goto out;
 		}
 		error = __split_vma(mm, vma, end, 0);
-		if (error) {
-			/*
-			 * madvise() returns EAGAIN if kernel resources, such as
-			 * slab, are temporarily unavailable.
-			 */
-			if (error == -ENOMEM)
-				error = -EAGAIN;
-			goto out;
-		}
+		if (error)
+			goto out_convert_errno;
 	}
 
 success:
@@ -185,6 +157,14 @@ static long madvise_behavior(struct vm_area_struct *vma,
 	 * vm_flags is protected by the mmap_sem held in write mode.
 	 */
 	vma->vm_flags = new_flags;
+
+out_convert_errno:
+	/*
+	 * madvise() returns EAGAIN if kernel resources, such as
+	 * slab, are temporarily unavailable.
+	 */
+	if (error == -ENOMEM)
+		error = -EAGAIN;
 out:
 	return error;
 }
-- 
2.7.4

