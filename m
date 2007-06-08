Received: by wr-out-0506.google.com with SMTP id 67so786564wri
        for <linux-mm@kvack.org>; Fri, 08 Jun 2007 11:02:18 -0700 (PDT)
Message-ID: <466999A2.8020608@googlemail.com>
Date: Fri, 08 Jun 2007 20:02:10 +0200
MIME-Version: 1.0
Subject: Re: [patch 00/12] Slab defragmentation V3
References: <20070607215529.147027769@sgi.com>
In-Reply-To: <20070607215529.147027769@sgi.com>
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 8bit
From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Michal Piotrowski <michal.k.k.piotrowski@gmail.com>, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

bash shared mapping + your script in a loop
while true;  do sudo ./run.sh; done > res3.txt


[ 2866.154597] =======================================================
[ 2866.162384] [ INFO: possible circular locking dependency detected ]
[ 2866.168698] 2.6.22-rc4-mm2 #1
[ 2866.171671] -------------------------------------------------------
[ 2866.177972] bash-shared-map/3245 is trying to acquire lock:
[ 2866.183566]  (slub_lock){----}, at: [<c0482510>] kmem_cache_defrag+0x18/0xb3

l *kmem_cache_defrag+0x18
0xc1082510 is in kmem_cache_defrag (mm/slub.c:2742).
2737            struct kmem_cache *s;
2738            unsigned long pages = 0;
2739            void *scratch;
2740
2741            down_read(&slub_lock);
2742            list_for_each_entry(s, &slab_caches, list) {
2743
2744                    /*
2745                     * The slab cache must have defrag methods.
2746                     */


[ 2866.190800] 
[ 2866.190801] but task is already holding lock:
[ 2866.196746]  (&inode->i_alloc_sem){--..}, at: [<c0498b07>] notify_change+0xdf/0x2ec

l *notify_change+0xdf
0xc1098b07 is in notify_change (fs/attr.c:145).
140                     return 0;
141
142             if (ia_valid & ATTR_SIZE)
143                     down_write(&dentry->d_inode->i_alloc_sem);
144
145             if (inode->i_op && inode->i_op->setattr) {
146                     error = security_inode_setattr(dentry, attr);
147                     if (!error)
148                             error = inode->i_op->setattr(dentry, attr);
149             } else {


[ 2866.204761] 
[ 2866.204762] which lock already depends on the new lock.
[ 2866.204764] 
[ 2866.213058] 
[ 2866.213060] the existing dependency chain (in reverse order) is:
[ 2866.220630] 
[ 2866.220631] -> #2 (&inode->i_alloc_sem){--..}:
[ 2866.226784]        [<c0441df1>] add_lock_to_list+0x67/0x8b
[ 2866.232525]        [<c0444bb9>] __lock_acquire+0xb02/0xd36
[ 2866.238315]        [<c0444e8b>] lock_acquire+0x9e/0xb8
[ 2866.243702]        [<c043c0c5>] down_write+0x3e/0x77
[ 2866.248914]        [<c0498b07>] notify_change+0xdf/0x2ec
[ 2866.254542]        [<c0484161>] do_truncate+0x60/0x79
[ 2866.259927]        [<c048d5fe>] may_open+0x1db/0x240
[ 2866.265165]        [<c048fbbd>] open_namei+0x2d6/0x6bb
[ 2866.270602]        [<c0483a5d>] do_filp_open+0x26/0x3b
[ 2866.275996]        [<c0483acf>] do_sys_open+0x5d/0xed
[ 2866.281382]        [<c0483b97>] sys_open+0x1c/0x1e
[ 2866.286508]        [<c0404182>] sysenter_past_esp+0x5f/0x99
[ 2866.292428]        [<b7f9d410>] 0xb7f9d410
[ 2866.296819]        [<ffffffff>] 0xffffffff
[ 2866.301177] 
[ 2866.301178] -> #1 (&sysfs_inode_imutex_key){--..}:
[ 2866.307632]        [<c0441df1>] add_lock_to_list+0x67/0x8b
[ 2866.313425]        [<c0444bb9>] __lock_acquire+0xb02/0xd36
[ 2866.319164]        [<c0444e8b>] lock_acquire+0x9e/0xb8
[ 2866.324576]        [<c065b745>] __mutex_lock_slowpath+0x107/0x369
[ 2866.331008]        [<c065b9c3>] mutex_lock+0x1c/0x1f
[ 2866.336314]        [<c04c2609>] create_dir+0x1e/0x1c2
[ 2866.341682]        [<c04c280d>] sysfs_create_dir+0x60/0x7b
[ 2866.347396]        [<c050a335>] kobject_shadow_add+0xd7/0x189
[ 2866.353499]        [<c050a3f1>] kobject_add+0xa/0xc
[ 2866.358685]        [<c0480f00>] sysfs_slab_add+0x10c/0x152
[ 2866.364374]        [<c048111b>] kmem_cache_create+0x13a/0x1d4
[ 2866.370442]        [<c083415d>] fasync_init+0x2e/0x37
[ 2866.375818]        [<c0824542>] kernel_init+0x14e/0x2bf
[ 2866.381351]        [<c0404e7b>] kernel_thread_helper+0x7/0x10
[ 2866.387419]        [<ffffffff>] 0xffffffff
[ 2866.391843] 
[ 2866.391845] -> #0 (slub_lock){----}:
[ 2866.397022]        [<c0442b04>] print_circular_bug_tail+0x2e/0x68
[ 2866.403359]        [<c0444aa5>] __lock_acquire+0x9ee/0xd36
[ 2866.409080]        [<c0444e8b>] lock_acquire+0x9e/0xb8
[ 2866.414466]        [<c043bfff>] down_read+0x3d/0x74
[ 2866.419635]        [<c0482510>] kmem_cache_defrag+0x18/0xb3
[ 2866.425540]        [<c046c7ac>] shrink_slab+0x1ca/0x1d5
[ 2866.431002]        [<c046cc1d>] try_to_free_pages+0x178/0x224
[ 2866.437044]        [<c046824f>] __alloc_pages+0x1cd/0x324
[ 2866.442794]        [<c0465282>] find_or_create_page+0x5c/0xa6
[ 2866.448817]        [<c04c9379>] ext3_truncate+0xbb/0x83b
[ 2866.454411]        [<c0472470>] vmtruncate+0x11a/0x140
[ 2866.459762]        [<c049894d>] inode_setattr+0x5c/0x137
[ 2866.465286]        [<c04caafb>] ext3_setattr+0x19c/0x1f8
[ 2866.470835]        [<c0498b61>] notify_change+0x139/0x2ec
[ 2866.476514]        [<c0484161>] do_truncate+0x60/0x79
[ 2866.481822]        [<c04842af>] do_sys_ftruncate+0x135/0x150
[ 2866.487778]        [<c04842e5>] sys_ftruncate64+0x1b/0x1d
[ 2866.493405]        [<c040420c>] syscall_call+0x7/0xb
[ 2866.498599]        [<b7f10410>] 0xb7f10410
[ 2866.502913]        [<ffffffff>] 0xffffffff
[ 2866.507201] 
[ 2866.507203] other info that might help us debug this:
[ 2866.507204] 
[ 2866.515363] 2 locks held by bash-shared-map/3245:
[ 2866.520151]  #0:  (&inode->i_mutex){--..}, at: [<c065b9c3>] mutex_lock+0x1c/0x1f
[ 2866.527826]  #1:  (&inode->i_alloc_sem){--..}, at: [<c0498b07>] notify_change+0xdf/0x2ec
[ 2866.536158] 
[ 2866.536160] stack backtrace:
[ 2866.540597]  [<c04052ad>] dump_trace+0x63/0x1eb
[ 2866.545187]  [<c040544f>] show_trace_log_lvl+0x1a/0x2f
[ 2866.550426]  [<c040608d>] show_trace+0x12/0x14
[ 2866.555005]  [<c04060a5>] dump_stack+0x16/0x18
[ 2866.559552]  [<c0442b35>] print_circular_bug_tail+0x5f/0x68
[ 2866.565216]  [<c0444aa5>] __lock_acquire+0x9ee/0xd36
[ 2866.570264]  [<c0444e8b>] lock_acquire+0x9e/0xb8
[ 2866.574991]  [<c043bfff>] down_read+0x3d/0x74
[ 2866.579487]  [<c0482510>] kmem_cache_defrag+0x18/0xb3
[ 2866.584664]  [<c046c7ac>] shrink_slab+0x1ca/0x1d5
[ 2866.589462]  [<c046cc1d>] try_to_free_pages+0x178/0x224
[ 2866.594796]  [<c046824f>] __alloc_pages+0x1cd/0x324
[ 2866.599800]  [<c0465282>] find_or_create_page+0x5c/0xa6
[ 2866.605099]  [<c04c9379>] ext3_truncate+0xbb/0x83b
[ 2866.609974]  [<c0472470>] vmtruncate+0x11a/0x140
[ 2866.614695]  [<c049894d>] inode_setattr+0x5c/0x137
[ 2866.619578]  [<c04caafb>] ext3_setattr+0x19c/0x1f8
[ 2866.624470]  [<c0498b61>] notify_change+0x139/0x2ec
[ 2866.629441]  [<c0484161>] do_truncate+0x60/0x79
[ 2866.634075]  [<c04842af>] do_sys_ftruncate+0x135/0x150
[ 2866.639339]  [<c04842e5>] sys_ftruncate64+0x1b/0x1d
[ 2866.644310]  [<c040420c>] syscall_call+0x7/0xb
[ 2866.648823]  [<b7f10410>] 0xb7f10410
[ 2866.652482]  =======================

http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/2.6.22-rc4-mm2-sd3/sd-dmesg
http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/2.6.22-rc4-mm2-sd3/sd-config

Regards,
Michal

-- 
"Najbardziej brakowa3o mi twojego milczenia."
-- Andrzej Sapkowski "Co? wiecej"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
