Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D93F8C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 04:40:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C2B421850
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 04:40:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C2B421850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 372966B0006; Fri,  5 Apr 2019 00:40:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31FFA6B000D; Fri,  5 Apr 2019 00:40:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2107D6B000E; Fri,  5 Apr 2019 00:40:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C81406B0006
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 00:40:27 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f7so605179edi.3
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 21:40:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:from
         :subject:message-id:date:user-agent:mime-version:content-language
         :content-transfer-encoding;
        bh=4rBa2lQ47FOZ5Uim8SqqJyIml9N0cy9jzd71eLdey7k=;
        b=tiXuEDjJOnrZVesow7WWKEzgss9QqBqNk125Ph5+sqM5GZt+IEicm3+hRwalI0y2B5
         XPSluahYCjKxMjVqfC1Oi34+rXJ0VYMwlQX1n6s/1lsX06iWpI9AW9tkJ2HWEnu10N4v
         0O8XCE7uoW8cqS/3dXIuCmv/GibWYYzpdet7M+1eePi5TGr6yk45VAmCFbWI6DuqpdIe
         RrTjPTop3PUAHl6SqB33PaNTFo470/kwsJk11YwWBkaVdKebqwA3azhkR2786cB78ifB
         ohpTGgGfO5FheV29TaaPYCzGfg+1RKkChhJqlnfAY9eGIo7B8+t65W6wdPIJv1yeBLOd
         sjyg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXMcIDgJluCqmpWdjvIqMdPw/LZlqSKQHfjDtPIDTAchy1AcLu9
	Ka/+nB0gLucBSujE919qrKq0EyGE1s3X8e6iS+jevOD2z1VNMcK97x/S1DLBQko4AN2psjRTeDr
	YeW4t8I4d0s87dHXY86JKh6wCuRCFtjlm1Pv/VqdjFPFDErzcSrD7TaGqZrzJ3pynCw==
X-Received: by 2002:a50:97b8:: with SMTP id e53mr6499691edb.4.1554439227298;
        Thu, 04 Apr 2019 21:40:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYz8pjOBtcsz2MEAeoQV4bG9GOuGyKY0ODUfZ1lfjzyXsjnE5S6IfWf81lWFic6J3rzJAv
X-Received: by 2002:a50:97b8:: with SMTP id e53mr6499622edb.4.1554439225766;
        Thu, 04 Apr 2019 21:40:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554439225; cv=none;
        d=google.com; s=arc-20160816;
        b=vZfp4H63jIffTuoKu0PjTH8ypce1VzUYzCv0x4MG+m0PqSiACgrr/w68iEBLIMS143
         Ees2SmyTsPykXUyUao6KVVvMaYjiIRiYs88D1FCUJfF3eYCbm5oXvysr/e+6Ef6El1y8
         ZbfzUl/itVR5dILJRMXnemg1pX///ySL3Os2XBb9rxi7I2s6FJzvdUD5LnjIxDc+my5S
         TYoeS8gcB94wOeH/UouQguATeEBTMs1sf2JDBTl9iwZO/qRNnHhmfIT0qfyuZe1sOax9
         HK3yL3ZVLqX84fohSoDWRcbJTmWIrOxG6R/z//z4i1b1vzFu/sCM7r8WUOKQT0WVB5w1
         qrDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:subject:from:to;
        bh=4rBa2lQ47FOZ5Uim8SqqJyIml9N0cy9jzd71eLdey7k=;
        b=Lzga/QqdiS7P9/l9y1SW2lUKJtXJaUpn+oVzLl5kVee/5aDrcTEpg2x8CTvEEY55np
         mYRTeRObTwnLTqp6CJ/8Hjx54Lvtb9fm2/UqkKWieGmgkmPFM+vYaHhy4m7U919dvdnr
         YjXQW6hr00wPT/p0jWyj5NZtvxY30VVc3J5Dp+/QAHPzkg0L0jjo4uCUJwWcnl2vyETq
         CJYvV60bwS+Dkcuh34a42T2dWMcMDNh7CzpVv2l8lq8DT4a30iAdc4tunscfXwMP2OMn
         zeqrJv40VNxj8G2o2n3ZGQ+g8sYtDIlL6FG+UH3M9M7HI9kaGpvGuRU0v/6X1ka8LZOr
         5Gng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ci4si3005453ejb.345.2019.04.04.21.40.24
        for <linux-mm@kvack.org>;
        Thu, 04 Apr 2019 21:40:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3CC1315AD;
	Thu,  4 Apr 2019 21:40:23 -0700 (PDT)
Received: from [10.162.40.100] (p8cg001049571a15.blr.arm.com [10.162.40.100])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 30D4E3F59C;
	Thu,  4 Apr 2019 21:40:20 -0700 (PDT)
