Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F2A2C43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 19:18:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46F76208C4
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 19:18:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="h5z1bbu8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46F76208C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12F796B0006; Wed,  1 May 2019 15:18:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0DFCF6B0007; Wed,  1 May 2019 15:18:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F11056B0008; Wed,  1 May 2019 15:18:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id CB56F6B0006
	for <linux-mm@kvack.org>; Wed,  1 May 2019 15:18:51 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id k68so60347qkd.21
        for <linux-mm@kvack.org>; Wed, 01 May 2019 12:18:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=154pK5P8ksWbhOO3IYrUyqpSsi0GfqRRa2gpHRslqUk=;
        b=jEPl0gs8vGQ/bvkgfUH31fTi9sO6wJPtahABjccrr0qDY9PPTIMscuzGncspJWpbXH
         nnb3GCQ7U4vwjGuItw6VmV6WHs6SCBpjwfwDAMitUQaAL7mAReudbu90g7WgzX2DTWlE
         lf3F55fmiaOnDcnb9+IgHLJmKoK8wt9LwGcicI6p0Pnms+BL7JRplcNT3IheEIvXN8QP
         NBQVZoOV7pOAHtEnJbEbSiDdQpS7NnG0xOdgk0Ia3uN6fTxr6IuV9CLbpsJD1Wki2ZBa
         LQ66w8hj2fBGEPv4S1eC8FeyKWJDnhU0mIbKdZxRjA2Xnx1rWQDJ7ZV9uBzynCIJwvdb
         RY/Q==
X-Gm-Message-State: APjAAAWczlu8G4JzYVApEhOQSy/DkGPgcnODUNCKLiNmaBl3YgYKEVbe
	OOk9+P0KkSFQhsnSOAGmj7xMRT/UJOr70Hd0EZyrA4jDkRZK7D609BTfXE4zjx7tdbn8afp3Vdl
	zl5hmnCQHqq2XdpXuoG6mGFK2ZVTSvaI+CA8TnMDD8N70gR+UGQeOqEcWcHxNqZbwbg==
X-Received: by 2002:ac8:35d1:: with SMTP id l17mr38309568qtb.43.1556738331620;
        Wed, 01 May 2019 12:18:51 -0700 (PDT)
X-Received: by 2002:ac8:35d1:: with SMTP id l17mr38309522qtb.43.1556738330827;
        Wed, 01 May 2019 12:18:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556738330; cv=none;
        d=google.com; s=arc-20160816;
        b=h6O27FmkeNw1WGSMa6LntOyuo3Qn0hTN8lnwR+SWElpLAtKXCEd+bd7IfFJfM+PmJm
         2EAhED2MfBa4HiUkYZBR0y0n5ivnQAtF2FnfnDO99pAunrZ4kfKHCGHiVG1RDFrM7Dft
         IcENqNa0gfG4pPnKkO1xRYCGwtB7xzn30aGMZF12OmE57sIEh/yV6LhRc2cEb4php6gO
         PADdk9XvTD5gsbdpupgps7B1rW7Za6/9Vma7xmfnJDPmJIr2WQn/tkJGCofkP2FyOvMY
         HSjHhbFSXGGbEUQidOZopZPNqrR824kiQWjoWNeZAHSnEVpsxogTQTatHfSaN/kUHBRl
         ntug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:dkim-signature;
        bh=154pK5P8ksWbhOO3IYrUyqpSsi0GfqRRa2gpHRslqUk=;
        b=ObTEgpNh2C+opSMh9abk06aTOKjoODimMA62JoCNb0gTzltt/U8j2rsEhXTm4xt9q5
         wXlhx6CO/U+N4p4rZDeoG3XxGaImm3FO+HDdRA+BY2F+bsck+f67OrVRg/0HDL92sF08
         p38Pms77pBO/iwD7pzp1yqvrPLMfxfeNF/gx0MFk/t6FSfbtWoWqHQIXrmcPaHvSD6e1
         GGvlmhXctjlx2f4SPej5TAskdRpZ2adAuOFhSFOuck8jJOGbngsElbHS3pgRkwH2NASl
         hS6yRuqF6VmrijiMVTEnHzdc8J1G3b+hGaFpjyZ0qJDLYjXBuSVZZrb2q9+dsamhm+TU
         RAMw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=h5z1bbu8;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 34sor39454652qto.21.2019.05.01.12.18.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 May 2019 12:18:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=h5z1bbu8;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=154pK5P8ksWbhOO3IYrUyqpSsi0GfqRRa2gpHRslqUk=;
        b=h5z1bbu8My60moCWezm7iQzfloAmd6aTxFKQXLUkDNyrqdYqTncDVWNt2X09qLxS3O
         XbNJsC/XnK1M4hHGHUsGpsWWJ1i66/0sC4pt//GILaeXj67jLKultNg/URuZLHxy9DUB
         n145ZqRuwWAPC05ewtKDW6T9fCTUIC1kV7gqHfS7NkOhqxEGKbdYX3L3QdBy8QG0TK+2
         p6Kiqtc4e3Q23gKMdpkbaVSUh5m4WX/FZssFEru/tThscoqK4pj6kyblkhFibSSTqHps
         jlV9ibZk/xaZpnwzsnlF3l2rW+yE2UD5A3zFgwhJCF3/xcOWS93XsJ8nIPrSkr14x6H6
         r4Zw==
