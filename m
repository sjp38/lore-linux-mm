Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id E38176B0038
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 18:26:00 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so20539910pab.0
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 15:26:00 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id d10si185283pap.237.2015.12.01.15.26.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 15:26:00 -0800 (PST)
Received: by pacej9 with SMTP id ej9so19928796pac.2
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 15:26:00 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [RFC] Add gup trace points support
Date: Tue,  1 Dec 2015 15:06:10 -0800
Message-Id: <1449011177-30686-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org


Some background about why I think this might be useful.

When I was profiling some hugetlb related program, I got page-faults event
doubled when hugetlb is enabled. When I looked into the code, I found page-faults
come from two places, do_page_fault and gup. So, I tried to figure out which
play a role (or both) in my use case. But I can't find existing finer tracing
event for sub page-faults in current mainline kernel.

So, I added the gup trace points support to have finer tracing events for
page-faults. The below events are added:

__get_user_pages
__get_user_pages_fast
fixup_user_fault

Both __get_user_pages and fixup_user_fault call handle_mm_fault.

Just added trace points to raw version __get_user_pages since all variants
will call it finally to do real work.

Although __get_user_pages_fast doesn't call handle_mm_fault, it might be useful
to have it to distinguish between slow and fast version.


Yang Shi (7):
      trace/events: Add gup trace events
      mm/gup: add gup trace points
      x86: mm/gup: add gup trace points
      mips: mm/gup: add gup trace points
      s390: mm/gup: add gup trace points
      sh: mm/gup: add gup trace points
      sparc64: mm/gup: add gup trace points

 arch/mips/mm/gup.c         |  7 +++++++
 arch/s390/mm/gup.c         |  7 +++++++
 arch/sh/mm/gup.c           |  8 ++++++++
 arch/sparc/mm/gup.c        |  8 ++++++++
 arch/x86/mm/gup.c          |  7 +++++++
 include/trace/events/gup.h | 77 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/gup.c                   |  8 ++++++++
 7 files changed, 122 insertions(+)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
