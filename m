Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id C1F336B0070
	for <linux-mm@kvack.org>; Mon, 20 Apr 2015 04:49:28 -0400 (EDT)
Received: by oiko83 with SMTP id o83so118975217oik.1
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 01:49:28 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id la5si13040829obb.103.2015.04.20.01.49.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Apr 2015 01:49:25 -0700 (PDT)
From: Xie XiuQi <xiexiuqi@huawei.com>
Subject: [PATCH v4 0/3] tracing: add trace event for memory-failure
Date: Mon, 20 Apr 2015 16:44:37 +0800
Message-ID: <1429519480-11687-1-git-send-email-xiexiuqi@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com, rostedt@goodmis.org, mingo@redhat.com
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, koct9i@gmail.com, hpa@linux.intel.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, luto@amacapital.net, nasa4836@gmail.com, gong.chen@linux.intel.com, bhelgaas@google.com, bp@suse.de, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jingle.chen@huawei.com

RAS user space tools like rasdaemon which base on trace event, could
receive mce error event, but no memory recovery result event. So, I
want to add this event to make this scenario complete.

This patchset add a event at ras group for memory-failure.

The output like below:
#  tracer: nop
#
#  entries-in-buffer/entries-written: 2/2   #P:24
#
#                               _-----=> irqs-off
#                              / _----=> need-resched
#                             | / _---=> hardirq/softirq
#                             || / _--=> preempt-depth
#                             ||| /     delay
#            TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
#               | |       |   ||||       |         |
       mce-inject-13150 [001] ....   277.019359: memory_failure_event: pfn 0x19869: recovery action for free buddy page: Delayed

--
v3->v4:
 - rebase on top of latest linux-next
 - update comments as Naoya's suggestion
 - add #ifdef CONFIG_MEMORY_FAILURE for this trace event
 - change type of action_result's param 3 to enum

v2->v3:
 - rebase on top of linux-next
 - based on Steven Rostedt's "tracing: Add TRACE_DEFINE_ENUM() macro
   to map enums to their values" patch set v1.

v1->v2:
 - Comment update
 - Just passing 'result' instead of 'action_name[result]',
   suggested by Steve. And hard coded there because trace-cmd
   and perf do not have a way to process enums.

Xie XiuQi (3):
  memory-failure: export page_type and action result
  memory-failure: change type of action_result's param 3 to enum
  tracing: add trace event for memory-failure

 include/linux/mm.h      |  34 ++++++++++
 include/ras/ras_event.h |  85 ++++++++++++++++++++++++
 mm/memory-failure.c     | 172 ++++++++++++++++++++----------------------------
 3 files changed, 190 insertions(+), 101 deletions(-)

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
