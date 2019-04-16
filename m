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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FE31C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:47:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53BA820868
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 11:47:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZEPNYfVS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53BA820868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02F2F6B026D; Tue, 16 Apr 2019 07:47:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F21D56B026E; Tue, 16 Apr 2019 07:47:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEC2D6B026F; Tue, 16 Apr 2019 07:47:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A51BC6B026D
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:47:15 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 33so12380723pgv.17
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 04:47:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:in-reply-to:references;
        bh=+cqpEOgVsQX6FuKbkjkqnPdK6JJEhfhSEvMIkCtIVgk=;
        b=Xjy9Wm7gUy5YawITaQXCvEPA7GnRjSGCpO8w8a20jPegq+xErun2fNKIgd3n44odgg
         yT6aXw+N5Ue7hPZ9gRUG2AD/Z5C9g/eByargmPC/z4z3SPWS//DunZXluNzl2kaiAdxn
         3y3rDDI6D4u47iV7v6GuRjrszRLj2P7trlj+iTjdMr4GucDvd/VG8PjAF8CWgg/SLpgj
         GtZS/JukyDUZvWlD3Gx97hZoRWTmx/Bhsryf1zMNbJ5XVjGOirpB5/PapPXCxRYY4uRA
         Ly/RvCgLQNFXLbZEvWJ16e8E09RXj0zfy5hvLwhUxXrvWO+/7XJHAJU8+ipbP89rDgZY
         6qpw==
X-Gm-Message-State: APjAAAV0Qmx5uOl/DDCS0V1dqnE006lU6TbO8NrWsCcvP9SYVB+E3zB0
	8CHQyie/AHn59gAHin8EhxJp6UOfG1n0IhCO5GQnrBinu1Bo9HJo5sWOP3eysqIKKIrMbyk+Hm/
	TXUKZ0B/4/xdXiUhnPSghG5h/fWn8BXOu0sCRt1YtlsYXa/9xV5B4/4lYnAfk07BU6g==
X-Received: by 2002:a63:5a47:: with SMTP id k7mr76039013pgm.174.1555415235301;
        Tue, 16 Apr 2019 04:47:15 -0700 (PDT)
X-Received: by 2002:a63:5a47:: with SMTP id k7mr76038954pgm.174.1555415234634;
        Tue, 16 Apr 2019 04:47:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555415234; cv=none;
        d=google.com; s=arc-20160816;
        b=aNryTsmncAtg6BMI9CyjA0wdbdVXnWegKAPFiVbfISxiYH2gLfue4xMGWJ47+Zin/l
         nFTHuYBUl/XwpNbFB3nopOmm+QFpP/rdlldO1PVOpDnjQtm03sgHn0mngQKCJM+UVU4c
         tDqTbHnZQCTUQFOuhIe0rh91o7geC97P/a24KcZyOskSWcO/qTbpKJgbKLvueHXsnuAj
         FdUGDqm1Au1fnQXlmsaFQAB9ay/Edgqx1a9RcT07g6TOhPi8HfyqnI2Ti7v96Fr4V/b+
         vWwy0n89hoCtIJlZYOqazhKLxc1MgY2yYkNrF3KlmTLDqpberfDEI8v2kDx4IxG41V7E
         HCtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:references:in-reply-to:message-id:date
         :subject:cc:to:from:dkim-signature;
        bh=+cqpEOgVsQX6FuKbkjkqnPdK6JJEhfhSEvMIkCtIVgk=;
        b=Hz629FFjzu8b28l5TXB5ZFd4ra9mDxjZhxCNDZnmYATSj9gTV/yjg0UxCJtyZDFR/A
         D+iCMZUEQYSh7cYS9jw8LAsZz9pJrGlRTaA+++xH9T8yEGgSWsMRLSY2/NizkYTiT21B
         cN2OGk/jVIJ1XWyGRxBTtKmJULG3+/gBITJp45FONG8urA4nA015gH6CxA+wPgjptPiz
         eqNmPGRujLjjC5lzKKJ+Inb9pJuG9VNwNGOg7Y/MPpi8Ma3IDO2lHLNsnJbKGMkV3Go8
         VpcVO24HDuDLUvC4a+LkItg2y+Q3Wr87iaATTRKdObo/5hnLWJT046cN69r0SJo+qoVb
         7voA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZEPNYfVS;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h9sor22818081pgi.30.2019.04.16.04.47.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 04:47:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZEPNYfVS;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :in-reply-to:references;
        bh=+cqpEOgVsQX6FuKbkjkqnPdK6JJEhfhSEvMIkCtIVgk=;
        b=ZEPNYfVSL4B5JX2ezXJn9ONMFjeBybnM7dEzWRU+VYIsRyGMGgpqRdABkKcexucE87
         7eS/EqdBIrK6bjtSszOfKTHQL093GWBbTgMhrkG8Fh7H6jPUs7F1cdiZh36WZTAKjZxG
         fXwKyWQnGk2U/GDN1NkdOmI9RlUNXGaha0RSVNQ1DgW9t3VfJBbFyFtFx9E+/utDSTsI
         gGihHxYgoxgGi1Z3uRwOi2dNAXZTpf36/83Ta4UTHVmc82WsQ3ECg5LfIZdF7Rnpd9M/
         M8J4YNEguL/QDMiYCuFlNnKdZR0nVg15NJqCTMb575aSSv31rt9RUSWXNGHBP/5MaHWL
         Sy6A==
