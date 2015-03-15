Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3AF7D6B00A7
	for <linux-mm@kvack.org>; Sun, 15 Mar 2015 01:43:51 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so25487667pdb.1
        for <linux-mm@kvack.org>; Sat, 14 Mar 2015 22:43:50 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id by8si13477419pdb.43.2015.03.14.22.43.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 14 Mar 2015 22:43:50 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm: Allow small allocations to fail
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1426107294-21551-1-git-send-email-mhocko@suse.cz>
	<1426107294-21551-2-git-send-email-mhocko@suse.cz>
In-Reply-To: <1426107294-21551-2-git-send-email-mhocko@suse.cz>
Message-Id: <201503151443.CFE04129.MVFOOStLFHFOQJ@I-love.SAKURA.ne.jp>
Date: Sun, 15 Mar 2015 14:43:37 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, akpm@linux-foundation.org
Cc: hannes@cmpxchg.org, david@fromorbit.com, mgorman@suse.de, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> As this behavior is established for many years we cannot change it
> immediately. This patch instead exports a new sysctl/proc knob which
> tells allocator how much to retry. The higher the number the longer will
> the allocator loop and try to trigger OOM killer when the memory is too
> low. This implementation counts only those retries which involved OOM
> killer because we do not want to be too eager to fail the request.

I found that this patch conflicts with commit cc87317726f8 ("mm: page_alloc:
revert inadvertent !__GFP_FS retry behavior change") and thus counting retries
regardless of whether the OOM killer was involved, making !__GFP_FS allocation
to fail as eager as commit 9879de7373fc ("mm: page_alloc: embed OOM killing
naturally into allocation slowpath") did when sysctl_nr_alloc_retry == 1.

----------
XFS: possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
XFS: possible memory allocation deadlock in xfs_buf_allocate_memory (mode:0x250)
warn_alloc_failed: 212565 callbacks suppressed
crond: page allocation failure: order:0, mode:0x2015a
rngd: page allocation failure: order:0, mode:0x2015a
CPU: 3 PID: 1667 Comm: rngd Not tainted 4.0.0-rc3+ #37
Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
 0000000000000000 00000000ce4cec53 0000000000000000 ffffffff815f30c4
 000000000002015a ffffffff8111063e ffff88007fffdb00 0000000000000000
 0000000000000040 ffff88007c223db0 0000000000000000 00000000ce4cec53
Call Trace:
 [<ffffffff815f30c4>] ? dump_stack+0x40/0x50
 [<ffffffff8111063e>] ? warn_alloc_failed+0xee/0x150
 [<ffffffff81113b03>] ? __alloc_pages_nodemask+0x623/0xa10
 [<ffffffff81150c57>] ? alloc_pages_current+0x87/0x100
 [<ffffffff8110d30d>] ? filemap_fault+0x1bd/0x400
 [<ffffffff812e3dbc>] ? radix_tree_next_chunk+0x5c/0x240
 [<ffffffff8112f85b>] ? __do_fault+0x4b/0xe0
 [<ffffffff81134465>] ? handle_mm_fault+0xc85/0x1640
 [<ffffffff81051c9a>] ? __do_page_fault+0x16a/0x430
 [<ffffffff81051f90>] ? do_page_fault+0x30/0x70
 [<ffffffff815fb03f>] ? error_exit+0x1f/0x60
 [<ffffffff815fae18>] ? page_fault+0x28/0x30
----------

If you want to count only those retries which involved OOM killer, you need
to do like

-			nr_retries++;
+			if (gfp_mask & __GFP_FS)
+				nr_retries++;

in this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
