Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 942336B03A1
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 02:15:52 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id o79so2370698ioo.15
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 23:15:52 -0700 (PDT)
Received: from cmccmta1.chinamobile.com (cmccmta1.chinamobile.com. [221.176.66.79])
        by mx.google.com with ESMTP id b4si20381429iog.199.2017.04.04.23.15.50
        for <linux-mm@kvack.org>;
        Tue, 04 Apr 2017 23:15:51 -0700 (PDT)
From: lixiubo@cmss.chinamobile.com
Subject: [PATCH v5 0/2] tcmu: Dynamic growing data area support
Date: Wed,  5 Apr 2017 14:06:55 +0800
Message-Id: <1491372417-5994-1-git-send-email-lixiubo@cmss.chinamobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nab@linux-iscsi.org
Cc: mchristi@redhat.com, agrover@redhat.com, iliastsi@arrikto.com, namei.unix@gmail.com, sheng@yasker.org, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Xiubo Li <lixiubo@cmss.chinamobile.com>

From: Xiubo Li <lixiubo@cmss.chinamobile.com>

Changed for V5:
- Rebase to the newest target-pending repository.
- Add as many comments as possbile to make the patch more readable.
- Move tcmu_handle_completions() in timeout handler to unmap thread
  and then replace the spin lock with mutex lock(because the unmap_*
  or zap_* may goto sleep) to simplify the patch and the code.
- Thanks very much for Mike's tips and suggestions.
- Tested this for more than 3 days by:
  * using fio and dd commands
  * using about 1~5 targets
  * set the global pool size to [512 1024 2048 512 * 1024] blocks * block_size
  * each target here needs more than 450 blocks when running in my environments.
  * fio: -iodepth [1 2 4 8 16] -thread -rw=[read write] -bs=[1K 2K 3K 5K 7K 16K 64K 1M] -size=20G -numjobs=10 -runtime=1000  ...
  * in the tcmu-runner, try to touch blocks out of tcmu_cmds' iov[] manually
  * restart the tcmu-runner at any time.
  * in my environment for the low IOPS case: the read throughput goes from about 5200KB/s to 6700KB/s; the write throughput goes from about 3000KB/s to 3700KB/s.

Changed for V4:
- re-order the #3, #4 at the head.
- merge most of the #5 to others.

Changed for V3:
- [PATCHv2 2/5] fix double usage of blocks and possible page fault
call trace.
- [PATCHv2 5/5] fix a mistake.

Changed for V2:
- [PATCHv2 1/5] just fixes some small spelling and other mistakes.
  And as the initial patch, here sets cmd area to 8M and data area to
  1G(1M fixed and 1023M growing)
- [PATCHv2 2/5] is a new one, adding global data block pool support.
  The max total size of the pool is 2G and all the targets will get
  growing blocks from here.
  Test this using multi-targets at the same time.
- [PATCHv2 3/5] changed nothing, respin it to avoid the conflict.
- [PATCHv2 4/5] and [PATCHv2 5/5] are new ones.

Xiubo Li (2):
  tcmu: Add dynamic growing data area feature support
  tcmu: Add global data block pool support

 drivers/target/target_core_user.c | 628 ++++++++++++++++++++++++++++++--------
 1 file changed, 499 insertions(+), 129 deletions(-)

-- 
1.8.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
