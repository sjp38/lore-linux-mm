Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B092FC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 13:21:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5322421873
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 13:21:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5322421873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B674B6B0003; Fri, 22 Mar 2019 09:21:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AECCB6B0006; Fri, 22 Mar 2019 09:21:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B60E6B0007; Fri, 22 Mar 2019 09:21:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3F96B6B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 09:21:13 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i59so940327edi.15
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 06:21:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=NESICYZR0j4y1+7pTaL66/Ee2Ii4unI3HqY/2UWn69w=;
        b=nRn/LkpEcIjpxdCRyrMPxVvK7zYDmqiuibNN8YlKVRa8m9Qwa5wF7/wPciQX7Dng24
         6DYnWatKXjAY5JKkA8Sir7u1y9wOqwwQDaPVRZkfKeHrx+9WYAi2TQGfIV1fEQTTqHPa
         8c2aQbrFeEPlhv0jFR6sDNOHmesky7Wk89enEzyo0crKVuzkjtjrKvBj+TLhf05HNShx
         whJtt39kCFZ+WsnjwITYm8RHGLRBPg6HdxoOYH3xAijg/CA+ORzGSVYiQNG3/3j53Obs
         YxL9V54dXP9OMKa13m8bDsX/NVtV8USL1x4UuxW36iak++cGr+Gws75Xj6N9bfBZEGfX
         226g==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 95.216.213.190 is neither permitted nor denied by best guess record for domain of sakari.ailus@linux.intel.com) smtp.mailfrom=sakari.ailus@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXfEs/SdZ2mmZi0/l0DblxGpjo8+jAvP0i8gx8r/HjqZVYG+0ZE
	pkYQYvdXaqksxdXHH4zpcPCQ3d530CaLFZed9LoRg7Vc5ZhFee7xhxDuqNDXsSB1piXUZ7t75cL
	fGBXgpOTAyOqiuYPMT+t0lmNYCkP70NcKKOIPu+i16O3j265pUP17u9vloq4fHOM=
X-Received: by 2002:a17:906:2ec2:: with SMTP id s2mr5614201eji.0.1553260872768;
        Fri, 22 Mar 2019 06:21:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLWWuOYmhfRVvLdc+vQsadntJzach6jdlDb9vxSzboDQIyjh1bpRKw7Pzz/4okA4nD5Y+p
X-Received: by 2002:a17:906:2ec2:: with SMTP id s2mr5614157eji.0.1553260871771;
        Fri, 22 Mar 2019 06:21:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553260871; cv=none;
        d=google.com; s=arc-20160816;
        b=L6eUsFlN7oozMJ1O8WPVaiE7uyy6oS7Oa3SebmNyA4vqCyY+rx4KM8DEUoQ1IXvbON
         igZisnQENYFOvQYWA4KV8V8olyGCl3/W0Uh3CLOemN+5fzm2KzRP9/dqR0D4Auzk/uk8
         /yVZTw85IH44LjfCkmfSgC1x5dC8bXnbluM/wJYS6SXWOy0Dkg+teq9GqNH/JzvAshCt
         umQJAwUV0ZiU+i9QxXUMFv2RH2cwvoEsJOpmQmbbRQcN1fqQYFhaEVCu56sZDWnUa8f/
         wszVkIJOqlhGzuN5wLmrNlDEwpAj/YVMtYZ0t8DxmhOd6yAJ0xje5DF6YM+6ZaxEFPt6
         QOrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=NESICYZR0j4y1+7pTaL66/Ee2Ii4unI3HqY/2UWn69w=;
        b=eJ2SLmMihipMQujU9vSiHHlBKA2gbFk/QB8h5M8Gabp+yhwcFNLWodqmF95/U6XI0M
         oeGUiUHIlcY5YRPa3YIvAzX2L3KMnPn4IsKhjxeW9vGkeo3+L4I8/Op8+ehVnsV/kWN7
         ScMwrEJAQLeLIRvx+AEQG/o2MrRCZSgRanOhGli6yTAO7YmU2twQ+Cd3bOGdvPrUYiQY
         X9182vaqSf+JC7JAVhThWQhZwl2sxtEJK+2cZe4rY/l95vu4R10Kw/1oozrbmuaK0fg9
         k2yF8NwiGIkPLe3zIKuUjBLTOC/WYYfMnZ9CbHyfc2odisQZmnfbxrjddclxMV15FYPp
         b3cA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 95.216.213.190 is neither permitted nor denied by best guess record for domain of sakari.ailus@linux.intel.com) smtp.mailfrom=sakari.ailus@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from hillosipuli.retiisi.org.uk (retiisi.org.uk. [95.216.213.190])
        by mx.google.com with ESMTPS id w5si1033763eje.253.2019.03.22.06.21.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Mar 2019 06:21:11 -0700 (PDT)
Received-SPF: neutral (google.com: 95.216.213.190 is neither permitted nor denied by best guess record for domain of sakari.ailus@linux.intel.com) client-ip=95.216.213.190;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 95.216.213.190 is neither permitted nor denied by best guess record for domain of sakari.ailus@linux.intel.com) smtp.mailfrom=sakari.ailus@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from lanttu.localdomain (unknown [IPv6:2a01:4f9:c010:4572::e1:1001])
	by hillosipuli.retiisi.org.uk (Postfix) with ESMTP id A5559634C7F;
	Fri, 22 Mar 2019 15:19:03 +0200 (EET)
