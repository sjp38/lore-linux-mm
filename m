Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CF7BC31E5D
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:06:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E65A320B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:06:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E65A320B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92CBB8E0001; Wed, 19 Jun 2019 02:06:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DE4E6B0269; Wed, 19 Jun 2019 02:06:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F3D08E0001; Wed, 19 Jun 2019 02:06:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 466436B0266
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:06:49 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id r142so10997238pfc.2
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:06:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=ZKEVF6/9Fmnf7YWUEHXmw9ISQdNkRcpJo8Na4G/GKC4=;
        b=UTQ2FS88aQW73kH3AdhtPdnEeJuF1LruLfa3mvy8eKyGuDFkwnvEHFLbdELKsCM9JF
         gKbA7wCHZUVryPvKPT68mhUtZ8RryOYaLgoMe3gIctRXitH0ep8Sfh33cB60cCS9VkP8
         j8NUAfMai2exah9h+nX8Q43mqdhtEhNLODaV1TDSXqS/2CeRWLVWWSTmlxGfMS0IKCdZ
         OVjaf2nNg5+ISgahZHOBBpJmYTtkDMUqhOOsnWbhbkZ93lOoPMbatDpICvBymdKIW8qc
         r9rexGQSxLQh+kREI4DLdvUcnNv860crPPpWO8FpR+0PsQfxsM0LC4J5U3bx6ciWGlG6
         KQHQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWcopqX+YsrkIn2FQBa9qSL8ZuXKalTQ8Cuu3MmmLv1ryZBsvWu
	mrV7sql7OY3JD1cnuFkLB9kJciQHDYwQL9pYvSyDI/Coo6Lo5eRRE53L4wB5RBGjA6t0ZBn8GVu
	2J3aEvD9h/ZXynyGClxnlvsJofELy8FVvlqxTQQkIx9eBblEzByzUt3DpZmip0o/bZA==
X-Received: by 2002:a63:2326:: with SMTP id j38mr6319652pgj.134.1560924408750;
        Tue, 18 Jun 2019 23:06:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIAMBpqzxfHg0KN0w1+yBof3dD3cpbCdAvsW/tD9CAyh4It7d3BJdCvzS2l3w9RmkdciT8
X-Received: by 2002:a63:2326:: with SMTP id j38mr6319574pgj.134.1560924407408;
        Tue, 18 Jun 2019 23:06:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560924407; cv=none;
        d=google.com; s=arc-20160816;
        b=JJMFi//CV8beoUae273cktcTe6Yh0E2vmZ6Sg7y76gRSHZKOBMlKKXxJCiaydqZVrM
         12MmWQChKcXLp2azfmA6LbGkBOz3B9w6yqJVmAn93S+IIiHMb1Jaxn+gxpDNBooAzWK3
         6hi7iaahJuqwEDUXaqg7eu/kKnRUM1H4I4al8rHw4+DcSsjduWhxfYdSAmwHHA/Qg8ZB
         kqU0ZgOc04Vxtw2xNVfWh+V37Y1a7UBbT/QX1OoZ8bvzt9h6I2oJtLlTWcQhRGI9zH+B
         vR67o0MTWUgB84NOI3tedIegrPYyI8AQ1MbCH+v3LCjMBQhpbCrLqBayClSyLBjbmHx1
         Cw+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=ZKEVF6/9Fmnf7YWUEHXmw9ISQdNkRcpJo8Na4G/GKC4=;
        b=fxZA2lUpRFVFZtcnEUKAyf9MX2KGoRe+0za1bNxAyNlDytBZ7mFAo6Bk+PN73F/f2G
         J3hy96j+Td3tElg3AbHdwsWmE73KnP9nxZGp6seCHtEJbCdMrsRUGcdEOnQfD3EFaNJg
         ysn4v07b9pLX6QfHJWA3mVAhAzVnayG5wH+dUItnuc4x16faaw0qccNxZe8rqE3gmgWZ
         TBTEPeWR8orPif9LCAb/i28+zG6SM02Vpb9Mbk/ddpMb8wGod79zF5w+tRTvnftsicME
         gw7pFDt8RSSFX2wm0iXMwKxAHX53hqEMNHrxsmlaUdBmHYJzV2c7/xTNsYyxl1i84mV+
         Cw3w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id g7si2239090pgd.32.2019.06.18.23.06.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 23:06:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 23:06:46 -0700
