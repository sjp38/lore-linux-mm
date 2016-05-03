Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id B1F996B0005
	for <linux-mm@kvack.org>; Tue,  3 May 2016 13:03:01 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id x67so46179282oix.2
        for <linux-mm@kvack.org>; Tue, 03 May 2016 10:03:01 -0700 (PDT)
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com. [32.97.110.159])
        by mx.google.com with ESMTPS id p128si182634iop.87.2016.05.03.10.03.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 03 May 2016 10:03:00 -0700 (PDT)
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Tue, 3 May 2016 11:02:58 -0600
Date: Tue, 3 May 2016 12:02:47 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: kcompactd hang during memory offlining
Message-ID: <20160503170247.GA4239@arbab-laptop.austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Arnd Bergmann <arnd@arndb.de>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Assume memory47 is the last online block left in node1. This will hang:

# echo offline > /sys/devices/system/node/node1/memory47/state

After a couple of minutes, the following pops up in dmesg:

INFO: task bash:957 blocked for more than 120 seconds.
       Not tainted 4.6.0-rc6+ #6
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
bash            D ffff8800b7adbaf8     0   957    951 0x00000000
  ffff8800b7adbaf8 ffff880034d5b880 ffff8800b698d4c0 ffff8800b7adc000
  7fffffffffffffff ffff88003381ff10 ffff8800b698d4c0 0000000000180000
  ffff8800b7adbb10 ffffffff817be0b5 ffff88003381ff08 ffff8800b7adbbc0
Call Trace:
  [<ffffffff817be0b5>] schedule+0x35/0x80
  [<ffffffff817c100c>] schedule_timeout+0x1ac/0x270
  [<ffffffff810d9750>] ? check_preempt_wakeup+0x100/0x220
  [<ffffffff810ce0a0>] ? check_preempt_curr+0x80/0x90
  [<ffffffff817bf501>] wait_for_completion+0xe1/0x120
  [<ffffffff810cefc0>] ? wake_up_q+0x70/0x70
  [<ffffffff810c42ff>] kthread_stop+0x4f/0x110
  [<ffffffff811e1046>] kcompactd_stop+0x26/0x40
  [<ffffffff817b7a16>] __offline_pages.constprop.28+0x7e6/0x840
  [<ffffffff8121ee61>] offline_pages+0x11/0x20
  [<ffffffff8151a073>] memory_block_action+0x73/0x1d0
  [<ffffffff8151a217>] memory_subsys_offline+0x47/0x60
  [<ffffffff81502dc6>] device_offline+0x86/0xb0
  [<ffffffff8151a8fa>] store_mem_state+0xda/0xf0
  [<ffffffff814ffea8>] dev_attr_store+0x18/0x30
  [<ffffffff812c1097>] sysfs_kf_write+0x37/0x40
  [<ffffffff812c062d>] kernfs_fop_write+0x11d/0x170
  [<ffffffff8123e797>] __vfs_write+0x37/0x120
  [<ffffffff8134d1ad>] ? security_file_permission+0x3d/0xc0
  [<ffffffff810eed32>] ? percpu_down_read+0x12/0x50
  [<ffffffff8123f969>] vfs_write+0xa9/0x1a0
  [<ffffffff8134d543>] ? security_file_fcntl+0x43/0x60
  [<ffffffff81240dc5>] SyS_write+0x55/0xc0
  [<ffffffff817c21b2>] entry_SYSCALL_64_fastpath+0x1a/0xa4

Bisect ends on commit 698b1b306 ("mm, compaction: introduce kcompactd").

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
