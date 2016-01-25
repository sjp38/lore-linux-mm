Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id AF59A828DF
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 11:55:57 -0500 (EST)
Received: by mail-qg0-f45.google.com with SMTP id e32so113800450qgf.3
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 08:55:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v192si11149479qka.4.2016.01.25.08.55.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 08:55:57 -0800 (PST)
From: Laura Abbott <labbott@fedoraproject.org>
Subject: [RFC][PATCH 0/3] Sanitization of buddy pages
Date: Mon, 25 Jan 2016 08:55:50 -0800
Message-Id: <1453740953-18109-1-git-send-email-labbott@fedoraproject.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>
Cc: Laura Abbott <labbott@fedoraproject.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>

Hi,

This is an implementation of page poisoning/sanitization for all arches. It
takes advantage of the existing implementation for
!ARCH_SUPPORTS_DEBUG_PAGEALLOC arches. This is a different approach than what
the Grsecurity patches were taking but should provide equivalent functionality.

For those who aren't familiar with this, the goal of sanitization is to reduce
the severity of use after free and uninitialized data bugs. Memory is cleared
on free so any sensitive data is no longer available. Discussion of
sanitization was brough up in a thread about CVEs
(lkml.kernel.org/g/<20160119112812.GA10818@mwanda>)

I eventually expect Kconfig names will want to be changed and or moved if this
is going to be used for security but that can happen later.

Credit to Mathias Krause for the version in grsecurity

Laura Abbott (3):
  mm/debug-pagealloc.c: Split out page poisoning from debug page_alloc
  mm/page_poison.c: Enable PAGE_POISONING as a separate option
  mm/page_poisoning.c: Allow for zero poisoning

 Documentation/kernel-parameters.txt |   5 ++
 include/linux/mm.h                  |  13 +++
 include/linux/poison.h              |   4 +
 mm/Kconfig.debug                    |  35 +++++++-
 mm/Makefile                         |   5 +-
 mm/debug-pagealloc.c                | 127 +----------------------------
 mm/page_alloc.c                     |  10 ++-
 mm/page_poison.c                    | 158 ++++++++++++++++++++++++++++++++++++
 8 files changed, 228 insertions(+), 129 deletions(-)
 create mode 100644 mm/page_poison.c

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
