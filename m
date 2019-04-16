Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42628C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:47:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03DDF21741
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:47:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DRbSr4JY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03DDF21741
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 97EE16B026E; Tue, 16 Apr 2019 07:47:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92E4B6B026F; Tue, 16 Apr 2019 07:47:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F5986B0270; Tue, 16 Apr 2019 07:47:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 48A686B026E
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:47:25 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id p13so13210913pll.20
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 04:47:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=wsI5nOykFSX6S7SyN92+LRaxG3yXSZXxVHkiaYJTa/M=;
        b=dTck56ggnlkMxtVfqk4od8uXGzRV7M9sTUFhx5xIyHf/uRrJq/IJVrNv3Xc7p1XXmC
         ptjYRGD1vjkwoT5y3gTtkk+EdnHx34/mVFueP64yaB42pqTgGmpHlL+Q2Wxu/0tQiHDL
         ufVRmheM+AZiNo2IeTXkwYoBtCvgIKyc2p+z+c86YDDF4LH0cwfxwXsEkY8ziwo2TKpY
         PuOFZpRmStUPd0fth3JLyes1ip53ihO/2j0ZnhgrgTzjTaI2bUPYkaOki+l33w5ah3PH
         l2wr/j5RSqwoAWa790BP464S5t/VC293fDTNkwZ3QIZLpJzRGWyPlZ116RFMuDkiuwyk
         PevA==
X-Gm-Message-State: APjAAAWSRRy0tVnB8ywWDKRA+8fEeQ5sDCiMglu0VWo3eqWLiTGenArW
	xM7zQIQ80IbShe3QwHTaBBlS6utj4BlImCpbcDCiGtt13xidhWEVuVkWXIRGz1EPvnbyN264UFs
	pzN8ITdq53ipdTH30dRoRKAq1OETh4bfU03BLnHYi2F8UuGKon7QZJtPqVm3Phn+pfA==
X-Received: by 2002:a63:3857:: with SMTP id h23mr74257328pgn.305.1555415244934;
        Tue, 16 Apr 2019 04:47:24 -0700 (PDT)
X-Received: by 2002:a63:3857:: with SMTP id h23mr74257284pgn.305.1555415244308;
        Tue, 16 Apr 2019 04:47:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555415244; cv=none;
        d=google.com; s=arc-20160816;
        b=A6TTcGswEKO0ke7bzVinb5uqsi46VIrmoNnJsqewxIRZtRNMgoX00GOhebk3MD80/z
         090OJ299dYGtYRc8bj0rh+Ik7SFIVGrhm3aJPN13qKLhBPkQ1z6qWFL1P1EEebK2ey9/
         1y5MTnET/G/5OQdb2kbSo39wAPqXOXDQcySezpJmIDVl9lQ36F3cHAiXj4GpLiYRKFVK
         SJfmiqaJHmCFoeO9F9Wq/UMIZInfoV0NLWEbzqqxSp7UqbzyCZUg3nnWHrbVqDWMh0Vr
         RTdQp0CS3z8knaYKoCQi6Jls2Ap/iFQJtcxWVGSm62LjQhUpbyylpw7r3B1SC9tBXh9U
         Yr1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=wsI5nOykFSX6S7SyN92+LRaxG3yXSZXxVHkiaYJTa/M=;
        b=p60S0YAwS40+l9xZgHDAzCi857WLafqcUjSpyhwpLkZbNOxTQxFOztdOy7MgwCmO09
         melcO86jFgWrzJzPeyLbfeexymu+/iGxwPl+qbI2PKVB7vodKwpkxlZcJSTM3kBsaUXA
         ZMv5caHY8NlmpjsPn290xZhwj7aK+esSEp1wnOjVbTDE6Eg8EoOrOxyyV8cQK7RO45sa
         Tvx9A3enBi8SgD9o9kXLHjEL2fRzSPL0HEmj5UnghbEImYN5Ol6Tet8V4eLlEMBzlLAK
         0oRWp8xLTkzz7yiaMj0VcRh/KFXIMubPYUdQk/xSRMC10KqCktl6W0pH1glvHBiAtrjz
         uXFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DRbSr4JY;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id bj5sor67616320plb.25.2019.04.16.04.47.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 04:47:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DRbSr4JY;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :in-reply-to:references;
        bh=wsI5nOykFSX6S7SyN92+LRaxG3yXSZXxVHkiaYJTa/M=;
        b=DRbSr4JYhMaKQ5p3pSrZNdJX2v94ShwHCZj4JAJ277tZ1wQsiIQl2m3vs4+ZyECEeS
         ypZFAEQ/iRhrJ4cy8tjSf8TINaI7KNT+bZBUhPA2nIMoy+GPcnOzX727oWD/PJNtlrh+
         HyaY9/HNlgDRuGW7rwokX24bptqOXuI9I8zNMxdpFUbLTeIv3TSNs3SkFfabWtME2qqp
         T/IiDWs5sO90ha1GY7nB5d4PNLg62FUtdtcVR8CmHWcINbDhMOvDh/r39YDnRTWFwcPF
         G5IZMu2jRg+rHhl3BtSMwVjwJinoSfvFQCvL2mrSSRqW5pkek6voVHHXMb94dmQpbOpR
         vYSQ==
