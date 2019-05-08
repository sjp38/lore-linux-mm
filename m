Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04D48C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 08:50:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B466F20989
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 08:50:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B466F20989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 515306B0003; Wed,  8 May 2019 04:50:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 49DF06B0005; Wed,  8 May 2019 04:50:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 319BA6B0007; Wed,  8 May 2019 04:50:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id ECDA46B0003
	for <linux-mm@kvack.org>; Wed,  8 May 2019 04:50:45 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j1so12207912pff.1
        for <linux-mm@kvack.org>; Wed, 08 May 2019 01:50:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=jDec5mGkTzDSo66HA2ZoS1SqKW0pSUZEjG48OuEVTNk=;
        b=XF8KQ1LruWPOD+iXWhSQZlgF/1D/LrIFJnBD83igLhR7UUCjtO5W0tPtsk2PftAnYs
         raWYHjZvjWpD8bo6oVLH6JnCzLdk2Uq41S2QyFoz9mJtlN1ysW0GRYrp3vB4y3T+BSKs
         AJrXtJuO5tUKVRMCBxzGmWc8Oj6tJbXCYzA6uCw1NUjXTm1M6e7iC4ewscfcOX/vCz3y
         X41WzD+lgk2QL04i6gTAXX1HdG/oU0xCFYIHdqcj7Whek8Fr7SoONq7BTVIBHL/DeYjU
         YDHCtHIB39PLvhwdVl8gzEDEZ+Gshxr9Y0rLI+eAh3wOxxsXbpbGWM2w6bwLWDdpTClL
         n1tg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVoqkq1xNfJ8JuhzGKrey+nMiUyewl+fTpTHlLTX7fT7C4HFSSu
	lwdDeZRVR4JTG2K5DxUQgkP0zzkUXsBZHbfI9JDv7p+czxEtLvcAWFchLI1hh60XAoV4Nl/eE9d
	h6jZWAAD9wIFou3klBphX+MMBErA/+dKF9kr8T1vUR3SVSioMlj+ER7hnR3emxVKlyQ==
X-Received: by 2002:a62:520b:: with SMTP id g11mr45565938pfb.215.1557305445618;
        Wed, 08 May 2019 01:50:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxFfjNMP6c6rG/vdJrvCzLrRgECL6ffjF474El3yZddWJQa3em4hunvDpLFrH4l3Bnm7f2M
X-Received: by 2002:a62:520b:: with SMTP id g11mr45565862pfb.215.1557305444452;
        Wed, 08 May 2019 01:50:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557305444; cv=none;
        d=google.com; s=arc-20160816;
        b=BNC1ZV3AJ3sGrFsEmuQr+vQ/tO3MXL3jBlDM+CfP9WuvSX36Clg0sUJ/0DvVIITA6b
         B5mzJz0n/EdrQGmuPu1YKc39l4DKhdusJqsbf0NGFfMDqACcjaFVq6tknMgAtYuc5nyQ
         feV5AGllPMNI71bTp8RCna26nB0Z1zwSEwzffc8tyhf+Oo2ok8C5NeMSwKI+GsW/1COk
         IeAqk6deFzVz8m+B5ITf3Mtdojkuy5KNzTQ2nA/C9F+UeCZ1LJxj5RKzl8ws+IQEYxnr
         WKNEO4rE+izIUK7Ccf0kNjT7rQ25umX1s6Ddn+EAF/c9Wy5qJ8AnFAmRv2WqeBPurCMz
         +HHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=jDec5mGkTzDSo66HA2ZoS1SqKW0pSUZEjG48OuEVTNk=;
        b=YVQbhmYySdAHCN7wLbCOjVzzClNGfjOwr3u4W5Hff9wMrk9Hs87HVhnP15+sYpxf4a
         tBEgo7TKEPGrzNDFzTbFy3N6sKnIzlqKK4TJCe5j03p3/a7Scxz5F4QmdZYuoJeB1ZYy
         Dggm7Q8kjCuT5ANpDc6dy5qqh+ZfblDIMxb9ToJv4759swBHL7EZGcoD5HwneNiBolPZ
         CBACnNbd7eRldltW5a4Ztp/Emd5t4BiJUu1jrvQD261qGj/NnqYY53qsvGOxkzlvnNdf
         NjNhERcN6IkOmLIThHwfllJgeRnfb4ypkLxZgfYn+Mh8Lm5owkc32m/oUGEVzzuRXlhD
         XBCw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id cn4si468105plb.244.2019.05.08.01.50.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 01:50:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x488gS5J147199
	for <linux-mm@kvack.org>; Wed, 8 May 2019 04:50:43 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sbtp6458w-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 May 2019 04:50:43 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 8 May 2019 09:50:41 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 8 May 2019 09:50:39 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x488ocTv41877528
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 8 May 2019 08:50:38 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 09E4C11C050;
	Wed,  8 May 2019 08:50:38 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B426511C05B;
	Wed,  8 May 2019 08:50:36 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed,  8 May 2019 08:50:36 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 08 May 2019 11:50:36 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH] mm/mprotect: fix compilation warning because of unused 'mm' varaible
Date: Wed,  8 May 2019 11:50:32 +0300
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19050808-0012-0000-0000-000003197922
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050808-0013-0000-0000-00002151F9D3
Message-Id: <1557305432-4940-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-08_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=900 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905080056
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Since commit 0cbe3e26abe0 ("mm: update ptep_modify_prot_start/commit to
take vm_area_struct as arg") the only place that uses the local 'mm'
variable in change_pte_range() is the call to set_pte_at().

Many architectures define set_pte_at() as macro that does not use the 'mm'
parameter, which generates the following compilation warning:

 CC      mm/mprotect.o
mm/mprotect.c: In function 'change_pte_range':
mm/mprotect.c:42:20: warning: unused variable 'mm' [-Wunused-variable]
  struct mm_struct *mm = vma->vm_mm;
                    ^~

Fix it by passing vma->mm to set_pte_at() and dropping the local 'mm'
variable in change_pte_range().

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 mm/mprotect.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 028c724..61bfe24 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -39,7 +39,6 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
 		int dirty_accountable, int prot_numa)
 {
-	struct mm_struct *mm = vma->vm_mm;
 	pte_t *pte, oldpte;
 	spinlock_t *ptl;
 	unsigned long pages = 0;
@@ -136,7 +135,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				newpte = swp_entry_to_pte(entry);
 				if (pte_swp_soft_dirty(oldpte))
 					newpte = pte_swp_mksoft_dirty(newpte);
-				set_pte_at(mm, addr, pte, newpte);
+				set_pte_at(vma->mm, addr, pte, newpte);
 
 				pages++;
 			}
-- 
2.7.4

