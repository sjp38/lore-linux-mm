Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id D6C806B0687
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 21:25:05 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id s22so291885pgv.8
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 18:25:05 -0800 (PST)
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id 31si5122290pgl.595.2018.11.08.18.25.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 18:25:04 -0800 (PST)
Message-ID: <5BE4EFFA.80608@huawei.com>
Date: Fri, 9 Nov 2018 10:24:58 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [Question] There is a thp count left when the process exits
References: <5BE44FDB.6040303@huawei.com>
In-Reply-To: <5BE44FDB.6040303@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Matthew Wilcox <willy@infradead.org>, Andrea
 Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

+LKML

I can not find the possibility when I check the code. because the mmap_sem and spin_lock will
protect the concurrence.

I will be appreciated if anyone has some clue.

Thanks,
zhong jiang


On 2018/11/8 23:01, zhong jiang wrote:
> Hi, 
>
> Recently,  I hit  the following issue in linux 3.10 stable.  and hard to recur.
>
> bad pmd ffff880c13ecea80(80000017b16000e7)
>
> Call Trace:
>   [<ffffffff8164195f>] dump_stack+0x19/0x1b
>   [<ffffffff8107b230>] warn_slowpath_common+0x70/0xb0
>   [<ffffffff8107b37a>] warn_slowpath_null+0x1a/0x20
>   [<ffffffff811a2b86>] exit_mmap+0x196/0x1a0
>   [<ffffffff810782e7>] mmput+0x67/0xf0
>   [<ffffffff81081b2c>] do_exit+0x28c/0xa60
>   [<ffffffff810a9dc0>] ? hrtimer_get_res+0x50/0x50
>   [<ffffffff8108237f>] do_group_exit+0x3f/0xa0
>   [<ffffffff81093240>] get_signal_to_deliver+0x1d0/0x6d0
>   [<ffffffff81014427>] do_signal+0x57/0x6b0
>   [<ffffffff810e4f92>] ? futex_wait_queue_me+0xa2/0x120
>   [<ffffffff8164d323>] ? __do_page_fault+0x183/0x470
>   [<ffffffff81014adf>] do_notify_resume+0x5f/0xb0
>   [<ffffffff816520bd>] int_signal+0x12/0x17
>
> BUG: Bad rss-counter state mm:ffff8820136b5dc0 idx:1 val:512
>
> The pmd entry show that it is still a thp. but It fails to check and clear the pmd.
> hence,   page fault will produce a new page for pmd when accessing the page,
> which thp count will reduplicative increase.
>
> Thanks,
> zhong jiang
