Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8C596681010
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 16:57:54 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id v184so39004340pgv.6
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 13:57:54 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 63si8157380pff.175.2017.02.16.13.57.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 13:57:53 -0800 (PST)
Subject: [PATCH v2 0/2] fix devm_memremap_pages() mem hotplug locking
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 16 Feb 2017 13:53:48 -0800
Message-ID: <148728202805.38457.18028105614854319884.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Toshi Kani <toshi.kani@hpe.com>, Ben Hutchings <ben@decadent.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-nvdimm@lists.01.org, stable@vger.kernel.org, linux-mm@kvack.org, Logan Gunthorpe <logang@deltatee.com>, Vlastimil Babka <vbabka@suse.cz>

Changes since v1 [1]:
* Reflowed the patches on 4.10-rc8. The v1 series no longer applies
  to -mm now that the sub-section memory hotplug support has been
  deferred to 4.12 [2].

[1]: https://lists.01.org/pipermail/linux-nvdimm/2017-February/008848.html
[2]: http://www.spinics.net/lists/linux-mm/msg121990.html

---

Ben notes that commit f931ab479dd2 "mm: fix devm_memremap_pages crash,
use mem_hotplug_{begin, done}" is incomplete and broken. Writes to
mem_hotplug.active_writer need to be coordinated under the device
hotplug lock. Otherwise, we can potentially corrupt mem_hotplug.refcount
leading to soft lockups.

---

Dan Williams (2):
      mm, devm_memremap_pages: hold device_hotplug lock over mem_hotplug_{begin,done}
      mm: validate device_hotplug is held for memory hotplug


 drivers/base/core.c    |    5 +++++
 include/linux/device.h |    1 +
 kernel/memremap.c      |    6 ++++++
 mm/memory_hotplug.c    |    2 ++
 4 files changed, 14 insertions(+)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
