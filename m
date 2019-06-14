Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1069BC31E4A
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:12:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4CF921537
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:12:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="neN3kBOM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4CF921537
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 190D56B000C; Thu, 13 Jun 2019 20:12:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 141EC6B000D; Thu, 13 Jun 2019 20:12:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0308B6B000E; Thu, 13 Jun 2019 20:12:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id D6DD16B000C
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 20:12:06 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id f69so692960ywb.21
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:12:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding:dkim-signature;
        bh=2rNJ7DTMjMPhOlVosuT+dcn+kIR1ESSVOR99OmM6ZKM=;
        b=Nx2UBZ+Cr1RWmFMvLE00WdrujkXE8ewOsvLNoryKxFEJMujVOMCUS6K76ykn2HrO0a
         zj0DQhbLBt2YyDOFvoWeWlSxnzDHvcvG6xAQKvH6zX9k3vh/OweQReAfC1xYHTcCVvkL
         WUCHfWBkdWKAAqAae7eVO0NMxgAmeVDXkSHyek4EpZUZDtI8LPqyWro/eplnlyyBoTy2
         Viw08028wbufWAE5a4UXR+clR8y1Yazfc0hDH0RyWpjH0K1wLSm6eIRpnNvLRu61z9bU
         bNI0wVYs48+Joyn83GoN/MO82PnywwH+aI+zqGEfZV+dCedWREo3DlVICuX/t+qEJKui
         qHuQ==
X-Gm-Message-State: APjAAAXiM83dMAtPCQbdmElUnXQuZrCN9Uv3aE9KhBEMaG4xTd4CG/k4
	rKEqKJIIkHcKEV95UmSdjtep+wesc3rRDyTWez3kpiYfjhYe8bBybExV+F20zf1F3Hfxk6rGIiq
	3MHdVXRHxyZXAJo5iPWv3ysNk9hXr8ADV0DJgPo1Qka6BTnFLSaa0u2oJBfo5QWi1OA==
X-Received: by 2002:a81:6ad4:: with SMTP id f203mr36500958ywc.196.1560471126634;
        Thu, 13 Jun 2019 17:12:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjSLUb1EHFIRdKXMEGQn15wCxZzAwAAxPLyKNqkNboHMBsdlacO6bTHRdKvlv2D/G0quyJ
X-Received: by 2002:a81:6ad4:: with SMTP id f203mr36500939ywc.196.1560471126083;
        Thu, 13 Jun 2019 17:12:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560471126; cv=none;
        d=google.com; s=arc-20160816;
        b=De83H2ZbJk3AGPuikqFLciln5QFk5/mTlnMR6snhO0i/AmuwN+MeBLH0CqurDDGXBG
         FwQv5DM/dv02XiM6QWzaJ0+G7PvVRTJ07c0FyQBQgb21yUCbPQTq/ejMhqrV21NQ+4bV
         Gxi+OMkHLUF76k26GU1e/VH5MEdXMAGDLYYJLeHKaIqYZFUPZ3PxO2zNnYOaHtDoDPUo
         Vj0cRXF/mPaRtJ4RviDOeLNl8fByO9ES8bBWcj1aOFp2HNjZuaeH2sVJt2AJ9NiD2Rh9
         qtl3oMNrSJqA4KyWWwfGq8NYlJXGDReVFEpnOzfFAE3d3y79vFMK/GIAFy03tfRdB2Eu
         /1Qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:message-id
         :date:subject:cc:to:from;
        bh=2rNJ7DTMjMPhOlVosuT+dcn+kIR1ESSVOR99OmM6ZKM=;
        b=vsWuvkek2u0DyYg90RK+Fnl9+/xuaz+I1FZgOVE2Te5G9MR4TsT+YiHRAgISuedcnV
         T73FaqBZ8Ja7s39DFNwSW41+CfnLlpZN6YAVcqWYwkVn4DXeJpMM2hjv1pvXfPSfOvp+
         XB69rRzzNr3FNy8ammVrIaRqp870RZdWr2Qx6qy9aa6i9/G0OfnpjzdhmAkNCFbRDCxe
         mcae5M/u63Lni9mTbJBUdx0fMTTKkp1L9TGLO+mmNfKeiAkImhoNBBpZWtvIJq2moqt+
         Y2zQRo9//O4s3Jqsl7lLjq0F23lxcjrITxeRDd+sxBXArU1cAKI5o6VTBZaJ7+TXj7it
         CRZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=neN3kBOM;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id u125si492306ywa.200.2019.06.13.17.12.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 17:12:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=neN3kBOM;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d02e6550000>; Thu, 13 Jun 2019 17:12:05 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Thu, 13 Jun 2019 17:12:05 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Thu, 13 Jun 2019 17:12:05 -0700