To: "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Dan Williams <dan.j.williams@intel.com>, Will Deacon <will.deacon@arm.com>,
 Catalin Marinas <catalin.marinas@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: struct dev_pagemap corruption
Message-ID: <7885dce0-edbe-db04-b5ec-bd271c9a0612@arm.com>
Date: Fri, 5 Apr 2019 10:10:22 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On arm64 platform "struct dev_pagemap" is getting corrupted during ZONE_DEVICE
unmapping path through device_destroy(). Its device memory range end address
(pgmap->res.end) which is getting corrupted in this particular case. AFAICS
pgmap which gets initialized by the driver and mapped with devm_memremap_pages()
should retain it's values during the unmapping path as well. Is this assumption
right ?

[   62.779412] Call trace:
[   62.779808]  dump_backtrace+0x0/0x118
[   62.780460]  show_stack+0x14/0x20
[   62.781204]  dump_stack+0xa8/0xcc
[   62.781941]  devm_memremap_pages_release+0x24/0x1d8
[   62.783021]  devm_action_release+0x10/0x18
[   62.783911]  release_nodes+0x1b0/0x220
[   62.784732]  devres_release_all+0x34/0x50
[   62.785623]  device_release+0x24/0x90
[   62.786454]  kobject_put+0x74/0xe8
[   62.787214]  device_destroy+0x48/0x58
[   62.788041]  zone_device_public_altmap_init+0x404/0x42c [zone_device_public_altmap]
[   62.789675]  do_one_initcall+0x74/0x190
[   62.790528]  do_init_module+0x50/0x1c0
[   62.791346]  load_module+0x1be4/0x2140
[   62.792192]  __se_sys_finit_module+0xb8/0xc8
[   62.793128]  __arm64_sys_finit_module+0x18/0x20
[   62.794128]  el0_svc_handler+0x88/0x100
[   62.794989]  el0_svc+0x8/0xc

The problem can be traced down here.

diff --git a/drivers/base/devres.c b/drivers/base/devres.c
index e038e2b3b7ea..2a410c88c596 100644
--- a/drivers/base/devres.c
+++ b/drivers/base/devres.c
@@ -33,7 +33,7 @@ struct devres {
         * Thus we use ARCH_KMALLOC_MINALIGN here and get exactly the same
         * buffer alignment as if it was allocated by plain kmalloc().
         */
-       u8 __aligned(ARCH_KMALLOC_MINALIGN) data[];
+       u8 __aligned(__alignof__(unsigned long long)) data[];
 };

On arm64 ARCH_KMALLOC_MINALIGN -> ARCH_DMA_MINALIGN -> 128

dev_pagemap being added:

#define ZONE_DEVICE_PHYS_START 0x680000000UL
#define ZONE_DEVICE_PHYS_END   0x6BFFFFFFFUL
#define ALTMAP_FREE 4096
#define ALTMAP_RESV 1024

	pgmap->type = MEMORY_DEVICE_PUBLIC;
	pgmap->res.start = ZONE_DEVICE_PHYS_START;
	pgmap->res.end = ZONE_DEVICE_PHYS_END;
	pgmap->ref = ref;
	pgmap->kill = zone_device_percpu_kill;
	pgmap->dev = dev;

	memset(&pgmap->altmap, 0, sizeof(struct vmem_altmap));
	pgmap->altmap.free = ALTMAP_FREE;
	pgmap->altmap.alloc = 0;
	pgmap->altmap.align = 0;
	pgmap->altmap_valid = 1;

	tmp = (unsigned long *)&pgmap->altmap.base_pfn;
	tmp1 = (unsigned long *)&pgmap->altmap.reserve;

	*tmp = pgmap->res.start >> PAGE_SHIFT;
	*tmp1 = ALTMAP_RESV;

With the patch:

[   53.027865] XXX: zone_device_public_altmap_init pgmap ffff8005de634218 resource ffff8005de634250 res->start 680000000 res->end 6bfffffff size 40000000
[   53.029840] XXX: devm_memremap_pages_release pgmap ffff8005de634218 resource ffff8005de634250 res->start 680000000 res->end 6bfffffff size 40000000

Without the patch:

[   34.326066] XXX: zone_device_public_altmap_init pgmap ffff8005de530a80 resource ffff8005de530ab8 res->start 680000000 res->end 6bfffffff size 40000000
[   34.328063] XXX: devm_memremap_pages_release pgmap ffff8005de530a80 resource ffff8005de530ab8 res->start 680000000 res->end 0 size fffffff980000001

Though this prevents the above corruption I wonder what was causing it in the
first place and how we can address the problem.

- Anshuman

