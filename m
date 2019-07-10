Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93AE8C73C66
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 01:16:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A7FD2073D
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 01:16:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="oIRaXzcB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A7FD2073D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92B778E0062; Tue,  9 Jul 2019 21:16:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DC918E0032; Tue,  9 Jul 2019 21:16:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 756F98E0062; Tue,  9 Jul 2019 21:16:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 555228E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 21:16:52 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x1so780700qts.9
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 18:16:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=tyS5k/4QJCxPGcV91OLPh8wYVhK9QVlUZJPQN7ARXzo=;
        b=oZxNd5hLuFDZWDx8yrMUd71x6emEC9h5lpXTw1TeSNM72bAiybzarrCWnoh/cOJhyp
         A601/u/qAnWeCuQ5/lIrJqCjH6/jE53oRTjnfM5uPiG7O5ARDf63vQ4Ffes1lAVdG8nS
         Hao4/w/5L8/hWQls+497mRV2XW/ovtAJDJ9DeNi/A6ExQXtK0AO+v0qY7FYSj7FQcSWP
         blGtzOpgCHoYDA9tDEaahQusPMaohqVV/k3f+Z900cFPlB63jXAZRBJiHTKdNwbLs7kW
         AqWR4hhf8NpIP3r/mX0QfIBUEkPjEs2M96Cmmg1i1ahZzeQyTC3yG373kmRM3fAHLUbd
         K+gw==
X-Gm-Message-State: APjAAAWZok18Ab0tVZZ1B+VZimtKYBJbomcRVSAv9gfFDZsyOI/zgyNB
	vwiN0dXFkbqcr1z49hyr0rjcKES1uHzqyQ9q4W9iq64RHlSaidflCugp4yEE0kp1tmImbDjeost
	0BBwmCw7uEhbbUaYTaHTtbGLpi2evxi4w3FF9Okfe2ItcVpByeTY57czMczUYERTMbQ==
X-Received: by 2002:ac8:2e14:: with SMTP id r20mr21857082qta.241.1562721412071;
        Tue, 09 Jul 2019 18:16:52 -0700 (PDT)
X-Received: by 2002:ac8:2e14:: with SMTP id r20mr21857053qta.241.1562721411353;
        Tue, 09 Jul 2019 18:16:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562721411; cv=none;
        d=google.com; s=arc-20160816;
        b=vRFSQOP8QpGZwkInUzm2bBaI78eVdOq3LPL9d5If/IPyFYzOdZOHZwc6rnl7X60ffU
         naqumuw8XFLgXv33RfMFHUEG8Qkb5jmG+8a29xDJAFKSdJ3a01lNXSW82wBx4lBhVJjm
         NGDq0wmtokK45yvDS6GaGluzcpErFOttpWqE3KO+S+bNiruD5tzlICENILaKU8Q85WQz
         NQ52z+zqO90t2C6P/ovHST8j+0iNsyKhMr9x8/DBDOW89JdGX/PDHrpjpTSTr4Go+xIZ
         V/RiUDcWKmI32vIFU2Y1v9Rn6e/SxWt3l7sBi8UZ8eidBySTGA5prZeaP6z26g7AAXTg
         H48g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:dkim-signature;
        bh=tyS5k/4QJCxPGcV91OLPh8wYVhK9QVlUZJPQN7ARXzo=;
        b=ALN4xPamQo3EMiumZ4sa/9/5piW+ZA0fTDgpsRVG0gjBnJVONGkG+3FdPyQIuhZrc8
         htTAFlM5JI7jGBMOVhB32yadxyRTu5i2KcmIHoR0xbd6UrVZ5IECUL/1yS9uI4QuZs1q
         q5V8diKyEWvW3cov5CgoLXvMXtA5TGCtJuWG1WVlK9vkXNyIajm8xDDvpolyIr3XmuEG
         4FvFEshIz5mUunaJNYHU6jpyfGA/mJzkuHYSV2bBXWatdOESCBLuaKzr1567AnTo4mdU
         RltEYNNSPLdSemY5lSjKYba4RpZFieIhpyYwIn2pDsrSL4EFHLXwewnsq8dwsRwLQuUR
         3nFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=oIRaXzcB;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d10sor259746qkl.81.2019.07.09.18.16.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jul 2019 18:16:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=oIRaXzcB;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tyS5k/4QJCxPGcV91OLPh8wYVhK9QVlUZJPQN7ARXzo=;
        b=oIRaXzcBKN21PrMZxpFfBUUbAE7wF/UfbZoNG2Bo81kTMfH1jkYTY98GTIENUsItos
         V/WX4vpB1ciXEijN9rOhXuZxWeYIPcAwTN7nY6AcOWXL/QBUJIZ3udoI5EgSSrYP/v6Z
         n5zMxjMJN0LyV1nPiAgnF9KWNaXCjsqQ1RA2g69lzwit3bTSsd3CTb+ZpP8Yt1JHTAk+
         7mMvv1dHPucOHLPxqVU9EeLk6XkScChSXpj10FLFNDhUBRW4PeMiFSAEMN4izsN74QLv
         hSem2wQeYJr4YYe7fdf7Rk+3Py/i9ot4l52CQSRsBrhnyLj311qazIkAWg8uhCACaTgT
         L9Qg==
X-Google-Smtp-Source: APXvYqzSbKGKdJu9YdO8wNTJ5v/G3QEIGSQCvwnfWWheykUuMY8FrLDyWCW6hyyPO85S9nAUTrUtAw==
X-Received: by 2002:a37:bac2:: with SMTP id k185mr20774793qkf.211.1562721411119;
        Tue, 09 Jul 2019 18:16:51 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id u7sm260057qta.82.2019.07.09.18.16.49
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 09 Jul 2019 18:16:50 -0700 (PDT)
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
Subject: [v7 1/3] device-dax: fix memory and resource leak if hotplug fails
Date: Tue,  9 Jul 2019 21:16:45 -0400
Message-Id: <20190710011647.10944-2-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190710011647.10944-1-pasha.tatashin@soleen.com>
References: <20190710011647.10944-1-pasha.tatashin@soleen.com>
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
2.22.0