X-IronPort-AV: E=Sophos;i="5.63,392,1557212400"; 
   d="scan'208";a="181561933"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga001-auth.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 23:06:46 -0700
Subject: [PATCH v10 10/13] mm: Document ZONE_DEVICE memory-model implications
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Jonathan Corbet <corbet@lwn.net>, Mike Rapoport <rppt@linux.ibm.com>,
 linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Date: Tue, 18 Jun 2019 22:52:29 -0700
Message-ID: <156092354985.979959.15763234410543451710.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Explain the general mechanisms of 'ZONE_DEVICE' pages and list the users
of 'devm_memremap_pages()'.

Cc: Jonathan Corbet <corbet@lwn.net>
Reported-by: Mike Rapoport <rppt@linux.ibm.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 Documentation/vm/memory-model.rst |   39 +++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/Documentation/vm/memory-model.rst b/Documentation/vm/memory-model.rst
index 382f72ace1fc..e0af47e02e78 100644
--- a/Documentation/vm/memory-model.rst
+++ b/Documentation/vm/memory-model.rst
@@ -181,3 +181,42 @@ that is eventually passed to vmemmap_populate() through a long chain
 of function calls. The vmemmap_populate() implementation may use the
 `vmem_altmap` along with :c:func:`altmap_alloc_block_buf` helper to
 allocate memory map on the persistent memory device.
+
+ZONE_DEVICE
+===========
+The `ZONE_DEVICE` facility builds upon `SPARSEMEM_VMEMMAP` to offer
+`struct page` `mem_map` services for device driver identified physical
+address ranges. The "device" aspect of `ZONE_DEVICE` relates to the fact
+that the page objects for these address ranges are never marked online,
+and that a reference must be taken against the device, not just the page
+to keep the memory pinned for active use. `ZONE_DEVICE`, via
+:c:func:`devm_memremap_pages`, performs just enough memory hotplug to
+turn on :c:func:`pfn_to_page`, :c:func:`page_to_pfn`, and
+:c:func:`get_user_pages` service for the given range of pfns. Since the
+page reference count never drops below 1 the page is never tracked as
+free memory and the page's `struct list_head lru` space is repurposed
+for back referencing to the host device / driver that mapped the memory.
+
+While `SPARSEMEM` presents memory as a collection of sections,
+optionally collected into memory blocks, `ZONE_DEVICE` users have a need
+for smaller granularity of populating the `mem_map`. Given that
+`ZONE_DEVICE` memory is never marked online it is subsequently never
+subject to its memory ranges being exposed through the sysfs memory
+hotplug api on memory block boundaries. The implementation relies on
+this lack of user-api constraint to allow sub-section sized memory
+ranges to be specified to :c:func:`arch_add_memory`, the top-half of
+memory hotplug. Sub-section support allows for `PMD_SIZE` as the minimum
+alignment granularity for :c:func:`devm_memremap_pages`.
+
+The users of `ZONE_DEVICE` are:
+* pmem: Map platform persistent memory to be used as a direct-I/O target
+  via DAX mappings.
+
+* hmm: Extend `ZONE_DEVICE` with `->page_fault()` and `->page_free()`
+  event callbacks to allow a device-driver to coordinate memory management
+  events related to device-memory, typically GPU memory. See
+  Documentation/vm/hmm.rst.
+
+* p2pdma: Create `struct page` objects to allow peer devices in a
+  PCI/-E topology to coordinate direct-DMA operations between themselves,
+  i.e. bypass host memory.

