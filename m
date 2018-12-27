Return-Path: <SRS0=02aR=PE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50657C43387
	for <linux-mm@archiver.kernel.org>; Thu, 27 Dec 2018 23:24:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3DB521741
	for <linux-mm@archiver.kernel.org>; Thu, 27 Dec 2018 23:24:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ICXCGPvi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3DB521741
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BECAA8E0022; Thu, 27 Dec 2018 18:24:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9B3F8E0001; Thu, 27 Dec 2018 18:24:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A8AB68E0022; Thu, 27 Dec 2018 18:24:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0048E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 18:24:04 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id r145so25222516qke.20
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 15:24:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=/EPudTNTCq6A/FDFSmKHo8KDd0/qXZYQkhOO70XqdFY=;
        b=Oh/s6B6Pne67oQM4BO4H3E2/gdyEM4vvDaQUZCBydjxmG+Wg6aoQcvM7vq3eqEyOIF
         QkBJl1OUD9R8VnNQiFdRFdv12mE5xWJ9sJwS86eIFWfKrMLzrxxgh2mfTHdKnBpUE9R6
         EQFhIYxRdFbmOgv8WztP7e5UJyPxmPGhii52xVZJ8aP+23ousWrImNgmTdHVDR93sYFQ
         eVdgi1aqFgCJIeknikhAx6Hsf9jESh33iiuJSU08W36Y64YHa97P+tlxIbZMX5K1dBlc
         vuoLOW0Fy1vMDrPbp5N8S9rLq+UNy0OAZN+NmyeyNYa7uY9I7c2lbZagdLXAr5YvesEz
         aewA==
X-Gm-Message-State: AJcUukcPH+kSwU3CSdiTlmvH2L8q/uPMZdDKO3daOQngcOJ9rL1ABD2I
	lRHraV49WFiPTHEOWne5P+d26UAwc6h04Bp5scwYYUO9M3hh2k+BNOE9ZAKCOlJ0JPyPqYRvOXP
	VTkiOgg/ejlXyo0bRMCesLnn1QsqcNFUChr8I40Pk7Jx47EdHpncAOJah6fff+q99FfC+hoA5Uv
	MOQcgvMUlnu9rJ40KAIOv4arsJiEeuaNZYkOOgnz3p0eRZ2kxD/sDM6pB3L2fo9M/1xspv4DPyr
	kH8RYcQVlCZZS92xZXs3ub5iIEFm/c4rm39ky89PIebuahIgpiv37joSuYN5VGhCGsB0QpcMBWQ
	Gf+rGTWnq+i/h5R6SGFkwOggjfg9AaFgJhjo0Na0astmNtrUFV4Nhlf6ZcZVgHnDz4zrkYZgeGE
	H
X-Received: by 2002:a37:5f82:: with SMTP id t124mr22989760qkb.204.1545953044205;
        Thu, 27 Dec 2018 15:24:04 -0800 (PST)
