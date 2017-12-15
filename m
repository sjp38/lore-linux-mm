Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1066F6B0069
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 09:10:12 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q186so7011892pga.23
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 06:10:12 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n12si5011231pls.677.2017.12.15.06.10.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 06:10:10 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: revamp vmem_altmap / dev_pagemap handling V2
Date: Fri, 15 Dec 2017 15:09:30 +0100
Message-Id: <20171215140947.26075-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi all,

this series started with two patches from Logan that now are in the
middle of the series to kill the memremap-internal pgmap structure
and to redo the dev_memreamp_pages interface to be better suitable
for future PCI P2P uses.  I reviewed them and noticed that there
isn't really any good reason to keep struct vmem_altmap either,
and that a lot of these alternative device page map access should
be better abstracted out instead of being sprinkled all over the
mm code.  But when we got the RCU warnings in V1 I went for yet
another approach, and now struct vmem_altmap is kept for now,
but passed explicitly through the memory hotplug code instead of
having to do unprotected lookups through the radix tree.  The
end result is that only the get_user_pages path ever looks up
struct dev_pagemap, and struct vmem_altmap is now always embedded
into struct dev_pagemap, and explicitly passed where needed.

Please review carefully, this has only been tested with my legacy
e820 NVDIMM system.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
