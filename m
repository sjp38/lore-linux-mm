Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6807CC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 07:24:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B6C52175B
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 07:24:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B6C52175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C36B68E00B0; Wed,  6 Feb 2019 02:24:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0D458E00AB; Wed,  6 Feb 2019 02:24:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFD058E00B0; Wed,  6 Feb 2019 02:24:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 64DCA8E00AB
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 02:24:55 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id w16so653070pll.15
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 23:24:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=EpAZipn8pPOg3lpg3mM/IxKKK2I8dRMDZZW6xMWJOhM=;
        b=GMWmP2ZEmlN+5YBls+wgRGFdenk7vgnwTCE5ogWv4PG47WxFq5LXqX21pt1H0I6kTL
         7f6PM1b6sWYGvaE6gq70h6pHaEGIn8bBJkvGokr5pees4ShvXCAk/8gHrT2emfl5w0nb
         7G9/J30FCAgcZ7mP7tJzGbz8DX4IBypMcOrZjroDDB8umOblnzqe0ARO3MG1yVT//lMf
         5JxcZU867ONyjIvYBdbKCCaSVHIR4NxVmbhr7zQQqRnJC1RgiolMJzMWX4vto0BP3BzW
         fAkPzRTI35qEoIiiABclxzvTcS+sXeUx9bWFLgcIoJK3R2Y/tVTsmMHnxZfv0UlMa1zK
         xOqQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaBnSzNMjTHDlKSACoLyUfzk+vj5PP/N/kzusprlIG3eixXe9yO
	GB5x95q5yBOWPl2CinXzOADErar4/KmNpffA9i444ulO+bVp8iYa0qd7XfyY81j1T5o7xp41MZ3
	Wq0xJ9Q0PmAw3JR42HETXiXB7+q5Na3GWQNBkENJk1FZkUjDnbbIuN2X1Hao5j1Dq8A==
X-Received: by 2002:a17:902:14e:: with SMTP id 72mr9369646plb.287.1549437895068;
        Tue, 05 Feb 2019 23:24:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZNlfsaHQFdJpwpmdCElqbYmwO4imc5VslhsHCo9Scw8CUALUndEMOtFqmupy3zRb46rrig
X-Received: by 2002:a17:902:14e:: with SMTP id 72mr9369608plb.287.1549437894341;
        Tue, 05 Feb 2019 23:24:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549437894; cv=none;
        d=google.com; s=arc-20160816;
        b=gXoJa7cvWJo/kFs0uPM/b6rUPHpg77sKFsG5xVbDZdcBFk+ruFZTkmI1uya6/zOIRE
         lEFTv3hbZYDxJEe65NzzPOXrhz/0SKtU4VC8vIrJC5H9Vz6I0Xkw4XvtxQSHDrIQWjTc
         jIHHe/LwXtFfTZsvR79Q2un8PEBGbPZdgVxTkLLXXDmd/WWS1hvDo+/EO7nWQ46dq7xj
         +5Zx9HgAC8g995my0bchvIJXbBXDu2QPSmRwGQmRYqabRyFc5qYRu8ScRQIN7gk9ieOf
         x34ndcnXMGmMt2lt7EWh1zYLZJvcyy7yx5SJ6VlTTe39BPVW+8rwa4tp04G3mOVVrIpB
         agug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=EpAZipn8pPOg3lpg3mM/IxKKK2I8dRMDZZW6xMWJOhM=;
        b=SqWlS/07klg+BGkJd3R/KkkH3rQoxR2e4Zr6zd15OiFMArkwGEn7doiwkOx6u9H6f3
         3h79o0KkchnGuGRr+uqiang4XAooczI8FIMeBpjGgoLBAxf7PAOwk5UvrAUd2z6Stcq4
         1Xr+U9kYAG2MDLzaFFO5KbfMLStO2w+Z31WRDW6n359W6OB/WNN+d59DG/WezsWsGvwp
         wr9fgPg7YFiy27teSi9yjmy996ii/oUwNLdCp/4KQvJQVpm0Gspqm+T4vWpqgcjLV8C/
         5lWH7EZRz85naFd+ylVrI7+7is7Muz/rp/Usw0f5w9J90A98V7LKnklbGX2/pFoNMRmj
         Iyzg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 61si1891588plz.117.2019.02.05.23.24.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Feb 2019 23:24:54 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Feb 2019 23:24:53 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,339,1544515200"; 
   d="scan'208";a="144567009"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga001.fm.intel.com with ESMTP; 05 Feb 2019 23:24:53 -0800
Subject: [PATCH 2/2] [-mm only] mm/shuffle: Default enable all shuffling
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, keescook@chromium.org, linux-kernel@vger.kernel.org
Date: Tue, 05 Feb 2019 23:12:15 -0800
Message-ID: <154943713572.3858443.11206307988382889377.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <154943712485.3858443.4491117952728936852.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <154943712485.3858443.4491117952728936852.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Per Andrew's request arrange for all memory allocation shuffling code to
be enabled by default.

The page_alloc.shuffle command line parameter can still be used to
disable shuffling at boot, but the kernel will default enable the
shuffling if the command line option is not specified.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 init/Kconfig |    4 ++--
 mm/shuffle.c |    4 ++--
 mm/shuffle.h |    2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index cfa199f3e9be..12557e12be4c 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1697,7 +1697,7 @@ config SLAB_MERGE_DEFAULT
 	  command line.
 
 config SLAB_FREELIST_RANDOM
-	default n
+	default y
 	depends on SLAB || SLUB
 	bool "SLAB freelist randomization"
 	help
@@ -1716,7 +1716,7 @@ config SLAB_FREELIST_HARDENED
 
 config SHUFFLE_PAGE_ALLOCATOR
 	bool "Page allocator randomization"
-	default SLAB_FREELIST_RANDOM && ACPI_NUMA
+	default y
 	help
 	  Randomization of the page allocator improves the average
 	  utilization of a direct-mapped memory-side-cache. See section
diff --git a/mm/shuffle.c b/mm/shuffle.c
index 3ce12481b1dc..a979b48be469 100644
--- a/mm/shuffle.c
+++ b/mm/shuffle.c
@@ -9,8 +9,8 @@
 #include "internal.h"
 #include "shuffle.h"
 
-DEFINE_STATIC_KEY_FALSE(page_alloc_shuffle_key);
-static unsigned long shuffle_state __ro_after_init;
+DEFINE_STATIC_KEY_TRUE(page_alloc_shuffle_key);
+static unsigned long shuffle_state __ro_after_init = 1 << SHUFFLE_ENABLE;
 
 /*
  * Depending on the architecture, module parameter parsing may run
diff --git a/mm/shuffle.h b/mm/shuffle.h
index fc1e327ae22d..466a5620e0aa 100644
--- a/mm/shuffle.h
+++ b/mm/shuffle.h
@@ -19,7 +19,7 @@ enum mm_shuffle_ctl {
 #define SHUFFLE_ORDER (MAX_ORDER-1)
 
 #ifdef CONFIG_SHUFFLE_PAGE_ALLOCATOR
-DECLARE_STATIC_KEY_FALSE(page_alloc_shuffle_key);
+DECLARE_STATIC_KEY_TRUE(page_alloc_shuffle_key);
 extern void page_alloc_shuffle(enum mm_shuffle_ctl ctl);
 extern void __shuffle_free_memory(pg_data_t *pgdat);
 static inline void shuffle_free_memory(pg_data_t *pgdat)

