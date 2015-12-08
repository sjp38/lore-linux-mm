Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 853576B0253
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 14:59:54 -0500 (EST)
Received: by pfnn128 with SMTP id n128so17048953pfn.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 11:59:54 -0800 (PST)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id e86si7082750pfj.161.2015.12.08.11.59.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 11:59:53 -0800 (PST)
Received: by pfnn128 with SMTP id n128so17048811pfn.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 11:59:53 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [RFC V3] Add gup trace points support
Date: Tue,  8 Dec 2015 11:39:48 -0800
Message-Id: <1449603595-718-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org


v3:
* Adopted suggestion from Dave Hansen to move the gup header include to the last
* Adopted comments from Steven:
  - Use DECLARE_EVENT_CLASS and DEFINE_EVENT
  - Just keep necessary TP_ARGS
* Moved archtichture specific fall-backable fast version trace point after the
  do while loop since it may jump to the slow version.
* Not implement recording return value since Steven plans to have it in generic
  tracing code
 
v2:
* Adopted commetns from Steven
  - remove all reference to tsk->comm since it is unnecessary for non-sched
    trace points
  - reduce arguments for __get_user_pages trace point and update mm/gup.c
    accordingly
* Added Ralf's acked-by for patch 4/7.

There is not content change for the trace points in arch specific mm/gup.c.


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
 arch/s390/mm/gup.c         |  6 ++++++
 arch/sh/mm/gup.c           |  7 +++++++
 arch/sparc/mm/gup.c        |  7 +++++++
 arch/x86/mm/gup.c          |  7 +++++++
 include/trace/events/gup.h | 63 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/gup.c                   |  8 ++++++++
 7 files changed, 105 insertions(+)
 create mode 100644 include/trace/events/gup.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
