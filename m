Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE7C6B00A1
	for <linux-mm@kvack.org>; Sun, 24 May 2015 12:00:42 -0400 (EDT)
Received: by pabru16 with SMTP id ru16so54631060pab.1
        for <linux-mm@kvack.org>; Sun, 24 May 2015 09:00:42 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id da1si12418590pad.9.2015.05.24.09.00.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 May 2015 09:00:41 -0700 (PDT)
Received: by pdbqa5 with SMTP id qa5so53578509pdb.0
        for <linux-mm@kvack.org>; Sun, 24 May 2015 09:00:41 -0700 (PDT)
From: Jungseok Lee <jungseoklee85@gmail.com>
Subject: [RFC PATCH 0/2] vmalloc based thread_info allocator
Date: Mon, 25 May 2015 01:00:31 +0900
Message-Id: <1432483231-23061-1-git-send-email-jungseoklee85@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: barami97@gmail.com

ARM64 kernel tries to get physically contiguous 16KB for thread_info
when creating a process. The allocation is sometimes failed on low
memory platforms due to memory fragmentation, not a lack of free memory.

The first approach is to improve memory compaction logic, but the work should
consider a lot of different factors and scenarios. Instead, Sungjinn Chung
suggests a vmalloc based thread_info allocator which can address the issue
by memory fragmentation without touching any internal memory management codes.

The patches implement the idea as allocating the memory from vmalloc space
instead of 1:1 mapping area. The idea is accompanied by another observation:
vmalloc space is large enough to handle allocation request on ARM64 kernel.
It is ~240GB under a combination of 39-bit VA and 4KB page.

If a 64-bit kernel with low system memory is not an unusual option on other
architectures, the idea could be expaneded into them.

All works are based on the following branch:
https://git.kernel.org/cgit/linux/kernel/git/arm64/linux.git/log/?h=for-next/core

Any feedback or comment very welcome!

Thanks in advance!

Jungseok Lee (2):
  kernel/fork.c: add a function to calculate page address from
    thread_info
  arm64: Implement vmalloc based thread_info allocator

 arch/arm64/Kconfig                   | 12 ++++++++++++
 arch/arm64/include/asm/thread_info.h |  9 +++++++++
 arch/arm64/kernel/process.c          |  7 +++++++
 kernel/fork.c                        |  7 ++++++-
 4 files changed, 34 insertions(+), 1 deletion(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
