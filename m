Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6F7706B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 03:19:29 -0400 (EDT)
Received: by obbsn1 with SMTP id sn1so5249277obb.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 00:19:29 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id m2si3283307obx.5.2015.06.10.00.19.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 00:19:28 -0700 (PDT)
Message-ID: <5577E483.7060500@huawei.com>
Date: Wed, 10 Jun 2015 15:17:23 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC] panic when reboot the system
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>, Xishi Qiu <qiuxishi@huawei.com>, Andrew
 Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Rafael Aquini <aquini@redhat.com>, Tejun Heo <tj@kernel.org>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000007

Pid: 1, comm: init Tainted: G  R        O 3.4.24.19-0.11-default #1
Call Trace:
 [<ffffffff8144dd24>] panic+0xc1/0x1e2
 [<ffffffff8104483b>] do_exit+0x7db/0x8d0
 [<ffffffff81044c7a>] do_group_exit+0x3a/0xa0
 [<ffffffff8105394b>] get_signal_to_deliver+0x1ab/0x5e0
 [<ffffffff81002270>] do_signal+0x60/0x5f0
 [<ffffffff8145bf97>] ? do_page_fault+0x4a7/0x4d0
 [<ffffffff81170d2c>] ? poll_select_copy_remaining+0xec/0x140
 [<ffffffff81002885>] do_notify_resume+0x65/0x80
 [<ffffffff8124ca7e>] ? trace_hardirqs_on_thunk+0x3a/0x3c
 [<ffffffff814587ab>] retint_signal+0x4d/0x92


The system has a little memory left, then reboot it, and get the panic.
Perhaps this is a bug and trigger it like this and the latest kernel maybe
also have the problem.

use a lot of memory
  wake up kswapd()
    reclaim some pages from init thread (pid=1)
      reboot
        shutdown the disk
          init thread read data from disk
            page fault, because the page has already reclaimed
              receive SIGBUS, and init thread exit
                trigger the panic


Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
