Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7DE6B6B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 16:36:53 -0500 (EST)
Date: Tue, 9 Nov 2010 22:36:06 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 02 of 66] mm, migration: Fix race between
 shift_arg_pages and rmap_walk by guaranteeing rmap_walk finds PTEs created
 within the temporary stack
Message-ID: <20101109213606.GD6809@random.random>
References: <patchbomb.1288798055@v2.random>
 <ad7a334318ea379be733.1288798057@v2.random>
 <20101109120109.BC42.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101109120109.BC42.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 09, 2010 at 12:01:55PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > Page migration requires rmap to be able to find all migration ptes
> > created by migration. If the second rmap_walk clearing migration PTEs
> > misses an entry, it is left dangling causing a BUG_ON to trigger during
> > fault. For example;
> > 
> > [  511.201534] kernel BUG at include/linux/swapops.h:105!
> > [  511.201534] invalid opcode: 0000 [#1] PREEMPT SMP
> > [  511.201534] last sysfs file: /sys/block/sde/size
> > [  511.201534] CPU 0
> > [  511.201534] Modules linked in: kvm_amd kvm dm_crypt loop i2c_piix4 serio_raw tpm_tis shpchp evdev tpm i2c_core pci_hotplug tpm_bios wmi processor button ext3 jbd mbcache dm_mirror dm_region_hash dm_log dm_snapshot dm_mod raid10 raid456 async_raid6_recov async_pq raid6_pq async_xor xor async_memcpy async_tx raid1 raid0 multipath linear md_mod sg sr_mod cdrom sd_mod ata_generic ahci libahci libata ide_pci_generic ehci_hcd ide_core r8169 mii ohci_hcd scsi_mod floppy thermal fan thermal_sys
> > [  511.888526]
> > [  511.888526] Pid: 20431, comm: date Not tainted 2.6.34-rc4-mm1-fix-swapops #6 GA-MA790GP-UD4H/GA-MA790GP-UD4H
> > [  511.888526] RIP: 0010:[<ffffffff811094ff>]  [<ffffffff811094ff>] migration_entry_wait+0xc1/0x129
> 
> Do you mean current linus-tree code is broken? do we need to merge this
> ASAP and need to backport stable tree?

No current upstream is not broken here, but it's required with THP
unless I add the below block to huge_memory.c rmap walks too. I am
afraid to forget special cases like the below in the long term, so the
fewer special/magic cases there are in the kernel to remember forever
the better for me, as it's less likely I introduce hard-to-reproduce
bugs later on in the kernel when I add more rmap walks.

-
-               /*
-                * During exec, a temporary VMA is setup and later
-               moved.
-                * The VMA is moved under the anon_vma lock but not
-               the
-                * page tables leading to a race where migration
-               cannot
-                * find the migration ptes. Rather than increasing the
-                * locking requirements of exec(), migration skips
-                * temporary VMAs until after exec() completes.
-                */
-               if (PAGE_MIGRATION && (flags & TTU_MIGRATION) &&
-                               is_vma_temporary_stack(vma))
-                       continue;
-

Now if Linus tells me to drop this patch, I will add the above block
to huge_memory.c, and then I can drop this 2/66 patch immediately
(hopefully the user stack will never be born as an hugepage or the
randomizing mremap during execve will be executed with perfect 2m
aligned offsets or then it wouldn't work anymore, but for now I can
safely remove this patch and add the above block to huge_memory.c).

I see the ugliness in exec.c, but I think we're less likely to have
bugs in the kernel in the future without the above magic in every
remap walk that needs to be accurate (like huge_memory.c and
migrate.c), the rmap walks are complicated enough already for my
taste. But I'm totally fine either ways, as I think I can remember.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