Received: from HQMAIL111.nvidia.com (172.20.187.18) by HQMAIL108.nvidia.com
 (172.18.146.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 14 Jun
 2019 00:12:04 +0000
Received: from HQMAIL104.nvidia.com (172.18.146.11) by HQMAIL111.nvidia.com
 (172.20.187.18) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 14 Jun
 2019 00:12:00 +0000
Received: from hqnvemgw01.nvidia.com (172.20.150.20) by HQMAIL104.nvidia.com
 (172.18.146.11) with Microsoft SMTP Server (TLS) id 15.0.1473.3 via Frontend
 Transport; Fri, 14 Jun 2019 00:12:00 +0000
Received: from rcampbell-dev.nvidia.com (Not Verified[10.110.48.66]) by hqnvemgw01.nvidia.com with Trustwave SEG (v7,5,8,10121)
	id <B5d02e64f0000>; Thu, 13 Jun 2019 17:11:59 -0700
From: Ralph Campbell <rcampbell@nvidia.com>
To: Jerome Glisse <jglisse@redhat.com>, David Airlie <airlied@linux.ie>, "Ben
 Skeggs" <bskeggs@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>
CC: <nouveau@lists.freedesktop.org>, <linux-mm@kvack.org>,
	<dri-devel@lists.freedesktop.org>, <linux-kernel@vger.kernel.org>, "Ralph
 Campbell" <rcampbell@nvidia.com>
Subject: [PATCH] drm/nouveau/dmem: missing mutex_lock in error path
Date: Thu, 13 Jun 2019 17:11:21 -0700
Message-ID: <20190614001121.23950-1-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1560471125; bh=2rNJ7DTMjMPhOlVosuT+dcn+kIR1ESSVOR99OmM6ZKM=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-NVConfidentiality:Content-Transfer-Encoding:
	 Content-Type;
	b=neN3kBOM4fwFzxxjmxWL1ltp+tFO8bAcbqFK/NkF6ljwaGDjCyCUNjyfFcYeKG9T4
	 5LdGR7QCJzezPlMCmrdKYb1uNBS/iIAEnpK1hMJVC4YlXEsNnr9L2qFHaYil+aBIyJ
	 60wMyDHM5XN/zwZxTsCkESQujXLaoeWvhG5kKgnBZubuDk3cxpKMsqfWLQComwBkgO
	 y8MOe90H/Rqb7zeWBsQG5hqIu9N7CqlNp/FIgtnz3xiNXN0ispWt/+exKroPpJ9wCJ
	 Pz57q/vucsb+GtG/qX1XENQ8dZu+F/CYr0G+CV/G3g2ekKciae45Ha0N3zk6j+9N+U
	 gbTCIFIddddug==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In nouveau_dmem_pages_alloc(), the drm->dmem->mutex is unlocked before
calling nouveau_dmem_chunk_alloc().
Reacquire the lock before continuing to the next page.

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
---

I found this while testing Jason Gunthorpe's hmm tree but this is
independant of those changes. I guess it could go through
David Airlie's tree for nouveau or Jason's tree.

 drivers/gpu/drm/nouveau/nouveau_dmem.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouve=
au/nouveau_dmem.c
index 27aa4e72abe9..00f7236af1b9 100644
--- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
+++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
@@ -379,9 +379,10 @@ nouveau_dmem_pages_alloc(struct nouveau_drm *drm,
 			ret =3D nouveau_dmem_chunk_alloc(drm);
 			if (ret) {
 				if (c)
-					break;
+					return 0;
 				return ret;
 			}
+			mutex_lock(&drm->dmem->mutex);
 			continue;
 		}
=20
--=20
2.20.1

