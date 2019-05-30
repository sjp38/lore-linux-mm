Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A75D4C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:13:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78E2F262F8
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:13:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78E2F262F8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2341F6B0281; Thu, 30 May 2019 19:13:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E4D66B0282; Thu, 30 May 2019 19:13:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D4146B0283; Thu, 30 May 2019 19:13:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id C65056B0281
	for <linux-mm@kvack.org>; Thu, 30 May 2019 19:13:22 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e69so3311806pgc.7
        for <linux-mm@kvack.org>; Thu, 30 May 2019 16:13:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=7kUKQNIdOWgFr9qr6uEyM12Od3PL5kNQnr9fjqXe59M=;
        b=ecyqyB77nDi4pzcXzuyAaZv3Q/eMk309h02b9A9nspNNE1icdD0fRoXqGNYjwh45GM
         sMRvCE078mkSsRm4k9rD1/fs5bR0vXG531PC/YBPomJWPKXZZpQ6fnmVWbMA6Nd5h97R
         JLUS0igJPuTMkNyQdGDbAvv31U7hVCimJFz6YMpkf1uvAXtNelHrSNH9JxDLkvQjU/WU
         bQiKIUG9rF6srqOaTbHdqnVIegX0Zjvv1WZD1sgjUzZv4smmnfuO5Phs83RczxRXejn+
         lXHvyEu2j0F2HSpFjIuMvJCXDZ71XEpK8IND+7d9TYSB+P4YeY5GHplTLeN2G+FFXF3y
         fjcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXNqnZvJO5qxwbdyYEGOtAdd3s2r3TRovah4S/ELxVYLUlngUiq
	+p+lOjaqS/CA40ds97EP/D8a5lI9YRuDTyV3IYLnUFsjtOWE2K+1rPTiuujdEzPcopxKV1s/yef
	dZAWoe/PuYGx9PXtjv5Bu2/Xd229i6lsP1GQcO1pcHOlYFj24DbpQGuoHPVZO0g3ESw==
X-Received: by 2002:aa7:93a7:: with SMTP id x7mr6329044pff.196.1559258002381;
        Thu, 30 May 2019 16:13:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznTKgS04EBm49u1+wM+NMebxjO/HrNUBzsgCV44lGamjPFEXXjl/zxoGZsF0NEt9VRNCF9
X-Received: by 2002:aa7:93a7:: with SMTP id x7mr6328987pff.196.1559258001603;
        Thu, 30 May 2019 16:13:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559258001; cv=none;
        d=google.com; s=arc-20160816;
        b=NYK3z/I53ZaxC1Bp641Waoq6AsMCw7dsUHFU160QxyM9d3si/IoXvX8WHzcGmYYjnS
         jcZ3qngGdxYS90KAkb4/GxGzdyJq1JgVN2MmIVAzDU4tMhwTRQj/wxsdqGFc2d/n5/zX
         d00+6lsXb3mEqOEGy98hmFecJitzwk2m3wexNExUpN/l5meUdmPMUBIXSEuXcD22jtIr
         ZqskP4m8yyiH/wYAj7C9chG+UMgRO8FCprfrhA/d1s8bn4qoQi7J8KmEb9PisJNDtqCp
         kKhhVRjnaltAJ8l08XteTByK8YEUqQl+j36HNrM1tcGY/0sd549FJOacuEYGBD0ZHaSd
         NsDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=7kUKQNIdOWgFr9qr6uEyM12Od3PL5kNQnr9fjqXe59M=;
        b=Pm3hQpfmdo7cG/PxB50gmAdbUG+jVColWS9g/pCGKYGsgRKDy8x+AGsZ/kS2GfA62U
         OPprwPMrjLH673SYWBXSFYiLrpztG5HlRcyzuiZU+svyuRM7iaUs0Um5DtsdQTA6xSnD
         4gn0WwEfSmGYo7v1CvlGShbkmpFDo9caSfOLsDorB7fzOw5X2JFnnTgIfMz9Rhjfx7LT
         jRxN/VSIxSdK73/zo1fPg/xq8UK+nDLxGZxOC+o6oB6bbokmlOgqx8dRFbu9Px+EybYH
         u+ZlRLC2MPE18YAw5VjBEds9Fb2UsiUfuCWTGA83Ncc5YNMM0i4hoktBwceW+xbyPGYU
         Lw4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id w2si4183851pga.495.2019.05.30.16.13.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 16:13:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 May 2019 16:13:21 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga006.jf.intel.com with ESMTP; 30 May 2019 16:13:20 -0700
Subject: [PATCH v2 2/8] acpi/hmat: Skip publishing target info for nodes
 with no online memory
From: Dan Williams <dan.j.williams@intel.com>
To: linux-efi@vger.kernel.org
Cc: vishal.l.verma@intel.com, ard.biesheuvel@linaro.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org
Date: Thu, 30 May 2019 15:59:32 -0700
Message-ID: <155925717294.3775979.5007799093584209240.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There are multiple scenarios where the HMAT may contain information
about proximity domains that are not currently online. Rather than fail
to report any HMAT data just elide those offline domains.

If and when those domains are later onlined they can be added to the
HMEM reporting at that point.

This was found while testing EFI_MEMORY_SP support which reserves
"specific purpose" memory from the general allocation pool. If that
reservation results in an empty numa-node then the node is not marked
online leading a spurious:

    "acpi/hmat: Ignoring HMAT: Invalid table"

...result for HMAT parsing.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/acpi/hmat.c |   14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/acpi/hmat.c b/drivers/acpi/hmat.c
index 96b7d39a97c6..2c220cb7b620 100644
--- a/drivers/acpi/hmat.c
+++ b/drivers/acpi/hmat.c
@@ -96,9 +96,6 @@ static __init void alloc_memory_target(unsigned int mem_pxm)
 {
 	struct memory_target *target;
 
-	if (pxm_to_node(mem_pxm) == NUMA_NO_NODE)
-		return;
-
 	target = find_mem_target(mem_pxm);
 	if (target)
 		return;
@@ -588,6 +585,17 @@ static __init void hmat_register_targets(void)
 	struct memory_target *target;
 
 	list_for_each_entry(target, &targets, node) {
+		int nid = pxm_to_node(target->memory_pxm);
+
+		/*
+		 * Skip offline nodes. This can happen when memory
+		 * marked EFI_MEMORY_SP, "specific purpose", is applied
+		 * to all the memory in a promixity domain leading to
+		 * the node being marked offline / unplugged, or if
+		 * memory-only "hotplug" node is offline.
+		 */
+		if (nid == NUMA_NO_NODE || !node_online(nid))
+			continue;
 		hmat_register_target_initiators(target);
 		hmat_register_target_perf(target);
 	}

