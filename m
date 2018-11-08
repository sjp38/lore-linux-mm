Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4D3E16B0615
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 10:02:04 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id w96so12795460ota.10
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 07:02:04 -0800 (PST)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id o81-v6si1671265oif.252.2018.11.08.07.02.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 07:02:02 -0800 (PST)
Message-ID: <5BE44FDB.6040303@huawei.com>
Date: Thu, 8 Nov 2018 23:01:47 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: [Question] There is a thp count left when the process exits
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Matthew Wilcox <willy@infradead.org>, Andrea
 Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>

Hi, 

Recently,  I hit  the following issue in linux 3.10 stable.  and hard to recur.

bad pmd ffff880c13ecea80(80000017b16000e7)

Call Trace:
  [<ffffffff8164195f>] dump_stack+0x19/0x1b
  [<ffffffff8107b230>] warn_slowpath_common+0x70/0xb0
  [<ffffffff8107b37a>] warn_slowpath_null+0x1a/0x20
  [<ffffffff811a2b86>] exit_mmap+0x196/0x1a0
  [<ffffffff810782e7>] mmput+0x67/0xf0
  [<ffffffff81081b2c>] do_exit+0x28c/0xa60
  [<ffffffff810a9dc0>] ? hrtimer_get_res+0x50/0x50
  [<ffffffff8108237f>] do_group_exit+0x3f/0xa0
  [<ffffffff81093240>] get_signal_to_deliver+0x1d0/0x6d0
  [<ffffffff81014427>] do_signal+0x57/0x6b0
  [<ffffffff810e4f92>] ? futex_wait_queue_me+0xa2/0x120
  [<ffffffff8164d323>] ? __do_page_fault+0x183/0x470
  [<ffffffff81014adf>] do_notify_resume+0x5f/0xb0
  [<ffffffff816520bd>] int_signal+0x12/0x17

BUG: Bad rss-counter state mm:ffff8820136b5dc0 idx:1 val:512

The pmd entry show that it is still a thp. but It fails to check and clear the pmd.
hence,   page fault will produce a new page for pmd when accessing the page,
which thp count will reduplicative increase.

Thanks,
zhong jiang
