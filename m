Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8D95D6B0259
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 21:38:24 -0500 (EST)
Received: by mail-qg0-f45.google.com with SMTP id o11so55593232qge.2
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 18:38:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t125si14751130qhc.129.2016.01.28.18.38.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 18:38:23 -0800 (PST)
From: Laura Abbott <labbott@fedoraproject.org>
Subject: [PATCHv2 0/2] Sanitization of buddy pages
Date: Thu, 28 Jan 2016 18:38:17 -0800
Message-Id: <1454035099-31583-1-git-send-email-labbott@fedoraproject.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>
Cc: Laura Abbott <labbott@fedoraproject.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>

Hi,

This is v2 of the series to add sanitization to the buddy allocator.
The standard sanitization blurb:

For those who aren't familiar with this, the goal of sanitization is to reduce
the severity of use after free and uninitialized data bugs. Memory is cleared
on free so any sensitive data is no longer available. Discussion of
sanitization was brough up in a thread about CVEs
(lkml.kernel.org/g/<20160119112812.GA10818@mwanda>)

Changes since v1:
- Squashed the refactor and adding the poisoning together. Having them separate
  didn't seem to give much extra benefit and lead to some churn as well.
- Corrected the order of poison vs. kernel_map in the alloc path
- zeroing can now be enabled with hibernation (enabling zero poisoning turns
  off hibernation)
- Added additional checks for skipping __GFP_ZERO. On SPARSEMEM systems the
  extended page flags are not initialized until after memory is freed to the
  buddy list which prevents the pages from being zeroed on first free via
  poisoning. This does also mean that any residual data that may be left in
  the pages from boot up will not be cleared which is a risk. I'm open to
  suggestions for fixing or it can be future work.
- A few spelling/checkpatch fixes.
- Addressed comments from Dave Hansen and Jianyu Zhan
- This series now depends on the change to allow debug_pagealloc_enabled
  to be used without !CONFIG_DEBUG_PAGEALLOC
  (http://article.gmane.org/gmane.linux.kernel.mm/145208)

Thanks,
Laura

Laura Abbott (2):
  mm/page_poison.c: Enable PAGE_POISONING as a separate option
  mm/page_poisoning.c: Allow for zero poisoning

 Documentation/kernel-parameters.txt |   5 +
 include/linux/mm.h                  |  15 +++
 include/linux/poison.h              |   4 +
 kernel/power/hibernate.c            |  17 ++++
 mm/Kconfig.debug                    |  36 ++++++-
 mm/Makefile                         |   2 +-
 mm/debug-pagealloc.c                | 137 ---------------------------
 mm/page_alloc.c                     |  13 ++-
 mm/page_ext.c                       |  10 +-
 mm/page_poison.c                    | 184 ++++++++++++++++++++++++++++++++++++
 10 files changed, 281 insertions(+), 142 deletions(-)
 delete mode 100644 mm/debug-pagealloc.c
 create mode 100644 mm/page_poison.c

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
