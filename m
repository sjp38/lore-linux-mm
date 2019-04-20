Return-Path: <SRS0=t1VS=SW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D948C282DD
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 15:31:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F07452087F
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 15:31:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="gv4y9y7c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F07452087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EFFA6B0006; Sat, 20 Apr 2019 11:31:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A1346B0007; Sat, 20 Apr 2019 11:31:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1446B6B0008; Sat, 20 Apr 2019 11:31:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id E521F6B0006
	for <linux-mm@kvack.org>; Sat, 20 Apr 2019 11:31:53 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id g7so6657622qkb.7
        for <linux-mm@kvack.org>; Sat, 20 Apr 2019 08:31:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=CYN5iyU5BivsuLuaj0p6OjCQw7Id7vPwrKGL/YIcXb0=;
        b=rMSZhlOjRa2Gi6WMk/QVewj+kvQ8YzMXE18XYEmPgd3VbG3bpXtEAN7hgiFJ4CLo6Q
         3ZJHnu5mk7nRlt0GMeZd0SsuYsLfgSMmPPokXlVy4eMr1RewP8HaguHnGB2XcmB9TKkw
         Nj6zxTVOgAudUGTnh7xs68T+5VAsewbymbIrFp+KBeEPf49Ppk+oQ75Ob5e0JMIoXGFK
         cubTqiZ6pwNBPvkYIhvwk8G066k5QZG3HQm967juWox09E+ZvQrOmOMR7V42Qss4HPN6
         +WhR7E36jWIio+DBmJSSVhTjuV0P2evOEcdTgH0mZoKbH6dTdVG3SXmys3WJIQoTbqqD
         v+fw==
X-Gm-Message-State: APjAAAWIEPWXQ+gCEqNLk54BW5t7IxtunKCI7ZG0ZklyZ6slDTq0jQyD
	+pY11S2EHTSM4DqbkmryFjW9Jm2XXvEiZjjDko8OiFxY8KzH4dxCj9ShpmCg4L9E3twF8z8b3aS
	lMOLx9tBVO8alFpT7S2iIo1/gzfHwVpxcp9sZEGTR/CwdkY3Z3Pxw1Z57kPkIzj51ZQ==
X-Received: by 2002:a05:620a:108a:: with SMTP id g10mr7606321qkk.309.1555774313623;
        Sat, 20 Apr 2019 08:31:53 -0700 (PDT)
X-Received: by 2002:a05:620a:108a:: with SMTP id g10mr7606268qkk.309.1555774312841;
        Sat, 20 Apr 2019 08:31:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555774312; cv=none;
        d=google.com; s=arc-20160816;
        b=NEx+kiItZK7/NVNUG0Keptq2H5CcMQNQ8pxSyzi/Hu7NYEVOBaZPAM9rEm3kpxTm7Z
         i2BEG/Sl9Zai9qcANHLO1dBW1nv4+hHv2xOJ6d18duxB73/uAr+b2DMEmg1/ivmiGt6T
         +RTsmRm3HwQXJuwhRALwVaFFFXvVZgeG+zq9Dledn+s41BrizHIANNybNyJyQtnnHf8l
         IBx4IQqttyS9n6sxmCcbBQU1O0ZTo44yxXKMMUC3GRMzSMJAD9zAz9Cacunyrdjfzf0f
         IfTEdt4vBc7CA/QC2T/2bfRQIoBIbpx8Pmwrk0HmBJhbH0uvLgxtZvvaWhiw2IMUVpsk
         6eqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:dkim-signature;
        bh=CYN5iyU5BivsuLuaj0p6OjCQw7Id7vPwrKGL/YIcXb0=;
        b=PFfRFp48w3cOIJaprlYgD2FgCp/QqDPDcDpY4g97POCMuiNTp9WRzg6KPRD7rwA9Ul
         dZuAuGSJNHUaVHeXCwWI9SMFHhvQzalscJG2kt99d3bU73Bmt9anR/P/L3reVSEmSlo/
         9drvGQKlAZCuTZK1FEuCJiy3ZeCrHJOo1qpyVVsupkjOAvD6MOXNuOAKss+odY1JuNKN
         2k+yfXOZNHQ5/bvMsYlOUtAIfuigpb7rZhEoFr+tKtoKU5KzEC3oxdCgJOEnhIL0DeWm
         IsIOC+KxJ6oXaFyeFccLEjUJvkLf8v798JW+ctMZmnEQzxz4abpE9pZkXQe5JHZKr5Ud
         l59g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=gv4y9y7c;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v15sor10962397qth.40.2019.04.20.08.31.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Apr 2019 08:31:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=gv4y9y7c;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CYN5iyU5BivsuLuaj0p6OjCQw7Id7vPwrKGL/YIcXb0=;
        b=gv4y9y7cf3o267pQaWmOusE3XjrIdET78C/jhvKeJOOIswRYeg+xJ6iCNkoIp7jwe8
         eMfmiMGvm3jiItgfWh7rsIC0iDU2arJGD0I8dEWbvohWpSoDYFJHV3UkftKRvGPAoITY
         i6rIXoLgVSE0QCGGL2ddMLcfig3wKerZ3dju3rIHWGRenLbwMbvtm+Lsy5PzFF4kpInT
         KtkQO0u2+bNCrI8wkRsYqKOOf0MB81gCxkVmhHSnce37h8lverX4ZAJfovKz65KVuDEZ
         NQQnlVEnrSOI+B8KgloCauPdOt7A+nn+BGv5pJdp8UVFUN+0TOUYGt5tUHMaPh4tM4jZ
         hVcw==
X-Google-Smtp-Source: APXvYqy+F9p8F+adABZCVE7+/c6WL6tSVwOuI2/YAflpnkot9CpEHJuJLRjxVI692CvA24SyHzRqyA==
X-Received: by 2002:ac8:1aec:: with SMTP id h41mr7984682qtk.345.1555774312594;
        Sat, 20 Apr 2019 08:31:52 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id n201sm3976523qka.10.2019.04.20.08.31.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Apr 2019 08:31:51 -0700 (PDT)
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
	jglisse@redhat.com
Subject: [v1 1/2] device-dax: fix memory and resource leak if hotplug fails
Date: Sat, 20 Apr 2019 11:31:47 -0400
Message-Id: <20190420153148.21548-2-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190420153148.21548-1-pasha.tatashin@soleen.com>
References: <20190420153148.21548-1-pasha.tatashin@soleen.com>
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

