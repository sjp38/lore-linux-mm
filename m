Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 466416B0033
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 09:50:29 -0400 (EDT)
Date: Tue, 18 Jun 2013 15:50:25 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130618135025.GK13677@dhcp22.suse.cz>
References: <20130617141822.GF5018@dhcp22.suse.cz>
 <20130617151403.GA25172@localhost.localdomain>
 <20130617143508.7417f1ac9ecd15d8b2877f76@linux-foundation.org>
 <20130617223004.GB2538@localhost.localdomain>
 <20130618024623.GP29338@dastard>
 <20130618063104.GB20528@localhost.localdomain>
 <20130618082414.GC13677@dhcp22.suse.cz>
 <20130618104443.GH13677@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130618104443.GH13677@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

And again, another hang. It looks like the inode deletion never
finishes. The good thing is that I do not see any LRU related BUG_ONs
anymore. I am going to test with the other patch in the thread.

2476 [<ffffffff8118325e>] __wait_on_freeing_inode+0x9e/0xc0	<<< waiting for an inode to go away
[<ffffffff81183321>] find_inode_fast+0xa1/0xc0
[<ffffffff8118525f>] iget_locked+0x4f/0x180
[<ffffffff811ef9e3>] ext4_iget+0x33/0x9f0
[<ffffffff811f6a1c>] ext4_lookup+0xbc/0x160
[<ffffffff81174ad0>] lookup_real+0x20/0x60
[<ffffffff81177e25>] lookup_open+0x175/0x1d0
[<ffffffff8117815e>] do_last+0x2de/0x780			<<< holds i_mutex
[<ffffffff8117ae9a>] path_openat+0xda/0x400
[<ffffffff8117b303>] do_filp_open+0x43/0xa0
[<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
[<ffffffff81168f9c>] sys_open+0x1c/0x20
[<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
11214 [<ffffffff81178144>] do_last+0x2c4/0x780			<<< blocked on i_mutex
[<ffffffff8117ae9a>] path_openat+0xda/0x400
[<ffffffff8117b303>] do_filp_open+0x43/0xa0
[<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
[<ffffffff81168f9c>] sys_open+0x1c/0x20
[<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
11217 [<ffffffff81178144>] do_last+0x2c4/0x780			<<< blocked on i_mutex
[<ffffffff8117ae9a>] path_openat+0xda/0x400
[<ffffffff8117b303>] do_filp_open+0x43/0xa0
[<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
[<ffffffff81168f9c>] sys_open+0x1c/0x20
[<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
11288 [<ffffffff81178144>] do_last+0x2c4/0x780			<<< blocked on i_mutex
[<ffffffff8117ae9a>] path_openat+0xda/0x400
[<ffffffff8117b303>] do_filp_open+0x43/0xa0
[<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
[<ffffffff81168f9c>] sys_open+0x1c/0x20
[<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
11453 [<ffffffff8118325e>] __wait_on_freeing_inode+0x9e/0xc0
[<ffffffff81183321>] find_inode_fast+0xa1/0xc0
[<ffffffff8118525f>] iget_locked+0x4f/0x180
[<ffffffff811ef9e3>] ext4_iget+0x33/0x9f0
[<ffffffff811f6a1c>] ext4_lookup+0xbc/0x160
[<ffffffff81174ad0>] lookup_real+0x20/0x60
[<ffffffff81177e25>] lookup_open+0x175/0x1d0
[<ffffffff8117815e>] do_last+0x2de/0x780
[<ffffffff8117ae9a>] path_openat+0xda/0x400
[<ffffffff8117b303>] do_filp_open+0x43/0xa0
[<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
[<ffffffff81168f9c>] sys_open+0x1c/0x20
[<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
12439 [<ffffffff8118325e>] __wait_on_freeing_inode+0x9e/0xc0
[<ffffffff81183321>] find_inode_fast+0xa1/0xc0
[<ffffffff8118525f>] iget_locked+0x4f/0x180
[<ffffffff811ef9e3>] ext4_iget+0x33/0x9f0
[<ffffffff811f6a1c>] ext4_lookup+0xbc/0x160
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
12542 [<ffffffff81179862>] path_lookupat+0x792/0x830
[<ffffffff81179933>] filename_lookup+0x33/0xd0
[<ffffffff8117ab0b>] user_path_at_empty+0x7b/0xb0
[<ffffffff8117ab4c>] user_path_at+0xc/0x10
[<ffffffff8116ff91>] vfs_fstatat+0x51/0xb0
[<ffffffff81170116>] vfs_stat+0x16/0x20
[<ffffffff8117013f>] sys_newstat+0x1f/0x50
[<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
12588 [<ffffffff81179862>] path_lookupat+0x792/0x830
[<ffffffff81179933>] filename_lookup+0x33/0xd0
[<ffffffff8117ab0b>] user_path_at_empty+0x7b/0xb0
[<ffffffff8117ab4c>] user_path_at+0xc/0x10
[<ffffffff8116ff91>] vfs_fstatat+0x51/0xb0
[<ffffffff81170116>] vfs_stat+0x16/0x20
[<ffffffff8117013f>] sys_newstat+0x1f/0x50
[<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
12589 [<ffffffff81179862>] path_lookupat+0x792/0x830
[<ffffffff81179933>] filename_lookup+0x33/0xd0
[<ffffffff8117ab0b>] user_path_at_empty+0x7b/0xb0
[<ffffffff8117ab4c>] user_path_at+0xc/0x10
[<ffffffff8116ff91>] vfs_fstatat+0x51/0xb0
[<ffffffff81170116>] vfs_stat+0x16/0x20
[<ffffffff8117013f>] sys_newstat+0x1f/0x50
[<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
13098 [<ffffffff8118325e>] __wait_on_freeing_inode+0x9e/0xc0
[<ffffffff81183321>] find_inode_fast+0xa1/0xc0
[<ffffffff8118525f>] iget_locked+0x4f/0x180
[<ffffffff811ef9e3>] ext4_iget+0x33/0x9f0
[<ffffffff811f6a1c>] ext4_lookup+0xbc/0x160
[<ffffffff81174ad0>] lookup_real+0x20/0x60
[<ffffffff81177e25>] lookup_open+0x175/0x1d0
[<ffffffff8117815e>] do_last+0x2de/0x780
[<ffffffff8117ae9a>] path_openat+0xda/0x400
[<ffffffff8117b303>] do_filp_open+0x43/0xa0
[<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
[<ffffffff81168f9c>] sys_open+0x1c/0x20
[<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
19091 [<ffffffff81179862>] path_lookupat+0x792/0x830
[<ffffffff81179933>] filename_lookup+0x33/0xd0
[<ffffffff8117ab0b>] user_path_at_empty+0x7b/0xb0
[<ffffffff8117ab4c>] user_path_at+0xc/0x10
[<ffffffff8116ff91>] vfs_fstatat+0x51/0xb0
[<ffffffff81170116>] vfs_stat+0x16/0x20
[<ffffffff8117013f>] sys_newstat+0x1f/0x50
[<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
19092 [<ffffffff81179862>] path_lookupat+0x792/0x830
[<ffffffff81179933>] filename_lookup+0x33/0xd0
[<ffffffff8117ab0b>] user_path_at_empty+0x7b/0xb0
[<ffffffff8117ab4c>] user_path_at+0xc/0x10
[<ffffffff8116ff91>] vfs_fstatat+0x51/0xb0
[<ffffffff81170116>] vfs_stat+0x16/0x20
[<ffffffff8117013f>] sys_newstat+0x1f/0x50
[<ffffffff81582fe9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
