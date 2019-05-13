Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23CA5C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D25072084A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 14:39:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="MqxRlocD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D25072084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7CEF6B0010; Mon, 13 May 2019 10:39:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D06A86B0266; Mon, 13 May 2019 10:39:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B81FF6B0269; Mon, 13 May 2019 10:39:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7BEC16B0010
	for <linux-mm@kvack.org>; Mon, 13 May 2019 10:39:16 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id g63so12279408ita.6
        for <linux-mm@kvack.org>; Mon, 13 May 2019 07:39:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=BckiUE2qwd6ce7s4e94ZCEH08ViWVb2Uhow4MmaOmmg=;
        b=cCW7EJyyyiEMkzyWSb5Y9qMt4w+4+WGLbAoqk2HAf5Ny5u3KR3sLUEy+hm2G65mprQ
         2aKBozA85jNAcexthHymh7Sm4jsm6YcDh2lZiyBtsMvkT1maGmZ/svtepFt5DsRh0qBA
         Un5l2jME6f/4a1pNHZMH43nL20ZO4zn/mabBKOzTgT5VTbj18GBoqzHLQkXItsLYag70
         ON0DSpC+lfUy4LMrr99IlRQSAWzjZNC8alVcJmzSi7K+qSAD/YFxdBzLObJPiaR340ad
         PniEpPAPVM1O9dlwr1PrN9/HR39Z1X7KahyH0es7mmnGN4+Gro9k8hBc1zGDsDUMprG0
         zgMQ==
X-Gm-Message-State: APjAAAW10c8o4bYlmpSFngQQTTkri50/teT1UXZYn2vfrZxQQqEiqiKe
	JW9SoyFSsREaiWQyxoDCfLeJO0wmrYBGGX2Ih52n4XBudUn0h2A7yY76eSBjeLVwhwyaMsIJhME
	owYBIeaEOidpXUfPRQiNfgt/kwO6zqz19UTtCYh50JnEecproC/uDQNQGlyNPaHO8AQ==
X-Received: by 2002:a24:1f50:: with SMTP id d77mr17645435itd.25.1557758356238;
        Mon, 13 May 2019 07:39:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqfgMm/81O7+/n8LVlwszWYEPY/hPItHtexhaRLbnP4Da9OGzrHkgkp2B2zoqudlVVXDVf
X-Received: by 2002:a24:1f50:: with SMTP id d77mr17645396itd.25.1557758355606;
        Mon, 13 May 2019 07:39:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557758355; cv=none;
        d=google.com; s=arc-20160816;
        b=NRrpcRnuidmR/nzXWJ0ow3NhscjF84FrGBa58Pri/POz0cSnEkV34dSfKBFDyGHJ6w
         fd6g9cMSIKPkDkbeiNvFv65vskcZcurfp2DL9SwEAp2/ZF+eA7HvrwhYcrXvuseEnY4S
         MXaLiWL7G3hdXAgXj/32Mxyx3R0/D/vOMjOoECPguOgP1Jus3iaal6H9Jcbu0vKm4wAD
         JPjyFtj2+h7yW669S2PMcY68BrarvcOh0TbOq9n3S5KxW1onLfCYYBnKAgv8j20wzD6F
         uNgKEZV3L5u9hYQOyJLaxcNpl4WxI70ip1KNtuIrWqdGr61ey2SD2UMNHjhFxBQ72bBF
         OjEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=BckiUE2qwd6ce7s4e94ZCEH08ViWVb2Uhow4MmaOmmg=;
        b=y8OGPgDjh+kmlJ7bTzQGxxO7ygD+R/SvEtUATuB1Jo+5qedHUhQeY7pxIFu0mshAeN
         d9C5BZPxzFGenkRTwPKirEGlxHwnRj2q39w+MMk7+O9TfBCfknNm/pWVND1/6FhkTssG
         hf4PbeUwr11aEdr1nILxNvDjQ5/VNoikxFLkjTnBg+Ss8Ckog7iyNTuX6evafOxLNP78
         2TYDSBx6zoEYFh18s4xvcAO5rjrvMhjuaraNlUdtcteqFZI7rqgvGUuHxgdcBqCmOlvK
         FQcT/K4jRTjIuT0mhCTUEqjAhu7RlRBnUj1SAjoFeSyEGKryNqKsi+q32dPWcogc9V2j
         e2Yg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=MqxRlocD;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id a7si8602214jap.6.2019.05.13.07.39.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 07:39:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=MqxRlocD;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DEd2YY194903;
	Mon, 13 May 2019 14:39:05 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=BckiUE2qwd6ce7s4e94ZCEH08ViWVb2Uhow4MmaOmmg=;
 b=MqxRlocDO4PBVSKI4njGqiBJNQ3Dwy7bXoxOg336yVqnxDPoOo4C8bDcoA+hRinUelY/
 IfBGNpsi5hC0VByASVpiWMEgObQsMVJz2ebCqcSbAU7+bP+dXw4f4OP72FR/CyrWZMzm
 C5l9JlMKOqhD3L7yBz6qxyBISnDBFSOI418qbfcikgzUXjTPisA4nha1WqGfH00pB+fR
 MAPL3suB/BEgJ7y+NOdtYN4R08kIlmFj7UCcos/Hh23ufmYdF9aqYoILoddmclvElloo
 MtVyLdQhfuOp3oe6RJY+QcC2ZMynhm3bA4JOkdVlLXIFA7MOvRKhnhe+hFi0uBip4m9o lw== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2sdq1q7aum-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 14:39:05 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x4DEcZQB022780;
	Mon, 13 May 2019 14:39:02 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, alexandre.chartre@oracle.com