X-Received: by 2002:a37:5f82:: with SMTP id t124mr22989744qkb.204.1545953043649;
        Thu, 27 Dec 2018 15:24:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545953043; cv=none;
        d=google.com; s=arc-20160816;
        b=lJS0ANaRe/HXVTDWgX3veNYnFssEJhW8sHTGlu+lFLn2zYktfG2P7ldb/+K54z+RDn
         THqMu4RClKalAi9+M6nAQNXoAjAKJhs2wx7G6Jze1r2jqi4cdwaNIKG74Wdije7kCOOD
         PdCEJNhrdJMBLGaK1M0w0vADzCviXKCXn64PcH76E9vJeNW4yWsa6wCqyPV+XX5K73UT
         UsFvOsFhwTHFUNVrDTeR2Tz1xxK7LgxPBsBRSZDyaqAcXxVy3DIqA2uK/hO1+RxbsW+v
         46TgkHeXJMSkPZRQeYA5GktS8oq+5FE6DnDjO0sbcfNRU8dzmyub5kz9iyHRSOAJTfjx
         U7CA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=/EPudTNTCq6A/FDFSmKHo8KDd0/qXZYQkhOO70XqdFY=;
        b=hNmG13HrJR5YZvAwFAFp8g+lvAxy2VRcR17h7/WrxEQis22SLAjov9Xl0C6e7N3u4D
         V/zRaJuT0MYVQDaPL+xLGe3Yh5uGLp9ZU1Qj5BXpXRIKdolocIiMZMaeAMvPf9wlfwJM
         0NMQ2CsrrdwKJTLsNU4udNiqB1QRwv1xWKVPSFUb3WyGybEKHbYsF3gS3bjCbdy53Xwf
         W+No7gxpJ4KTt/Pl0u/d4rs492EJ5QYqZbjOzh4aBvDonE748m1yfw50nauXp7/jUFFt
         P/Ddr4a8S3olJ6QIEM7iAjwj0+jn2iJWCSJFmhAvTxI5SCaklbdrJ6NR3phdDiJ1/oSJ
         tlHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ICXCGPvi;
       spf=pass (google.com: domain of 3e18lxagkce40885yu78w44w1u.s421y3ad-220bqs0.47w@flex--ksspiers.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3E18lXAgKCE40885yu78w44w1u.s421y3AD-220Bqs0.47w@flex--ksspiers.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id c16sor29844652qtq.58.2018.12.27.15.24.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Dec 2018 15:24:03 -0800 (PST)
Received-SPF: pass (google.com: domain of 3e18lxagkce40885yu78w44w1u.s421y3ad-220bqs0.47w@flex--ksspiers.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ICXCGPvi;
       spf=pass (google.com: domain of 3e18lxagkce40885yu78w44w1u.s421y3ad-220bqs0.47w@flex--ksspiers.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3E18lXAgKCE40885yu78w44w1u.s421y3AD-220Bqs0.47w@flex--ksspiers.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=/EPudTNTCq6A/FDFSmKHo8KDd0/qXZYQkhOO70XqdFY=;
        b=ICXCGPvizN+YIcmS6sKJFNWk8na/m9i3Rq+r7Bq2yRFPRzfnA5NCZ+jvToLfPu9cBT
         DxW6HlXi1aPAHETpDgifwyd7gcKgN60HKjPTA0lTy97bcC8lDcuQMgmv2MohL6JDMNE4
         BHDtsUyC0pFyFQP45HInBC4kd88R94sJc1g4DYK3ypcNY24jjrULXzft7KgIBY6X9jKp
         UT3NbAjf+5VEa6jTvbvmyEYVd10+CVAue1WM+nb8VPC2L4GUPnfY158yaHg59lrIpEFr
         XAvXku8YhWYesYFlojgnabaCeKutP1MmWy/9GzA3/IK9UJViZoZ/9Os7ygMN3ImFakFi
         E6zA==
X-Google-Smtp-Source: AFSGD/U7619okJT/MmqRvvy/VsDXoCm1OtFCLvuLwoIolPSFkuNW6cmjTJF5K4EdrQZPuAtKtPrhCU7Rrldw5Q==
X-Received: by 2002:aed:22cb:: with SMTP id q11mr18964903qtc.31.1545953043487;
 Thu, 27 Dec 2018 15:24:03 -0800 (PST)
Date: Thu, 27 Dec 2018 15:23:54 -0800
Message-Id: <20181227232354.64562-1-ksspiers@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.20.1.415.g653613c723-goog
Subject: [PATCH] include/linux/gfp.h: fix typo
From: Kyle Spiers <ksspiers@google.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Kyle Spiers <ksspiers@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.010889, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181227232354.AfNCV_m3KJsWO_NwBCzthtJoCISiLpAR8r0gcbPUjy8@z>

Fix misspelled "satisfied"

Signed-off-by: Kyle Spiers <ksspiers@google.com>
---
 include/linux/gfp.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 0705164f928c..5f5e25fd6149 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -81,7 +81,7 @@ struct vm_area_struct;
  *
  * %__GFP_HARDWALL enforces the cpuset memory allocation policy.
  *
- * %__GFP_THISNODE forces the allocation to be satisified from the requested
+ * %__GFP_THISNODE forces the allocation to be satisfied from the requested
  * node with no fallbacks or placement policy enforcements.
  *
  * %__GFP_ACCOUNT causes the allocation to be accounted to kmemcg.
-- 
2.20.1.415.g653613c723-goog


