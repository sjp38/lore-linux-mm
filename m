Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AA83C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 02:20:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 192662147C
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 02:20:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WSM8bcfn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 192662147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A91E46B0007; Mon, 18 Mar 2019 22:20:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A41986B000A; Mon, 18 Mar 2019 22:20:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90A236B000C; Mon, 18 Mar 2019 22:20:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5568B6B0007
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 22:20:55 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g83so8412471pfd.3
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 19:20:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=naB3KMuHNTCaDD6/Z64EGJGrk7XQ7GW1pzVQ9Q3Vf6s=;
        b=hJ8ofbebXB2W529DGhiJXrSLna0Nsry9ZCQNPeknNuPP69wkudKFOpGh66PgnLjCId
         u6OyFO4VieJml3iPfHsrnS7cIcwPQJejLzjzpbvKihmzdmKUZnAhd2QrPjvp+uelqikB
         Yv9GtTEt2edVJvwgqSS5uPm1AzX8FoWa+Cl+1FaEFArwtIdPf3X+PW3K51p+tQ5rne4F
         9Foo32dLnSj7ScZ9aX1Qp7mJDrhm4MMi2ybWnmk4QODxGBwWpaODof2CjV2Yjl91KKXV
         nscf6HUr/UYy4PeJohfR8YLsNwrCotBIAV1BLHEYJsrvidvobm2V7/J9iqZLD3Us0vqs
         QH/Q==
X-Gm-Message-State: APjAAAWCHkypPJjxK8W7Cbl0WZ6hiRZ79RlenKONF6dBw+uZUqbQ0Y+L
	8GMaFy1j28xX3f8SpZk5lgCYE6ziQPGzCjyXW+moTWjWwhO72Gm707l91rck61IyW55K0RHYVqO
	g4ZwBMsvmYwnig4u802GVAtQYeHtuaFQ2waVx0symuBhm/5johbdJ9D0yFQAwAtmU0w==
X-Received: by 2002:a17:902:282b:: with SMTP id e40mr23107685plb.111.1552962055020;
        Mon, 18 Mar 2019 19:20:55 -0700 (PDT)
X-Received: by 2002:a17:902:282b:: with SMTP id e40mr23107624plb.111.1552962053841;
        Mon, 18 Mar 2019 19:20:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552962053; cv=none;
        d=google.com; s=arc-20160816;
        b=lGH55YkQ4l+BwuMZUADZZtAYAF34RQY6qT13v+ugjqdIVMZfuLe0/qbM38lW3ry3aj
         RDs+FtMguXLNgYkajKA2mPcU0+g2axItpMKNQ4tw2vGVPH0uyVcARtDVQDN1/MFXihAU
         iFDTzvn3Pan1bFnyrGvrhWC4ddT0V+vTkk5OwmOh9RHJIppExCP2Qb6XltKq2KHKisED
         IL3QpjFsde7G/PmP0JiKpvMqKfpfyL3DaO1wxi5quNgca4c4x09fDp9okWVwcG31wHWM
         2elyCqTfPasqEYG2zaDc08xjwYR3Ohxw+pTC3WwdF7h4adL5tQ7CdDDFkkc2YjxPUgD/
         L3xA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=naB3KMuHNTCaDD6/Z64EGJGrk7XQ7GW1pzVQ9Q3Vf6s=;
        b=xZALcs7sSBjq6hsgs+iJ6Ncy5cFbgaW/0/G3D2NL9stnuvnix/Brrw1oGJCZw/84Is
         yzkGA5RkwlPGnX8RUkKKWInwD/J5s/aHEbpHMNRKmGR2NDFMXiojwZw9Vn/23ltIVmnU
         RsivHZN6jdE9QoG2hEO39h0/IUZ97d4IzsN0nJqqg4cx60AXcs9pVlLTHw9vn8hqgR0y
         +DDIJa/+tCIuTx/3Bpsg6CllLzZPsdTLC/HFcrYxR8fprhouStJN1/z+oNqfJqunVj3l
         imrjoS7H/v3+4iet1189JaiTsQrHWFwN+hda1rzTLw949rG+c8VpgXHMVW//FBiPDJaW
         ttkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WSM8bcfn;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t17sor3645587pgi.53.2019.03.18.19.20.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 19:20:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WSM8bcfn;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=naB3KMuHNTCaDD6/Z64EGJGrk7XQ7GW1pzVQ9Q3Vf6s=;
        b=WSM8bcfnzprJdWx5H+Bbv4NvzZb7wmLUkYvEXRdyRIA5Wek38wiyF5fe3XVDp6HxhT
         SvVyViH+yOhwKt5+i0vurYanvZ8p+7/XaZT+N/09Z4mb0j1ffPYCdO/VV/Rmg1j8OXR6
         l6vfFMjD9dK320LX88jeEMALCpeYCU+OZQFHRrJB7BYXIx+Wf/mTqJevt5oMTgUEhjNO
         HhGi9v8uHsnhCYu4jocHvOqIx1oxeMs3wYpDBpUnKWFzF2ByzT1hFXJfEWfMxZ9sjOVQ
         qa2yU0L1O2tZ7bhBxG+k+KBlp+I2vnJMt0+oDT36Q/jj6m8hTO9q1IET22Be90zWrdWm
         P+lg==
X-Google-Smtp-Source: APXvYqydjAiDuBrPLoPLHvLscIhaXBUi7pdqSp5G6oVnWTJMUlOMWrMZhOnpVN474rtNeCUPGWjaAg==
X-Received: by 2002:a63:4550:: with SMTP id u16mr20189420pgk.73.1552962053552;
        Mon, 18 Mar 2019 19:20:53 -0700 (PDT)
Received: from jordon-HP-15-Notebook-PC ([106.51.22.39])
        by smtp.gmail.com with ESMTPSA id m3sm13043728pgp.85.2019.03.18.19.20.52
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Mar 2019 19:20:52 -0700 (PDT)
Date: Tue, 19 Mar 2019 07:55:27 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	stefanr@s5r6.in-berlin.de, linux@armlinux.org.uk,
	robin.murphy@arm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux1394-devel@lists.sourceforge.net
Subject: [RESEND PATCH v4 3/9] drivers/firewire/core-iso.c: Convert to use
 vm_map_pages_zero()
Message-ID: <88645f5ea8202784a8baaf389e592aeb8c505e8e.1552921225.git.jrdr.linux@gmail.com>
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

