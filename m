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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86C33C43612
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 13:19:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DA2721850
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 13:19:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bZlLJOIm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DA2721850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D11608E0006; Mon, 24 Dec 2018 08:19:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C99858E0001; Mon, 24 Dec 2018 08:19:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B621D8E0006; Mon, 24 Dec 2018 08:19:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6AE3F8E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 08:19:50 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id o9so10793865pgv.19
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 05:19:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=ta45jCjTTw9h608mLSaRumjRsUxHErr+7YYhcRdk80Q=;
        b=QnG5rUSJlSLEzHxk3vbtIwvAikFxODlkZDd86GjrDrfJKP1noNTMhKG1g+SbC5Sy3m
         RO3b8t132JXMjAh9NRda1E+u00pFVGN4OwEyjC0G0++GjgEiPYXbUJ9fIBMo8wtq76m6
         zh/ccr86b1zCLhZug6iMTgI1i7tm+FCA5YnJiLex1Lepa4IlKuRRgQvtPLaoZXpbrv4l
         ghspGC7AI1+VQcphY3ruFGlzQck3CFHoOG3rqv2jpQ1qkmVt9ijbXGTCs2t1PlNg6M4m
         g1Uq0/x/rUY+5H8h6Ed6piYr71qXPHi8Nni+gEeIym1E8hCgqeFFq/R2prwuU38R8DDI
         FBZQ==
X-Gm-Message-State: AJcUukeUPoJdrvpwg3wVySfFnkJMmlsNK6zH8+9z+b3VZHB2p6tAfhqp
	dEA6XmkL0zX9JlJWyL/gF61NZvqN/PnoRm0HkljYWe54N2VlRcyooM62DtdtGtupFTZWLzj+B6I
	4RPGgqTqyukI54lizYpshddOEI224/ZKflEZuSt6BL0ui4zJBRmhD/2AnVArACqCXAC07PkDzal
	KImxCcf8s67n059Y11tpD0sjL+7eEYpX5GSz15KVhrkHMYzIBBrFQRv0IOP4kM31vMF7To8URo5
	UXSc1hyHGAVi+1tlNB9U9rbXklMH/udmzZToWt1noR6VO2d1dBs+i5YEyF2nbWzTlH+080B7Ggp
	nzdulHe6vs4aZrU//rYI5s4nvQ/ommPOwoVgZUjxOyTOaCDMy0aIfNa7/gRDvPkInL++BvjKvLt
	3
X-Received: by 2002:a17:902:1102:: with SMTP id d2mr13044658pla.138.1545657590114;
        Mon, 24 Dec 2018 05:19:50 -0800 (PST)
X-Received: by 2002:a17:902:1102:: with SMTP id d2mr13044624pla.138.1545657589472;
        Mon, 24 Dec 2018 05:19:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545657589; cv=none;
        d=google.com; s=arc-20160816;
        b=PUeOZADbrloNNN/kzD6VVe9I/YgGRXDd3qnFK4gPQnhyh7wpLyWNKRtaOalBYfiMlt
         TI0ptjFKiXGYGlcjtkgwwkC5Tsm5PkNwMsytlm94JBc1324fWYH/e7J63JpzMAW0uS8s
         /H1BFPPN+noWUcS9B0IhtrsuLLlGkknr3sXuJa0h288Yl6qADcf5Cnq3oVyzEFx57zpr
         LEUOhUQwuFlweoCTpRQqDCXIoZFyRer6fScsrg69l/Mo4qH3FzoLb9FMyZMLwJpKQ04j
         u3G0KcBf4w+y6rMtIM680lQ2V2UNUykEsVWkSbmtQCD0H8dBogxvnYRi4X1NEERzaorY
         dNYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=ta45jCjTTw9h608mLSaRumjRsUxHErr+7YYhcRdk80Q=;
        b=MUj9mE9JjuZ2G4Xq0AieRM2aTm/jLEtnCfKRRYgVDPA9EsGi+fyLVByhKYTKfzOBKZ
         87BsOGxvPRFyklOtSqO+szrtDa7LDLuRmt9q5enWarsPiV2pAtwriM4HLq47Exh83ELH
         k1wauCMYGBL6Wok4n9iS56LQvAPD9byIaXF6xkAhAR2SeX3u3WvmCNDuwwlDg8Q+3XyY
         oHmWOZEY4rzebo8A86PKlmKBsh8x0EXYoKfecGA2PWRlI7t9+dXAZsRqAIBkopdDUhK8
         L/7mB4l1lqZBpkIfvHAgvVtWRrC0fCSEWfURryuFWoPgBxEP0QjqOkVtMDdDyCWWem8e
         WkMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bZlLJOIm;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p18sor50649233pgl.33.2018.12.24.05.19.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Dec 2018 05:19:49 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bZlLJOIm;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=ta45jCjTTw9h608mLSaRumjRsUxHErr+7YYhcRdk80Q=;
        b=bZlLJOImO/1bupplpSBgyvMTMpxNs0KKCyh9eTwdH+0uwPXfvhWmQ2pAF8DBwsk9Rh
         bUzZMgNq5nuyQY4GhD3gBu+bVpcBE11KxlyMH4e4GZcPAfuh33MQNhj1AdFZ3jCDGO80
         pw0nh5Zx//0/hc8/8FFns4JVjWJHJEPmTg/eT1k0ZUpBl00xFnUcKdIg5f+PdxVKKQa5
         FCwYRtJKVzzaeQlNqWS4BSXGJQUhPC21z/MJEvaiy2M9oJNQzcrFQKX4+e8lpIRSzbhj
         CXPgWhP0XbFWNCAtL9bP3cJwnXoT0RpNFDimxMCjz/XJnM+Mzti5wvF9ze4fxY1gPbV3
         yV9A==
