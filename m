Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 880CC6B0032
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 03:42:17 -0400 (EDT)
Date: Tue, 18 Jun 2013 09:42:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130618074215.GA13677@dhcp22.suse.cz>
References: <20130617141822.GF5018@dhcp22.suse.cz>
 <20130617151403.GA25172@localhost.localdomain>
 <20130617153302.GI5018@dhcp22.suse.cz>
 <20130617165409.GA10764@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130617165409.GA10764@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 17-06-13 20:54:10, Glauber Costa wrote:
> On Mon, Jun 17, 2013 at 05:33:02PM +0200, Michal Hocko wrote:
[...]
> > I have seen some other traces as well (mentioning ext3 dput paths) but I
> > cannot reproduce them anymore.
> > 
> 
> Do you have those traces? If there is a bug in the ext3 dput, then it is
> most likely the culprit. dput() is when we insert things into the LRU. So
> if we are not fully inserting an element that we should have - and later
> on try to remove it, we'll go negative.
> 
> Can we see those traces?

Unfortunatelly I don't because the machine where I saw those didn't have
a serial console and the traces where scrolling like crazy. Anyway I am
working on reproducing this. Linux next is hard to debug due to
unrelated crashes so I am still with my -mm git tree.

Anyway, I was able to reproduce one of those hangs which smells like the
same/similar issue:
 4659 pts/0    S+     0:00                 /bin/sh ./run_batch.sh mmotm
 4661 pts/0    S+     0:00                   /bin/bash ./start.sh
 4666 pts/0    S+     5:08                     /bin/bash ./start.sh
18294 pts/0    S+     0:00                       sleep 1s
 4682 pts/0    S+     0:00                     /bin/bash ./run_test.sh /dev/cgroup B 2
 4683 pts/0    S+     5:16                       /bin/bash ./run_test.sh /dev/cgroup B 2
18293 pts/0    S+     0:00                         sleep 1s
 8509 pts/0    S+     0:00                       /usr/bin/time -v make -j4 vmlinux
 8510 pts/0    S+     0:00                         make -j4 vmlinux
11730 pts/0    S+     0:00                           make -f scripts/Makefile.build obj=drivers
13135 pts/0    S+     0:00                             make -f scripts/Makefile.build obj=drivers/net
13415 pts/0    S+     0:00                               make -f scripts/Makefile.build obj=drivers/net/wireless
13657 pts/0    S+     0:00                                 make -f scripts/Makefile.build obj=drivers/net/wireless/rtl818x
13665 pts/0    D+     0:00                                   make -f scripts/Makefile.build obj=drivers/net/wireless/rtl818x/rtl8180
13737 pts/0    S+     0:00                                 make -f scripts/Makefile.build obj=drivers/net/wireless/rtlwifi
13754 pts/0    D+     0:00                                   make -f scripts/Makefile.build obj=drivers/net/wireless/rtlwifi/rtl8192de
13917 pts/0    D+     0:00                                   make -f scripts/Makefile.build obj=drivers/net/wireless/rtlwifi/rtl8192se

demon:/home/mhocko # cat /proc/13917/stack 
[<ffffffff81179862>] path_lookupat+0x792/0x830
[<ffffffff81179933>] filename_lookup+0x33/0xd0
[<ffffffff8117ab0b>] user_path_at_empty+0x7b/0xb0
[<ffffffff8117ab4c>] user_path_at+0xc/0x10
[<ffffffff8116ff91>] vfs_fstatat+0x51/0xb0
[<ffffffff81170116>] vfs_stat+0x16/0x20
[<ffffffff8117013f>] sys_newstat+0x1f/0x50
[<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff

demon:/home/mhocko # cat /proc/13754/stack 
[<ffffffff8118325e>] __wait_on_freeing_inode+0x9e/0xc0
[<ffffffff81183321>] find_inode_fast+0xa1/0xc0
[<ffffffff8118526f>] iget_locked+0x4f/0x180
[<ffffffff811ef9f3>] ext4_iget+0x33/0x9f0
[<ffffffff811f6a2c>] ext4_lookup+0xbc/0x160
[<ffffffff81174ad0>] lookup_real+0x20/0x60
[<ffffffff81175254>] __lookup_hash+0x34/0x40
[<ffffffff81179872>] path_lookupat+0x7a2/0x830
[<ffffffff81179933>] filename_lookup+0x33/0xd0
[<ffffffff8117ab0b>] user_path_at_empty+0x7b/0xb0
[<ffffffff8117ab4c>] user_path_at+0xc/0x10
[<ffffffff8116ff91>] vfs_fstatat+0x51/0xb0
[<ffffffff81170116>] vfs_stat+0x16/0x20
[<ffffffff8117013f>] sys_newstat+0x1f/0x50
[<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff

demon:/home/mhocko # cat /proc/13665/stack 
[<ffffffff8118325e>] __wait_on_freeing_inode+0x9e/0xc0
[<ffffffff81183321>] find_inode_fast+0xa1/0xc0
[<ffffffff8118526f>] iget_locked+0x4f/0x180
[<ffffffff811ef9f3>] ext4_iget+0x33/0x9f0
[<ffffffff811f6a2c>] ext4_lookup+0xbc/0x160
[<ffffffff81174ad0>] lookup_real+0x20/0x60
[<ffffffff81177e25>] lookup_open+0x175/0x1d0
[<ffffffff8117815e>] do_last+0x2de/0x780
[<ffffffff8117ae9a>] path_openat+0xda/0x400
[<ffffffff8117b303>] do_filp_open+0x43/0xa0
[<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
[<ffffffff81168f9c>] sys_open+0x1c/0x20
[<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff

Sysrq+l doesn't show only idle CPUs. Ext4 is showing in the traces
because of CONFIG_EXT4_USE_FOR_EXT23=y.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
