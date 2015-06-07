Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 82BFA6B0075
	for <linux-mm@kvack.org>; Sun,  7 Jun 2015 13:45:49 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so43066398pac.2
        for <linux-mm@kvack.org>; Sun, 07 Jun 2015 10:45:49 -0700 (PDT)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id nt2si401723pbc.28.2015.06.07.10.45.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Jun 2015 10:45:48 -0700 (PDT)
Date: Sun, 7 Jun 2015 10:43:16 -0700
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-957561ec0fa8a701f60ca6a0f40cc46f5c554920@git.kernel.org>
Reply-To: linux-mm@kvack.org, bp@suse.de, mcgrof@suse.com, hpa@zytor.com,
        toshi.kani@hp.com, luto@amacapital.net, akpm@linux-foundation.org,
        dan.j.williams@intel.com, tglx@linutronix.de, peterz@infradead.org,
        torvalds@linux-foundation.org, mingo@kernel.org,
        linux-kernel@vger.kernel.org
In-Reply-To: <1433436928-31903-14-git-send-email-bp@alien8.de>
References: <1433436928-31903-14-git-send-email-bp@alien8.de>
Subject: [tip:x86/mm] drivers/block/pmem: Map NVDIMM in Write-Through mode
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, mingo@kernel.org, peterz@infradead.org, tglx@linutronix.de, dan.j.williams@intel.com, akpm@linux-foundation.org, luto@amacapital.net, toshi.kani@hp.com, hpa@zytor.com, bp@suse.de, mcgrof@suse.com, linux-mm@kvack.org

Commit-ID:  957561ec0fa8a701f60ca6a0f40cc46f5c554920
Gitweb:     http://git.kernel.org/tip/957561ec0fa8a701f60ca6a0f40cc46f5c554920
Author:     Toshi Kani <toshi.kani@hp.com>
AuthorDate: Thu, 4 Jun 2015 18:55:21 +0200
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sun, 7 Jun 2015 15:29:01 +0200

drivers/block/pmem: Map NVDIMM in Write-Through mode

The pmem driver maps NVDIMM uncacheable so that we don't lose
data which hasn't reached non-volatile storage in the case of a
crash. Change this to Write-Through mode which provides uncached
writes but cached reads, thus improving read performance.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Acked-by: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Elliott@hp.com
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: arnd@arndb.de
Cc: hch@lst.de
Cc: hmh@hmh.eng.br
Cc: jgross@suse.com
Cc: konrad.wilk@oracle.com
Cc: linux-mm <linux-mm@kvack.org>
Cc: linux-nvdimm@lists.01.org
Cc: stefan.bader@canonical.com
Cc: yigal@plexistor.com
Link: http://lkml.kernel.org/r/1433436928-31903-14-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 drivers/block/pmem.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/block/pmem.c b/drivers/block/pmem.c
index eabf4a8..095dfaa 100644
--- a/drivers/block/pmem.c
+++ b/drivers/block/pmem.c
@@ -139,11 +139,11 @@ static struct pmem_device *pmem_alloc(struct device *dev, struct resource *res)
 	}
 
 	/*
-	 * Map the memory as non-cachable, as we can't write back the contents
+	 * Map the memory as write-through, as we can't write back the contents
 	 * of the CPU caches in case of a crash.
 	 */
 	err = -ENOMEM;
-	pmem->virt_addr = ioremap_nocache(pmem->phys_addr, pmem->size);
+	pmem->virt_addr = ioremap_wt(pmem->phys_addr, pmem->size);
 	if (!pmem->virt_addr)
 		goto out_release_region;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
