Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A974C28D18
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 22:12:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC2E52070B
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 22:12:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC2E52070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 796F26B0273; Wed,  5 Jun 2019 18:12:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 745BC6B0274; Wed,  5 Jun 2019 18:12:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65C2B6B0276; Wed,  5 Jun 2019 18:12:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 324276B0273
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 18:12:46 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id bb9so214448plb.2
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 15:12:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=LEsj0JvF5oyzUNmNgQWz6pMzr+Cf/rYYP2iyFKbjxv8=;
        b=TrR9efAp8kuiCsgm72WXa/f6Yy4U7uwEn4pWgi0N4YXItvbV/eGsiMjpD6i3kWtyFp
         mmqzok1nf/YkN0AAsE0kgOD8L7tuCuL/7Q/oCHERf70DdIWx/azAmH1U638asrTBevkJ
         2/tE1WM9t4wpLAPjjTDZQyyc1WNZyziFTtiloL//BhFqDjqYhP4xxdmc/w2h7efW1e4o
         bo1yvaqJNVRcfxSBljCsXAjOXZgYW6eFDfUmRYjgFl7z1bSOJJxGQtrCdoiVaz0tv4of
         /Dvz83Qh2NlaNcFS1vA4qkz8KBleP5fe+yAHAui2+PL7ZMfnGqTH8E0myZv8z1qfE+/M
         42CA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV6iBwCGkDaewqXDE7wQVm8VtEnZQEWSuQR7+/DM3S3lLXUhjrQ
	4tiDVtm+ghA386gGdf6cK5qbhmpoAQyp0BFXS7J7t/N8dT2r2i2U2G3I2bn46YESOIxznAVoMWt
	QAbEw9+Y20cun3VoVzGG1jhqVrrRX/oGEcMPEdOWx/ZLE73VuD+UofPZS0x09nWstSQ==
X-Received: by 2002:a63:fb01:: with SMTP id o1mr97762pgh.410.1559772765674;
        Wed, 05 Jun 2019 15:12:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEHBgQ6nM3J0NxPUAWLbUHffYQaNfJPsyBMHEtYkObpv+iptTu+glAjP1s2VvpOpprzJ9+
X-Received: by 2002:a63:fb01:: with SMTP id o1mr97680pgh.410.1559772764841;
        Wed, 05 Jun 2019 15:12:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559772764; cv=none;
        d=google.com; s=arc-20160816;
        b=B9tTmw66oracIb7MiMqq/oPHFPtmbBtvOBlvEfcP9Bmk8WV74meUGI7gxrB8Vn2tWM
         md32vRYGZzs+UJ4md8qviaanc/LBjRH6tOkpCcKR7ad3fDzIuwbPpBU5cTpi7M9W36eA
         yoF+2Jl6T9Y+nZBeUnpVbD40VOz8YNJeumK44l/GbZrklaq52nWkeijIohAoQA1OA/bz
         uKMsEOmUJYPgdmRQ6ia2udMkZPcPxB5Ci44ybT5O8w0aULKwvfwzjjoXO3N9F3FZq6M0
         PQNlm6Pe+Y6rTZ7elP2c29TMhRvWreLgjGq8FnBoJthIaW4Bj4ss425MGFxbskXqgMQV
         d5aQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=LEsj0JvF5oyzUNmNgQWz6pMzr+Cf/rYYP2iyFKbjxv8=;
        b=S/whieR3KA2av18vPTXCH2kqjB3NnQADfrtpCHcImt1CxFSWU8BPZMMU/z13ofHQZT
         PxUlGJ7Zt/1E3Fe06kcnFhKlhTTmtNwA/ImiGhtc68e7nbtLonooPNOToP/udnqWJaIZ
         V2D2lK8wER3Zyw7MikAhc3Tb8j3nK+P3wofAn8KbS5wmViMvkHJoo84zyBu6x7GYt7T8
         q6hZAYZp5aLy9tB3mZUr+VqvCoF7iZEeuj/wo3Wi7bFnRahlqYzrqVvRStm+EMg+Lefa
         tUVA/7nOyGkLgoaG2vU+0dPS/ylOxUb6fVMUdUqHJVoNcrHsFAqEvg3zx4rQMVQmqABj
         J8OQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id f9si193471pgv.5.2019.06.05.15.12.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 15:12:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jun 2019 15:12:44 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga004.jf.intel.com with ESMTP; 05 Jun 2019 15:12:44 -0700
Subject: [PATCH v9 05/12] mm/hotplug: Kill is_dev_zone() usage in
 __remove_pages()
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Logan Gunthorpe <logang@deltatee.com>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>,
 linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org,
 osalvador@suse.de, mhocko@suse.com
Date: Wed, 05 Jun 2019 14:58:27 -0700
Message-ID: <155977190749.2443951.1028412998584791672.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The zone type check was a leftover from the cleanup that plumbed altmap
through the memory hotplug path, i.e. commit da024512a1fa "mm: pass the
vmem_altmap to arch_remove_memory and __remove_pages".

Cc: Michal Hocko <mhocko@suse.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Reviewed-by: David Hildenbrand <david@redhat.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/memory_hotplug.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 647859a1d119..4b882c57781a 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -535,11 +535,8 @@ void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 	unsigned long map_offset = 0;
 	int sections_to_remove;
 
-	/* In the ZONE_DEVICE case device driver owns the memory region */
-	if (is_dev_zone(zone)) {
-		if (altmap)
-			map_offset = vmem_altmap_offset(altmap);
-	}
+	if (altmap)
+		map_offset = vmem_altmap_offset(altmap);
 
 	clear_zone_contiguous(zone);
 

