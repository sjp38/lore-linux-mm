Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 451F36B0256
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 12:49:20 -0500 (EST)
Received: by pfu207 with SMTP id 207so33385109pfu.2
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 09:49:20 -0800 (PST)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id ks7si13987752pab.109.2015.12.09.09.49.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 09:49:18 -0800 (PST)
Received: by pfdd184 with SMTP id d184so33348226pfd.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 09:49:18 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [RFC V4] Add gup trace points support
Date: Wed,  9 Dec 2015 09:29:17 -0800
Message-Id: <1449682164-9933-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org


v4:
* Adopted Steven's suggestion to use "unsigned int" for nr_pages to save
  space in ring buffer since it is unlikely to have more than 0xffffffff
  pages are touched by gup in one invoke
* Remove unnecessray type cast

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
