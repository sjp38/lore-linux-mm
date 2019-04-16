Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CCC7AC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 21:07:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 896A720880
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 21:07:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 896A720880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D0A66B0007; Tue, 16 Apr 2019 17:07:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 280AD6B0008; Tue, 16 Apr 2019 17:07:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 122756B000A; Tue, 16 Apr 2019 17:07:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA0176B0007
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 17:07:52 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a8so334057pgq.22
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 14:07:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=n97B44f2A9Q8r7Y4SuVmn5Yal+Ru7FTSgdxu4oD2xGU=;
        b=f+/igJ9D8f+1tINxwbUCBZhOAcIh3sZP6BbUlfMOcyraI4ks5KK7hqyuq/Z73mq6a6
         r6RrkCLbJZt2gDPLnvEyC4mP6wkxeahFyoPQyEAQ4zx2c9ALMdOnTNk8DuJx75rBukW7
         F5bAPH3mVX/wHFerZQS6pPttmCi4OEgjqUT9et5JI3xxLGPNwm3HgBCrGQP76UJ0V6ZX
         bPhmjL8D/M3BK17dg+Pty7ebp1cHMe8IsDEWmOGGUqtdVbQbPkxOPjR0Fg5TZsQMBpsb
         MDrwImHoOxdipnTZHW49OmPJCU3SHxO8ROD/JJHgLyja8aFis2Bn6bnscbnnElJQivRX
         IE+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUXRelO0aYp1HBGVY2/erMKmed465pfQrbg7zyFUJgFzndEDWUO
	gn1A0h5eOmBshGUSI6+XeGbu308AzDxUWm+TPfOccOA9hv5JEC2aoU/8Vv5j/YpPFAen6H5Ams1
	2x3kfFkAxtvaLu9tuw5YTDbZ5B3nn51c595Pgybvu/JPnfgFcItbgP8GzxV8UxvamJw==
X-Received: by 2002:aa7:943b:: with SMTP id y27mr60893879pfo.59.1555448872233;
        Tue, 16 Apr 2019 14:07:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjaFQaiyuHSXw3jd5VV4vppaTSwkH0R300nG5ZhIMAiUFpvhmejiDWqd9HFumZpbzXAIFp
X-Received: by 2002:aa7:943b:: with SMTP id y27mr60893793pfo.59.1555448871384;
        Tue, 16 Apr 2019 14:07:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555448871; cv=none;
        d=google.com; s=arc-20160816;
        b=1Cm+jVzPZxZWpbxX9FHiRa6m+HoslLvKZkaLnBtinllvD++flNcoWZw72hj4UHucia
         pgNbvDWGFv68wql/RGo3X3EDx05akrfTWLALvuTBdD06ISvMpBsniVyZTeJ7v1sdGgtm
         UWFPlDfVoh9PjTsD4q6Aalh7hexx5F170Mt8zVYwubfILv7ZTSeiFxz6YS3assCtduyk
         v8Om7k9ILqZXP1TxhEXFdLiBZBcmGkbXmGtEREWNW2gxqypQOxbXknzTRkA/8XhB7Rjy
         EuucfnIHNJghTRHmlDiFaODdpKN8BiybIdN4uwgw+RRvTWa/GXsL+I9MpiHF6mHTIM1i
         f3Mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject;
        bh=n97B44f2A9Q8r7Y4SuVmn5Yal+Ru7FTSgdxu4oD2xGU=;
        b=wKHXKvVx9HOhRU6fy42GdyHfeAo+NRS+pLLNhBaZdpnUSpWnHkJbDWKWVfWiQ4X1V6
         QT0xbA+32+Qtsw46Apw3jGaEzerJxuPeKCwx7AbRq2TWOxyB2B6NdPZ3NkVYMGN8FAaz
         +BJ9WRICvFxBZpRU/YXzuy9w5xkmDI1sn4Uv4l2hux15HAwDHptqAvsCzqlwRcpleUMI
         lkpIzjXtmlynqCr9JKjj6I1LomXiEV0Y3gcU+oaVX5E1pFMVTswQqc9jC+ZUFk/qVggv
         YgSgzR88bAK+tVas8SjmaWXICbCJU8/DZd8Ruq0BP4cx2MoehiSWcPv0dukq+HdByVIE
         P8iA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id y6si53344344pfb.269.2019.04.16.14.07.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 14:07:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 16 Apr 2019 14:07:50 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,359,1549958400"; 
   d="scan'208";a="143496351"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga007.fm.intel.com with ESMTP; 16 Apr 2019 14:07:50 -0700
