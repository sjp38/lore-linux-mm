Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 420EAC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:03:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB747222B1
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 14:03:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VpMiZSwr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB747222B1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 774978E0002; Wed, 13 Feb 2019 09:03:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 723658E0001; Wed, 13 Feb 2019 09:03:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C6EA8E0002; Wed, 13 Feb 2019 09:03:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 16C488E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:03:12 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id q20so1782252pls.4
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 06:03:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=H3f1MfvSqhk7fYk2/rKXnYTMr6+lbY/NU0rOXhC8O5U=;
        b=TsG+z4oxi0qtx9Ay48e04jc9kV6FsqViiDjz32E5JqRCESwxs90eiHX+p0DSb4sFY0
         Swls+OFXHCiB8xJYWtdU8caRq4XcVz5uDI9vVDm35FAut5yDXycRudv9KYIWdFBPQ8eC
         iCFQJdLJ61BiqzKWzPUIw5EYsG/rlZ0dH8EC3RQoxH9seK0StUceC3/YpkJMoaqPmdvy
         xajMpDMMZG2Capbe8BiUIt1LfKkMbv50E8LrI5UI9Bsvi0LFpSPMTkWfOhMFVwn3/0/F
         5037atv+MuzG5R9GMCyeM9TNGf9BwEEEHpVHHRzaTq3GfJ5Zt1M/teI5ED3WHjqP4sYy
         n1Dw==
X-Gm-Message-State: AHQUAuZTUS41F4cPW0lkI6eUvKklF+XAAKVXeCEazlTXWl2ww/mbMlOR
	RH/VstodosF6CmdaOrluiSXNttSn9IRw23wJehBYjM4QpTn+T6SDmrhw/YszELOB+1bCUvzd6lu
	DukfnBJKGJZ8DN0KJSTNc0lNJrCEisAe7+7TUSR1wxAUnUoirhVYsXNOYe2zltlxCFNRcEAVPAK
	p7n585UfUxAJokv+/NJjoCWQwGDKkX0Dar4m5JGHFHpFRHCYoxrEkP+7bIfKiLi1Ra2VHJnsOT6
	7vNjOE++C7XqIONiMIoIy6XV+swTkug6UaOpHPFqBgsDPILAtGGQg1PVcoJLHOT8rZ5cFz4PRgz
	MegTJCkytZys1nt/7tkZ68d6dIA3Q8/h7fCJuVCrP6fy8q99lCVdv2X4gnRGgGimvB7q2va8qXB
	s
X-Received: by 2002:a62:1043:: with SMTP id y64mr700606pfi.78.1550066591766;
        Wed, 13 Feb 2019 06:03:11 -0800 (PST)
