Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id B156B828DF
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 11:42:19 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id n128so16348803pfn.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 08:42:19 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id b74si10252869pfd.48.2016.02.03.08.42.18
        for <linux-mm@kvack.org>;
        Wed, 03 Feb 2016 08:42:18 -0800 (PST)
Date: Wed, 3 Feb 2016 09:42:09 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v8 4/9] dax: support dirty DAX entries in radix tree
Message-ID: <20160203164209.GA29275@linux.intel.com>
References: <1452230879-18117-1-git-send-email-ross.zwisler@linux.intel.com>
 <1452230879-18117-5-git-send-email-ross.zwisler@linux.intel.com>
 <20160113094411.GA17057@quack.suse.cz>
 <20160113184832.GA5904@linux.intel.com>
 <20160115132249.GL15950@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160115132249.GL15950@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com

On Fri, Jan 15, 2016 at 02:22:49PM +0100, Jan Kara wrote:
> On Wed 13-01-16 11:48:32, Ross Zwisler wrote:
> > On Wed, Jan 13, 2016 at 10:44:11AM +0100, Jan Kara wrote:
> > > On Thu 07-01-16 22:27:54, Ross Zwisler wrote:
> > > > Add support for tracking dirty DAX entries in the struct address_space
> > > > radix tree.  This tree is already used for dirty page writeback, and it
> > > > already supports the use of exceptional (non struct page*) entries.
> > > > 
> > > > In order to properly track dirty DAX pages we will insert new exceptional
> > > > entries into the radix tree that represent dirty DAX PTE or PMD pages.
> > > > These exceptional entries will also contain the writeback sectors for the
> > > > PTE or PMD faults that we can use at fsync/msync time.
> > > > 
> > > > There are currently two types of exceptional entries (shmem and shadow)
> > > > that can be placed into the radix tree, and this adds a third.  We rely on
> > > > the fact that only one type of exceptional entry can be found in a given
> > > > radix tree based on its usage.  This happens for free with DAX vs shmem but
> > > > we explicitly prevent shadow entries from being added to radix trees for
> > > > DAX mappings.
> > > > 
> > > > The only shadow entries that would be generated for DAX radix trees would
> > > > be to track zero page mappings that were created for holes.  These pages
> > > > would receive minimal benefit from having shadow entries, and the choice
> > > > to have only one type of exceptional entry in a given radix tree makes the
> > > > logic simpler both in clear_exceptional_entry() and in the rest of DAX.
> > > > 
> > > > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > > > Reviewed-by: Jan Kara <jack@suse.cz>
> > > 
> > > I have realized there's one issue with this code. See below:
> > > 
> > > > @@ -34,31 +35,39 @@ static void clear_exceptional_entry(struct address_space *mapping,
> > > >  		return;
> > > >  
> > > >  	spin_lock_irq(&mapping->tree_lock);
> > > > -	/*
> > > > -	 * Regular page slots are stabilized by the page lock even
> > > > -	 * without the tree itself locked.  These unlocked entries
> > > > -	 * need verification under the tree lock.
> > > > -	 */
> > > > -	if (!__radix_tree_lookup(&mapping->page_tree, index, &node, &slot))
> > > > -		goto unlock;
> > > > -	if (*slot != entry)
> > > > -		goto unlock;
> > > > -	radix_tree_replace_slot(slot, NULL);
> > > > -	mapping->nrshadows--;
> > > > -	if (!node)
> > > > -		goto unlock;
> > > > -	workingset_node_shadows_dec(node);
> > > > -	/*
> > > > -	 * Don't track node without shadow entries.
> > > > -	 *
> > > > -	 * Avoid acquiring the list_lru lock if already untracked.
> > > > -	 * The list_empty() test is safe as node->private_list is
> > > > -	 * protected by mapping->tree_lock.
> > > > -	 */
> > > > -	if (!workingset_node_shadows(node) &&
> > > > -	    !list_empty(&node->private_list))
> > > > -		list_lru_del(&workingset_shadow_nodes, &node->private_list);
> > > > -	__radix_tree_delete_node(&mapping->page_tree, node);
> > > > +
> > > > +	if (dax_mapping(mapping)) {
> > > > +		if (radix_tree_delete_item(&mapping->page_tree, index, entry))
> > > > +			mapping->nrexceptional--;
> > > 
> > > So when you punch hole in a file, you can delete a PMD entry from a radix
> > > tree which covers part of the file which still stays. So in this case you
> > > have to split the PMD entry into PTE entries (probably that needs to happen
> > > up in truncate_inode_pages_range()) or something similar...
> > 
> > I think (and will verify) that the DAX code just unmaps the entire PMD range
> > when we receive a hole punch request inside of the PMD.  If this is true then
> > I think the radix tree code should behave the same way and just remove the PMD
> > entry in the radix tree.
> 
> But you cannot just remove it if it is dirty... You have to keep somewhere
> information that part of the PMD range is still dirty (or write that range
> out before removing the radix tree entry).

It turns out that hole punching a DAX PMD hits a BUG:

[  247.821632] ------------[ cut here ]------------
[  247.822744] kernel BUG at mm/memory.c:1195!
[  247.823742] invalid opcode: 0000 [#1] SMP 
[  247.824768] Modules linked in: nd_pmem nd_btt nd_e820 libnvdimm
[  247.826299] CPU: 1 PID: 1544 Comm: test Tainted: G        W       4.4.0-rc8+ #9
[  247.828017] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.8.2-20150714_191134- 04/01/2014
[  247.830298] task: ffff880036756200 ti: ffff8800a077c000 task.ti: ffff8800a077c000
[  247.831935] RIP: 0010:[<ffffffff81203157>]  [<ffffffff81203157>] unmap_page_range+0x907/0x910
[  247.833847] RSP: 0018:ffff8800a077fb88  EFLAGS: 00010282
[  247.835030] RAX: 0000000000000073 RBX: ffffc00000000fff RCX: 0000000000000000
[  247.836595] RDX: 0000000000000000 RSI: ffff88051a3ce168 RDI: ffff88051a3ce168
[  247.838168] RBP: ffff8800a077fc68 R08: 0000000000000001 R09: 0000000000000001
[  247.839728] R10: 0000000000000001 R11: 0000000000000001 R12: 0000000010405000
[  247.841244] R13: 0000000010403000 R14: ffff8800a077fcb0 R15: 0000000010403000
[  247.842715] FS:  00007f533a5bb700(0000) GS:ffff88051a200000(0000) knlGS:0000000000000000
[  247.844395] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  247.845589] CR2: 0000000010403000 CR3: 0000000514337000 CR4: 00000000000006e0
[  247.847076] Stack:
[  247.847502]  ffff8800a077fcb0 ffff8800a077fc38 ffff880036756200 ffff8800a077fbb0
[  247.849126]  0000000010404fff 0000000010404fff 0000000010404fff ffff880514337000
[  247.850714]  ffff880513499000 ffff8800a077fcc0 0000000010405000 0000000000000000
[  247.852246] Call Trace:
[  247.852740]  [<ffffffff810fbb4d>] ? trace_hardirqs_on+0xd/0x10
[  247.853883]  [<ffffffff812031dd>] unmap_single_vma+0x7d/0xe0
[  247.855004]  [<ffffffff812032ed>] zap_page_range_single+0xad/0xf0
[  247.856195]  [<ffffffff81203410>] ? unmap_mapping_range+0xa0/0x190
[  247.857403]  [<ffffffff812034d6>] unmap_mapping_range+0x166/0x190
[  247.858596]  [<ffffffff811e0948>] truncate_pagecache_range+0x48/0x60
[  247.859839]  [<ffffffff8130b7ba>] ext4_punch_hole+0x33a/0x4b0
[  247.860837]  [<ffffffff8133a274>] ext4_fallocate+0x144/0x890
[  247.861784]  [<ffffffff810f6cd7>] ? update_fast_ctr+0x17/0x30
[  247.862751]  [<ffffffff810f6d69>] ? percpu_down_read+0x49/0x90
[  247.863731]  [<ffffffff812640c4>] ? __sb_start_write+0xb4/0xf0
[  247.864709]  [<ffffffff8125d900>] vfs_fallocate+0x140/0x220
[  247.865645]  [<ffffffff8125e7d4>] SyS_fallocate+0x44/0x70
[  247.866553]  [<ffffffff81a68ef2>] entry_SYSCALL_64_fastpath+0x12/0x76
[  247.867632] Code: 12 fe ff ff 0f 0b 48 8b 45 98 48 8b 4d 90 4c 89 fa 48 c7 c6 78 30 c2 81 48 c7 c7 50 6b f0 81 4c 8b 48 08 4c 8b 00 e8 06 4a fc ff <0f> 0b e8 d2 2f ea ff 66 90 66 66 66 66 90 48 8b 06 4c 8b 4e 08 
[  247.871862] RIP  [<ffffffff81203157>] unmap_page_range+0x907/0x910
[  247.872843]  RSP <ffff8800a077fb88>
[  247.873435] ---[ end trace 75145e78670ba43d ]---

This happens with XFS as well.  I'm not sure that this path has ever been run,
so essentially the next step is "add PMD hole punch support to DAX, including
fsync/msync support".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
