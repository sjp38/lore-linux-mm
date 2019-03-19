Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C701CC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 02:23:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8304820835
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 02:23:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="r0tcryB8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8304820835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DE436B0007; Mon, 18 Mar 2019 22:23:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18D296B000A; Mon, 18 Mar 2019 22:23:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07D366B000C; Mon, 18 Mar 2019 22:23:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C342C6B0007
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 22:23:03 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id n63so7639527pfb.14
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 19:23:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=wsI5nOykFSX6S7SyN92+LRaxG3yXSZXxVHkiaYJTa/M=;
        b=bZ7Sw78hQLWMyhO5YWg/2n/v6ZkbQVOPKeV2pu4MGRVixThUkXCQY1CFTG7YERkpbP
         lPO2S7+BENNtuXhJCi/Mj8cANB4dkFjzeSKnkXwEEohM0Yz4wmIQfBKdNsLSBFuup1h7
         K0jbi/lR7x3z+UQ3GjZcQM/ndsaZKkrlJo4dRpG7lC+yqFpFw5mdxRf1t/+c12kBuEDW
         bY1BtIfdvg3pWKvelR4dVbr8aUAUwvmF2uNK24WgI/iC1RuJGXTfzzym5Onnin1HxHBh
         Zc1ArosVfq7ldb4cwN+xnFOyjipA9s9K5JH2I8OHRAqQkXn1Z20xFbSPacfIL6wA/1K2
         UgAA==
X-Gm-Message-State: APjAAAWeAeIlnVTkHrubqeQlOuiPHK1IoGOSFVVI1eVN1PgoaNGxIMJW
	oxV3of3L5rRWDNf2tKc8fmSwvYK6LiYKR3V9sN045PUcla0bxKJp5ZCWPtTlfS3F6//kWXfUCjM
	kXSAMI5V63W9wnTJeiKqmUTGmtGg0EvBaop+2sCFLTiOeidpZCUNw0CHvm0SpIsZMaQ==
X-Received: by 2002:a63:ee55:: with SMTP id n21mr4102pgk.211.1552962183417;
        Mon, 18 Mar 2019 19:23:03 -0700 (PDT)
X-Received: by 2002:a63:ee55:: with SMTP id n21mr4046pgk.211.1552962182241;
        Mon, 18 Mar 2019 19:23:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552962182; cv=none;
        d=google.com; s=arc-20160816;
        b=fCwxDKv1uXbtYc4MShs5DdCZ0l7r/j5oQGbNCoH9ZeP9KtG8g5+Z6EcNi08rRmNUIq
         wyr7j7MJntxsshwsr3M9Ge+KwDdtb29IHnOTyjanhpwZhe115v7it8aWz8RGwoq6Mr2c
         rWjykfKXpWBetxDLGFh9DuEltWQtV638Ifxfk1ZYNNvFCRzRood+ixevmvBiqwW/SeQj
         oVwhV4Sn4NFmjP6njDXJD4QJAoqpox/W2NZwjL3rW/yCpJqXUCB2wdKLJdY5tMAYhR9u
         pvpiuAmNno+FiZj5SeG6d/0DzCyUwfAD8cs93/vcHQ87b5nDwuRTMKB3SZiF1XeVm32W
         n1HQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=wsI5nOykFSX6S7SyN92+LRaxG3yXSZXxVHkiaYJTa/M=;
        b=XROnDGq6CuEHAlfgvAID3QWgku521fAhpChVarPZLpO799pHk2pYJQxYUcUQKOkj4B
         q3emmY9IJUbim0/L6lTdJ9pK33zTBw/tovOUzxSooWIzpgVyCS1zwFmnLlekpo+bK1F5
         cy3OPd5IsW8AxjEY/h8a22p0fHcdPwvjUgZnbG9D4xIQl8gGP3mj+6BH+RgpoF6+bTCo
         zG27x+5lKsGqXYQiT8bldR+m+dgapoqfVd3QHTUzHb8XZuCHuZRRMP/fa8k4RaNwTwM+
         yrxHyMQ7+ATTUzj65Kspwvw9TMp/PobkAZ4yKTA2F/WJgmPHU8XNGks+74iARGEDtK/a
         nwZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=r0tcryB8;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s7sor17545955plp.27.2019.03.18.19.23.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 19:23:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=r0tcryB8;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=wsI5nOykFSX6S7SyN92+LRaxG3yXSZXxVHkiaYJTa/M=;
        b=r0tcryB8FIFERLIj7h0R33SOmYQKY3BszrJoO9gjENz3TFDIJjslV5YKjuYSuiYBUV
         i4+oGUagTKlmINiPDRLeTjbaA0eWp0BIpZZgCb2Qe0Tao76itUzijedlOG2GIRjFE/Hz
         BaWedKn2ryfGsOn5FBK7iz78EkzaoCRUznER5dHb86rqpZNrvE6rCWhhXrrRvSBpf9C1
         7ILDZf7aFsdefLmMnDiUZnSWFexWdlbI3y3kvYZ9e/pzLyTe0dvAvQ2aONlmJJdR4Pcn
         X3qaxjDMZwQfqR4Aaa6V6UxgRjnM6WB3QSwTbx0ZuSHyFlLa2E63NVEBREXlVUGi2Z6J
         6X6g==
X-Google-Smtp-Source: APXvYqxDQ8p8D25l6mu8hirVXzXqpLPPAgWgqdF/gLd3vbvYIwZUmDpQg4eiKwmgL/qbB8DgDPB4wA==
X-Received: by 2002:a17:902:1:: with SMTP id 1mr13784pla.226.1552962181959;
        Mon, 18 Mar 2019 19:23:01 -0700 (PDT)
Received: from jordon-HP-15-Notebook-PC ([106.51.22.39])
        by smtp.gmail.com with ESMTPSA id 3sm15567578pfp.115.2019.03.18.19.23.00
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Mar 2019 19:23:01 -0700 (PDT)
Date: Tue, 19 Mar 2019 07:57:36 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	oleksandr_andrushchenko@epam.com, airlied@linux.ie,
	linux@armlinux.org.uk, robin.murphy@arm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	dri-devel@lists.freedesktop.org, xen-devel@lists.xen.org
Subject: [RESEND PATCH v4 5/9] drm/xen/xen_drm_front_gem.c: Convert to use
 vm_map_pages()
Message-ID: <ff8e10ba778d79419c66ee8215bccf01560540fd.1552921225.git.jrdr.linux@gmail.com>
References: <cover.1552921225.git.jrdr.linux@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1552921225.git.jrdr.linux@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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

