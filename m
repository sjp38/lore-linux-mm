Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0507A6B0005
	for <linux-mm@kvack.org>; Sun, 26 Jun 2016 05:00:36 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id he1so282515376pac.0
        for <linux-mm@kvack.org>; Sun, 26 Jun 2016 02:00:35 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e127si11460348pfa.238.2016.06.26.02.00.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 26 Jun 2016 02:00:34 -0700 (PDT)
Subject: Re: 4.6.2 frequent crashes under memory + IO pressure
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160623091830.GA32535@sig21.net>
	<201606232026.GFJ26539.QVtFFOJOOLHFMS@I-love.SAKURA.ne.jp>
	<20160625155006.GA4166@sig21.net>
	<201606260204.BDB48978.FSFFJQHOMLVOtO@I-love.SAKURA.ne.jp>
	<20160625172951.GA5586@sig21.net>
In-Reply-To: <20160625172951.GA5586@sig21.net>
Message-Id: <201606261800.FGF57303.OFtMFSQHJFLOVO@I-love.SAKURA.ne.jp>
Date: Sun, 26 Jun 2016 18:00:28 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js@sig21.net
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@kernel.org

Johannes Stezenbach wrote:
> On Sun, Jun 26, 2016 at 02:04:40AM +0900, Tetsuo Handa wrote:
> > It seems to me that somebody is using ALLOC_NO_WATERMARKS (with possibly
> > __GFP_NOWARN), but I don't know how to identify such callers. Maybe print
> > backtrace from __alloc_pages_slowpath() when ALLOC_NO_WATERMARKS is used?
> 
> Wouldn't this create too much output for slow serial console?
> Or is this case supposed to be triggered rarely?
> 
> This crash testing is pretty painful but I can try it tomorrow
> if there is no better idea.
> 
> Johannes
> 

If you can use latest SystemTap from git repository, I think you can get traces
with "uniq" using below script.

# ~/systemtap.tmp/bin/stap --version
Systemtap translator/driver (version 3.1/0.163, commit release-3.0-133-g42b97387ed3f)
Copyright (C) 2005-2016 Red Hat, Inc. and others
This is free software; see the source for copying conditions.
tested kernel versions: 2.6.18 ... 4.6-rc
enabled features: JAVA NLS

# ~/systemtap.tmp/bin/stap -e 'global traces_bt[65536];
probe begin { printf("Probe start!\n"); }
function dump_if_new(mask:long) {
  bt = backtrace();
  if (traces_bt[bt]++ == 0) {
    printf("%s(%u) 0x%lx\n", execname(), pid(), mask);
    print_backtrace();
    printf("\n");
  }
}
probe kernel.function("get_page_from_freelist") { if ($alloc_flags & 0x4) dump_if_new($gfp_mask); }
probe kernel.function("gfp_pfmemalloc_allowed").return { if ($return != 0) dump_if_new($gfp_mask); }
probe end { delete traces_bt; }'

----------
Probe start!
oom-torture(15957) 0x342004a
 0xffffffff81188e40 : get_page_from_freelist+0x0/0xcf0 [kernel]
 0xffffffff8118a146 : __alloc_pages_nodemask+0x616/0xcd0 [kernel]
 0xffffffff811dfc22 : alloc_pages_current+0x92/0x190 [kernel]
 0xffffffff8117cf56 : __page_cache_alloc+0x146/0x180 [kernel]
 0xffffffff8117e961 : pagecache_get_page+0x51/0x280 [kernel]
 0xffffffff8117ef14 : grab_cache_page_write_begin+0x24/0x40 [kernel]
 0xffffffff812fadbf : xfs_vm_write_begin+0x2f/0x100 [kernel]
 0xffffffff8117cd1d : generic_perform_write+0xcd/0x1c0 [kernel]
 0xffffffff8130ffdd : xfs_file_buffered_aio_write+0x15d/0x3d0 [kernel]
 0xffffffff813102d6 : xfs_file_write_iter+0x86/0x140 [kernel]
 0xffffffff812168a7 : __vfs_write+0xc7/0x100 [kernel]
 0xffffffff8121773d : vfs_write+0x9d/0x190 [kernel]
 0xffffffff81218b63 : sys_write+0x53/0xc0 [kernel]
 0xffffffff81002dbc : do_syscall_64+0x5c/0x170 [kernel]
 0xffffffff81724ada : return_from_SYSCALL_64+0x0/0x7a [kernel]

oom-torture(15957) 0x2000200
 0xffffffff81188e40 : get_page_from_freelist+0x0/0xcf0 [kernel]
 0xffffffff8118a146 : __alloc_pages_nodemask+0x616/0xcd0 [kernel]
 0xffffffff811dfc22 : alloc_pages_current+0x92/0x190 [kernel]
 0xffffffff811841ff : __get_free_pages+0xf/0x40 [kernel]
 0xffffffff811b8622 : __tlb_remove_page+0x62/0xa0 [kernel]
 0xffffffff811b9c82 : unmap_page_range+0x692/0x8f0 [kernel]
 0xffffffff811b9f34 : unmap_single_vma+0x54/0xd0 [kernel]
 0xffffffff811ba25c : unmap_vmas+0x3c/0x50 [kernel]
 0xffffffff811c2ad6 : exit_mmap+0xc6/0x140 [kernel]
 0xffffffff81068a6d : mmput+0x4d/0xe0 [kernel]
 0xffffffff81070f60 : do_exit+0x280/0xd20 [kernel]
 0xffffffff81071a87 : do_group_exit+0x47/0xc0 [kernel]
 0xffffffff8107ffbb : get_signal+0x33b/0x9b0 [kernel]
 0xffffffff8101d312 : do_signal+0x32/0x6c0 [kernel]
 0xffffffff81065fc6 : exit_to_usermode_loop+0x46/0x84 [kernel]
 0xffffffff81002e6d : do_syscall_64+0x10d/0x170 [kernel]
 0xffffffff81724ada : return_from_SYSCALL_64+0x0/0x7a [kernel]

----------

# addr2line -i -e /usr/src/linux-4.6.2/vmlinux 0xffffffff811b9c82
/usr/src/linux-4.6.2/mm/memory.c:1162
/usr/src/linux-4.6.2/mm/memory.c:1241
/usr/src/linux-4.6.2/mm/memory.c:1262
/usr/src/linux-4.6.2/mm/memory.c:1283

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
