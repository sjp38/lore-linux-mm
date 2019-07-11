Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E8C9C74A35
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC24A2166E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="VxnBJQPS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC24A2166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D559D8E00DC; Thu, 11 Jul 2019 10:27:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D07BB8E00DB; Thu, 11 Jul 2019 10:27:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2F068E00DC; Thu, 11 Jul 2019 10:27:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9295D8E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:27:25 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id c5so6906522iom.18
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:27:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=p0TwseF6Rl2ptej9BTwWkpZCi9Mm6El6sXWBWxSv9Wc=;
        b=cPgqGNZZMUF1vTM/VI0/cyT200JAzNFB96+gCOVBB6nEe8I3mCZufLB5ykwlQTLbOD
         XqG8C7VZTcoaBry+cQUcG3bCKHose2x0VDoHRTnGMOcygTBd3z1E7R+lKZGweOjuu25U
         UfLETeN5s/IhbX3+iRkmcjWNrq3kC5ELUSdKOyG8vtRW6Qn6Lu44PDSeEUqAe6PbOHbs
         d+3B1ECFux+FKuJaJWFD3hh7FmK5AdPcaV2SeJxqK0Mn0/f1n70aEqo8FnhswEp6GJZg
         4lE+caJfF0of86qjriFey2Wzn157+PlDHEUQUup2U23KjWEsj5ec/020l8aW1tLdXYNN
         Q90w==
X-Gm-Message-State: APjAAAXXkDdUd2O1eW+cOIaQchMJIefYXJkf22ZoyR6msTjMTfghD0PX
	BfIoBzCA11gmtJLllGChTVM0j17Aq3+fpzAWaK4/PYquUV98js8RNIPhE7f/ACI4i/2GqNFRyPa
	55rqp4Q+xBwMht5Har+KTTK3M7PiaCXlPYWWcVvAsFenRcCZptjnGMqgWYQcW6NnX9Q==
X-Received: by 2002:a02:9004:: with SMTP id w4mr4954615jaf.111.1562855245396;
        Thu, 11 Jul 2019 07:27:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxY4/hh5m5SARweNKm68n49sZBK3UFUoSJu4Ps0b1/z9Qt52U09oBe4TGGLy7x6gk01Ajlx
X-Received: by 2002:a02:9004:: with SMTP id w4mr4954555jaf.111.1562855244728;
        Thu, 11 Jul 2019 07:27:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562855244; cv=none;
        d=google.com; s=arc-20160816;
        b=VqH8UFfAkBsxOEzKylrcP9/zZucI073ilvxmjfmxLO4nuHq6K8qwcm2kcEeFf1cLk4
         VWSIt1E/z1KtEGxMtRGxEHdKrbfvnwS+12UEd4KfQh2Eg/G3uIIWEXAy9mRzbhcuuDIM
         iP5A65U+5B5CtsATxNESg14v/m9wUYXNZS+VO0yFrYFgrHqeJUR/o0VpRWkPsBUZqUQE
         MKdjPcNl0RVC/3QCLH9abY5JKphD27bvRkOmoEu+N7g412qkzLEkqemgxX4LYBaTWSR9
         07LKELoxSFEQGduUaVfV5uu9yks7eh5eraAaXFLMTTGcfX6ZxKS/Ftm2tMdW+7RKrqk8
         GoDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=p0TwseF6Rl2ptej9BTwWkpZCi9Mm6El6sXWBWxSv9Wc=;
        b=Cp/bG3U+Ov/O9UNn3ZU8FPPDTS4BJ3TwE9+faplUmK9q239ntbbSbyaL/xZ+rvDYmu
         ouK5QvIiJ0atARW72MdyuamP5gyrG6dGZ1w0zgopeBIG72n87lZHarVGwclR1Z6u7TdV
         9bxumpdAg0tcWwakBkT2VxGTRGkjSNSkYqPGnlO5G20I0fcca7es938ZjkLiVp7l9mtN
         jhlzZ3TOLO/B5bvg+X1dR1WjnOB9kiwgVreNzoNZtpSL6oX6FoT95TpfTE5aLOGePhdA
         mM31a6c9nsjM4B/yp3ogfQwjABOJoWZMe5KGA5VTpntmQ1aZheuRkJ3ISHXAkGRzk/xZ
         SQcw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=VxnBJQPS;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id b10si7691987ioq.76.2019.07.11.07.27.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:27:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=VxnBJQPS;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BEO8vQ001464;
	Thu, 11 Jul 2019 14:27:16 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=p0TwseF6Rl2ptej9BTwWkpZCi9Mm6El6sXWBWxSv9Wc=;
 b=VxnBJQPSh0LmxFyWqVND6G3imbrgiNDc2XYktPKhPxTH7jeK12iQ07uhiR7KSkYssaXb
 Pv64TstUQ6TZGJ1PMaSuITPpNq63mpZXM6Iv7MEPC/m1XIUd6uAVwnuCuLzWwEkJpk+d
 bLhzpPXWzEGxFhxH1pYNQvLU4rahHXqpvu4/IcVK0tDJMHq3A7NSNALQrgdnEe+A5MWw
 HjWBvSrm/StSA0wUZr133cDwxkrZIL+2nTAatg2QWIUq+pis7baTZiMjbcwkfcdkdyAy
 8SJFtfEFVLR+g5pFWeVErgqD0yalSI8+c1PK8OfF5ETzFY1qWu5XfRWDWSejjFNNjfXr 8Q== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2tjk2u0e5t-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 14:27:15 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x6BEPcuJ021444;
	Thu, 11 Jul 2019 14:27:06 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com,
        alexandre.chartre@oracle.com
