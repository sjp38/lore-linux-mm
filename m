Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id BC0836B0149
	for <linux-mm@kvack.org>; Wed, 20 May 2015 23:50:23 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so92872056pdb.0
        for <linux-mm@kvack.org>; Wed, 20 May 2015 20:50:23 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id kk7si27935340pab.75.2015.05.20.20.50.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 20 May 2015 20:50:21 -0700 (PDT)
From: Xie XiuQi <xiexiuqi@huawei.com>
Subject: [PATCH v6 0/5] tracing: add trace event for memory-failure
Date: Thu, 21 May 2015 11:41:20 +0800
Message-ID: <1432179685-11369-1-git-send-email-xiexiuqi@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com
Cc: rostedt@goodmis.org, gong.chen@linux.intel.com, mingo@redhat.com, bp@suse.de, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jingle.chen@huawei.com, sfr@canb.auug.org.au, rdunlap@infradead.org, jim.epost@gmail.com

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
v5->v6:
 - fix a build error
 - move ras_event.h under include/trace/events
 - rebase on top of latest mainline

v4->v5:
 - fix a typo
 - rebase on top of latest mainline

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

Naoya Horiguchi (1):
  trace, ras: move ras_event.h under include/trace/events

Xie XiuQi (4):
  memory-failure: export page_type and action result
  memory-failure: change type of action_result's param 3 to enum
  tracing: add trace event for memory-failure
  tracing: fix build error in mm/memory-failure.c

 drivers/acpi/acpi_extlog.c             |    2 +-
 drivers/edac/edac_mc.c                 |    2 +-
 drivers/edac/ghes_edac.c               |    2 +-
 drivers/pci/pcie/aer/aerdrv_errprint.c |    2 +-
 drivers/ras/ras.c                      |    3 +-
 include/linux/mm.h                     |   34 ++++
 include/ras/ras_event.h                |  238 -----------------------
 include/trace/events/ras.h             |  322 ++++++++++++++++++++++++++++++++
 mm/Kconfig                             |    1 +
 mm/memory-failure.c                    |  172 +++++++----------
 10 files changed, 433 insertions(+), 345 deletions(-)
 delete mode 100644 include/ras/ras_event.h
 create mode 100644 include/trace/events/ras.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
