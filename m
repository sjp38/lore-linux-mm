Return-Path: <SRS0=oA8h=PB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46553C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 13:21:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F036321850
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 13:20:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CUnAh/Rq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F036321850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9411A8E0007; Mon, 24 Dec 2018 08:20:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C7D48E0001; Mon, 24 Dec 2018 08:20:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76A6E8E0007; Mon, 24 Dec 2018 08:20:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2FC6D8E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 08:20:59 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id v2so9921982plg.6
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 05:20:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=YwqNkUNPLYdK07Ra2/mSQ+jZoA95B8gqjnUO/EioucE=;
        b=GnxkUDCIlwXqpumvz+CfY+E2zSS1N59QevbKBf2LVD+8G+AbY8029DopF/hmKARtrs
         R32Zwp3WnWXVta2nkRDg+wvdfmad+6sFnh2VRZlNxRWmxHXL0McQhUhHRFEvpU+831AQ
         D40jl8geqNHI7h5ayw6x/22xhocrbppCARHAmPd+69Xw5cRb9jGQ9ZZttc69vtJATAM7
         1OeFSz8bQIX9XncNhmfR4WHq/NAUdXZNR22ofw6ygDhTKtCqUxBjCPeml496mzjoQzOk
         J1m75WkHDEu3zNHJJvh6vhmiv6vR80TIuS7q2FgiQamLWpGwndp3ZyOAwhQOasYXsky1
         oR6Q==
X-Gm-Message-State: AJcUukefgtw/nmmCzuuKZK69QsfZPW6QDWCehmDN4B8pvaH8GjznUgAd
	KDL0qVgsZqffTxtJluFUNGPKjENaw4TH3ezqFS2grgXJPgxyK568rNphXCG6Y/QlNceSgOXgP7W
	3VWICafGVskIzRv8oK6EGmFy7beKaRHe6uZA8GA4+6oxnoHHrtOTOzur/Vp4ZjzAyQVDTXig6nR
	dYPuAe7D8ataKTNyx8C7s1JGKN208sgQ1fH0BL4QjB3FWvAbTc19XjHeowhZp6lJiSxkn2mLe34
	Yk46WIYMXXXcQSTE5NdvnBfWA1fL1ju+q51Wqka+OEYU2GDWhXmgWBvuhltu0IJ7WT4R+x5YpMD
	NBxrlHw4pdkDG1PAAN8H521wlr3gzUntQqSEJB56xnvCVcZIiq0dqbzr54SgyegfR5bQIzFGyZZ
	s
X-Received: by 2002:a63:b649:: with SMTP id v9mr12368551pgt.436.1545657658878;
        Mon, 24 Dec 2018 05:20:58 -0800 (PST)
X-Received: by 2002:a63:b649:: with SMTP id v9mr12368516pgt.436.1545657658181;
        Mon, 24 Dec 2018 05:20:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545657658; cv=none;
        d=google.com; s=arc-20160816;
        b=ZgM15I4tgLpq00JOrvE9wq32XViS71SGGw0fkAzQonnTiQc4ilH5QSYOZUBKNQ1oUs
         190XmCXsqFB2mVN/UvoQFuA/AH5vXQcYulda+T+8yXFnDVDScNXvC2TWLAj+KRfc+Jzw
         o8xdf0QrNy21woQdup/cQFpGEq9mTHMy0JVbO10xy5Aci/bxuRN+93L+Znq0HfpDuJNf
         dHenIU9USsq6ULSfc+lDAXC63x7S/A8siWKHytb61cI4A4S2rwUjtwpI6D0Iake/mw1e
         CqMUy7wzfkRF8A/IbNTDe1kpYauW711lu7tzFsClOARvKQIv0cBItCG+m0NhbwgLOzSi
         j9yw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=YwqNkUNPLYdK07Ra2/mSQ+jZoA95B8gqjnUO/EioucE=;
        b=ZkIpSvZd3GogixalcVHylENrfeNb67C6fu3MbUFmfJ2bPxYtqI8Pgg5/QCsopcTJ83
         y+5Jwncq+oqY1AyrROXxMpTQaeYcDIRZb8MSOpbosurnfQ9CiMn6H6m893TqZiQHnI6n
         e+X29cIg0TBWbxrTUYSBLrwXttDlBcAauOPDja8XRG5lE5KjDci8Vh5s6KzA8khKJSzs
         Rrk2j1YPuH2TyyFb/Vm3fHFULEpnZG5LkcJpmPrK4eRW4PKtPi3Nc4AbsiYCLmzlwix9
         Lco0D1hV0l3AvDEPviGapSCJQk175odFIlFH+4Ud/R+h631lCe6WC+NGrm7ct5noBRFY
         1bsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="CUnAh/Rq";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 23sor51720325pfr.25.2018.12.24.05.20.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Dec 2018 05:20:58 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="CUnAh/Rq";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=YwqNkUNPLYdK07Ra2/mSQ+jZoA95B8gqjnUO/EioucE=;
        b=CUnAh/Rqve+lXu2kbGyo9bkEQtyA5AD0Ti2n6JA3IoBI/ZQ2YxAVlgC5u47FeQQMhn
         RpjsyPtlNuUeBZsoZ+4VsJYM9iGoFNhhpJn2J68frv2rKaaO0T0uYDo2Sj+NUpduPHzm
         EgtQ1QgTv89NIcvJAt/gcyrEod5yHLdsLtYUsZaZpo25zf5zGahIyOpp2kMc5TgdpRt8
         nKZrw+ux+pYMX7mul836T5MMdBuL4Kvuy3Nh05KJbMHRyYflMaTF53Q70EqkpjhsZmfa
         17K6i6wlPIIC5zVJ30t12v5tkCWaDvMmkBB1Kla3Tlld8MXLACGIePanxTtvXoop3ANE
         8tQg==