X-Google-Smtp-Source: APXvYqyrLQsRSnTjPgcZvGACSx9pqT9Y2eLgTKItzz2brxMgzhzMpJHBo0PeONjvaK7uMxB6G+wAOQ==
X-Received: by 2002:a65:420b:: with SMTP id c11mr76375087pgq.24.1555415234335;
        Tue, 16 Apr 2019 04:47:14 -0700 (PDT)
Received: from jordon-HP-15-Notebook-PC.domain.name ([49.207.50.11])
        by smtp.gmail.com with ESMTPSA id p6sm55942835pfd.122.2019.04.16.04.47.04
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 16 Apr 2019 04:47:13 -0700 (PDT)
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
Subject: [REBASE PATCH v5 4/9] drm/rockchip/rockchip_drm_gem.c: Convert to use vm_map_pages()
Date: Tue, 16 Apr 2019 17:19:45 +0530
Message-Id:
 <7ba359eb1aceac388d05983c1f29b915bdf291f9.1552921225.git.jrdr.linux@gmail.com>
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
Message-ID: <20190416114945.QguHjsvQDWUl3k2Ym7B6Jdc5zLH5uTqQFx0o3eBnGAw@z>

Convert to use vm_map_pages() to map range of kernel
memory to user vma.

Tested on Rockchip hardware and display is working,
including talking to Lima via prime.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Tested-by: Heiko Stuebner <heiko@sntech.de>
---
 drivers/gpu/drm/rockchip/rockchip_drm_gem.c | 17 ++---------------
 1 file changed, 2 insertions(+), 15 deletions(-)

diff --git a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
index a8db758..a2ebb08 100644
--- a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
+++ b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
@@ -221,26 +221,13 @@ static int rockchip_drm_gem_object_mmap_iommu(struct drm_gem_object *obj,
 					      struct vm_area_struct *vma)
 {
 	struct rockchip_gem_object *rk_obj = to_rockchip_obj(obj);
-	unsigned int i, count = obj->size >> PAGE_SHIFT;
+	unsigned int count = obj->size >> PAGE_SHIFT;
 	unsigned long user_count = vma_pages(vma);
-	unsigned long uaddr = vma->vm_start;
-	unsigned long offset = vma->vm_pgoff;
-	unsigned long end = user_count + offset;
-	int ret;
 
 	if (user_count == 0)
 		return -ENXIO;
-	if (end > count)
-		return -ENXIO;
 
-	for (i = offset; i < end; i++) {
-		ret = vm_insert_page(vma, uaddr, rk_obj->pages[i]);
-		if (ret)
-			return ret;
-		uaddr += PAGE_SIZE;
-	}
-
-	return 0;
+	return vm_map_pages(vma, rk_obj->pages, count);
 }
 
 static int rockchip_drm_gem_object_mmap_dma(struct drm_gem_object *obj,
-- 
1.9.1

