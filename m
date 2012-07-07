Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 707E26B0074
	for <linux-mm@kvack.org>; Sat,  7 Jul 2012 10:42:40 -0400 (EDT)
Date: Sat, 7 Jul 2012 22:42:28 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/7] Make TestSetPageDirty and dirty page accounting in
 one func
Message-ID: <20120707144228.GA24329@localhost>
References: <1340880885-5427-1-git-send-email-handai.szj@taobao.com>
 <1340881275-5651-1-git-send-email-handai.szj@taobao.com>
 <4FF1827A.7060806@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FF1827A.7060806@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Sha Zhengju <handai.szj@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, gthelen@google.com, yinghan@google.com, akpm@linux-foundation.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On Mon, Jul 02, 2012 at 08:14:02PM +0900, KAMEZAWA Hiroyuki wrote:
> (2012/06/28 20:01), Sha Zhengju wrote:
> > From: Sha Zhengju <handai.szj@taobao.com>
> > 
> > Commit a8e7d49a(Fix race in create_empty_buffers() vs __set_page_dirty_buffers())
> > extracts TestSetPageDirty from __set_page_dirty and is far away from
> > account_page_dirtied.But it's better to make the two operations in one single
> > function to keep modular.So in order to avoid the potential race mentioned in
> > commit a8e7d49a, we can hold private_lock until __set_page_dirty completes.
> > I guess there's no deadlock between ->private_lock and ->tree_lock by quick look.
> > 
> > It's a prepare patch for following memcg dirty page accounting patches.
> > 
> > Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> 
> I think there is no problem with the lock order.

Me think so, too.

> My small concern is the impact on the performance. IIUC, lock contention here can be
> seen if multiple threads write to the same file in parallel.
> Do you have any numbers before/after the patch ?

That would be a worthwhile test. The patch moves ->tree_lock and
->i_lock into ->private_lock, these are often contented locks..

For example, in the below case of 12 hard disks, each running 1 dd
write, the ->tree_lock and ->private_lock have the top #1 and #2
contentions.

lkp-nex04/JBOD-12HDD-thresh=1000M/ext4-1dd-1-3.3.0/lock_stat
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                              class name    con-bounces    contentions   waittime-min   waittime-max waittime-total    acq-bounces   acquisitions   holdtime-min   holdtime-max holdtime-total
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

           &(&mapping->tree_lock)->rlock:      18629034       19138284           0.09        1029.32    24353812.07       49650988      482883410           0.11         186.88   260706119.09
           -----------------------------
           &(&mapping->tree_lock)->rlock            783          [<ffffffff81109267>] tag_pages_for_writeback+0x2b/0x9d
           &(&mapping->tree_lock)->rlock        3195817          [<ffffffff81100d6c>] add_to_page_cache_locked+0xa3/0x119
           &(&mapping->tree_lock)->rlock        3863710          [<ffffffff81108df7>] test_set_page_writeback+0x63/0x140
           &(&mapping->tree_lock)->rlock        3311518          [<ffffffff81172ade>] __set_page_dirty+0x25/0xa5
           -----------------------------
           &(&mapping->tree_lock)->rlock        3450725          [<ffffffff81100d6c>] add_to_page_cache_locked+0xa3/0x119
           &(&mapping->tree_lock)->rlock        3225542          [<ffffffff81172ade>] __set_page_dirty+0x25/0xa5
           &(&mapping->tree_lock)->rlock        2241958          [<ffffffff81108df7>] test_set_page_writeback+0x63/0x140
           &(&mapping->tree_lock)->rlock        7339603          [<ffffffff8110ac33>] test_clear_page_writeback+0x64/0x155

...............................................................................................................................................................................................

        &(&mapping->private_lock)->rlock:       1165199        1191201           0.11        2843.25     1621608.38       13341420      152761848           0.10        3727.92    33559035.07
        --------------------------------
        &(&mapping->private_lock)->rlock              1          [<ffffffff81172913>] __find_get_block_slow+0x5a/0x135
        &(&mapping->private_lock)->rlock         385576          [<ffffffff811735d6>] create_empty_buffers+0x48/0xbf
        &(&mapping->private_lock)->rlock         805624          [<ffffffff8117346d>] try_to_free_buffers+0x57/0xaa
        --------------------------------
        &(&mapping->private_lock)->rlock              1          [<ffffffff811746dd>] __getblk+0x1b8/0x257
        &(&mapping->private_lock)->rlock         952718          [<ffffffff8117346d>] try_to_free_buffers+0x57/0xaa
        &(&mapping->private_lock)->rlock         238482          [<ffffffff811735d6>] create_empty_buffers+0x48/0xbf

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
