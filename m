Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28AA3C10F06
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:17:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4B9B2147A
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 19:17:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4B9B2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE4228E0003; Mon, 11 Mar 2019 15:17:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D92BE8E0002; Mon, 11 Mar 2019 15:17:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C34338E0003; Mon, 11 Mar 2019 15:17:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 803978E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 15:17:11 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a6so6870856pgj.4
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 12:17:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:mime-version:content-transfer-encoding:message-id;
        bh=kvoaLenib6UpHt63aR9qAvBsoXkA2wFs1fRaFfF02V8=;
        b=BpA4uGOImYaSlsR2PAvkI136mMtpwua5DCXHAEOdeJIkf8ARu8rHpxpG4mPMKSiZwP
         wSLvg2x0gcLsvQRTCQZpqA3+NFqKCoJYFk2Awenx8B+JJa/ffCzzxHjOkQKnMQNe38bi
         4Z+u3/zv1FHVf2DjcMElMhQD0pQp45pIPFciMSZhDTLf3K5X7uCslRnHIVD8fP4jIjrC
         BVwjiZdvLA2HmCJ5IMERYwIDmKdXaPv58JvZ431BwBpJZxmDqe2B9BrIKpMNSiRKL7jo
         mqhGU7KSdl75Lx8xFGsz6/FjQH4KcUPeqgmyS1mg7VBKB9dr8cOt4hp0UCFDDnuW1gOl
         HwWA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXPrWM9eAbqxspRrNObB+snZk0ZMP/TCu0QEr+qIm+GCJUf8K11
	UHBsVhHCPlPdf1ITF25348wRV9gqNF1lZCaI2/m9maNkcoWsfmnV1v5tiP3Uf4Cvg98kSzUdWT8
	38l/8Ulo2ls32jkw82HX7o/OvjmGu6jyLlYr7lRh67Qf2mTDCVJ+qoJk9RIWzSBCx4Q==
X-Received: by 2002:a17:902:42d:: with SMTP id 42mr36505008ple.229.1552331831187;
        Mon, 11 Mar 2019 12:17:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLFD3U957WKDq5AmPVleB5xntkIKS6G36PbcJaiMpAiiOSbM97zeXPWcDQuRm0rIeNxe0+
X-Received: by 2002:a17:902:42d:: with SMTP id 42mr36504925ple.229.1552331830150;
        Mon, 11 Mar 2019 12:17:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552331830; cv=none;
        d=google.com; s=arc-20160816;
        b=IB98Y2O5b7gVMYlg2iQTU54FPp+wlaLr1uOZvPZTrkP4p3QqNIGPbPNzcKDnRi8Q/y
         1zY442a/YpAdHptOD9o6Eu69Ya+FlN9gvhU7xGMxymdAgtoyUVYvhP62hh2xH0BU6DyT
         UOuppbLZNHhkc/iIyKNImSxyD9QlqVemUCChO5/+4SCeLFD9lUDkxumvY301s0qMh+Ao
         P/gC1mTnfvOZwbVIwQqw9wXgzeApMNFaFjCTLLesVHo+xTpPnPgvLCGqKE1SeioLZ+hi
         Qk40IQNxenuY6sj8a1NtocvKe+D9DN/gvhRXi626dxLyuuo70/fSfEnrWAoYwWL2wGEl
         AmZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:subject:cc
         :to:from;
        bh=kvoaLenib6UpHt63aR9qAvBsoXkA2wFs1fRaFfF02V8=;
        b=iNEdLkFy3J5HnJeTeFvC7Ame/+Fhi76EKjEIbpEXfGjVQlcDrpqxOwb5Hc2CfiV84K
         qekY1Th77WjUkXv15FE/oEWEBwwjR5nVTYGtrKCPgCSIFwiUS9LrYytdoLjQ0+j4OTIA
         1lcB5cf6laI1ba/IqqX4Yud08F2ihHe1ODMDLqgRPgaFzyTnxtChJxWdL4CwAXIRlL5e
         s6Flj0gYMU/UD1gDa4fOUkmE5vvR8tdTZmqEex645Q375wOdORyACgd1d60f8QGCWTyu
         NyxygrScsGhA25hsLOl9w+ZRtTgpBLfY2v/wz79zClszXlnV0MJAJm9cVSuUDKX5bpso
         oBAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 64si6354855ply.239.2019.03.11.12.17.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 12:17:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2BJ9UvR084183
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 15:17:09 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2r5tymfqr2-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 15:17:09 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Mon, 11 Mar 2019 19:17:06 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 11 Mar 2019 19:17:03 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2BJH2KF34930866
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 11 Mar 2019 19:17:02 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3E79EA4054;
	Mon, 11 Mar 2019 19:17:02 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8D385A405C;
	Mon, 11 Mar 2019 19:17:01 +0000 (GMT)
Received: from pomme.aus.stglabs.ibm.com (unknown [9.145.164.181])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Mon, 11 Mar 2019 19:17:01 +0000 (GMT)
From: Laurent Dufour <ldufour@linux.ibm.com>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: stable@vger.kernel.org, Christoph Lameter <cl@linux.com>,
        Pekka Enberg <penberg@kernel.org>,
        David Rientjes <rientjes@google.com>,
        Joonsoo Kim <iamjoonsoo.kim@lge.com>,
        Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH] mm/slab: protect cache_reap() against CPU and memory hot plug operations
Date: Mon, 11 Mar 2019 20:17:01 +0100
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19031119-0008-0000-0000-000002CB630F
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19031119-0009-0000-0000-000022377F0E
Message-Id: <20190311191701.24325-1-ldufour@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-11_14:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903110133
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit 95402b382901 ("cpu-hotplug: replace per-subsystem mutexes with
get_online_cpus()") remove the CPU_LOCK_ACQUIRE operation which was use to
grap the cache_chain_mutex lock which was protecting cache_reap() against
CPU hot plug operations.

Later the commit 18004c5d4084 ("mm, sl[aou]b: Use a common mutex
definition") changed cache_chain_mutex to slab_mutex but this didn't help
fixing the missing the cache_reap() protection against CPU hot plug
operations.

Here we are stopping the per cpu worker while holding the slab_mutex to
ensure that cache_reap() is not running in our back and will not be
triggered anymore for this cpu.

This patch fixes that race leading to SLAB's data corruption when CPU
hotplug are triggered. We hit it while doing partition migration on PowerVM
leading to CPU reconfiguration through the CPU hotplug mechanism.

This fix is covering kernel containing to the commit 6731d4f12315 ("slab:
Convert to hotplug state machine"), ie 4.9.1, earlier kernel needs a
slightly different patch.

Cc: stable@vger.kernel.org
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
---
 mm/slab.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/slab.c b/mm/slab.c
index 28652e4218e0..ba499d90f27f 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1103,6 +1103,7 @@ static int slab_online_cpu(unsigned int cpu)
 
 static int slab_offline_cpu(unsigned int cpu)
 {
+	mutex_lock(&slab_mutex);
 	/*
 	 * Shutdown cache reaper. Note that the slab_mutex is held so
 	 * that if cache_reap() is invoked it cannot do anything
@@ -1112,6 +1113,7 @@ static int slab_offline_cpu(unsigned int cpu)
 	cancel_delayed_work_sync(&per_cpu(slab_reap_work, cpu));
 	/* Now the cache_reaper is guaranteed to be not running. */
 	per_cpu(slab_reap_work, cpu).work.func = NULL;
+	mutex_unlock(&slab_mutex);
 	return 0;
 }
 
-- 
2.21.0

