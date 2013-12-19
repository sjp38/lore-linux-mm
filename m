Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f180.google.com (mail-ea0-f180.google.com [209.85.215.180])
	by kanga.kvack.org (Postfix) with ESMTP id 65DF86B0038
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 07:00:10 -0500 (EST)
Received: by mail-ea0-f180.google.com with SMTP id f15so417630eak.25
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 04:00:09 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5si3958047eei.207.2013.12.19.04.00.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 04:00:09 -0800 (PST)
Date: Thu, 19 Dec 2013 12:00:07 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: Remove bogus warning in copy_huge_pmd
Message-ID: <20131219120007.GJ11295@suse.de>
References: <1386690695-27380-1-git-send-email-mgorman@suse.de>
 <1386690695-27380-11-git-send-email-mgorman@suse.de>
 <52B0D5F9.5030208@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <52B0D5F9.5030208@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Sasha Levin reported the following warning being triggered

[ 1704.594807] WARNING: CPU: 28 PID: 35287 at mm/huge_memory.c:887 copy_huge_pmd+0x145/ 0x3a0()
[ 1704.597258] Modules linked in:
[ 1704.597844] CPU: 28 PID: 35287 Comm: trinity-main Tainted: G        W    3.13.0-rc4-next-20131217-sasha-00013-ga878504-dirty #4149
[ 1704.599924]  0000000000000377e delta! pid slot 27 [36258]: old:2 now:537927697 diff: 537927695 ffff8803593ddb90 ffffffff8439501c ffffffff854722c1
[ 1704.604846]  0000000000000000 ffff8803593ddbd0 ffffffff8112f8ac ffff8803593ddbe0
[ 1704.606391]  ffff88034bc137f0 ffff880e41677000 8000000b47c009e4 ffff88034a638000
[ 1704.608008] Call Trace:
[ 1704.608511]  [<ffffffff8439501c>] dump_stack+0x52/0x7f
[ 1704.609699]  [<ffffffff8112f8ac>] warn_slowpath_common+0x8c/0xc0
[ 1704.612617]  [<ffffffff8112f8fa>] warn_slowpath_null+0x1a/0x20
[ 1704.614043]  [<ffffffff812b91c5>] copy_huge_pmd+0x145/0x3a0
[ 1704.615587]  [<ffffffff8127e032>] copy_page_range+0x3f2/0x560
[ 1704.616869]  [<ffffffff81199ef1>] ? rwsem_wake+0x51/0x70
[ 1704.617942]  [<ffffffff8112cf59>] dup_mmap+0x2c9/0x3d0
[ 1704.619146]  [<ffffffff8112d54d>] dup_mm+0xad/0x150
[ 1704.620051]  [<ffffffff8112e178>] copy_process+0xa68/0x12e0
[ 1704.622976]  [<ffffffff81194eda>] ? __lock_release+0x1da/0x1f0
[ 1704.624234]  [<ffffffff8112eee6>] do_fork+0x96/0x270
[ 1704.624975]  [<ffffffff81249465>] ? context_tracking_user_exit+0x195/0x1d0
[ 1704.626427]  [<ffffffff811930ed>] ? trace_hardirqs_on+0xd/0x10
[ 1704.627681]  [<ffffffff8112f0d6>] SyS_clone+0x16/0x20
[ 1704.628833]  [<ffffffff843a6309>] stub_clone+0x69/0x90
[ 1704.629672]  [<ffffffff843a6150>] ? tracesys+0xdd/0xe2

This warning was introduced by "mm: numa: Avoid unnecessary disruption
of NUMA hinting during migration" for paranoia reasons but the warning
is bogus. I was thinking of parallel races between NUMA hinting faults
and forks but this warning would also be triggered by a parallel reclaim
splitting a THP during a fork. Remote the bogus warning.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/huge_memory.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e3b6a75..468bd3a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -883,9 +883,6 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		goto out_unlock;
 	}
 
-	/* mmap_sem prevents this happening but warn if that changes */
-	WARN_ON(pmd_trans_migrating(pmd));
-
 	if (unlikely(pmd_trans_splitting(pmd))) {
 		/* split huge page running from under us */
 		spin_unlock(src_ptl);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
