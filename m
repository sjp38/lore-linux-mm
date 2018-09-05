Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 38E3C6B7242
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 04:55:49 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h10-v6so2315289eda.9
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 01:55:49 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h25-v6si1447104edr.245.2018.09.05.01.55.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 01:55:47 -0700 (PDT)
Date: Wed, 5 Sep 2018 10:55:45 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: linux-next test error
Message-ID: <20180905085545.GD24902@quack2.suse.cz>
References: <0000000000004f6b5805751a8189@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000000000004f6b5805751a8189@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+87a05ae4accd500f5242@syzkaller.appspotmail.com>
Cc: ak@linux.intel.com, akpm@linux-foundation.org, jack@suse.cz, jrdr.linux@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mawilcox@microsoft.com, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com, tim.c.chen@linux.intel.com, zwisler@kernel.org

On Wed 05-09-18 00:13:02, syzbot wrote:
> Hello,
> 
> syzbot found the following crash on:
> 
> HEAD commit:    387ac6229ecf Add linux-next specific files for 20180905
> git tree:       linux-next
> console output: https://syzkaller.appspot.com/x/log.txt?x=149c67a6400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=ad5163873ecfbc32
> dashboard link: https://syzkaller.appspot.com/bug?extid=87a05ae4accd500f5242
> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> 
> Unfortunately, I don't have any reproducer for this crash yet.
> 
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+87a05ae4accd500f5242@syzkaller.appspotmail.com
> 
> INFO: task hung in do_page_mkwriteINFO: task syz-fuzzer:4876 blocked for
> more than 140 seconds.
>       Not tainted 4.19.0-rc2-next-20180905+ #56
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> syz-fuzzer      D21704  4876   4871 0x00000000
> Call Trace:
>  context_switch kernel/sched/core.c:2825 [inline]
>  __schedule+0x87c/0x1df0 kernel/sched/core.c:3473
>  schedule+0xfb/0x450 kernel/sched/core.c:3517
>  io_schedule+0x1c/0x70 kernel/sched/core.c:5140
>  wait_on_page_bit_common mm/filemap.c:1100 [inline]
>  __lock_page+0x5b7/0x7a0 mm/filemap.c:1273
>  lock_page include/linux/pagemap.h:483 [inline]
>  do_page_mkwrite+0x429/0x520 mm/memory.c:2391

Waiting for page lock after ->page_mkwrite callback. Which means
->page_mkwrite did not return VM_FAULT_LOCKED but 0. Looking into
linux-next... indeed "fs: convert return type int to vm_fault_t" has busted
block_page_mkwrite(). It has to return VM_FAULT_LOCKED and not 0 now.
Souptick, can I ask you to run 'fstests' for at least common filesystems
like ext4, xfs, btrfs when you change generic filesystem code please? That
would catch a bug like this immediately. Thanks.

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
