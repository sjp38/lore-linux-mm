Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 321E4C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 21:58:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDE20216C8
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 21:58:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDE20216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F3696B0007; Thu,  8 Aug 2019 17:58:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A1EC6B0008; Thu,  8 Aug 2019 17:58:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B91F6B000A; Thu,  8 Aug 2019 17:58:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 262376B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 17:58:08 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id y7so9367132pgq.3
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 14:58:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=k0+j2laRAGuXurIWOL04i8EKiYLnkk10Qo29z95H0fo=;
        b=Xr0Ljb8kPdMAvjA/CLUkORwaiQlByeG0ASvruJqtbBGIwNwfm+PuCRvI9oIDp+Uxsv
         /xP2lUZgcE0MSW1IgEQxd2k7RJ3sFdflyvVBPMrguxNdemt4iJyLNoFv4ClF/huEy4h9
         VWm5lBFrI38fIwyKEyWBtR4DcUEqaQalv6aB8XVWGR9tO/F4gGQTkkE8qNgWMGTyhoE+
         zfyKgwVu/6yIkG5lpz4BfIvMUGGPklsemxf4a4CiBsE+VCHS9wyuxByRWOSsjNUnaNPZ
         z1q/eFKsYMNxx6FkNxds2KeGOvkTrz0XYQPRuUvg36T2CWNdny3bRcWDThMhSoWIxkTd
         8cZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVjc+PkLjgKZdIkqUod/jwuPEzxMr8TH1ohtOGrqiKyS5V7CloZ
	UG8VRNZ0D/tIRnIesrgLg9IoB6XPu6I2GsCsrgmWyJ+3cyizxLjHHsCoKgELoUeEW8ojnXvRfzS
	u+WyxlXz8DJnvod+2YWMo8vCOhA6apjuxccr1h2V1vhOIZVAtvCvEUrvnk6uiOZ7oSA==
X-Received: by 2002:a17:90b:94:: with SMTP id bb20mr6317274pjb.16.1565301487812;
        Thu, 08 Aug 2019 14:58:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyEWBHgspTsBpB2WlKaQ8J7WWkM9aTNbsja2u+LnIPdyNgqZDZW2NHoqoQz663b56px1C+0
X-Received: by 2002:a17:90b:94:: with SMTP id bb20mr6317245pjb.16.1565301487047;
        Thu, 08 Aug 2019 14:58:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565301487; cv=none;
        d=google.com; s=arc-20160816;
        b=FdLePPoY3l2YQuIkQmtyORA4N85996lTuaGVGTQRjdVOQv9xGyMtTcALfMA9mZPMod
         77Twtgr4VxrBDtnQV2srguVQiG2OOR+K7kou4/1NqbPTnMV+XywyR42ge3WYES0UBA2e
         8qNBMxg1m5Ow+b/2niUy8Aci+4EGTcAPwsvim2d7H8SUOql/14vIi95L2sRevAM7QYLz
         L3O26mprm/ObVgBfO9T+2KhLCqelgy4mtdL20msQ1YKu7eecVbyvd9V+1ikQZRmkbOcV
         mcQ2Sri3xkeRApstyVm7It1XATTXToWMIpA6+lmOU8wKi1fLLXOvJkui/Wi+pSBlDrRc
         8+Cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject;
        bh=k0+j2laRAGuXurIWOL04i8EKiYLnkk10Qo29z95H0fo=;
        b=TumXVOqsS/5uWpM2Fblu2ZlGqfsCM7SQxjuJVAV27v3xuRDjcQrz20lrdb5CRzvL94
         rb2r8G5f685kJGbMgdle2lEG3hiPae4+9vFHUVDp8CLbMhRlZWbESJgHspvN/EVxX+FR
         ih5tUc5c/g7c05I+QsZ/xc9rV8D2DxKTRatFzx7Zlgq9NOAWaUvHunfwhWzK7+p8YjgD
         ydnvModBq2M4X6M1XfEL2nEADjpBEABCbGMGW2+2lY7J1PuMJKevzOMgOEeKQyaMYTOf
         RhPGv0434f66OUwOzaLfpCEAviteFkyc2ffbC3iVeN/nTktqC6QTRmWrdDJ+FfoLQJLb
         Itqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id v189si52439289pgd.289.2019.08.08.14.58.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 14:58:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 Aug 2019 14:58:06 -0700
X-IronPort-AV: E=Sophos;i="5.64,363,1559545200"; 
   d="scan'208";a="169126521"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga008-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 Aug 2019 14:58:06 -0700
Subject: [PATCH] mm/memremap: Fix reuse of pgmap instances with internal
 references
From: Dan Williams <dan.j.williams@intel.com>
To: linux-nvdimm@lists.01.org
Cc: Fan Du <fan.du@intel.com>, Vishal Verma <vishal.l.verma@intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>,
 Ira Weiny <ira.weiny@intel.com>, Jason Gunthorpe <jgg@mellanox.com>,
 linux-mm@kvack.org
Date: Thu, 08 Aug 2019 14:43:49 -0700
Message-ID: <156530042781.2068700.8733813683117819799.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, attempts to shutdown and re-enable a device-dax instance
trigger:

    Missing reference count teardown definition
    WARNING: CPU: 37 PID: 1608 at mm/memremap.c:211 devm_memremap_pages+0x234/0x850
    [..]
    RIP: 0010:devm_memremap_pages+0x234/0x850
    [..]
    Call Trace:
     dev_dax_probe+0x66/0x190 [device_dax]
     really_probe+0xef/0x390
     driver_probe_device+0xb4/0x100
     device_driver_attach+0x4f/0x60

Given that the setup path initializes pgmap->ref, arrange for it to be
also torn down so devm_memremap_pages() is ready to be called again and
not be mistaken for the 3rd-party per-cpu-ref case.

Fixes: 24917f6b1041 ("memremap: provide an optional internal refcount in struct dev_pagemap")
Reported-by: Fan Du <fan.du@intel.com>
Tested-by: Vishal Verma <vishal.l.verma@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

Andrew, I have another dax fix pending, so I'm ok to take this through
the nvdimm tree, holler if you want it in -mm.

 mm/memremap.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/mm/memremap.c b/mm/memremap.c
index 6ee03a816d67..86432650f829 100644
--- a/mm/memremap.c
+++ b/mm/memremap.c
@@ -91,6 +91,12 @@ static void dev_pagemap_cleanup(struct dev_pagemap *pgmap)
 		wait_for_completion(&pgmap->done);
 		percpu_ref_exit(pgmap->ref);
 	}
+	/*
+	 * Undo the pgmap ref assignment for the internal case as the
+	 * caller may re-enable the same pgmap.
+	 */
+	if (pgmap->ref == &pgmap->internal_ref)
+		pgmap->ref = NULL;
 }
 
 static void devm_memremap_pages_release(void *data)

