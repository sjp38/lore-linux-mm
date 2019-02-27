Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78CA6C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 20:52:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36886217F5
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 20:52:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="I6JQ/yot"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36886217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8148A8E0004; Wed, 27 Feb 2019 15:52:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C4BF8E0001; Wed, 27 Feb 2019 15:52:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B30A8E0004; Wed, 27 Feb 2019 15:52:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 484E08E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 15:52:51 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id o34so16564841qtf.19
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:52:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=Pqif0CrV1iUCG/KA2vWPDRwvp9OJTIFlQ54VsyglFrA=;
        b=NsYp3j7rsoPISn6QebF9o9ecycqz4gegNAeSbItqHb3QfJF0hVQ+/+5R7W+fBQv/Od
         inQCfmkOrekhU4xjPmJ4bMvrDhV1oJjR1vuaqtq22+YFuaNuZd/KAuOQUGyONa1hB25T
         lM+msetKKh06Gwt5yvdEkWQ7G9SgmQBv5bGrygX7eW3Z5lL34pSqatQPDDyPsSz1ptLX
         4IJYes5KnJ4ym1tDbIDyAobOydXqqeAew6Ul/GreCrkDJtxGP3voiAFIXqS+VZTxGP8S
         l+poV6gQtBGfUVxYdn4un9QEhY9ASdT1txI1oXqL2EtLXs97g4slMPyD9l5JwrZlJAMw
         wFFQ==
X-Gm-Message-State: APjAAAWEQwgfx2rxLzIOs8Mgm1mZQABjGZotuSGt5LdCmn7QPPTnTcqV
	uMAUR7J2Y/oZ8bGVbrHFMFOZg2axYKpfdPOtKORKfhslexDA/XXozYPv44Ze9nO/fWOAAiTMcXe
	sIux2gq23ICk4MlGQbpSFfEhwsCxIvn0P36Y/IFRhw6rINCrSxOGxvcWLGyvd8gGt/gVGCL6B4Y
	HFPDoHaibxtlHHOACEQpU8i+cgLHgR8bASBiaXxUe4PoI65SVzIj+RxUBX3HFgJSsZOaLg6FISO
	5JDJ6deWXgGyZ/A+f59g41PxLZcm5/g2++x7EHHkEXCiC3PuslSnzTDEcIQIUYuWEtbXg1fgCua
	xyzge5N35ZkRvYAr2Yx+DxSehWNLFcnlv+EwFqXrNKxRXxEiRBDWEOS+ZP6O+lsn21mLysPJ2o0
	M
X-Received: by 2002:a0c:8874:: with SMTP id 49mr3598462qvm.138.1551300771029;
        Wed, 27 Feb 2019 12:52:51 -0800 (PST)
X-Received: by 2002:a0c:8874:: with SMTP id 49mr3598429qvm.138.1551300770355;
        Wed, 27 Feb 2019 12:52:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551300770; cv=none;
        d=google.com; s=arc-20160816;
        b=QxkySrq4odFmOEGTUurAx8b164rHBek2UcmCtK71524bvd5wWzNSaEYCM8ob+yIVFw
         JNOSCA4lxPfaC0aN2dEzJlxLHdXd8U6IfNVGLiSpT3f9cVi9znD1K9iHyMUuFVI2PJGZ
         nkmXqgBdriUzz8BWd5fuiGZxlIAIO/GwVyURgJ/2BMQACiLy3AW3VoiCRonNuOdlSIw9
         hqNQyAUSgQvy4WyHXJemwSbmro/eEFQeakMYQTPxiLn+GzbTsz4GZE54A6HOPPQWEWRv
         8IPP0nS+MOBRJkSUiNoSmRe6EQQNf3lXBl1q1DwSdciP0YebcwREUJichZ5+VnHAzxPD
         ROIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=Pqif0CrV1iUCG/KA2vWPDRwvp9OJTIFlQ54VsyglFrA=;
        b=mOaxUA42u6PaQfDXU+zZgfDHBI06l98FfeXBpu6h0m6B//3IpvOAWcIBkVC6EHI/Z5
         ogPVVyqtBWyINzQGTC/8xVGlnz3BsfgFfwI94GEi9ODjvm1nzUk3KvSBHiEBMhQN8jOi
         tcXJnljFTyLmdXxYi/HPL8jHHg3YlgNPV4gJ721oyji3fv9WJhF0fR/bdSV/Oo3Ue+Nh
         s8SBsKFl36zEEi3nNuaG5hRPUJs72gh4SdwUQvpU4TSjvTYbLV/5yPINfJTkBGlSgFML
         chPQ83TakG8G7JnO2YkDTg6CJ9Zvw4SuHLnHB9oUMVEEt8pUC0aAJYBaCP/qHpr5EJYy
         F9og==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="I6JQ/yot";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i12sor10400744qkm.105.2019.02.27.12.52.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 12:52:50 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="I6JQ/yot";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=Pqif0CrV1iUCG/KA2vWPDRwvp9OJTIFlQ54VsyglFrA=;
        b=I6JQ/yotuISU27iCbP/uRP3BXZAQTkjhUR8mLvqgVXslpFqQXt7qTFRGq59Q4nhyR+
         N4zyfRHkeZxbfUuUCjOCQUrAl+8S3gcZi4SHSM/Vwq242ev6SMYWQooULcmqx4kknsq0
         zzPv1kWgZKXquriQC1JvPAOivaQeiCCR478M+JtAHgWv5zvbRFTNCaCvW8ei4XQBJRzn
         mSaxEThp0/UAwIXc8kiQ5p2ubj9UN6nKb79wUdtsByzN5+bE1lhhdNoVnY2LKRTwB2pe
         ysup6SCRVBW9W/RaToCsKq4EdOUU16VzmsE/lBmU259HjOJKhaBqftWmm/LuYNCoT8KG
         9DsQ==
X-Google-Smtp-Source: APXvYqzYA320jkBa30rVZ8/Hy5ED0MteiZaFxbekgU5Qe61z837GoDl3ta9VgsPAWBqNcKkBww7QDg==
X-Received: by 2002:a37:491:: with SMTP id 139mr3775133qke.345.1551300770136;
        Wed, 27 Feb 2019 12:52:50 -0800 (PST)
Received: from Qians-MBP.fios-router.home (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id z190sm9073932qkb.9.2019.02.27.12.52.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 12:52:49 -0800 (PST)
From: Qian Cai <cai@lca.pw>
To: hannes@cmpxchg.org,
	mhocko@kernel.org,
	vdavydov.dev@gmail.com
Cc: cgroups@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] memcg: fix a bad line
Date: Wed, 27 Feb 2019 15:52:42 -0500
Message-Id: <20190227205242.77355-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000025, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Miss a star.

Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index af7f18b32389..d4b96dc4bd8a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5747,7 +5747,7 @@ struct cgroup_subsys memory_cgrp_subsys = {
  *
  *             | memory.current, if memory.current < memory.low
  * low_usage = |
-	       | 0, otherwise.
+ *	       | 0, otherwise.
  *
  *
  * Such definition of the effective memory.low provides the expected
-- 
2.17.2 (Apple Git-113)

