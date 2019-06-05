Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C502C28CC6
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 22:13:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B4432075B
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 22:13:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B4432075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D13956B0278; Wed,  5 Jun 2019 18:13:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC4AA6B0279; Wed,  5 Jun 2019 18:13:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD9D76B027A; Wed,  5 Jun 2019 18:13:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 88CBA6B0278
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 18:13:07 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id o184so295364pfg.1
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 15:13:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=ZKEVF6/9Fmnf7YWUEHXmw9ISQdNkRcpJo8Na4G/GKC4=;
        b=BCeqToVzLBF1A1ZbWV9+cG9POqmsiD7ImpqRXtbidKaD7LyIHvX2zbMyLnH7pkrSY3
         A/2G4IRARUGlWtYnf8cojZnwsTX/dGSoJeAIFxwDLX3dbJ6pdiWsz/yXYSVv0JisY2Ep
         fofwdBVljof9ud9lvOWrzU8RvqbfU2ROFnsB1CozwP7tLlwr3Fy2R5X2E/JvaT9lChxX
         TNIPjpZPuC41ryFNerKwiqgKQJrZHV3uDfy2Ka922kn8dBzjnaZZCb/pwg7bNCijmbwl
         sAT5h5RnuwHHRhcojRC/JBqTRAN2KXkcNZTCAEfHDrkJpnng+LjnAzJLwDL6qYqBW0p5
         VVng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW0mGyjR/39WAwdSKFAFLG6m4IfVC0tNqZCZkEf+tLSV4tvvZeu
	3kAyM9DNowiSBRJtjJnianDg0OdpTD40+xqrAyI61wdAa42IojCv5g551Iy2onz23SyhxA2dkZc
	fhO7M2CFOwZ/L5JKC2Wv0trFaeooENo0WK9WyZgCSAyeeU+xqKfaas7b/37UWHXqmSg==
X-Received: by 2002:a62:6844:: with SMTP id d65mr49852196pfc.175.1559772787071;
        Wed, 05 Jun 2019 15:13:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzOrtAL1AwWounTtOkAYRDAe1mqjQ4r+x2AJblYA/43LdlB/U5cDZoB46q7dxBps6Oy1t3/
X-Received: by 2002:a62:6844:: with SMTP id d65mr49852068pfc.175.1559772785999;
        Wed, 05 Jun 2019 15:13:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559772785; cv=none;
        d=google.com; s=arc-20160816;
        b=TR5rrXpDVhZsekuRzaSB4AsqO2fb7IuTcTG7+PW7OdNqYOwlL1rICZLxi2tvZe9j4S
         ZqEMimBhgSZfXuU+HDfbrOpIKElnOJlviH1ah6DnnFCpVaPt3AEk0GRkoPLkNgBzvFL+
         IPMNEZ+JETOtdDerbwzAY9c32Y8NJ8CiMf5HFIbcaOaJvc17iK+cc6qPCp3BDCPuYk77
         n4O1AXHTNU6HUH2zV04IAjHEk2IG/F+DFzAgxyxMX9bhoexoGWqHF5gkCGQOE1ak8eiZ
         xIl1OH8oeglPIMrxqmJsv6pzGUUPrfkZTx7f2ZpFaDHuhxOrRyh5Olu+5XZcviyR4eiK
         m8Pw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=ZKEVF6/9Fmnf7YWUEHXmw9ISQdNkRcpJo8Na4G/GKC4=;
        b=Lsx+GCXH4jA80/tsF/krCVdFvNs6+19xY7y4/p/oTU4cNXGEHZXz5JImzU8h4BxnDH
         4ZdzZ+y/N6+i9QbV3KE1ARd6Gnf5B8H0GBfUouZodg+vV+WMz86ZhVUqODVCNqcPkxlR
         uoro5C/RVrQ6HLJd0WqNeqOzAowCPf5AkcI5bNMCL0yqdoDBkGVccLMNud/+Hz9g0U7q
         J8nzFdj3wy9C12mURmWze9QNryU6r8xQiSZy/oDUU6gbjhpFL+CtpOryHylEdxpAd+B3
         KqA7rbVc7/0LDqP7PoPH72DCWPivlr2gRkq+RkVSIPhsR0+orX49S6LZuDThHwcmwyCY
         glZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id i2si152453pgl.282.2019.06.05.15.13.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 15:13:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jun 2019 15:13:04 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga008.fm.intel.com with ESMTP; 05 Jun 2019 15:13:04 -0700
Subject: [PATCH v9 09/12] mm: Document ZONE_DEVICE memory-model implications
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Jonathan Corbet <corbet@lwn.net>, Mike Rapoport <rppt@linux.ibm.com>,
 linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org,
 osalvador@suse.de, mhocko@suse.com
Date: Wed, 05 Jun 2019 14:58:47 -0700
Message-ID: <155977192794.2443951.16177998596403034849.stgit@dwillia2-desk3.amr.corp.intel.com>
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

