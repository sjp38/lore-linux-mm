Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 30A776B0038
	for <linux-mm@kvack.org>; Mon, 15 May 2017 04:36:35 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id p134so20908081wmg.3
        for <linux-mm@kvack.org>; Mon, 15 May 2017 01:36:35 -0700 (PDT)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id n126si10006940wma.15.2017.05.15.01.36.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 01:36:33 -0700 (PDT)
Received: by mail-wr0-x244.google.com with SMTP id v42so14102038wrc.3
        for <linux-mm@kvack.org>; Mon, 15 May 2017 01:36:33 -0700 (PDT)
Date: Mon, 15 May 2017 11:36:31 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/1] ksm: prevent crash after write_protect_page fails
Message-ID: <20170515083631.pm4llmnrk6frsesr@node.shutemov.name>
References: <20170513131040.21732-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170513131040.21732-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Federico Simoncelli <fsimonce@redhat.com>

On Sat, May 13, 2017 at 03:10:40PM +0200, Andrea Arcangeli wrote:
> "err" needs to be left set to -EFAULT if split_huge_page
> succeeds. Otherwise if "err" gets clobbered with zero and
> write_protect_page fails, try_to_merge_one_page() will succeed instead
> of returning -EFAULT and then try_to_merge_with_ksm_page() will
> continue thinking kpage is a PageKsm when in fact it's still an
> anonymous page. Eventually it'll crash in page_add_anon_rmap.
> 
> This has been reproduced on Fedora25 kernel but I can reproduce with
> upstream too.
> 
> The bug was introduced in commit
> f765f540598a129dc4bb6f698fd4acc92f296c14 in v4.5.
> 
> page:fffff67546ce1cc0 count:4 mapcount:2 mapping:ffffa094551e36e1 index:0x7f0f46673
> flags: 0x2ffffc0004007c(referenced|uptodate|dirty|lru|active|swapbacked)
> page dumped because: VM_BUG_ON_PAGE(!PageLocked(page))
> page->mem_cgroup:ffffa09674bf0000
> ------------[ cut here ]------------
> kernel BUG at mm/rmap.c:1222!
> invalid opcode: 0000 [#1] SMP
> CPU: 1 PID: 76 Comm: ksmd Not tainted 4.9.3-200.fc25.x86_64 #1
> task: ffffa0968be65b80 task.stack: ffffc0e941b3c000
> RIP: 0010:[<ffffffff9a20ac94>]  [<ffffffff9a20ac94>] do_page_add_anon_rmap+0x1c4/0x240
> RSP: 0018:ffffc0e941b3fd48  EFLAGS: 00010282
> RAX: 0000000000000021 RBX: fffff67546ce1cc0 RCX: 0000000000000006
> RDX: 0000000000000000 RSI: 0000000000000246 RDI: ffffa0969ec4e0a0
> RBP: ffffc0e941b3fd70 R08: 0000000000018a84 R09: 0000000000000005
> R10: fffff6754f87de00 R11: 000000000000049f R12: 00007fe6f5f67000
> R13: ffffa094990ecc00 R14: 0000000000000000 R15: ffffa093c369c480
> FS:  0000000000000000(0000) GS:ffffa0969ec40000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00007f4c21c221f0 CR3: 0000000152e07000 CR4: 00000000000426e0
> Stack:
>  fffff675470fd9c0 00007fe6f5f67000 fffff67540f8a900 ffffa094990ecc00
>  ffffa093c369c480 ffffc0e941b3fd80 ffffffff9a20ad28 ffffc0e941b3fe00
>  ffffffff9a228b4b 80000001c3f67807 0000000000000000 80000001c3f67805
> Call Trace:
>  [<ffffffff9a20ad28>] page_add_anon_rmap+0x18/0x20
>  [<ffffffff9a228b4b>] try_to_merge_with_ksm_page+0x50b/0x780
>  [<ffffffff9a229fd1>] ksm_scan_thread+0x1211/0x1410
>  [<ffffffff9a0e7270>] ? prepare_to_wait_event+0x100/0x100
>  [<ffffffff9a228dc0>] ? try_to_merge_with_ksm_page+0x780/0x780
>  [<ffffffff9a0c2569>] kthread+0xd9/0xf0
>  [<ffffffff9a0c2490>] ? kthread_park+0x60/0x60
>  [<ffffffff9a81be55>] ret_from_fork+0x25/0x30
> 
> Reported-by: Federico Simoncelli <fsimonce@redhat.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