X-Google-Smtp-Source: APXvYqzlA1gs8NVCmNdnzWYF++bUyEWeUdXTHpCbd3dCNNP+aZRzqljBcQRUhKZSNsgRGIhKd6+NhA==
X-Received: by 2002:ac8:1c82:: with SMTP id f2mr8326722qtl.68.1556738330592;
        Wed, 01 May 2019 12:18:50 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id x47sm12610946qth.68.2019.05.01.12.18.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 12:18:49 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: pasha.tatashin@soleen.com,
	jmorris@namei.org,
	sashal@kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nvdimm@lists.01.org,
	akpm@linux-foundation.org,
	mhocko@suse.com,
	dave.hansen@linux.intel.com,
	dan.j.williams@intel.com,
	keith.busch@intel.com,
	vishal.l.verma@intel.com,
	dave.jiang@intel.com,
	zwisler@kernel.org,
	thomas.lendacky@amd.com,
	ying.huang@intel.com,
	fengguang.wu@intel.com,
	bp@suse.de,
	bhelgaas@google.com,
	baiyaowei@cmss.chinamobile.com,
	tiwai@suse.de,
	jglisse@redhat.com,
	david@redhat.com
Subject: [v4 1/2] device-dax: fix memory and resource leak if hotplug fails
Date: Wed,  1 May 2019 15:18:45 -0400
Message-Id: <20190501191846.12634-2-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190501191846.12634-1-pasha.tatashin@soleen.com>
References: <20190501191846.12634-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When add_memory() function fails, the resource and the memory should be
freed.

Fixes: c221c0b0308f ("device-dax: "Hotplug" persistent memory for use like normal RAM")

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Reviewed-by: Dave Hansen <dave.hansen@intel.com>
---
 drivers/dax/kmem.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/dax/kmem.c b/drivers/dax/kmem.c
index a02318c6d28a..4c0131857133 100644
--- a/drivers/dax/kmem.c
+++ b/drivers/dax/kmem.c
@@ -66,8 +66,11 @@ int dev_dax_kmem_probe(struct device *dev)
 	new_res->name = dev_name(dev);
 
 	rc = add_memory(numa_node, new_res->start, resource_size(new_res));
-	if (rc)
+	if (rc) {
+		release_resource(new_res);
+		kfree(new_res);
 		return rc;
+	}
 
 	return 0;
 }
-- 
2.21.0

