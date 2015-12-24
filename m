Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id E154382F99
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 04:48:02 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id l126so178973925wml.1
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 01:48:02 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id h70si7393916wmd.58.2015.12.24.01.48.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Dec 2015 01:48:01 -0800 (PST)
Received: by mail-wm0-f49.google.com with SMTP id l126so176517193wml.0
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 01:48:01 -0800 (PST)
Date: Thu, 24 Dec 2015 10:47:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
Message-ID: <20151224094758.GA22760@dhcp22.suse.cz>
References: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
 <CAOxpaSV38vy2ywCqQZggfydWsSfAOVo-q8cn7OcuN86ch=4mEA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOxpaSV38vy2ywCqQZggfydWsSfAOVo-q8cn7OcuN86ch=4mEA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <zwisler@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Wed 23-12-15 16:00:09, Ross Zwisler wrote:
[...]
> While running xfstests on next-20151223 I hit a pair of kernel BUGs
> that bisected to this commit:
> 
> 1eb3a80d8239 ("mm, oom: introduce oom reaper")

Thank you for the report and the bisection.

> Here is a BUG produced by generic/029 when run against XFS:
> 
> [  235.751723] ------------[ cut here ]------------
> [  235.752194] kernel BUG at mm/filemap.c:208!

This is VM_BUG_ON_PAGE(page_mapped(page), page), right? Could you attach
the full kernel log? It all smells like a race when OOM reaper tears
down the mapping and there is a truncate still in progress. But hitting
the BUG_ON just because of that doesn't make much sense to me. OOM
reaper is essentially MADV_DONTNEED. I have to think about this some
more, though, but I am in a holiday mode until early next year so please
bear with me.

[...]
> [  235.765638] Call Trace:
> [  235.765903]  [<ffffffff811c8493>] delete_from_page_cache+0x63/0xd0
> [  235.766513]  [<ffffffff811dc3e5>] truncate_inode_page+0xa5/0x120
> [  235.767088]  [<ffffffff811dc648>] truncate_inode_pages_range+0x1a8/0x7f0
> [  235.767725]  [<ffffffff81021459>] ? sched_clock+0x9/0x10
> [  235.768239]  [<ffffffff810db37c>] ? local_clock+0x1c/0x20
> [  235.768779]  [<ffffffff811feba4>] ? unmap_mapping_range+0x64/0x130
> [  235.769385]  [<ffffffff811febb4>] ? unmap_mapping_range+0x74/0x130
> [  235.770010]  [<ffffffff810f5c3f>] ? up_write+0x1f/0x40
> [  235.770501]  [<ffffffff811febb4>] ? unmap_mapping_range+0x74/0x130
> [  235.771092]  [<ffffffff811dcd58>] truncate_pagecache+0x48/0x70
> [  235.771646]  [<ffffffff811dcdb2>] truncate_setsize+0x32/0x40
> [  235.772276]  [<ffffffff8148e972>] xfs_setattr_size+0x232/0x470
> [  235.772839]  [<ffffffff8148ec64>] xfs_vn_setattr+0xb4/0xc0
> [  235.773369]  [<ffffffff8127af87>] notify_change+0x237/0x350
> [  235.773945]  [<ffffffff81257c87>] do_truncate+0x77/0xc0
> [  235.774446]  [<ffffffff8125800f>] do_sys_ftruncate.constprop.15+0xef/0x150
> [  235.775156]  [<ffffffff812580ae>] SyS_ftruncate+0xe/0x10
> [  235.775650]  [<ffffffff81a527b2>] entry_SYSCALL_64_fastpath+0x12/0x76
> [  235.776257] Code: 5f 5d c3 48 8b 43 20 48 8d 78 ff a8 01 48 0f 44
> fb 8b 47 48 85 c0 0f 88 2b 01 00 00 48 c7 c6 a8 57 f0 81 48 89 df e8
> fa 1a 03 00 <0f> 0b 4c 89 ce 44 89 fa 4c 89 e7 4c 89 45 b0 4c 89 4d b8
> e8 32
> [  235.778695] RIP  [<ffffffff811c81f6>] __delete_from_page_cache+0x206/0x440
> [  235.779350]  RSP <ffff8800bab83b60>
> [  235.779694] ---[ end trace fac9dd65c4cdd828 ]---
> 
> And a different BUG produced by generic/095, also with XFS:
> 
> [  609.398897] ------------[ cut here ]------------
> [  609.399843] kernel BUG at mm/truncate.c:629!

Hmm, I do not see any BUG_ON at this line. But there is
BUG_ON(page_mapped(page)) at line 620.

> [  609.400666] invalid opcode: 0000 [#1] SMP
> [  609.401512] Modules linked in: nd_pmem nd_btt nd_e820 libnvdimm
> [  609.402719] CPU: 4 PID: 26782 Comm: fio Tainted: G        W

There was a warning before this triggered. The full kernel log would be
helpful as well.

[...]
> [  609.425325] Call Trace:
> [  609.425797]  [<ffffffff811dc307>] invalidate_inode_pages2+0x17/0x20
> [  609.426971]  [<ffffffff81482167>] xfs_file_read_iter+0x297/0x300
> [  609.428097]  [<ffffffff81259ac9>] __vfs_read+0xc9/0x100
> [  609.429073]  [<ffffffff8125a319>] vfs_read+0x89/0x130
> [  609.430010]  [<ffffffff8125b418>] SyS_read+0x58/0xd0
> [  609.430943]  [<ffffffff81a527b2>] entry_SYSCALL_64_fastpath+0x12/0x76
> [  609.432139] Code: 85 d8 fe ff ff 01 00 00 00 f6 c4 40 0f 84 59 ff
> ff ff 49 8b 47 20 48 8d 78 ff a8 01 49 0f 44 ff 8b 47 48 85 c0 0f 88
> bd 01 00 00 <0f> 0b 4d 3b 67 08 0f 85 70 ff ff ff 49 f7 07 00 18 00 00
> 74 15
[...]
> My test setup is a qemu guest machine with a pair of 4 GiB PMEM
> ramdisk test devices, one for the xfstest test disk and one for the
> scratch disk.

Is this just a plain ramdisk device or it needs a special configuration?
Is this somehow DAX related?

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
