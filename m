Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 0C2DE6B0038
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 16:42:22 -0500 (EST)
Received: by pfdd184 with SMTP id d184so36142149pfd.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 13:42:21 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id d3si15104082pas.116.2015.12.09.13.42.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 13:42:21 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so35951790pac.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 13:42:21 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [RFC V5] Add gup trace points support
Date: Wed,  9 Dec 2015 13:22:24 -0800
Message-Id: <1449696151-4195-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org


v5:
* Fixed a typo introduced by v4 rebase
* Removed redundant "#define CREATE_TRACE_POINTS" from architecture specifc
  gup.c

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
