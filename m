Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC6F1C28D1D
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 12:04:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5A0A207E0
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 12:04:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uo/bYAEC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5A0A207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 462786B026D; Thu,  6 Jun 2019 08:04:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 414666B026E; Thu,  6 Jun 2019 08:04:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DCDC6B026F; Thu,  6 Jun 2019 08:04:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id C43746B026D
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 08:04:27 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id v188so297970lfa.20
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 05:04:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=tSlWixv8IsvTJaR5wWju6+N+gv5t7ksDAwbc0pe3EIc=;
        b=JzrNLkAzoEZPkzAnYzlI0vgPuLVjYfniMNXSJtrYWkSz8EwYFr2/x8nY57MhrHX/oF
         9e1XV8FU9Z0iUzGmf5mkb5zUHaqKTKICSZXQR76KPQVqRMFMowN6DTL6oULQFcMmap8K
         Sp8BR/CyKtmrzkbl8YCVa8lWJAUaL8TwpOHUVkDHD3jVvHBDrWWNGupIwoY9ZD9gfjIb
         wyonhLwTBxsmS4wJGsPA2xxAfcemJJBWXpgkG0Got2gSvIzT5Aqy8ouQ7ZQujo8u7MyX
         AJ3DJr/s7rkyN7z84lX0LajeVG8Id/l/tED2VP8H9HiLhxxzgAZBCQRc1J0fow6rhBBF
         WS1A==
X-Gm-Message-State: APjAAAXp/3vXvXL1aZXk5PPsMiXv0rGz9d2O914Tmjk/KdGSqzHXfZK0
	qLUEMMpBIbblHI7dPiqcBzjX+qWOl/Nn6TDSQGt4/J9zUqYLwWEVOZOlGjmu4OMQVUlF9x5CocQ
	ITN1tjuLceuH3JFuMQ06G4Q909i9h/USaL1z7v+9Uf9li16PMbfF1qV43siTnp7kJMA==
X-Received: by 2002:ac2:494f:: with SMTP id o15mr8732561lfi.84.1559822667215;
        Thu, 06 Jun 2019 05:04:27 -0700 (PDT)
X-Received: by 2002:ac2:494f:: with SMTP id o15mr8732480lfi.84.1559822665210;
        Thu, 06 Jun 2019 05:04:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559822665; cv=none;
        d=google.com; s=arc-20160816;
        b=zZKKCiIsE/J9uo62nJcf0iiNiDLJJPwAimmkD5QV0F0sQz3oaCFXJa0Q55wFEuvPG7
         nLv993ZFZYy0O9lYvontGMdVDRf2y9fyXndPyAi+Td3c2fSZgf2RQJDkklOuS/5G74R5
         jfymkZQisl1d6mwj1BABjijsn+bfrrUs1KLbhSiMcA7d4eekouUfJW9OepCa+xCX9gYf
         cIcud7eXG3M8Y060pKH3QudVKaWnv1GyZC7svmpY7/+Ww23vC/9ViKrcokJ9gYHgWZrK
         lZT7OOUNCTWLarQ/8GVgU3TfhyYDgrh21ina+A6hb9GeGWMlfot4faN6GNGmY4m127w8
         dwdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=tSlWixv8IsvTJaR5wWju6+N+gv5t7ksDAwbc0pe3EIc=;
        b=td4rUSJE21pZn+/PcrfMpimt9F44z9pukG0Jw4PB4fDAYVPZMapFszGBBz8wmQPjuK
         VMzwOVwjypfKFU1ibMsbVm+IjJpnB9vRxUXWTDlVj9kf3NVOJ6btrq9Fd89z8d45nuak
         aehXmjVLz1zOIaFUoMkKLFYprkUeOPoN+9a3lAfXJZRQfmchIEqK+GoEl+64haoNsq9V
         gYmkdACR0uwCWSInw/avsxLBUCVQrXbam1nrFiK3nIRcKFQX0mVDRw6iQKz/wDCIY7Vq
         newz0BXPhZwMakWwisVTq3XpXhlLBQVdvN9T0UaI8ipt5pDDHrqNa7sxVZvDYTEOWtJq
         Ls1w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="uo/bYAEC";
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d19sor478354lfb.33.2019.06.06.05.04.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 05:04:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="uo/bYAEC";
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=tSlWixv8IsvTJaR5wWju6+N+gv5t7ksDAwbc0pe3EIc=;
        b=uo/bYAECP+lJOkvdd6HNBObFeZirBPefZcLHVmO1hypQ59nvutuCoABltauglPwvqa
         Nl9KAZ7lpc9I/siL6djGDZXANHMdr/hKUY/0Wtg/8CJ6v8s2ua96EB7/Ikx8BpgkMRcR
         1jzop2g7p82ZamqXdZKiYANa/XXHS0nJjeDElbOWzEtc3N52euhAjcvranvQX/oAAk9L
         m4SYC1H8gLNFh3Q5RuggzpduF2YQEMkl2h/662SUCqsVXxe6igui3vy2e2qnFYHSgxnf
         hDt2ULRisUPRhEc3GJtppLb3TNtnV8M1pHwhjCBxQ34MVVip0v8j03p1jqCCL8gtmYI7
         6Ygg==
X-Google-Smtp-Source: APXvYqxBXnv+S0Y5hu8OhQxFX3OJWWZVDxpvO95/4636pF8ZSPX2vsTgwse7qghOIBiFu/zcfM79qg==
X-Received: by 2002:ac2:5446:: with SMTP id d6mr23078445lfn.138.1559822664793;
        Thu, 06 Jun 2019 05:04:24 -0700 (PDT)
Received: from pc636.lan (h5ef52e31.seluork.dyn.perspektivbredband.net. [94.245.46.49])
        by smtp.gmail.com with ESMTPSA id l18sm309036lja.94.2019.06.06.05.04.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 05:04:23 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Roman Gushchin <guro@fb.com>,
	Uladzislau Rezki <urezki@gmail.com>,
	Hillf Danton <hdanton@sina.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH v5 1/4] mm/vmalloc.c: remove "node" argument
Date: Thu,  6 Jun 2019 14:04:08 +0200
Message-Id: <20190606120411.8298-2-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190606120411.8298-1-urezki@gmail.com>
References: <20190606120411.8298-1-urezki@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Remove unused argument from the __alloc_vmap_area() function.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Reviewed-by: Roman Gushchin <guro@fb.com>
---
 mm/vmalloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index bed6a065f73a..6e5e3e39c05e 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -986,7 +986,7 @@ adjust_va_to_fit_type(struct vmap_area *va,
  */
 static __always_inline unsigned long
 __alloc_vmap_area(unsigned long size, unsigned long align,
-	unsigned long vstart, unsigned long vend, int node)
+	unsigned long vstart, unsigned long vend)
 {
 	unsigned long nva_start_addr;
 	struct vmap_area *va;
@@ -1063,7 +1063,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	 * If an allocation fails, the "vend" address is
 	 * returned. Therefore trigger the overflow path.
 	 */
-	addr = __alloc_vmap_area(size, align, vstart, vend, node);
+	addr = __alloc_vmap_area(size, align, vstart, vend);
 	if (unlikely(addr == vend))
 		goto overflow;
 
-- 
2.11.0

