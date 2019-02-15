Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62B2CC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:39:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 167112192B
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 02:39:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kLj6pOyk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 167112192B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C00DB8E0003; Thu, 14 Feb 2019 21:39:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD81D8E0001; Thu, 14 Feb 2019 21:39:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC8AA8E0003; Thu, 14 Feb 2019 21:39:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 764188E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 21:39:48 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id y66so6385789pfg.16
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 18:39:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=naB3KMuHNTCaDD6/Z64EGJGrk7XQ7GW1pzVQ9Q3Vf6s=;
        b=T4UjB4KDsGJj8a3L24ZlIo6TNadpy51d/FguI3WLTISyEeP2iSSSSudqj2BZh8BH3z
         +T9d/i6NTgNyBZ+zbrnMhnio4NEwNXIVSB7mZen/BlbVDAsVZSCd4VBFZ8f15y63p8et
         9xwleMxhLf6wMHUhCRsseUU+H/BJ4jTB64iPwoC/JKW1vJrBeIQQvA8bg8mT/q1kn9UG
         KfimOoMv3mM36ADWrTL6+QF/79bsoDpsx6P0dU3gEwo7nNoNTfARJ7XmjcBpiVdyS7wM
         ehmd7CwioDMWt8K+fW3efIgp6GVqoi29Zv06wL9maRQSej2jLTUBV5Ul51nXIJsRTVkQ
         iE0w==
X-Gm-Message-State: AHQUAuZIoZiJsUsrny2oo6SZj+elA4pEgyTxO7gDALSenAvgTzm661p3
	j74Uuhn5ezz0berZgSF9zum2iBB7IRkOMVTNkDIazrGheQ5BnIAdiCJCP3IwpaJdtJoBvNUAmpl
	jxz4ozrU8qU54yH9IoIIWklglb9zgLu69g3CWvV+stL9FpTfLHTbrE4WowwpWgpvCJdl/HOkYrv
	Uk/GtadxBJREP4M8/WA7/z2mXIRYtLs/jwKghSuZ/+otq7YdmO+8FsxlcI2gac78cnrOcApQEVC
	NsQVOMRUBfv97BJQVgUTlAA5JDVnlAk44D9lV7YADXiU3evtjM05Gv1tXv+6+dOHHA5m0p5fEoI
	6siObRKz+1XrsaRjmOe903uCbk8Wsh+bTMJLxgRlt6ot+H7qcJ6KCXuCS9pp/SrpJbEqUCOp5YJ
	r
X-Received: by 2002:a63:cd4c:: with SMTP id a12mr3146156pgj.252.1550198388165;
        Thu, 14 Feb 2019 18:39:48 -0800 (PST)