Subject: [RFC v2 26/26] KVM: x86/asi: Map KVM memslots and IO buses into KVM ASI
Date: Thu, 11 Jul 2019 16:25:38 +0200
Message-Id: <1562855138-19507-27-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907110162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Map KVM memslots and IO buses into KVM ASI. Mapping is checking on each
KVM ASI enter because they can change.

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kvm/x86.c       |   36 +++++++++++++++++++++++++++++++++++-
 include/linux/kvm_host.h |    2 ++
 2 files changed, 37 insertions(+), 1 deletions(-)

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 9458413..7c52827 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -7748,11 +7748,45 @@ void __kvm_request_immediate_exit(struct kvm_vcpu *vcpu)
 
 static void vcpu_isolation_enter(struct kvm_vcpu *vcpu)
 {
-	int err;
+	struct kvm *kvm = vcpu->kvm;
+	struct kvm_io_bus *bus;
+	int i, err;
 
 	if (!vcpu->asi)
 		return;
 
+	/*
+	 * Check memslots and buses mapping as they tend to change.
+	 */
+	for (i = 0; i < KVM_ADDRESS_SPACE_NUM; i++) {
+		if (vcpu->asi_memslots[i] == kvm->memslots[i])
+			continue;
+		pr_debug("remapping kvm memslots[%d]: %px -> %px\n",
+			 i, vcpu->asi_memslots[i], kvm->memslots[i]);
+		err = asi_remap(vcpu->asi, &vcpu->asi_memslots[i],
+				kvm->memslots[i], sizeof(struct kvm_memslots));
+		if (err) {
+			pr_debug("failed to map kvm memslots[%d]: error %d\n",
+				 i, err);
+		}
+	}
+
+
+	for (i = 0; i < KVM_NR_BUSES; i++) {
+		bus = kvm->buses[i];
+		if (bus == vcpu->asi_buses[i])
+			continue;
+		pr_debug("remapped kvm buses[%d]: %px -> %px\n",
+			 i, vcpu->asi_buses[i], bus);
+		err = asi_remap(vcpu->asi, &vcpu->asi_buses[i], bus,
+				sizeof(*bus) + bus->dev_count *
+				sizeof(struct kvm_io_range));
+		if (err) {
+			pr_debug("failed to map kvm buses[%d]: error %d\n",
+				 i, err);
+		}
+	}
+
 	err = asi_enter(vcpu->asi);
 	if (err)
 		pr_debug("KVM isolation failed: error %d\n", err);
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index 2a9d073..1f82de4 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -324,6 +324,8 @@ struct kvm_vcpu {
 
 #ifdef CONFIG_ADDRESS_SPACE_ISOLATION
 	struct asi *asi;
+	void *asi_memslots[KVM_ADDRESS_SPACE_NUM];
+	void *asi_buses[KVM_NR_BUSES];
 #endif
 };
 
-- 
1.7.1