X-Google-Smtp-Source: ALg8bN5WlOmqbcy4mwSttJzqAgLDaKxP0MsWaY4oRqlS6nY5gpEXpC5t31E85FE+ygzeYcDzQuE9IQ==
X-Received: by 2002:a63:db48:: with SMTP id x8mr11898908pgi.365.1545657589149;
        Mon, 24 Dec 2018 05:19:49 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([106.51.18.181])
        by smtp.gmail.com with ESMTPSA id s9sm42516339pgl.88.2018.12.24.05.19.47
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Dec 2018 05:19:48 -0800 (PST)
Date: Mon, 24 Dec 2018 18:53:40 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	hjc@rock-chips.com, heiko@sntech.de, airlied@linux.ie,
	linux@armlinux.org.uk, robin.murphy@arm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org
Subject: [PATCH v5 4/9] drm/rockchip/rockchip_drm_gem.c: Convert to use
 vm_insert_range
Message-ID: <20181224132340.GA22112@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181224132340.W-vrBlqudXVQUwS1SWK1qR_p7Z0NBnx8U9ghepCyouk@z>

Convert to use vm_insert_range() to map range of kernel
memory to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Tested-by: Heiko Stuebner <heiko@sntech.de>
Acked-by: Heiko Stuebner <heiko@sntech.de>
---
 drivers/gpu/drm/rockchip/rockchip_drm_gem.c | 14 +++-----------
 1 file changed, 3 insertions(+), 11 deletions(-)

diff --git a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
index a8db758..28458ae 100644
--- a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
+++ b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
@@ -221,26 +221,18 @@ static int rockchip_drm_gem_object_mmap_iommu(struct drm_gem_object *obj,
 					      struct vm_area_struct *vma)
 {
 	struct rockchip_gem_object *rk_obj = to_rockchip_obj(obj);
-	unsigned int i, count = obj->size >> PAGE_SHIFT;
+	unsigned int count = obj->size >> PAGE_SHIFT;
 	unsigned long user_count = vma_pages(vma);
-	unsigned long uaddr = vma->vm_start;
 	unsigned long offset = vma->vm_pgoff;
 	unsigned long end = user_count + offset;
-	int ret;
 
 	if (user_count == 0)
 		return -ENXIO;
 	if (end > count)
 		return -ENXIO;
 
-	for (i = offset; i < end; i++) {
-		ret = vm_insert_page(vma, uaddr, rk_obj->pages[i]);
-		if (ret)
-			return ret;
-		uaddr += PAGE_SIZE;
-	}
-
-	return 0;
+	return vm_insert_range(vma, vma->vm_start, rk_obj->pages + offset,
+				user_count);
 }
 
 static int rockchip_drm_gem_object_mmap_dma(struct drm_gem_object *obj,
-- 
1.9.1

