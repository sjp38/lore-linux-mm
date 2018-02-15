Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 74B456B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 11:08:46 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id r17so582339itc.7
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 08:08:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n66sor7681765iof.187.2018.02.15.08.08.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Feb 2018 08:08:45 -0800 (PST)
From: Dennis Zhou <dennisszhou@gmail.com>
Subject: [PATCH 0/3] percpu: introduce no retry semantics and gfp passthrough
Date: Thu, 15 Feb 2018 10:08:13 -0600
Message-Id: <cover.1518668149.git.dennisszhou@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dennis Zhou <dennisszhou@gmail.com>

Hi everyone,

The percpu memory using the valloc area based chunk allocator lazily
populates chunks by first requesting the full virtual address space
required for the chunk and subsequently adding pages as allocations come
through. To ensure atomic allocations can succeed, a workqueue item is
used to maintain a minimum number of empty pages. In certain scenarios,
such as reported in [1], it is possible that physical memory becomes
quite scarce which can result in either a rather long time spent trying
to find free pages or worse, a kernel panic.

This patchset introduces no retry semantics to percpu memory by allowing
users to pass through certain flags controlled by a whitelist. In this
case, only __GFP_NORETRY and __GFP_NOWARN are initially allowed. This
should prevent the eventual kernel panic due to the workqueue item and
now give flexibility to users to decide how they want to fail when the
percpu allocator fails if they use the additional flags. This does not
prevent the allocator from panicking should an allocation without the
additional flags cause an underlying allocator to trigger out of memory.

I tested this by running basic allocations with and without passing
the additional flags. Allocations are able to proceed / fail as
expected without triggering the out of memory kernel panic. I still
saw OOM killer activate, but I attribute that to other programs faulting
in the background. Without the flags, the kernel panics pretty quickly
with the expected out of memory panic.

[1] https://lkml.org/lkml/2018/2/12/551

This patchset contains the following 3 patches:
  0001-percpu-match-chunk-allocator-declarations-with-defin.patch
  0002-percpu-add-__GFP_NORETRY-semantics-to-the-percpu-bal.patch
  0003-percpu-allow-select-gfp-to-be-passed-to-underlying-a.patch

0001 fixes out of sync declaration and definiton variable names. 0002 adds
no retry semantics to the workqueue balance path. 0003 enables users to
pass through flags to the underlying percpu memory allocators. This also
cleans up the semantics surrounding how the flags are managed.

This patchset is ontop of percpu#master 7928b2cbe5.

diffstats below:

Dennis Zhou (3):
  percpu: match chunk allocator declarations with definitions
  percpu: add __GFP_NORETRY semantics to the percpu balancing path
  percpu: allow select gfp to be passed to underlying allocators

 mm/percpu-km.c |  8 ++++----
 mm/percpu-vm.c | 18 +++++++++++-------
 mm/percpu.c    | 52 ++++++++++++++++++++++++++++++++++------------------
 3 files changed, 49 insertions(+), 29 deletions(-)

Thanks,
Dennis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
