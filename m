Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8EB9C282D8
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 03:07:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A500E2184D
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 03:07:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NZQeve9z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A500E2184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B09B8E0003; Wed, 30 Jan 2019 22:07:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4600F8E0001; Wed, 30 Jan 2019 22:07:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37A798E0003; Wed, 30 Jan 2019 22:07:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id E92EB8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 22:07:30 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id f3so1186259pgq.13
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 19:07:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=2owR9Y+Fu1XiPkZWSyijL0gEQb0pHlWrbxT50sCCie8=;
        b=X/JnwqYZk43/b20RJQBwScieCi+qtr8TueVLICtOSXwOKGakfJN6pumKfuFk+WpZ7I
         NV5nOYhyjrcjR+SK1DriedJfY0X+ad4SkbahOcslaqrrArERe3Wn9GUtU2u8hrAAGluP
         SKbeYOPU9Tt3V6Mu+LRLOYepZcaUR/J9xrJFwTdygfGHADB0C6riLEbchQPI0cvX1UH1
         Ijne5339ZcriIxmp4VANLB6+jLknj/GSCjIfzlC+5SHoiDKrmRxBwSocLzbofHsiJuJ6
         zDfRs5T+F2TNJ7HUpyKcPS4p+gXD5PPV9aBt2WSGOaxbe/6NJuSyyawTaaxgFsgxgM6n
         ntfg==
X-Gm-Message-State: AJcUukfPtTRsGpSCMUbC/AVV+rzoqt7Db8s3FIYVgJgLJtdnblRoG/nA
	CQFsYRrduR7qKq8PZQ/OPH519XX8kZF9BkIShckX/0kFYgGED1vCz52Jnj3XYhtF7aiK6Im+hPv
	+K7VHVRasXFuM7O8LEv57BEqyTcJSpncvWCETE2p7GeeDSLibZ1QapW3qZ8S6t0lOONAEsg3CPc
	9pf9l3v99ukVJmeARn4nq7iRB7bChYbjJu1kjghTJIPgPxTDsAapb/hQu5ldb9k9VM263diYv6Q
	ct6g9y7f5xZl4DeOsWL5iy53jxM+SQx8HbvOo21//iFcsipIke+6qM8eROb7FrxH6dOmWxwrokJ
	/BmNDL1nCKn5SEzfbCwwl/N+z0irP5WiLcNsenNqzrt2c2MMEb6BV7f24FvoKrfEV3FGuS+ThQq
	p
X-Received: by 2002:a62:31c1:: with SMTP id x184mr34015356pfx.204.1548904050615;
        Wed, 30 Jan 2019 19:07:30 -0800 (PST)
X-Received: by 2002:a62:31c1:: with SMTP id x184mr34015331pfx.204.1548904049886;
        Wed, 30 Jan 2019 19:07:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548904049; cv=none;
        d=google.com; s=arc-20160816;
        b=yKjzqntj9Zh2vJHr9cTJr1YSJEwJ1DuP0/kXmZF4MdixN2ljqr1fbZgzuvw9mV5QSL
         Lk3NuIXOQc4S0sDJNPl9RzAtKFxha7sg2aS6Pm+Qu9VZDLX74hYVkSwbcvgeC1D2HiQx
         H8a5eGxmPRSBSYHtVe7hvBXfONY89UDRFimMfnriE8amV0VxkkSebZpDHm0uN7CGUEYX
         cXXOoMHECU+trgeV4VPvsO9AfpI/09C95qzY3DjQYmId/2K/stLparUAqqULnBrcZAFt
         VynetViGsWu881FyhEn7opk9UMgGVsnTZe5oNKx92EP6O20sWSKyMXclUfTYAcOV5DSc
         qKqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=2owR9Y+Fu1XiPkZWSyijL0gEQb0pHlWrbxT50sCCie8=;
        b=Df2kL0vrBSZcF5rjBDZO/A7SB8m9baGjI03rmjnazpNJk78/k+AJED7FcbA0fX9vFz
         Mazww8FTW2wrxIFHVXonl35hjmiWCOngc4vCtumOvT7D16uuAUmAiBTwbg2fCzXRXLHV
         t1iAQS4YlI6BpkdzhUM/rgLnlLfxC8rsS0UexA2Vdy7Hc9/hCMRYgKu8KGmWcqAF0zs1
         0kAQqdNsxNRoe+xXYhMpEon+aPW4nH2rz8brhvWoF7bI9IwxxYK7cGbUkfru46fvLVAq
         KJ318jtj6vlhpI30JV0oNwQldYBW+Ysm54vWeVu0MqbXhUofPe+zAMZZe0deRhnicKfE
         X+Bw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NZQeve9z;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z6sor4945360pgl.57.2019.01.30.19.07.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 19:07:29 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NZQeve9z;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=2owR9Y+Fu1XiPkZWSyijL0gEQb0pHlWrbxT50sCCie8=;
        b=NZQeve9zbX4Ge5xvXA78Atzzs0uz6ecZSf2jwkaGy9naKq9UQ0tGyf9387X8jWOLDY
         4ZExfwm2IiQfWLdL33XwJ3bqjuvWu3hYYxHJMPAMFEaVhAeOUc/0AE0trX9/ICzKCOpS
         i+ewoNERn06fUr3RKBdUL5yInvTYP9sftxNuXJaahmRL+kntme6zlalSzoLx36Tmhh8C
         VinMhm7g3UqnH8SQWO1LKsOibcKBsobp48bdEEKBNKNSZzue/f6r7SLEkykVE53pLDdT
         dpMFxOI4SJeXn7LVUGa+EVhuKWGKqicsil2CZOCmz1DHhwtAFNoCWpswU1DfJptM3n6G
         R9Ag==
X-Google-Smtp-Source: ALg8bN6J223zMhkVRUiamGrLjZpFQzF4EOI76I5mSAxon5PpAWsE/WAQPINgw1LsAAmjinCuk+7zEA==
X-Received: by 2002:a63:7512:: with SMTP id q18mr27636577pgc.231.1548904049578;
        Wed, 30 Jan 2019 19:07:29 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([106.51.20.103])
        by smtp.gmail.com with ESMTPSA id v184sm3913763pfb.182.2019.01.30.19.07.28
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 30 Jan 2019 19:07:28 -0800 (PST)
Date: Thu, 31 Jan 2019 08:41:42 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	oleksandr_andrushchenko@epam.com, airlied@linux.ie,
	linux@armlinux.org.uk, robin.murphy@arm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	dri-devel@lists.freedesktop.org, xen-devel@lists.xen.org
Subject: [PATCHv2 5/9] drm/xen/xen_drm_front_gem.c: Convert to use
 vm_insert_range
Message-ID: <20190131031142.GA2339@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Convert to use vm_insert_range() to map range of kernel
memory to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Oleksandr Andrushchenko <oleksandr_andrushchenko@epam.com>
---
 drivers/gpu/drm/xen/xen_drm_front_gem.c | 18 +++++-------------
 1 file changed, 5 insertions(+), 13 deletions(-)

diff --git a/drivers/gpu/drm/xen/xen_drm_front_gem.c b/drivers/gpu/drm/xen/xen_drm_front_gem.c
index 28bc501..b72cf11 100644
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
+	ret = vm_insert_range(vma, xen_obj->pages, xen_obj->num_pages);
+	if (ret < 0)
+		DRM_ERROR("Failed to insert pages into vma: %d\n", ret);
 
-		addr += PAGE_SIZE;
-	}
-	return 0;
+	return ret;
 }
 
 int xen_drm_front_gem_mmap(struct file *filp, struct vm_area_struct *vma)
-- 
1.9.1

