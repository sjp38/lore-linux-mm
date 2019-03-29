Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54B9AC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 15:40:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B5D2218A5
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 15:40:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B5D2218A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B10F96B0010; Fri, 29 Mar 2019 11:40:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A987D6B0269; Fri, 29 Mar 2019 11:40:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 911836B026A; Fri, 29 Mar 2019 11:40:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 575A16B0010
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 11:40:06 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i14so1730822pfd.10
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 08:40:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=HhvSzRyq8WkMw7W9vxsrODC4BAjOkgowhQkgNrCP1Jg=;
        b=Xjnb42H4yID3XR9PbtxNKApvZTVcgAmstqZiRaQ11Y/sDrLC5+ZgMkIUIGTMbfL6TO
         QsaOz8kAmAtNhJvDGlbF4vTmd31MB/r+KgAC2JIM+suVqCKnIiV/5IMzpCFMJgKRLwIC
         rT1xipL6+BVDRsSS333Ekc2b3MsaMyTJAf/biQuKWY3nWZ5WA4JocD0h+VEi2n/3j83K
         RSYmWcV6zbJon40ZScDnK2S+dbEV7qsvqqj9FU7+u6dx9J4kBZCKCe3hp+bm6J/cjJKu
         dCCnLrTo9dQIIu0AuI8IUkI9d6kVC2MjnC0rU7Sqy5+VFRTmbEcBcDCnodpG3RML0pnK
         vp8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXrT2H7SKIKfQPbEkqNbVMO2A4wqJSjgoO9ebiPPGRd2JR76F41
	YqFi2tKAfe75itRE06dmL8BCxKwoq5KsyPPTJPBTHtFjnuc4SWL2amcVU9K7F8U3LPDQMuhIP0J
	XPPJ0x0gSoPwCwhKaq+2HESkH/z03LpuxckXBT9hrCEfTkynpWZICyQjLLdef4X9J0Q==
X-Received: by 2002:a65:5c4b:: with SMTP id v11mr45575324pgr.411.1553874005956;
        Fri, 29 Mar 2019 08:40:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIeUtuXy2UC+F51J9xvRuCGQ2lNXInRoDBVz9EVdxjfP614gBEUJe21GlK6Przwq/6U+zH
X-Received: by 2002:a65:5c4b:: with SMTP id v11mr45575253pgr.411.1553874005095;
        Fri, 29 Mar 2019 08:40:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553874005; cv=none;
        d=google.com; s=arc-20160816;
        b=alt0J8OiDg0Wow5wjXABbcS5qEiSlGQxoEkyFxV7KAcvuiUcj5J7zm639vux/opphh
         AdB8M13bJp1HAPfFMxCnV2hXbAyrF+1Atqc9zdyb/sYQJAzucVGTNGIvBF9tURxjRzwu
         9+S7BOXCxblobODj0yFdjWvRnMFfoSnBszfpBe7CrKibskQVWfPAxoML6RRLUydFhUYE
         cBTDYnFtS/lUHkEHZu/PGxrittGPwxEy/9kK58dJQNQhG9WRxO6yf+z392Nbht2LuHHB
         fGaLPKGxorf/ezw0VxGXV1aizbIoOFAYdfWdpgzEOasfEUkiUw/QEa8PQjWOqyF1Y1f6
         h4yQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject;
        bh=HhvSzRyq8WkMw7W9vxsrODC4BAjOkgowhQkgNrCP1Jg=;
        b=E8bYeZaKlBmCe9nzXQRmW8vABhwxpg4TT1MA3jKGuppZ11JjmhQoukpSNuASUKRIg2
         k23JoypRJphayhXVBZxFFL6OOo0EqGE8rUWTEZzUENjv5XAxqsliJs+yNPX+8V2j3E+n
         5N5z3xFXhOYofB9kC+h2sGoZPbTd6d14tI47egEU65D9URrT3geRjRl1NsswO2VW6kxo
         kB0tptLXRkk4GKWHvAzfKE9gmscotJOTwzg5mRJlhQxiILY10MZLaoiWmIsDSOKqOZlx
         nT6vhAsBYU9vjq42jqKd+AByg08jv1nNIRHNPwiyhXr26lSIG2905UBVJpvp5h17yMvV
         Tk9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id v4si2125949pgr.591.2019.03.29.08.40.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 08:40:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 Mar 2019 08:40:03 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,284,1549958400"; 
   d="scan'208";a="129793982"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga008.jf.intel.com with ESMTP; 29 Mar 2019 08:40:03 -0700
Subject: [PATCH 0/6] mm/devm_memremap_pages: Fix page release race
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Ira Weiny <ira.weiny@intel.com>, Bjorn Helgaas <bhelgaas@google.com>,
 Logan Gunthorpe <logang@deltatee.com>, Christoph Hellwig <hch@lst.de>,
 =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>, linux-mm@kvack.org,
 linux-pci@vger.kernel.org, linux-nvdimm@lists.01.org,
 linux-kernel@vger.kernel.org
Date: Fri, 29 Mar 2019 08:27:24 -0700
Message-ID: <155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Logan audited the devm_memremap_pages() shutdown path and noticed that
it was possible to proceed to arch_remove_memory() before all
potential page references have been reaped.

Introduce a new ->cleanup() callback to do the work of waiting for any
straggling page references and then perform the percpu_ref_exit() in
devm_memremap_pages_release() context.

For p2pdma this involves some deeper reworks to reference count
resources on a per-instance basis rather than a per pci-device basis. A
modified genalloc api is introduced to convey a driver-private pointer
through gen_pool_{alloc,free}() interfaces. Also, a
devm_memunmap_pages() api is introduced since p2pdma does not
auto-release resources on a setup failure.

The dax and pmem changes pass the nvdimm unit tests, but the hmm and
p2pdma changes are compile-tested only.

Thoughts on the api changes?

I'm targeting to land this through Andrew's tree. 0day has chewed on
this for a day and reported no issues so far.

---

Dan Williams (6):
      drivers/base/devres: Introduce devm_release_action()
      mm/devm_memremap_pages: Introduce devm_memunmap_pages
      pci/p2pdma: Fix the gen_pool_add_virt() failure path
      lib/genalloc: Introduce chunk owners
      pci/p2pdma: Track pgmap references per resource, not globally
      mm/devm_memremap_pages: Fix final page put race


 drivers/base/devres.c             |   24 ++++++++
 drivers/dax/device.c              |   13 +----
 drivers/nvdimm/pmem.c             |   17 +++++-
 drivers/pci/p2pdma.c              |  105 +++++++++++++++++++++++--------------
 include/linux/device.h            |    1 
 include/linux/genalloc.h          |   55 +++++++++++++++++--
 include/linux/memremap.h          |    8 +++
 kernel/memremap.c                 |   23 ++++++--
 lib/genalloc.c                    |   51 +++++++++---------
 mm/hmm.c                          |   14 +----
 tools/testing/nvdimm/test/iomap.c |    2 +
 11 files changed, 209 insertions(+), 104 deletions(-)