X-Google-Smtp-Source: ALg8bN5/gh7iKSFeVbCDxnlm68Sjq9dvwVK/fGxmQ8vvM0+wZbEa4aML94BwBBLnwyDRbrgezk3ImQ==
X-Received: by 2002:a62:c185:: with SMTP id i127mr620171pfg.43.1545657657811;
        Mon, 24 Dec 2018 05:20:57 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([106.51.18.181])
        by smtp.gmail.com with ESMTPSA id 84sm87589245pfa.115.2018.12.24.05.20.56
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Dec 2018 05:20:56 -0800 (PST)
Date: Mon, 24 Dec 2018 18:54:53 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	oleksandr_andrushchenko@epam.com, airlied@linux.ie,
	linux@armlinux.org.uk, robin.murphy@arm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	dri-devel@lists.freedesktop.org, xen-devel@lists.xen.org
Subject: [PATCH v5 5/9] drm/xen/xen_drm_front_gem.c: Convert to use
 vm_insert_range
Message-ID: <20181224132453.GA22132@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181224132453.HyQd7wr0qoA-xusiWDBV898Yp8V53N9SQ6lpCVkg0BQ@z>

Convert to use vm_insert_range() to map range of kernel
memory to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Matthew Wilcox <willy@infradead.org>
Reviewed-by: Oleksandr Andrushchenko <oleksandr_andrushchenko@epam.com>
---
 drivers/gpu/drm/xen/xen_drm_front_gem.c | 20 ++++++--------------
 1 file changed, 6 insertions(+), 14 deletions(-)

diff --git a/drivers/gpu/drm/xen/xen_drm_front_gem.c b/drivers/gpu/drm/xen/xen_drm_front_gem.c
index 47ff019..c21e5d1 100644
--- a/drivers/gpu/drm/xen/xen_drm_front_gem.c
+++ b/drivers/gpu/drm/xen/xen_drm_front_gem.c
@@ -225,8 +225,7 @@ struct drm_gem_object *
 static int gem_mmap_obj(struct xen_gem_object *xen_obj,
 			struct vm_area_struct *vma)
 {
-	unsigned long addr = vma->vm_start;
-	int i;
+	int ret;
 
 	/*
 	 * clear the VM_PFNMAP flag that was set by drm_gem_mmap(), and set the
@@ -247,18 +246,11 @@ static int gem_mmap_obj(struct xen_gem_object *xen_obj,
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
-
-		addr += PAGE_SIZE;
-	}
-	return 0;
+	ret = vm_insert_range(vma, vma->vm_start, xen_obj->pages,
+				xen_obj->num_pages);
+	if (ret < 0)
+		DRM_ERROR("Failed to insert pages into vma: %d\n", ret);
+	return ret;
 }
 
 int xen_drm_front_gem_mmap(struct file *filp, struct vm_area_struct *vma)
-- 
1.9.1

