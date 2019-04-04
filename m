Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E25D3C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:01:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E66020820
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 02:01:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sent.com header.i=@sent.com header.b="jSVkSs1r";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="jtoOK51R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E66020820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=sent.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D3EB6B026A; Wed,  3 Apr 2019 22:01:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58A166B026B; Wed,  3 Apr 2019 22:01:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B3AB6B026C; Wed,  3 Apr 2019 22:01:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 15E616B026A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 22:01:26 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id q21so954215qtf.10
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 19:01:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :date:message-id:in-reply-to:references:reply-to:mime-version
         :content-transfer-encoding;
        bh=g7J5EGJkF982neBEIpQt+y8NYDKq8lV93wLGcNRGrUg=;
        b=cuAj2a5I1Sb1b3O0fhMnRd5S3r/zRkR4Vy9uJxG8jG8Xl/Q+zuMCzvem8kzH9hqtij
         W+vJFHm81Js1F0Q05aaEY9jRKoaLK33Z7Li3Fy59R3YubD7DjiIp2rCHSC5smuPntNhk
         94InyxMUPULFjSpkBEaISvqwGcCwCP56eVjTGE60+PU3sHcPQ0qvo/8QeH9ZAh/d0pfK
         LvGtHcPEaJpg/eHGVQs1IG8Op57UuBGDNO5CuH1wlCjbL/zVSNg7gl8QwX+kTn7ovlg5
         Gtz4Sr8Ma1MPaW13enZRNulwQ1Fyh6xJZZGDs6KrgdantDuE3/+Uis+3Zw1PL21Ub2Vw
         oItw==
X-Gm-Message-State: APjAAAXN5pYsPXVbCc3WmdYeORp/Yqu8ZbbNbPBCoxj+9TIpSUmIsALc
	QBn4czf97t6hzjo5vkOLc1Gt+aP9kUWvSP0lvvvDafRAm3qibItSjwecu/DKZv+qlDBPXvgKwmZ
	eGW+PoDyXAhQWDqtRtptlyNQmH8N6pExzpsYvJsQlI3wVDnplUqwAIlIAlT8FG26/3A==
X-Received: by 2002:a0c:ac98:: with SMTP id m24mr2579085qvc.3.1554343285885;
        Wed, 03 Apr 2019 19:01:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrNC8G4NMbaUa8wNnc8dGfXjwwBlSQdrKx+bqifeA7IUnBaEX1FxA4bVQWnwwSNLnyND1A
X-Received: by 2002:a0c:ac98:: with SMTP id m24mr2579027qvc.3.1554343285095;
        Wed, 03 Apr 2019 19:01:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554343285; cv=none;
        d=google.com; s=arc-20160816;
        b=wLUQpYtEJuXgkwSKds3nsOTPWnvjsQddXcsNpITGsVMd8uvq5bdx3TIVruAxLJmQoI
         o+BA7z2LpujF692riZlhX1UsSCbAfQPwKGkW1wLEDZ2lb/Mekjy+l+raYXHJi3CNVOz4
         /0w5iwdXGM7KgjgUljh6hFEHjccSqSA/nvOwdOmA9tqbhw1B2M6nHkOwIT22xMTEi6t/
         tgGh0BkwWUKFQRVuErqcGkU0+E4WjAca/Q0H+xSrfS7WdLrpqKHJDvTZmQibTgYKl0zY
         VZ4RVJcbUzfUlNl1c05KVC3uaaaL2RMw53g6OvazRqXSzsr3/Vcz7UhmRL/6q8GvyLye
         DX+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:reply-to:references
         :in-reply-to:message-id:date:subject:cc:to:from:dkim-signature
         :dkim-signature;
        bh=g7J5EGJkF982neBEIpQt+y8NYDKq8lV93wLGcNRGrUg=;
        b=vpRSypob3INczGneghjXwsYfCDDvYziL3mMrfUDxyetosbKHywDekWoQvwgdk0FaAM
         M6cmy7JSu3E8FtILBNrX4TxNI8qJSq2CL1a5NqGcyk3GgbsKA0df3dOd5dQxHbEgeOkn
         gZ4dRXZ44CpW/PeW9hFqFguwBBqRtF1xkEtfRiJHOjlTXJDaNBHVogo9oYvG1FEz6P9A
         NzuEvytOb9GjPspaLF09SLZfpSxdOerFwJQ7GFAQePAaIvWMtwop1P66WnCynmVsYLQL
         jEve/Erfp/y17MHyqIy5Ng5kBHFFFI3PHIV+6Z+OZId23y9cx38T7lpjld73box7F5Yu
         nbBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=jSVkSs1r;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=jtoOK51R;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from out5-smtp.messagingengine.com (out5-smtp.messagingengine.com. [66.111.4.29])
        by mx.google.com with ESMTPS id g10si2107215qvd.203.2019.04.03.19.01.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 19:01:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) client-ip=66.111.4.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sent.com header.s=fm3 header.b=jSVkSs1r;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=jtoOK51R;
       spf=pass (google.com: domain of zi.yan@sent.com designates 66.111.4.29 as permitted sender) smtp.mailfrom=zi.yan@sent.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=sent.com
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id CC6CC22349;
	Wed,  3 Apr 2019 22:01:24 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute3.internal (MEProxy); Wed, 03 Apr 2019 22:01:24 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=sent.com; h=from
	:to:cc:subject:date:message-id:in-reply-to:references:reply-to
	:mime-version:content-transfer-encoding; s=fm3; bh=g7J5EGJkF982n
	eBEIpQt+y8NYDKq8lV93wLGcNRGrUg=; b=jSVkSs1rwApArJJjueU/Y1eE6QFai
	I7aySDXdakm6FTGtVY90fGPEfYRnfabDBiMF/46y6vtkbaSWlBgx0GxQ0wpR6KzY
	lIWQ90i+kEMssaE275N1SF5NIc1GHAaDmNt3yfwxU1gmG/a5JXN3wUtCt9vzHhgO
	XABVtqqtZxdKHuhhMfmOEaTe6z19aflOYV1hulx4kIOZctp9cGSAPghX8q8+jAsQ
	o8DcQIvN5vH9WcEcAAedNRUGimVk7PHlR6Nze1kNehNbssIXhxuXgL51viGllNd6
	clTLSZt/H8zbnzmJ1n7GzBRpobSSlG+jarYPhgnlqV+dobnGbwUFexd7g==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:date:from
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; bh=g7J5EGJkF982neBEIpQt+y8NYDKq8lV93wLGcNRGrUg=; b=jtoOK51R
	zy2Eaf8VRvQ6u4ssXI9X3RRF9upJUM1hxNW+RYxexrXDcxg9nx72SESIcFGVqo3J
	+A7Wdt+y3HlXgKYSqqncBSwe7XWDgWqSh+xQjHTvfIT57DMQmQXlWgbpn3wfeSXE
	Qc/aMkRJFYbm8/Se4Kx79aw2qkv0WUSdefLs4txlJRkgdvILfJvE8JYPGsZ/OsJJ
	Ei+0BiCbxjuD8bljF2XBRo7nBhGpBZkhipuAcTx7fP/ydO9fr/jJalTQEo1M8iGA
	tHAAnao64a8KcN/UTP/2cz3VMRhmoj1MzSj7r8/uAgsm18tHOWMryON6RHuaZbEw
	p062fZGSIw+npQ==