Subject: [RFC KVM 08/27] KVM: x86: Optimize branches which checks if address space isolation enabled
Date: Mon, 13 May 2019 16:38:16 +0200
Message-Id: <1557758315-12667-9-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9255 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130103
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Liran Alon <liran.alon@oracle.com>

As every entry to guest checks if should switch from host_mm to kvm_mm,
these branches is at very hot path. Optimize them by using
static_branch.

Signed-off-by: Liran Alon <liran.alon@oracle.com>
Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 arch/x86/kvm/isolation.c |   11 ++++++++---
 arch/x86/kvm/isolation.h |    7 +++++++
 2 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/arch/x86/kvm/isolation.c b/arch/x86/kvm/isolation.c
index eeb60c4..43fd924 100644
--- a/arch/x86/kvm/isolation.c
+++ b/arch/x86/kvm/isolation.c
@@ -23,6 +23,9 @@ struct mm_struct kvm_mm = {
 	.mmlist			= LIST_HEAD_INIT(kvm_mm.mmlist),
 };
 
+DEFINE_STATIC_KEY_FALSE(kvm_isolation_enabled);
+EXPORT_SYMBOL(kvm_isolation_enabled);
+
 /*
  * When set to true, KVM #VMExit handlers run in isolated address space
  * which maps only KVM required code and per-VM information instead of
@@ -118,15 +121,17 @@ int kvm_isolation_init(void)
 
 	kvm_isolation_set_handlers();
 	pr_info("KVM: x86: Running with isolated address space\n");
+	static_branch_enable(&kvm_isolation_enabled);
 
 	return 0;
 }
 
 void kvm_isolation_uninit(void)
 {
-	if (!address_space_isolation)
+	if (!kvm_isolation())
 		return;
 
+	static_branch_disable(&kvm_isolation_enabled);
 	kvm_isolation_clear_handlers();
 	kvm_isolation_uninit_mm();
 	pr_info("KVM: x86: End of isolated address space\n");
@@ -140,7 +145,7 @@ void kvm_may_access_sensitive_data(struct kvm_vcpu *vcpu)
 
 void kvm_isolation_enter(void)
 {
-	if (address_space_isolation) {
+	if (kvm_isolation()) {
 		/*
 		 * Switches to kvm_mm should happen from vCPU thread,
 		 * which should not be a kernel thread with no mm
@@ -152,7 +157,7 @@ void kvm_isolation_enter(void)
 
 void kvm_isolation_exit(void)
 {
-	if (address_space_isolation) {
+	if (kvm_isolation()) {
 		/* TODO: Kick sibling hyperthread before switch to host mm */
 		/* TODO: switch back to original mm */
 	}
diff --git a/arch/x86/kvm/isolation.h b/arch/x86/kvm/isolation.h
index 1290d32..aa5e979 100644
--- a/arch/x86/kvm/isolation.h
+++ b/arch/x86/kvm/isolation.h
@@ -4,6 +4,13 @@
 
 #include <linux/kvm_host.h>
 
+DECLARE_STATIC_KEY_FALSE(kvm_isolation_enabled);
+
+static inline bool kvm_isolation(void)
+{
+	return static_branch_likely(&kvm_isolation_enabled);
+}
+
 extern int kvm_isolation_init(void);
 extern void kvm_isolation_uninit(void);
 extern void kvm_isolation_enter(void);
-- 
1.7.1

