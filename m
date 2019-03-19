Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3984C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 02:22:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2A9520700
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 02:22:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BwZwO/mg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2A9520700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6EA366B0008; Mon, 18 Mar 2019 22:22:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 697336B000A; Mon, 18 Mar 2019 22:22:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 586766B000C; Mon, 18 Mar 2019 22:22:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 14EFD6B0008
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 22:22:06 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id v3so7011204pgk.9
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 19:22:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+cqpEOgVsQX6FuKbkjkqnPdK6JJEhfhSEvMIkCtIVgk=;
        b=FmwPwZ2Hi0aV/USgbqQvD2rzQKI9C/8Z7zVt2UIGG74rWkcF7vl0l9vJ5nfq5XOAWE
         dzotUs4VzUJqoDLxtLEKvpiQ7FvpmlAIGBFYaJQPiggImedvkbmqneOI3hGAKJEaUiLD
         IZsgnvywuHlaGpSm6fUCTltEoO50bS6rf5Dt6d7EpfdNu2TaskpyNC43XRXNBYjzO3uz
         dYkuKkaflJbB+YW8fEFB+8NvI+VErhvZnAeZZ9l5FyBG9h8iUU5kQMbvyKMqXdic4Ggo
         p79V9xUFCKtCrEKdRZUH6kI3F+0ebgtQRLDI4I7BnLalVYhjPsjfEeMgRKSSrjy7Cp0v
         iSQQ==
X-Gm-Message-State: APjAAAWtny5239SCf/gGNu/iuberX4gek5d8/bs5RIa5MjlCwYFkcA87
	YKeRsNB565sL1UFQh5qSXKbPHv7vWvGYu61Jr+TjUM8QJ+vvzbDunXoS5e7bBKHMYzeVcqgDVqi
	NU+VDkQBmSRlrGTPTNyufYlVJGYRhtlTQdvRSWjQHdMe6DtakTdasYGJL3Eu8yC3ecQ==
X-Received: by 2002:a62:bd13:: with SMTP id a19mr22085648pff.222.1552962125740;
        Mon, 18 Mar 2019 19:22:05 -0700 (PDT)
X-Received: by 2002:a62:bd13:: with SMTP id a19mr22085587pff.222.1552962124496;
        Mon, 18 Mar 2019 19:22:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552962124; cv=none;
        d=google.com; s=arc-20160816;
        b=MhKM3UxPdv+ADkjPUoG5D/WFxWRROVdBFxZbJIGTdqYRu+a+pdchPgPNk8C2APkJvV
         zUq+2NVLt26xipgsPd8oK3U0tMP5g/iVLIQ0zNbI81zKjK4yWSB/7Jg8J0ZUi+Uixg8L
         9QjVrmELdV0SmDXfgxTwN7UcHmfgqvwsENwuqsn5hEVE/YNQWXx6XH9WX8B6T1YhhU89
         9WQk1bWzEo3lRz/fGBqLQQrdL+RbOtp7+uNxXDvUym+82Y71uQWDPDFZNbdZuJvkIquH
         Qm0TuCAncDPlmI1E78yjWG8x6rhZIO1gaKdp1fj417OY6WonwtuhYj63Ri5pYQo+qoM2
         cDXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+cqpEOgVsQX6FuKbkjkqnPdK6JJEhfhSEvMIkCtIVgk=;
        b=uVGC3ejgI4cyRrpw2oTgE0KNRcNy3KGsIObUjvERPyW00H1zZgVcCo0PP17y619Buy
         20Do2U4GYRP0FURr2thuAhwd/Z7H6SjDguzhbmfhDJV2e2reuLk1AAmv1z8YTT7ScPGi
         2OGAqcLG0u5avk9/vT+F0hhFBYunRADoiBaAXveVAh3Pk/JLAuFcC5eSELgA2snmSBgR
         +N2McTUK2k9Cuny583ajK/k154KFcm44DGoLAZ+Zgj1YHNzmzwwfoGqT10E7bUc3fSNu
         ADswCfGIUd7mutVoz53ZVp0zj+CvxYrFy0YCFqKYddDim5PkCgZPCkfGUbMnOrZc5eIB
         L4JA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="BwZwO/mg";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n8sor17938225pgv.9.2019.03.18.19.22.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 19:22:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="BwZwO/mg";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=+cqpEOgVsQX6FuKbkjkqnPdK6JJEhfhSEvMIkCtIVgk=;
        b=BwZwO/mgWw5cmeGQm07gg2bfziVPZ2aU3Vz8l9vhecEXfsRq1wSNLw5Tv+yoAr4k6e
         QfcEA2+DQTTXbDaHXA8Quutyc5CY8LDUaHkqOISw8iBUR/dvs0yFXwhZyT8R4RnRvaik
         KPtZ2hALQAlGX1QFF5QVZVR6tkmcCp+oX0SlhSzKvqSvm3PLsXqywOOy5EHyo8Pyx2vS
         odp83dilftZ3mXWQaGhoshFSyINw4LYI6tGaRywK7Dd11M80UdE4NViEOWK7UPfUzza2
         0y7QmRBNIAy3JVAQlWVVE/67nyWjwXO4GQ2vYciubrJBZZGh3pq7KI3y4a4NmMPx/ufi
         NXLw==
X-Google-Smtp-Source: APXvYqyDvI4zt3fFzBxE7EA/O8ssnYTAAyn+bRG1R0qqvVNexLq29fF+EGU3IMdTuIzc3YDUOwMWrw==
X-Received: by 2002:a63:6e8d:: with SMTP id j135mr20527765pgc.160.1552962124157;
        Mon, 18 Mar 2019 19:22:04 -0700 (PDT)
Received: from jordon-HP-15-Notebook-PC ([106.51.22.39])
        by smtp.gmail.com with ESMTPSA id i79sm24658598pfj.28.2019.03.18.19.22.02
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Mar 2019 19:22:03 -0700 (PDT)
Date: Tue, 19 Mar 2019 07:56:38 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	hjc@rock-chips.com, heiko@sntech.de, airlied@linux.ie,
	linux@armlinux.org.uk, robin.murphy@arm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org
Subject: [RESEND PATCH v4 4/9] drm/rockchip/rockchip_drm_gem.c: Convert to
 use vm_map_pages()
Message-ID: <7ba359eb1aceac388d05983c1f29b915bdf291f9.1552921225.git.jrdr.linux@gmail.com>
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