X-ME-Sender: <xms:dGWlXEEzEwqgUjBKG3CUWhZEvlpoKplSMKeX5pRZhwWc4h-YGkYytA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrtdeggdehudculddtuddrgedutddrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdp
    uffrtefokffrpgfnqfghnecuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivg
    hnthhsucdlqddutddtmdenucfjughrpefhvffufffkofgjfhhrggfgsedtkeertdertddt
    necuhfhrohhmpegkihcujggrnhcuoeiiihdrhigrnhesshgvnhhtrdgtohhmqeenucfkph
    epvdduiedrvddvkedrudduvddrvddvnecurfgrrhgrmhepmhgrihhlfhhrohhmpeiiihdr
    higrnhesshgvnhhtrdgtohhmnecuvehluhhsthgvrhfuihiivgepge
X-ME-Proxy: <xmx:dGWlXAiW-ETY4h78s2Ob9cSINpViXXwEqAwJJyuJEQuks_hozl2YpQ>
    <xmx:dGWlXE8nMG0G143LYy_pPyyN2Uv0LQIiWV8nH33n8ZgJ8eQhLuEZHQ>
    <xmx:dGWlXLLTNh2LVzzs18qek3AVYrbi9UJ2MFkmYQFRlDfKyFMRHvnLxg>
    <xmx:dGWlXPiqjjAy9qLyJU3F-ct5dJQky0qTST4K8DYaPzIej-TdOvqzAA>
Received: from nvrsysarch5.nvidia.com (thunderhill.nvidia.com [216.228.112.22])
	by mail.messagingengine.com (Postfix) with ESMTPA id A6B321030F;
	Wed,  3 Apr 2019 22:01:21 -0400 (EDT)
From: Zi Yan <zi.yan@sent.com>
To: Dave Hansen <dave.hansen@linux.intel.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Keith Busch <keith.busch@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	Javier Cabezas <jcabezas@nvidia.com>,
	David Nellans <dnellans@nvidia.com>,
	Zi Yan <ziy@nvidia.com>
Subject: [RFC PATCH 06/25] mm: migrate: Make the number of copy threads adjustable via sysctl.
Date: Wed,  3 Apr 2019 19:00:27 -0700
Message-Id: <20190404020046.32741-7-zi.yan@sent.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190404020046.32741-1-zi.yan@sent.com>
References: <20190404020046.32741-1-zi.yan@sent.com>
Reply-To: ziy@nvidia.com
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zi Yan <ziy@nvidia.com>

Signed-off-by: Zi Yan <ziy@nvidia.com>
---
 kernel/sysctl.c | 9 +++++++++
 mm/copy_page.c  | 2 +-
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 3d8490e..0eae0b8 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -102,6 +102,7 @@
 #if defined(CONFIG_SYSCTL)
 
 extern int accel_page_copy;
+extern unsigned int limit_mt_num;
 
 /* External variables not in a header file. */
 extern int suid_dumpable;
@@ -1441,6 +1442,14 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &zero,
 		.extra2		= &one,
 	},
+	{
+		.procname	= "limit_mt_num",
+		.data		= &limit_mt_num,
+		.maxlen		= sizeof(limit_mt_num),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+		.extra1		= &zero,
+	},
 	 {
 		.procname	= "hugetlb_shm_group",
 		.data		= &sysctl_hugetlb_shm_group,
diff --git a/mm/copy_page.c b/mm/copy_page.c
index 9cf849c..6665e3d 100644
--- a/mm/copy_page.c
+++ b/mm/copy_page.c
@@ -23,7 +23,7 @@
 #include <linux/freezer.h>
 
 
-const unsigned int limit_mt_num = 4;
+unsigned int limit_mt_num = 4;
 
 /* ======================== multi-threaded copy page ======================== */
 
-- 
2.7.4