From: Sakari Ailus <sakari.ailus@linux.intel.com>
To: Petr Mladek <pmladek@suse.com>,
	linux-kernel@vger.kernel.org
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	linux-arm-kernel@lists.infradead.org,
	sparclinux@vger.kernel.org,
	linux-um@lists.infradead.org,
	xen-devel@lists.xenproject.org,
	linux-acpi@vger.kernel.org,
	linux-pm@vger.kernel.org,
	drbd-dev@lists.linbit.com,
	linux-block@vger.kernel.org,
	linux-mmc@vger.kernel.org,
	linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	linux-f2fs-devel@lists.sourceforge.net,
	linux-mm@kvack.org,
	ceph-devel@vger.kernel.org,
	netdev@vger.kernel.org
Subject: [PATCH 2/2] vsprintf: Remove support for %pF and %pf in favour of %pS and %ps
Date: Fri, 22 Mar 2019 15:21:08 +0200
Message-Id: <20190322132108.25501-3-sakari.ailus@linux.intel.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190322132108.25501-1-sakari.ailus@linux.intel.com>
References: <20190322132108.25501-1-sakari.ailus@linux.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

%pS and %ps are now the preferred conversion specifiers to print function
%names. The functionality is equivalent; remove the old, deprecated %pF
%and %pf support.

Signed-off-by: Sakari Ailus <sakari.ailus@linux.intel.com>
---
 Documentation/core-api/printk-formats.rst | 10 ----------
 lib/vsprintf.c                            |  8 ++------
 scripts/checkpatch.pl                     |  5 -----
 3 files changed, 2 insertions(+), 21 deletions(-)

diff --git a/Documentation/core-api/printk-formats.rst b/Documentation/core-api/printk-formats.rst
index c37ec7cd9c06..c90826a1ff17 100644
--- a/Documentation/core-api/printk-formats.rst
+++ b/Documentation/core-api/printk-formats.rst
@@ -78,8 +78,6 @@ Symbols/Function Pointers
 
 	%pS	versatile_init+0x0/0x110
 	%ps	versatile_init
-	%pF	versatile_init+0x0/0x110
-	%pf	versatile_init
 	%pSR	versatile_init+0x9/0x110
 		(with __builtin_extract_return_addr() translation)
 	%pB	prev_fn_of_versatile_init+0x88/0x88
@@ -89,14 +87,6 @@ The ``S`` and ``s`` specifiers are used for printing a pointer in symbolic
 format. They result in the symbol name with (S) or without (s)
 offsets. If KALLSYMS are disabled then the symbol address is printed instead.
 
-Note, that the ``F`` and ``f`` specifiers are identical to ``S`` (``s``)
-and thus deprecated. We have ``F`` and ``f`` because on ia64, ppc64 and
-parisc64 function pointers are indirect and, in fact, are function
-descriptors, which require additional dereferencing before we can lookup
-the symbol. As of now, ``S`` and ``s`` perform dereferencing on those
-platforms (when needed), so ``F`` and ``f`` exist for compatibility
-reasons only.
-
 The ``B`` specifier results in the symbol name with offsets and should be
 used when printing stack backtraces. The specifier takes into
 consideration the effect of compiler optimisations which may occur
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 791b6fa36905..5f60b8d41277 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -797,7 +797,7 @@ char *symbol_string(char *buf, char *end, void *ptr,
 #ifdef CONFIG_KALLSYMS
 	if (*fmt == 'B')
 		sprint_backtrace(sym, value);
-	else if (*fmt != 'f' && *fmt != 's')
+	else if (*fmt != 's')
 		sprint_symbol(sym, value);
 	else
 		sprint_symbol_no_offset(sym, value);
@@ -1853,9 +1853,7 @@ char *device_node_string(char *buf, char *end, struct device_node *dn,
  *
  * - 'S' For symbolic direct pointers (or function descriptors) with offset
  * - 's' For symbolic direct pointers (or function descriptors) without offset
- * - 'F' Same as 'S'
- * - 'f' Same as 's'
- * - '[FfSs]R' as above with __builtin_extract_return_addr() translation
+ * - '[Ss]R' as above with __builtin_extract_return_addr() translation
  * - 'B' For backtraced symbolic direct pointers with offset
  * - 'R' For decoded struct resource, e.g., [mem 0x0-0x1f 64bit pref]
  * - 'r' For raw struct resource, e.g., [mem 0x0-0x1f flags 0x201]
@@ -1970,8 +1968,6 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 	}
 
 	switch (*fmt) {
-	case 'F':
-	case 'f':
 	case 'S':
 	case 's':
 		ptr = dereference_symbol_descriptor(ptr);
diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 5b756278df13..b4e456b48fd7 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -5993,11 +5993,6 @@ sub process {
 					my $stat_real = get_stat_real($linenr, $lc);
 					my $ext_type = "Invalid";
 					my $use = "";
-					if ($bad_specifier =~ /p[Ff]/) {
-						$ext_type = "Deprecated";
-						$use = " - use %pS instead";
-						$use =~ s/pS/ps/ if ($bad_specifier =~ /pf/);
-					}
 
 					WARN("VSPRINTF_POINTER_EXTENSION",
 					     "$ext_type vsprintf pointer extension '$bad_specifier'$use\n" . "$here\n$stat_real\n");
-- 
2.11.0