Subject: [PATCH] init: Initialize jump labels before command line option
 parsing
From: Dan Williams <dan.j.williams@intel.com>
To: linux-kernel@vger.kernel.org
Cc: Guenter Roeck <groeck@google.com>,
 Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Thomas Gleixner <tglx@linutronix.de>, Mike Rapoport <rppt@linux.ibm.com>,
 linux-mm@kvack.org
Date: Tue, 16 Apr 2019 13:54:04 -0700
Message-ID: <155544804466.1032396.13418949511615676665.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When a module option, or core kernel argument, toggles a static-key it
requires jump labels to be initialized early. While x86, PowerPC, and
ARM64 arrange for jump_label_init() to be called before parse_args(),
ARM does not.

  Kernel command line: rdinit=/sbin/init page_alloc.shuffle=1 panic=-1 console=ttyAMA0,115200 page_alloc.shuffle=1
  ------------[ cut here ]------------
  WARNING: CPU: 0 PID: 0 at ./include/linux/jump_label.h:303
  page_alloc_shuffle+0x12c/0x1ac
  static_key_enable(): static key 'page_alloc_shuffle_key+0x0/0x4' used
  before call to jump_label_init()
  Modules linked in:
  CPU: 0 PID: 0 Comm: swapper Not tainted
  5.1.0-rc4-next-20190410-00003-g3367c36ce744 #1
  Hardware name: ARM Integrator/CP (Device Tree)
  [<c0011c68>] (unwind_backtrace) from [<c000ec48>] (show_stack+0x10/0x18)
  [<c000ec48>] (show_stack) from [<c07e9710>] (dump_stack+0x18/0x24)
  [<c07e9710>] (dump_stack) from [<c001bb1c>] (__warn+0xe0/0x108)
  [<c001bb1c>] (__warn) from [<c001bb88>] (warn_slowpath_fmt+0x44/0x6c)
  [<c001bb88>] (warn_slowpath_fmt) from [<c0b0c4a8>]
  (page_alloc_shuffle+0x12c/0x1ac)
  [<c0b0c4a8>] (page_alloc_shuffle) from [<c0b0c550>] (shuffle_store+0x28/0x48)
  [<c0b0c550>] (shuffle_store) from [<c003e6a0>] (parse_args+0x1f4/0x350)
  [<c003e6a0>] (parse_args) from [<c0ac3c00>] (start_kernel+0x1c0/0x488)

Move the fallback call to jump_label_init() to occur before
parse_args(). The redundant calls to jump_label_init() in other archs
are left intact in case they have static key toggling use cases that are
even earlier than option parsing.

Reported-by: Guenter Roeck <groeck@google.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 init/main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/init/main.c b/init/main.c
index 598e278b46f7..7d4025d665eb 100644
--- a/init/main.c
+++ b/init/main.c
@@ -582,6 +582,8 @@ asmlinkage __visible void __init start_kernel(void)
 	page_alloc_init();
 
 	pr_notice("Kernel command line: %s\n", boot_command_line);
+	/* parameters may set static keys */
+	jump_label_init();
 	parse_early_param();
 	after_dashes = parse_args("Booting kernel",
 				  static_command_line, __start___param,
@@ -591,8 +593,6 @@ asmlinkage __visible void __init start_kernel(void)
 		parse_args("Setting init args", after_dashes, NULL, 0, -1, -1,
 			   NULL, set_init_arg);
 
-	jump_label_init();
-
 	/*
 	 * These use large bootmem allocations and must precede
 	 * kmem_cache_init()

