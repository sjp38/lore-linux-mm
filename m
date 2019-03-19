Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 700DFC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 02:26:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F75120828
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 02:26:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="axQ01i8I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F75120828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D267E6B0007; Mon, 18 Mar 2019 22:26:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD6616B000A; Mon, 18 Mar 2019 22:26:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC5DC6B000C; Mon, 18 Mar 2019 22:26:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7957A6B0007
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 22:26:18 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c15so21314349pfn.11
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 19:26:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=F9hIq6OqtC1SVS2O3U7ZkPoLnNclA70DsapCWy7Q+lE=;
        b=P4MXhrYtM1vcPPmbXnjFJJ55RIE6BqoNXfYf3GO1tn3u4LhI5mlYzURIpiRsBqUrMk
         C5nxr3W7W6EvYEw+UIh/4IpSFIDTNOf6G8t2bkY8FrNojyc4uM/slVV2OfrEqMdzxtMf
         axguWjgRf2O4T+LX6heyVse2+W8jEyfRgUGYNgqI1Rc61+XULE167pOoas+T9BrjteKl
         EaY25YVIAjdcJ72LHIv9JolI9eMIvl6+/mKPqYvyhzECzoogsNa2DuZHGXYY1sXW5rR0
         li9B+CSTw1amHY169dPjipvjboLIPnat7Ip+wzkkvPkuuBl8eaIfoCDyla+BTPVohQDy
         xhZg==
X-Gm-Message-State: APjAAAU/svFGFlkpqMM58zHxoSFA+SeYt9YsHulpkVQ+h4uob81tUAeP
	Wbbje4q8q/q0Ig5Pfha0QIAryrQpBzs/Ty5xNEI0M20NaMvbL7NM+PYu7mPpo2Is6G8tJQir3qO
	q7cLTzzkZkfgkHq/MmvRvnnQqDMS+LMiirbwItz0G0pLSvJGhHEqei4YTTyo1BB9Tdw==
X-Received: by 2002:a62:6c43:: with SMTP id h64mr8039090pfc.123.1552962378168;
        Mon, 18 Mar 2019 19:26:18 -0700 (PDT)
X-Received: by 2002:a62:6c43:: with SMTP id h64mr8039043pfc.123.1552962377234;
        Mon, 18 Mar 2019 19:26:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552962377; cv=none;
        d=google.com; s=arc-20160816;
        b=OS7DJDn0m85ecZ0TL5vLfmNRaAIeDcu4Fk2OEdU3/WkpYUuNKybYc9uXTmaSdngqge
         M+xrd3buzc0UFOoVpMjXaLL6U68AP1ImAQa+wlTTbzw/UwNWSKo49PxPx8abbC5hcV2V
         P+jznvdF0Bio8a20M7358CGGqekDqn8uOeW0viOIqefP4J1bNu6fBV6zcH0JE/293Uvu
         OnLsA8jvGkStcWQ+ic1fjEEvcLzFMeva2WnsnanEK7cGuvz3GVeLQYqXaKAZq4tt0P78
         I384R43EerHWiWvJjSH3VoCdLSEnmKxQGBVFp0HT91qurPGKadDFI4oKNZsv8N89uC9d
         Zt9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=F9hIq6OqtC1SVS2O3U7ZkPoLnNclA70DsapCWy7Q+lE=;
        b=jJjYyorX4jdCK4kLlZxzZgfRtxPfjCGeQnSU6PsvReDs++Zw8Un+mxRAWtY7SwLQq0
         gNmY3tnkv5LMQGIxUC++FqzPH7fNfNU54Jt/U4c7T83V9CbYXSDbnJ2XKensNniQeZiG
         C2MHelXjWSqrGieIW6MiEwmKgfQvXU0GUDOlRRnE86+6wosT46BZ1DD8fJ8H6L5Bzz39
         DQptTEVLvw5tDH+1hRdYCy8sUfNFJgtR+D47SshfOHFBcDDeeBtcLDwvLTSJD8ToBd15
         lhZ+QGZawcMTJsm14NWHRAB7JHSt1ceCwd6oWvM7zZ0a+bHr7ba9pAdjBXNP1ZvGWY+5
         8iGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=axQ01i8I;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u11sor12320246pgp.78.2019.03.18.19.26.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 19:26:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=axQ01i8I;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=F9hIq6OqtC1SVS2O3U7ZkPoLnNclA70DsapCWy7Q+lE=;
        b=axQ01i8IBZi45x8kocMbwsCnxyGWV2J6KPZD0Kvgs2/Yaw/Le0kbKh4v6TjS8TlLN/
         Fp1i11g2wUSy9AxXfQGRlmcKVs6D+8q5JgaGppoXZDWZ6E08ke8uQygcG2EGAEoCtGsx
         UFLiaLRZlpLGEKiubhXWZ/PmRqC3+92ojBfVO/yWdt0kFn/ZAPUhGKykq5XnL7GFNyle
         wwduJrwn8QRqkDXVKxcrG+gP4/1dGOKT1a0MvDM0uxgedBI0PBb86jSFen+JBmyPEcp5
         OtUtOsoojCEt6asjiBR1//iQ0mQm9kT1vJjSfz2yiTcGpUHiyQD6dTVTpKpFvR5WdtUP
         RHDA==
X-Google-Smtp-Source: APXvYqzT+r2qSiocZjhBB5Mm80gaR6+7Ywju7MjSzVTtt6VaSEqofhbQuEZfX4U+yLgEjsULEq7Ykw==
X-Received: by 2002:a63:f74c:: with SMTP id f12mr75210pgk.124.1552962376538;
        Mon, 18 Mar 2019 19:26:16 -0700 (PDT)
Received: from jordon-HP-15-Notebook-PC ([106.51.22.39])
        by smtp.gmail.com with ESMTPSA id u13sm18812634pfa.169.2019.03.18.19.26.15
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Mar 2019 19:26:15 -0700 (PDT)
Date: Tue, 19 Mar 2019 08:00:51 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	boris.ostrovsky@oracle.com, jgross@suse.com, linux@armlinux.org.uk,
	robin.murphy@arm.com
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [RESEND PATCH v4 9/9] xen/privcmd-buf.c: Convert to use
 vm_map_pages_zero()
Message-ID: <acf678e81d554d01a9b590716ac0ccbdcdf71c25.1552921225.git.jrdr.linux@gmail.com>
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

Convert to use vm_map_pages_zero() to map range of kernel
memory to user vma.

This driver has ignored vm_pgoff. We could later "fix" these drivers
to behave according to the normal vm_pgoff offsetting simply by
removing the _zero suffix on the function name and if that causes
regressions, it gives us an easy way to revert.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
---
 drivers/xen/privcmd-buf.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/xen/privcmd-buf.c b/drivers/xen/privcmd-buf.c
index de01a6d..d02dc43 100644
--- a/drivers/xen/privcmd-buf.c
+++ b/drivers/xen/privcmd-buf.c
@@ -166,12 +166,8 @@ static int privcmd_buf_mmap(struct file *file, struct vm_area_struct *vma)
 	if (vma_priv->n_pages != count)
 		ret = -ENOMEM;
 	else
-		for (i = 0; i < vma_priv->n_pages; i++) {
-			ret = vm_insert_page(vma, vma->vm_start + i * PAGE_SIZE,
-					     vma_priv->pages[i]);
-			if (ret)
-				break;
-		}
+		ret = vm_map_pages_zero(vma, vma_priv->pages,
+						vma_priv->n_pages);
 
 	if (ret)
 		privcmd_buf_vmapriv_free(vma_priv);
-- 
1.9.1