X-Received: by 2002:a63:cd4c:: with SMTP id a12mr3146130pgj.252.1550198387544;
        Thu, 14 Feb 2019 18:39:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550198387; cv=none;
        d=google.com; s=arc-20160816;
        b=N94lrJHH/frwQmnjou8sbz1xisNpMutoA0BEf5kzny69PpHIjb3Eyv2+zmLDzXz84q
         YMzwRS7iMGfVTxPcLdZIjCMZ+95feKQA9iga3p0ON89cNjmdjBcpl4gbccm1A09/uuuu
         1qjU3CFepqUMfV48kC3SlmxAn2/MFJK/CPgVM8u2L0fKujkrVf1kjT4rCM/3xk8EV+gX
         7IN56AogXrurfSARs3dg5ieQYwJFJAcXqDkDdAy5lQdI34DYnaVBszUW7gd9UOVncepN
         jNyceakG1O865APQkt0NM8i3/PObq7bHdE+xfa6mtkkFUrOSzpzSoQsfA7HGgIaygw+/
         9Ydw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=naB3KMuHNTCaDD6/Z64EGJGrk7XQ7GW1pzVQ9Q3Vf6s=;
        b=tAwt1lFGrMEIVGgPaKhUwbsRnYJ1gcUyvRzkb+ZFo02FoRY5CnNdiLfNiFFcFhUgTH
         Qo4vZBPsDlvfhCaN7QeeVsALXGHbvR0TBWSUoyRFL6o2PovNmAOXiPGwvr91BGexj6zc
         OUlXLUiyW2TVe+A1JShGow0A6CnPJ/8A0HO2W2ndovMMEuEvBDW6+F0hzjVcAAhVRVSN
         WY26YZIWPHQM5SjRC3EgVr0yDNs3frZG+EJXEATF6HHCZMq1lHXLQp/N2Apk29G7YF1F
         l2kDG5fSqDipyS7PCnoyveqpBRSmJkSZ7hVg43NeBZh4Fm/+dig26d+UG4BrIOU7sVcV
         yuwg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kLj6pOyk;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g16sor6555673plo.1.2019.02.14.18.39.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 18:39:47 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kLj6pOyk;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=naB3KMuHNTCaDD6/Z64EGJGrk7XQ7GW1pzVQ9Q3Vf6s=;
        b=kLj6pOykfXcUG+qvmp8kJ2UtHrXBRj6IN3Rg/liMZsHGVPGT1Cp7dMXvFmX5uZCSeY
         B3KIkeIYAm0k1MB8GKNJ87FZ4Vy695j5l38NPs1xFMYDCLZUvhkvGy1mlKkfvT+k8GQ2
         sxhz7j+Ff8zJlO1XPDqtwuLtZpw+ZlgXtuuxCDdo1lQuxcTTQZL7hLUUEsrmJDB7raae
         ML3zxRkAZIlYzUwLc95t1N0v/NAKk5JyljdPIuHYJC9t4svAJVwEY6qRlPpJWfd+8Y21
         tfowupbrIJH1YLp3e5fxV5An+XpPk5PkF0zIASwVxYHrVgB2K7TOXw9wK0KqNnd5f49U
         yn9g==
X-Google-Smtp-Source: AHgI3IY7ZJP/9c0JvwcJkUpHOWFlwfJrQShpMUSfzKDJXptrzyrCoFV9i84p4XJmD8juyeubZ7QRMQ==
X-Received: by 2002:a17:902:1:: with SMTP id 1mr7294631pla.276.1550198387177;
        Thu, 14 Feb 2019 18:39:47 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([49.207.53.51])
        by smtp.gmail.com with ESMTPSA id k1sm4194873pgq.45.2019.02.14.18.39.45
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Feb 2019 18:39:46 -0800 (PST)
Date: Fri, 15 Feb 2019 08:14:07 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	stefanr@s5r6.in-berlin.de, linux@armlinux.org.uk,
	robin.murphy@arm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux1394-devel@lists.sourceforge.net
Subject: [PATCH v4 3/9] drivers/firewire/core-iso.c: Convert to use
 vm_map_pages_zero()
Message-ID: <20190215024407.GA26389@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Convert to use vm_map_pages_zero() to map range of kernel memory
to user vma.

This driver has ignored vm_pgoff and mapped the entire pages. We
could later "fix" these drivers to behave according to the normal
vm_pgoff offsetting simply by removing the _zero suffix on the
function name and if that causes regressions, it gives us an easy
way to revert.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 drivers/firewire/core-iso.c | 15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/drivers/firewire/core-iso.c b/drivers/firewire/core-iso.c
index 35e784c..5414eb1 100644
--- a/drivers/firewire/core-iso.c
+++ b/drivers/firewire/core-iso.c
@@ -107,19 +107,8 @@ int fw_iso_buffer_init(struct fw_iso_buffer *buffer, struct fw_card *card,
 int fw_iso_buffer_map_vma(struct fw_iso_buffer *buffer,
 			  struct vm_area_struct *vma)
 {
-	unsigned long uaddr;
-	int i, err;
-
-	uaddr = vma->vm_start;
-	for (i = 0; i < buffer->page_count; i++) {
-		err = vm_insert_page(vma, uaddr, buffer->pages[i]);
-		if (err)
-			return err;
-
-		uaddr += PAGE_SIZE;
-	}
-
-	return 0;
+	return vm_map_pages_zero(vma, buffer->pages,
+					buffer->page_count);
 }
 
 void fw_iso_buffer_destroy(struct fw_iso_buffer *buffer,
-- 
1.9.1

