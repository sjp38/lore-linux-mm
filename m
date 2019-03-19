Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37410C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 02:25:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB5E720700
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 02:25:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jiBtkKML"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB5E720700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F6976B0008; Mon, 18 Mar 2019 22:25:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A6416B000A; Mon, 18 Mar 2019 22:25:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6960E6B000C; Mon, 18 Mar 2019 22:25:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 310B06B0008
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 22:25:35 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y2so7741656pfl.16
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 19:25:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=n/NDS47nz9uuNytg4LeJJ+li959uQqsTwzm1mhrxiWA=;
        b=fWNM+ucDOl0RhGecWb8DWDP+EUmYELcIKJW3MDS2s0pxG3ievRcLoOOEONlAqfuPvQ
         lauwYJdk3NKtLjWae1R2aKObvVafWJTdI+jRPsBouLRm+DGhMG5Rc1lkHn+g4BbNb2wG
         yK/YYz9tnVVRc9hWj1pBZz4+4x3j0zgGwmATA29eolhyA2wK4vjdTTQ7WzzDD4RY+Nwd
         wVIx6bCqUUfr37CVvwHwd0y/Oh2bCbtAXU8rWKhCWkInGf3IhrgI/IF9YqDpikBANdem
         YESSbtMZmDGePJoSH+nJp8dNT8UquHEPILv2n2ZgBfSpWrsahnNi8/WqqnO0uWv2nsva
         sYbw==
X-Gm-Message-State: APjAAAXU8c5JM12b5UsuEn2rt0u7dZUbURQYBLWc/tNQVS68egIZf0RH
	trCEKyPnMT2YtKZtLFeLdO8NR/CoRNFGKwCMIr6Q3siC9DkAqCuaMC7LO+K4LPQmjylWE0M/M/a
	RDoz1ZpsA8UOJx9lp5tQGO5jdlD9pTG2q2Dy4TQ7aPn8Kgo7XTqFgkC0ZHP6R3lYeRg==
X-Received: by 2002:a63:104e:: with SMTP id 14mr20422690pgq.185.1552962334863;
        Mon, 18 Mar 2019 19:25:34 -0700 (PDT)
X-Received: by 2002:a63:104e:: with SMTP id 14mr20422631pgq.185.1552962333677;
        Mon, 18 Mar 2019 19:25:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552962333; cv=none;
        d=google.com; s=arc-20160816;
        b=KOftxjekbZ2EAI+3cYiWZRcpX9unCtKQ4dj8iIAqObZ/keqoerXYYjlOatHZHVNOsV
         TDKmXkiwlSpYWTjXxOHF/gXKmZuR5xklBvv7hGNu3YeBDYfVKK0GlM5YFWI2EplOQdeI
         Tru+Dtv4ul3yusfXkg16e6SnAK/rVapN6lOgkouNIeAi4wkSq1cSSOqY5QgOBCAH47qr
         PZDZH3qCrfmgTOM0sYjyIcpsHhYzMmX3e9JmJJQxyi2IZEFFCBIFQQbqUW/9kmmyjAJG
         CyEme8GpfKbgKBkGaDUNaZga6MRDIqjKWenWftCjGjFpKjvuRH8ZIqAU8X1aOOVkK+Sn
         xn0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=n/NDS47nz9uuNytg4LeJJ+li959uQqsTwzm1mhrxiWA=;
        b=F3oDSS5RzXXpchDcCWzZgrgUBOVYQ+6wBTDB4r8ARTt+L66Y6goY75s1iPERmOYdpW
         y5q0BCo9QORGRC9dP+j/gqX417sMPykuG+kpb+m7ZzBSSvdzNjWATtv9d9U46LM2g5pp
         DaCTtAsdUBNx+axb4lQEQ5KDorABG7XN+MsvjtRnnLFz0zTLf3u4+5nAVBoHIKK3Z0HX
         wDIaq2gVq1bO+cc6+Xm0Zt/NxoTtO8SwWqlFlVe56mNaEX/U+LhTr1Gk48MNEe7+B4Ma
         Nu9wyvBMejcVN5SVppZodyT9hcQYXm2UWZSNgX0XeWmQOT0IeV4UkRZm+7XEuojeFhsP
         1kmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jiBtkKML;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s127sor17669816pgs.7.2019.03.18.19.25.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 19:25:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jiBtkKML;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=n/NDS47nz9uuNytg4LeJJ+li959uQqsTwzm1mhrxiWA=;
        b=jiBtkKMLnhknyJBqO0pykSJ1rbddZqUTZxiCQSo/SQdWsCg6rLr0Cy1/XcNb01JLUe
         arpg6kvnCyN5mQVoBrYIXH3jjsPbg038amLqb/8cOmOdXYXMUoJGico4viaD0NRc4vzS
         tqNZi/bzEiId0TsLouzvEpgHrIloi0yxX3b5HKTc68Ot8AOc22832Bwi6kZpXbWljicc
         Z6NmfIIGCh7KJixA06QsQBncUA/fr0iFgC3sIQ2960zrQ/E63Zzk79r1DAeIZ/RVs56o
         Z92k7Ksf6tDBHwMo12HW/o2rx8yQUNX35Sfm4tjZIIcRXJ2dzt3xtZBPd9C4QamrFLr+
         ZhPw==
X-Google-Smtp-Source: APXvYqw25r5MaAPOEBNu+onH2jr/m6hG8lprEL1PtpTxaPWtjQk1ZzP3VFv20URyYkFjUUqJo+9YQg==
X-Received: by 2002:a63:ff0f:: with SMTP id k15mr7714pgi.301.1552962332881;
        Mon, 18 Mar 2019 19:25:32 -0700 (PDT)
Received: from jordon-HP-15-Notebook-PC ([106.51.22.39])
        by smtp.gmail.com with ESMTPSA id b17sm3327180pgj.79.2019.03.18.19.25.31
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Mar 2019 19:25:32 -0700 (PDT)
Date: Tue, 19 Mar 2019 08:00:07 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	boris.ostrovsky@oracle.com, jgross@suse.com, linux@armlinux.org.uk,
	robin.murphy@arm.com
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [RESEND PATCH v4 8/9] xen/gntdev.c: Convert to use vm_map_pages()
Message-ID: <88e56e82d2db98705c2d842e9c9806c00b366d67.1552921225.git.jrdr.linux@gmail.com>
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

map->count is passed to vm_map_pages() and internal API
verify map->count against count ( count = vma_pages(vma))
for page array boundary overrun condition.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
---
 drivers/xen/gntdev.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index 5efc5ee..5d64262 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -1084,7 +1084,7 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
 	int index = vma->vm_pgoff;
 	int count = vma_pages(vma);
 	struct gntdev_grant_map *map;
-	int i, err = -EINVAL;
+	int err = -EINVAL;
 
 	if ((vma->vm_flags & VM_WRITE) && !(vma->vm_flags & VM_SHARED))
 		return -EINVAL;
@@ -1145,12 +1145,9 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
 		goto out_put_map;
 
 	if (!use_ptemod) {
-		for (i = 0; i < count; i++) {
-			err = vm_insert_page(vma, vma->vm_start + i*PAGE_SIZE,
-				map->pages[i]);
-			if (err)
-				goto out_put_map;
-		}
+		err = vm_map_pages(vma, map->pages, map->count);
+		if (err)
+			goto out_put_map;
 	} else {
 #ifdef CONFIG_X86
 		/*
-- 
1.9.1

