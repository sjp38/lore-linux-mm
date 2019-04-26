Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50128C43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 10:28:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 153602084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 10:28:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 153602084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F5666B0007; Fri, 26 Apr 2019 06:28:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B2E26B000A; Fri, 26 Apr 2019 06:28:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8461F6B0008; Fri, 26 Apr 2019 06:28:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 451646B0006
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 06:28:22 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id j1so1746104pll.13
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:28:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gQYT5P+ht7eVzcc7fL8kuF7anDSCynUFeYAAcAZAgn4=;
        b=kVGapTVf1rSjNyOumH4zrrH+fgALTfyM8iCKGhtAL38wjKS/d3epgitdeAKavwO8sR
         u6yK8DxEKD+Hu6X0Sm1LPKgfO4zZ31XKstzXdOzdY0YLp31eEJ7gozkPl2WZt+Ol/p5I
         emBAAMKTI4jRzxCNSkeVJMYqX/iHP4cyQil5Xa/SfZ4u8E79vOKfIIK2UiFfJTg/4tLS
         J447SC3XuCYEKUJHpNrJMbCL3ZJvjGIf6mBTaaGmhHK+DaQZbJLXtUSpba6yltG9kYU9
         JGztAKVcwtc2MkfMWgMmUrugA+mkibx93CRoXA6sifHgkj78Zxdl8ztjffofetLdQM01
         dgqQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX2qjqbFarNfX/LMjFKNm+3pzrpm1Pb3RuumiAMhHjkb1y59wVT
	Ts+aB7dsLkI9Uij1/ar4K0TU+agmQ1vtZut9xlzbvyIPZoDjMidKQUWQr8gHNYd+7VFyyQ4GfuZ
	Puz/HVO64YUXK+/Zs1HXK1VhzA1x3lU7gYLkM2jjQkbXIXaQ6YVjuzkCd3An1uJaPxA==
X-Received: by 2002:a65:5106:: with SMTP id f6mr43187110pgq.253.1556274501950;
        Fri, 26 Apr 2019 03:28:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaZUsMYtFUAKZZugBELZMwFj2Ikub7QDtQQXcsEAtQWnRCXbj0SEZQDCHyioxUONheFIv6
X-Received: by 2002:a65:5106:: with SMTP id f6mr43187049pgq.253.1556274501159;
        Fri, 26 Apr 2019 03:28:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556274501; cv=none;
        d=google.com; s=arc-20160816;
        b=l0VTvRueixRwpKEkUxzqZENc7CBfg4aicyFEk/zNK0BknW03GdrA0o1Xv+LPugW8NX
         AiI4j1hIkVlzSJPS/71R/zvzg5r0f4gf/3KZnv+EmLukHN9XeCjQduNRgj5zvwc7b3aD
         F1lyIrBdTZD4OXJByTJlcxqW+i1O/uWWiJsX8eVSZ2fBVul9v2cyjsTcFN2sdh+wYpHa
         iUtNQ9IfiLP17xFQrJOm9vpelLXbicagZJ1H54I5ysN15sZJG+sPApW6iidKPoqyYBvi
         MY49C5giqTUYngoPur1XoFlJQBsX+zXSWpbI/sDqtOS7y/KaONyNWq1ZQ+/AmV6/FVor
         bYCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gQYT5P+ht7eVzcc7fL8kuF7anDSCynUFeYAAcAZAgn4=;
        b=Z5hHpzxT3Ezhv9cNiY89Bk50bSQOuidjPGjUmzyNJbTXgcNhExDjgGLHm6EBWtPvD1
         XgGpH7wHZQ2el5JK+OxiRkvNM5aXgQnWmMk0fSITfccZeaRgCXmVH1j+VXg5tTEqfzqU
         DKsNMwDAK3VXYJblKkaQXmPhWHqV3441qvG5W3UBWbH6sO1RYhkSYrh+dEbC/uX01B3C
         82d8nYnYLpdX8XycBM/NdrBsW1BTgBogxfsuRYzP7zFF4r7WRwavQ8i1J6D2i3bm/Gjb
         r62D+mzKhSTWEfeoqpkxg//m988h9xqO+XMtwY4Pvf/TRBhWcGmaO3IqLhGBcDRr7rzV
         eD+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id w11si24191458pge.187.2019.04.26.03.28.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 03:28:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Apr 2019 03:28:20 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,397,1549958400"; 
   d="scan'208";a="146022770"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by fmsmga007.fm.intel.com with ESMTP; 26 Apr 2019 03:28:19 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hJy5a-0002gd-Iy; Fri, 26 Apr 2019 18:28:18 +0800
Date: Fri, 26 Apr 2019 18:27:48 +0800
From: kbuild test robot <lkp@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>,
	Manfred Spraul <manfred@colorfullife.com>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: [RFC PATCH mmotm] virtgpu_gem_prime_import_sg_table() can be static
Message-ID: <20190426102748.GA77131@lkp-kbuild16>
References: <201904261833.Kd9aE58N%lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201904261833.Kd9aE58N%lkp@intel.com>
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Fixes: 4a323f14cbb7 ("linux-next-git-rejects")
Signed-off-by: kbuild test robot <lkp@intel.com>
---
 virtgpu_prime.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/virtio/virtgpu_prime.c b/drivers/gpu/drm/virtio/virtgpu_prime.c
index 8fbf71b..6e8880e3 100644
--- a/drivers/gpu/drm/virtio/virtgpu_prime.c
+++ b/drivers/gpu/drm/virtio/virtgpu_prime.c
@@ -40,7 +40,7 @@ struct sg_table *virtgpu_gem_prime_get_sg_table(struct drm_gem_object *obj)
 				     bo->tbo.ttm->num_pages);
 }
 
-struct drm_gem_object *virtgpu_gem_prime_import_sg_table(
+static struct drm_gem_object *virtgpu_gem_prime_import_sg_table(
 	struct drm_device *dev, struct dma_buf_attachment *attach,
 	struct sg_table *table)
 {

