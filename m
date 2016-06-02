Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 836E76B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 14:59:03 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e3so31243745wme.3
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 11:59:03 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id g207si37433735wme.16.2016.06.02.11.59.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 11:59:02 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id n184so17632067wmn.1
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 11:59:02 -0700 (PDT)
Date: Thu, 2 Jun 2016 21:58:56 +0300
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: Re: [linux-next: Tree for Jun 1] __khugepaged_exit
 rwsem_down_write_failed lockup
Message-ID: <20160602185856.GA3854@debian>
References: <20160601131122.7dbb0a65@canb.auug.org.au>
 <20160602014835.GA635@swordfish>
 <0c47a3a0-5530-b257-1c1f-28ed44ba97e6@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0c47a3a0-5530-b257-1c1f-28ed44ba97e6@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vbabka@suse.cz, sergey.senozhatsky.work@gmail.com, akpm@linux-foundation.org
Cc: mhocko@kernel.org, kirill.shutemov@linux.intel.com, sfr@canb.auug.org.au, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, riel@redhat.com, aarcange@redhat.com

On Thu, Jun 02, 2016 at 03:24:05PM +0200, Vlastimil Babka wrote:
> [+CC's]
> 
> On 06/02/2016 03:48 AM, Sergey Senozhatsky wrote:
> >On (06/01/16 13:11), Stephen Rothwell wrote:
> >>Hi all,
> >>
> >>Changes since 20160531:
> >>
> >>My fixes tree contains:
> >>
> >>  of: silence warnings due to max() usage
> >>
> >>The arm tree gained a conflict against Linus' tree.
> >>
> >>Non-merge commits (relative to Linus' tree): 1100
> >> 936 files changed, 38159 insertions(+), 17475 deletions(-)
> >
> >Hello,
> >
> >the cc1 process ended up in DN state during kernel -j4 compilation.
> >
> >...
> >[ 2856.323052] INFO: task cc1:4582 blocked for more than 21 seconds.
> >[ 2856.323055]       Not tainted 4.7.0-rc1-next-20160601-dbg-00012-g52c180e-dirty #453
> >[ 2856.323056] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> >[ 2856.323059] cc1             D ffff880057e9fd78     0  4582   4575 0x00000000
> >[ 2856.323062]  ffff880057e9fd78 ffff880057e08000 ffff880057e9fd90 ffff880057ea0000
> >[ 2856.323065]  ffff88005dc3dc68 ffffffff00000001 ffff880057e09500 ffff88005dc3dc80
> >[ 2856.323067]  ffff880057e9fd90 ffffffff81441e33 ffff88005dc3dc68 ffff880057e9fe00
> >[ 2856.323068] Call Trace:
> >[ 2856.323074]  [<ffffffff81441e33>] schedule+0x83/0x98
> >[ 2856.323077]  [<ffffffff81443d9b>] rwsem_down_write_failed+0x18e/0x1d3
> >[ 2856.323080]  [<ffffffff810a87cf>] ? unlock_page+0x2b/0x2d
> >[ 2856.323083]  [<ffffffff811bdb77>] call_rwsem_down_write_failed+0x17/0x30
> >[ 2856.323084]  [<ffffffff811bdb77>] ? call_rwsem_down_write_failed+0x17/0x30
> >[ 2856.323086]  [<ffffffff81443630>] down_write+0x1f/0x2e
> >[ 2856.323089]  [<ffffffff810ea4f3>] __khugepaged_exit+0x104/0x11a
> >[ 2856.323091]  [<ffffffff8103702a>] mmput+0x29/0xc5
> >[ 2856.323093]  [<ffffffff8103bbd8>] do_exit+0x34c/0x894
> >[ 2856.323095]  [<ffffffff8102f9e0>] ? __do_page_fault+0x2f7/0x399
> >[ 2856.323097]  [<ffffffff8103c188>] do_group_exit+0x3c/0x98
> >[ 2856.323099]  [<ffffffff8103c1f3>] SyS_exit_group+0xf/0xf
> >[ 2856.323101]  [<ffffffff81444cdb>] entry_SYSCALL_64_fastpath+0x13/0x8f
> >
> >[ 2877.322853] INFO: task cc1:4582 blocked for more than 21 seconds.
> >[ 2877.322858]       Not tainted 4.7.0-rc1-next-20160601-dbg-00012-g52c180e-dirty #453
> >[ 2877.322858] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> >[ 2877.322861] cc1             D ffff880057e9fd78     0  4582   4575 0x00000000
> >[ 2877.322865]  ffff880057e9fd78 ffff880057e08000 ffff880057e9fd90 ffff880057ea0000
> >[ 2877.322867]  ffff88005dc3dc68 ffffffff00000001 ffff880057e09500 ffff88005dc3dc80
> >[ 2877.322867]  ffff880057e9fd90 ffffffff81441e33 ffff88005dc3dc68 ffff880057e9fe00
> >[ 2877.322870] Call Trace:
> >[ 2877.322875]  [<ffffffff81441e33>] schedule+0x83/0x98
> >[ 2877.322878]  [<ffffffff81443d9b>] rwsem_down_write_failed+0x18e/0x1d3
> >[ 2877.322881]  [<ffffffff810a87cf>] ? unlock_page+0x2b/0x2d
> >[ 2877.322884]  [<ffffffff811bdb77>] call_rwsem_down_write_failed+0x17/0x30
> >[ 2877.322885]  [<ffffffff811bdb77>] ? call_rwsem_down_write_failed+0x17/0x30
> >[ 2877.322887]  [<ffffffff81443630>] down_write+0x1f/0x2e
> >[ 2877.322890]  [<ffffffff810ea4f3>] __khugepaged_exit+0x104/0x11a
> >[ 2877.322892]  [<ffffffff8103702a>] mmput+0x29/0xc5
> >[ 2877.322894]  [<ffffffff8103bbd8>] do_exit+0x34c/0x894
> >[ 2877.322896]  [<ffffffff8102f9e0>] ? __do_page_fault+0x2f7/0x399
> >[ 2877.322898]  [<ffffffff8103c188>] do_group_exit+0x3c/0x98
> >[ 2877.322900]  [<ffffffff8103c1f3>] SyS_exit_group+0xf/0xf
> >[ 2877.322902]  [<ffffffff81444cdb>] entry_SYSCALL_64_fastpath+0x13/0x8f
> 
> I think it's this patch:
> 
> http://ozlabs.org/~akpm/mmots/broken-out/mm-thp-make-swapin-readahead-under-down_read-of-mmap_sem.patch
> 
> Some parts of the code in collapse_huge_page() that were under
> down_write(mmap_sem) are under down_read() after the patch. But
> there's "goto out" which continues via "goto out_up_write" which
> does up_write(mmap_sem) so there's an imbalance. One path seems to
> go via both up_read() and up_write(). I can imagine this can cause a
> stuck down_write() among other things?
Recently, I realized the same imbalance, it is an obvious
inconsistency. I don't know, this issue can be related with
mine. I'll send a fix patch.

Kind regards.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