X-Received: by 2002:a62:1043:: with SMTP id y64mr700547pfi.78.1550066591005;
        Wed, 13 Feb 2019 06:03:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550066591; cv=none;
        d=google.com; s=arc-20160816;
        b=KO+YfERRAmBoA6yNBbsMuZGCytfHa4x+M9QXhnMVJBwrfQx+0M8vPIgN/Vxs5plw3K
         mUhYos/FM8dI0GV0cLuDxBJ38CTw0TiHz9F+lFkayTPmKxfN4EOSitwFTr9HGKF0NeJc
         umVv9EWMIp9UjM95kEp6xB3KDYZfaQCVWFj/H6p7hvmOVhPJc/ifBON9GHpaklEXtKVi
         3NR2fmatRFqBuyTXLE7japXl+gvIjnFUpKI6ktF9Q/+6xfQgSo0e5eCRRQF8gIB1rGjS
         e0WD9bBEZiL63jZ4F/EFjUn99Sd1hpl9o3NCJxxLzVlZVcMCNXd+YR65PBap60Pc86R+
         ujzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=H3f1MfvSqhk7fYk2/rKXnYTMr6+lbY/NU0rOXhC8O5U=;
        b=sJbpbUQP78GT6S487a5Wrp9547VLeZ8iocD75aqEbNj08tYRgbkp/5WWxAyRfupExn
         TE4sErQmZ2DJOOAxQ+dU2RxSVufGqw841UXiIKIoGmjBbdpDh57+w4sYglMsaIfy7DZQ
         60wtotFawPRhBpCH3fn7x7payW/w5YhBYFPxWMIn61eEHAX3IwnW/Eq9VuNk5/owswtI
         CeHpajF4rXta05bH42ja2G71Y0b6mYOXX/nnUQKenVJBEtyJeXjeM0ZwJlz5T4jrw91g
         FIhJENDB8gTPUHI2zDWNqBXCYl+Y2xgVX96oI++akhB7RxOdgVAymQqpnkciaxGcn8jr
         nlLA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VpMiZSwr;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k20sor24608719pfb.26.2019.02.13.06.03.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 06:03:10 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VpMiZSwr;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=H3f1MfvSqhk7fYk2/rKXnYTMr6+lbY/NU0rOXhC8O5U=;
        b=VpMiZSwr42h7RxTwV/fk8d9BvpQX7IxZRgpbvLieA3dNWhefjo4gx9DsgkSJxHG5xY
         wC8gs8rhLMdhakzvA7oL3jNRziwz7HEyOTtO2L3OQIzTamDfB/biwjzged3RE0GG3ATU
         xuWbBjt2GRG8opSicVG2QUTYyUnn+GGduoR+U6oEElaJScHfTOMoRrcwP5w0vms4QADZ
         9VBDPI8ieNLKUwgTj1XSYpg8Ft8L5J7CWA6BmuBq/Ue9jTcjw/QWui/8DSIihzIKTXLv
         OQeBIirsIL7XlCwp3H6auQQD2MIsgvPcgl9fMY7o0nzmpEMK84/HhiQq7ryFqw3J6BLN
         P70A==
X-Google-Smtp-Source: AHgI3Iak/rjAyAcN8Vw2WTjmvGMW4dx0H2O1oZmqXhf6ReElXpJJUKu4heHYpMVKWTk/KCbDtzDT8g==
X-Received: by 2002:aa7:8497:: with SMTP id u23mr631577pfn.253.1550066590259;
        Wed, 13 Feb 2019 06:03:10 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([49.207.48.54])
        by smtp.gmail.com with ESMTPSA id o2sm27533402pfa.149.2019.02.13.06.03.08
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Feb 2019 06:03:09 -0800 (PST)
Date: Wed, 13 Feb 2019 19:37:28 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	boris.ostrovsky@oracle.com, jgross@suse.com, linux@armlinux.org.uk,
	robin.murphy@arm.com
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH v3 8/9] xen/gntdev.c: Convert to use vm_map_pages()
Message-ID: <20190213140728.GA22080@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
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
for page array boundary overrun. With this count is not
needed inside gntdev_mmap() and it could be replaced with
vma_pages(vma).

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
---
 drivers/xen/gntdev.c | 16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
index 5efc5ee..7f65ba3 100644
--- a/drivers/xen/gntdev.c
+++ b/drivers/xen/gntdev.c
@@ -1082,18 +1082,17 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
 {
 	struct gntdev_priv *priv = flip->private_data;
 	int index = vma->vm_pgoff;
-	int count = vma_pages(vma);
 	struct gntdev_grant_map *map;
-	int i, err = -EINVAL;
+	int err = -EINVAL;
 
 	if ((vma->vm_flags & VM_WRITE) && !(vma->vm_flags & VM_SHARED))
 		return -EINVAL;
 
 	pr_debug("map %d+%d at %lx (pgoff %lx)\n",
-			index, count, vma->vm_start, vma->vm_pgoff);
+			index, vma_pages(vma), vma->vm_start, vma->vm_pgoff);
 
 	mutex_lock(&priv->lock);
-	map = gntdev_find_map_index(priv, index, count);
+	map = gntdev_find_map_index(priv, index, vma_pages(vma));
 	if (!map)
 		goto unlock_out;
 	if (use_ptemod && map->vma)
@@ -1145,12 +1144,9 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
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