X-Google-Smtp-Source: APXvYqwD0xz7vCOqB5SDlSiBwryde6J7jA8KbAOcQ8+b3Q+tiiDDskcFLBFNGuxSXVMUW6Tz86k9Zg==
X-Received: by 2002:a17:902:e382:: with SMTP id ch2mr79568490plb.94.1555415244031;
        Tue, 16 Apr 2019 04:47:24 -0700 (PDT)
Received: from jordon-HP-15-Notebook-PC.domain.name ([49.207.50.11])
        by smtp.gmail.com with ESMTPSA id p6sm55942835pfd.122.2019.04.16.04.47.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 16 Apr 2019 04:47:23 -0700 (PDT)
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org,
	willy@infradead.org,
	mhocko@suse.com,
	kirill.shutemov@linux.intel.com,
	vbabka@suse.cz,
	riel@surriel.com,
	sfr@canb.auug.org.au,
	rppt@linux.vnet.ibm.com,
	peterz@infradead.org,
	linux@armlinux.org.uk,
	robin.murphy@arm.com,
	iamjoonsoo.kim@lge.com,
	treding@nvidia.com,
	keescook@chromium.org,
	m.szyprowski@samsung.com,
	stefanr@s5r6.in-berlin.de,
	hjc@rock-chips.com,
	heiko@sntech.de,
	airlied@linux.ie,
	oleksandr_andrushchenko@epam.com,
	joro@8bytes.org,
	pawel@osciak.com,
	kyungmin.park@samsung.com,
	mchehab@kernel.org,
	boris.ostrovsky@oracle.com,
	jgross@suse.com
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux1394-devel@lists.sourceforge.net,
	dri-devel@lists.freedesktop.org,
	linux-rockchip@lists.infradead.org,
	xen-devel@lists.xen.org,
	iommu@lists.linux-foundation.org,
	linux-media@vger.kernel.org,
	Souptick Joarder <jrdr.linux@gmail.com>
Subject: [REBASE PATCH v5 5/9] drm/xen/xen_drm_front_gem.c: Convert to use vm_map_pages()
Date: Tue, 16 Apr 2019 17:19:46 +0530
Message-Id:
 <ff8e10ba778d79419c66ee8215bccf01560540fd.1552921225.git.jrdr.linux@gmail.com>
X-Mailer: git-send-email 1.9.1
In-Reply-To: <cover.1552921225.git.jrdr.linux@gmail.com>
References: <cover.1552921225.git.jrdr.linux@gmail.com>
In-Reply-To: <cover.1552921225.git.jrdr.linux@gmail.com>
References: <cover.1552921225.git.jrdr.linux@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190416114946.84KMQCd65k2W6BkzEPYlaNcxZrwwmAnHdq9XoIZtraU@z>

Convert to use vm_map_pages() to map range of kernel
memory to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Oleksandr Andrushchenko <oleksandr_andrushchenko@epam.com>
---
 drivers/gpu/drm/xen/xen_drm_front_gem.c | 18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git a/drivers/gpu/drm/xen/xen_drm_front_gem.c b/drivers/gpu/drm/xen/xen_drm_front_gem.c
index 28bc501..dd0602d 100644
--- a/drivers/gpu/drm/xen/xen_drm_front_gem.c
+++ b/drivers/gpu/drm/xen/xen_drm_front_gem.c
@@ -224,8 +224,7 @@ struct drm_gem_object *
 static int gem_mmap_obj(struct xen_gem_object *xen_obj,
 			struct vm_area_struct *vma)
 {
-	unsigned long addr = vma->vm_start;
-	int i;
+	int ret;
 
 	/*
 	 * clear the VM_PFNMAP flag that was set by drm_gem_mmap(), and set the
@@ -246,18 +245,11 @@ static int gem_mmap_obj(struct xen_gem_object *xen_obj,
 	 * FIXME: as we insert all the pages now then no .fault handler must
 	 * be called, so don't provide one
 	 */
-	for (i = 0; i < xen_obj->num_pages; i++) {
-		int ret;
-
-		ret = vm_insert_page(vma, addr, xen_obj->pages[i]);
-		if (ret < 0) {
-			DRM_ERROR("Failed to insert pages into vma: %d\n", ret);
-			return ret;
-		}
+	ret = vm_map_pages(vma, xen_obj->pages, xen_obj->num_pages);
+	if (ret < 0)
+		DRM_ERROR("Failed to map pages into vma: %d\n", ret);
 
-		addr += PAGE_SIZE;
-	}
-	return 0;
+	return ret;
 }
 
 int xen_drm_front_gem_mmap(struct file *filp, struct vm_area_struct *vma)
-- 
1.9.1

