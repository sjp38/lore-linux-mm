Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E4DD6B0007
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 05:20:39 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id e15so12435110wrj.14
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 02:20:39 -0700 (PDT)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id d13si5129086wme.138.2018.04.16.02.20.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 02:20:37 -0700 (PDT)
Received: from mail-qk0-f199.google.com ([209.85.220.199])
	by youngberry.canonical.com with esmtps (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.76)
	(envelope-from <gavin.guo@canonical.com>)
	id 1f80JQ-0001Ki-8J
	for linux-mm@kvack.org; Mon, 16 Apr 2018 09:20:36 +0000
Received: by mail-qk0-f199.google.com with SMTP id 132so213785qkl.7
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 02:20:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180413125815.i5m4taaprr42blxn@quack2.suse.cz>
References: <20180103100430.GE4911@quack2.suse.cz> <CAPcyv4grBxGs0cnFVyRx29t0xhG5EBTy_nP=qhsVh5=8nusNsw@mail.gmail.com>
 <20180104113301.GE29010@quack2.suse.cz> <CA+eFSM2ZB_X+x2ZU0c_QtJQgYQ6WvnmUZnah1iSZPLbbGRfRQQ@mail.gmail.com>
 <20180413125815.i5m4taaprr42blxn@quack2.suse.cz>
From: Gavin Guo <gavin.guo@canonical.com>
Date: Mon, 16 Apr 2018 17:20:33 +0800
Message-ID: <CA+eFSM0U_i+rZH5PROiZjN-=A6qg0Gx867Kyso1_QeBNyNqTDA@mail.gmail.com>
Subject: Re: Filesystem crashes due to pages without buffers
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Fri, Apr 13, 2018 at 8:58 PM, Jan Kara <jack@suse.cz> wrote:
> Hi!
>
> On Fri 13-04-18 20:39:06, Gavin Guo wrote:
>> On Thu, Jan 4, 2018 at 7:33 PM, Jan Kara <jack@suse.cz> wrote:
>> >
>> > On Wed 03-01-18 20:56:32, Dan Williams wrote:
>> > > On Wed, Jan 3, 2018 at 2:04 AM, Jan Kara <jack@suse.cz> wrote:
>> > > > Hello,
>> > > >
>> > > > Over the years I have seen so far unexplained crashed in filesystem's
>> > > > (ext4, xfs) writeback path due to dirty pages without buffers attached to
>> > > > them (see [1] and [2] for relatively recent reports). This was confusing as
>> > > > reclaim takes care not to strip buffers from a dirty page and both
>> > > > filesystems do add buffers to a page when it is first written to - in
>> > > > ->page_mkwrite() and ->write_begin callbacks.
>> > > >
>> > > > Recently I have come across a code path that is probably leading to this
>> > > > inconsistent state and I'd like to discuss how to best fix the problem
>> > > > because it's not obvious to me. Consider the following race:
>> > > >
>> > > > CPU1                                    CPU2
>> > > >
>> > > > addr = mmap(file1, MAP_SHARED, ...);
>> > > > fd2 = open(file2, O_DIRECT | O_RDONLY);
>> > > > read(fd2, addr, len)
>> > > >   do_direct_IO()
>> > > >     page = dio_get_page()
>> > > >       dio_refill_pages()
>> > > >         iov_iter_get_pages()
>> > > >           get_user_pages_fast()
>> > > >             - page fault
>> > > >               ->page_mkwrite()
>> > > >                 block_page_mkwrite()
>> > > >                   lock_page(page);
>> > > >                   - attaches buffers to page
>> > > >                   - makes sure blocks are allocated
>> > > >                   set_page_dirty(page)
>> > > >               - install writeable PTE
>> > > >               unlock_page(page);
>> > > >     submit_page_section(page)
>> > > >       - submits bio with 'page' as a buffer
>> > > >                                         kswapd reclaims pages:
>> > > >                                         ...
>> > > >                                         shrink_page_list()
>> > > >                                           trylock_page(page) - this is the
>> > > >                                             page CPU1 has just faulted in
>> > > >                                           try_to_unmap(page)
>> > > >                                           pageout(page);
>> > > >                                             clear_page_dirty_for_io(page);
>> > > >                                             ->writepage()
>> > > >                                           - let's assume page got written
>> > > >                                             out fast enough, alternatively
>> > > >                                             we could get to the same path as
>> > > >                                             soon as the page IO completes
>> > > >                                           if (page_has_private(page)) {
>> > > >                                             try_to_release_page(page)
>> > > >                                               - reclaims buffers from the
>> > > >                                                 page
>> > > >                                            __remove_mapping(page)
>> > > >                                              - fails as DIO code still
>> > > >                                                holds page reference
>> > > > ...
>> > > >
>> > > > eventually read completes
>> > > >   dio_bio_complete(bio)
>> > > >     set_page_dirty_lock(page)
>> > > >       Bummer, we've just marked the page as dirty without having buffers.
>> > > >       Eventually writeback will find it and filesystem will complain...
>> > > >
>> > > > Am I missing something?
>> > > >
>> > > > The problem here is that filesystems fundamentally assume that a page can
>> > > > be written to only between ->write_begin - ->write_end (in this interval
>> > > > the page is locked), or between ->page_mkwrite - ->writepage and above is
>> > > > an example where this does not hold because when a page reference is
>> > > > acquired through get_user_pages(), page can get written to by the holder of
>> > > > the reference and dirtied even after it has been unmapped from page tables
>> > > > and ->writepage has been called. This is not only a cosmetic issue leading
>> > > > to assertion failure but it can also lead to data loss, data corruption, or
>> > > > other unpleasant surprises as filesystems assume page contents cannot be
>> > > > modified until either ->write_begin() or ->page_mkwrite gets called and
>> > > > those calls are serialized by proper locking with problematic operations
>> > > > such as hole punching etc.
>> > > >
>> > > > I'm not sure how to fix this problem. We could 'simulate' a writeable page
>> > > > fault in set_page_dirty_lock(). It is a bit ugly since we don't have a
>> > > > virtual address of the fault, don't hold mmap_sem, etc., possibly
>> > > > expensive, but it would make filesystems happy. Data stored by GUP user
>> > > > (e.g. read by DIO in the above case) could still get lost if someone e.g.
>> > > > punched hole under the buffer or otherwise messed with the underlying
>> > > > storage of the page while DIO was running but arguably users could expect
>> > > > such outcome.
>> > > >
>> > > > Another possible solution would be to make sure page is writeably mapped
>> > > > until GUP user drops its reference. That would be arguably cleaner but
>> > > > probably that would mean we have to track number of writeable GUP page
>> > > > references separately (no space space in struct page is a problem here) and
>> > > > block page_mkclean() until they are dropped. Also for long term GUP users
>> > > > like Infiniband or V4L we'd have to come up with some solution as we should
>> > > > not block page_mkclean() for so long.
>> > >
>> > > Do we need to block page_mkclean, or could we defer buffer reclaiming
>> > > to the last put of the page?
>> >
>> > As I wrote to Dave the problem is no so much with reclaiming of buffers but
>> > with the fact filesystems don't expect page can be dirtied after
>> > page_mkclean() is finished.
>> >
>> > > I think once we have the "register memory with lease" mechanism for
>> > > Infiniband we could expand it to the page cache case. The problem is
>> > > the regression this would cause with userspace that expects it can
>> > > maintain file backed memory registrations indefinitely.
>> > >
>> > > What are the implications of holding off page_mkclean or release
>> > > buffers indefinitely?
>> >
>> > Bad. You cannot write the page to disk until page_mkclean() finishes as
>> > page_mkclean() is part of clear_page_dirty_for_io(). And we really do need
>> > that functionality there e.g. to make sure tail of the last page in the
>> > file is properly zeroed out, storage with DIF/DIX can compute checksum of
>> > the data safely before submitting it to the device etc.
>> >
>> > > Is an indefinite / interruptible sleep waiting for the 'put' event of
>> > > a get_user_pages() page unacceptable? The current case that the file
>> > > contents will not be coherent with respect to in-flight RDMA, perhaps
>> > > waiting for that to complete is better than cleaning buffers from the
>> > > page prematurely.
>> >
>> > Yeah, indefinite sleep is really a no-go.
>> >
>> > > > As a side note DAX needs some solution for GUP users as well. The problems
>> > > > are similar there in nature, just much easier to hit. So at least a
>> > > > solution for long-term GUP users can (and I strongly believe should) be
>> > > > shared between standard and DAX paths.
>> > >
>> > > In the DAX case we rely on the fact that when the page goes idle we
>> > > only need to worry about the filesytem block map changing, the page
>> > > won't get reallocated somewhere else. We can't use page idle as an
>> > > event in this case, however, if the page reference count is one then
>> > > the DIO code can know that it has the page exclusively, so maybe DAX
>> > > and non-DAX can share the page count == 1 event notification.
>> >
>> > The races I describe do not need to involve truncate / hole punching. It is
>> > just enough to race with page writeback. So page references are of no use
>> > here. We would have to specifically track number of references acquired by
>> > GUP or something like that. So what I wanted to share with DAX is the
>> > long-term pin handling, the rest is unclear for now.
>> >
>> >                                                                 Honza
>> > --
>> > Jan Kara <jack@suse.com>
>> > SUSE Labs, CR
>> >
>> > --
>> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> > the body to majordomo@kvack.org.  For more info on Linux MM,
>> > see: http://www.linux-mm.org/ .
>> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>> The bug can be reliably reproduced in our platform with the
>> current upstream kernel(80aa76bcd364 Merge tag 'xfs-4.17-merge-4' of
>> git://git.kernel.org/pub/scm/fs/xfs/xfs-linux). I'm happy to
>> help to test and debug. The error message is as following:
>
> Thanks for report! So what workload do you run to trigger this? Is it just
> a direct IO read to a buffer in a shared file mapping or something else?
>
>                                                                 Honza
>
>> kernel BUG at /home/gavin/work-kernel/fs/ext4/inode.c:2126!
>> invalid opcode: 0000 [#1] SMP PTI
>> Modules linked in: veth ipt_MASQUERADE nf_nat_masquerade_ipv4
>> nf_conntrack_netlink nfnetlink xfrm_user iptable_nat nf_conntrack_ipv4
>> nf_defrag_ipv4 nf_nat_ipv4 xt_addrtype xt_conntrack nf_nat
>> nf_conntrack br_netfilter bridge stp llc overlay xt_multiport
>> iptable_filter ip_tables x_tables cachefiles fscache esp6_offload esp6
>> esp4_offload esp4 xfrm_algo nls_iso8859_1 intel_rapl sb_edac
>> x86_pkg_temp_thermal intel_powerclamp ipmi_ssif coretemp kvm_intel
>> nvidia_uvm(POE) mxm_wmi kvm joydev input_leds irqbypass intel_cstate
>> intel_rapl_perf mei_me ipmi_si shpchp lpc_ich mei acpi_power_meter
>> mac_hid wmi ib_iser rdma_cm iw_cm ib_cm ib_core iscsi_tcp libiscsi_tcp
>> libiscsi scsi_transport_iscsi ipmi_devintf sunrpc ipmi_msghandler
>> autofs4 btrfs zstd_compress raid10 raid456 async_raid6_recov
>> async_memcpy
>>  async_pq async_xor async_tx xor raid6_pq libcrc32c raid1 raid0
>> multipath linear i2c_algo_bit nvidia_drm(POE) ses crct10dif_pclmul
>> crc32_pclmul nvidia_modeset(POE) ttm ghash_clmulni_intel enclosure
>> hid_generic uas pcbc scsi_transport_sas drm_kms_helper usbhid
>> aesni_intel hid aes_x86_64 usb_storage syscopyarea crypto_simd
>> sysfillrect mlx5_core cryptd nvidia(POE) sysimgblt glue_helper ixgbe
>> mlxfw megaraid_sas fb_sys_fops devlink dca ahci ptp drm libahci
>> pps_core mdio
>> CPU: 54 PID: 8938 Comm: kworker/u161:0 Tainted: P           OE
>> 4.16.0-999-generic #201804102200
>>
>> Workqueue: writeback wb_workfn (flush-8:0)
>> RIP: 0010:ext4_writepage+0x318/0x770
>> RSP: 0018:ffffb514e76cb7f8 EFLAGS: 00010246
>> RAX: 00500b4e8000026d RBX: 0000000000001000 RCX: ffff8c2cafba5000
>> RDX: ffff8bec4069a020 RSI: ffffb514e76cbc28 RDI: ffffe91efcc8bd80
>> RBP: ffffb514e76cb870 R08: 0000000000028115 R09: 00000000000280c0
>> R10: 0000000000000002 R11: ffff8c2dbffd4000 R12: ffffe91efcc8bd80
>> R13: ffff8bec40699ea8 R14: ffffb514e76cbc28 R15: ffffe91efcc8bd80
>> FS:  0000000000000000(0000) GS:ffff8becbfc80000(0000)
>> knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> CR2: 00007ffcc8f6f080 CR3: 0000004b9ce0a006 CR4: 00000000003606e0
>> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
>> DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
>> Call Trace:
>>  ? rmap_walk+0x41/0x60
>>  ? page_mkclean+0x9f/0xb0
>>  ? invalid_page_referenced_vma+0x80/0x80
>>  __writepage+0x17/0x50
>>  write_cache_pages+0x228/0x4a0
>>  ? __wb_calc_thresh+0x140/0x140
>>  generic_writepages+0x61/0xa0
>>  ? _cond_resched+0x1a/0x50
>>  ? write_cache_pages+0x396/0x4a0
>>  ext4_writepages+0x1fc/0xe00
>>  ? ext4_writepages+0x1fc/0xe00
>>  ? generic_writepages+0x6d/0xa0
>>  ? fprop_fraction_percpu+0x2f/0x80
>>  do_writepages+0x1c/0x60
>>  ? do_writepages+0x1c/0x60
>>  __writeback_single_inode+0x45/0x320
>>  writeback_sb_inodes+0x266/0x580
>>  __writeback_inodes_wb+0x92/0xc0
>>  wb_writeback+0x282/0x310
>>  wb_workfn+0x1a3/0x440
>>  ? wb_workfn+0x1a3/0x440
>>  process_one_work+0x1db/0x3c0
>>  worker_thread+0x4b/0x420
>>  kthread+0x102/0x140
>>  ? rescuer_thread+0x380/0x380
>>  ? kthread_create_worker_on_cpu+0x70/0x70
>>  ret_from_fork+0x35/0x40
>> Code: ff f6 c4 08 0f 85 58 ff ff ff e8 68 56 00 00 ba 00 10 00 00 31
>> f6 41 bd fb ff ff ff e8 a2 9e ff ff 4c 89 e7 e8 fa 39 ea ff eb 8a <0f>
>> 0b c6 45 a8 00 e9 f0 fd ff ff 49 83 7c 24 10 00 0f 85 c7 03
>> RIP: ext4_writepage+0x318/0x770 RSP: ffffb514e76cb7f8
>> ---[ end trace 59d4e1a4b221404b ]---
> --
> Jan Kara <jack@suse.com>
> SUSE Labs, CR

##############################
## The reproducing scenario ##
##############################

The reproducer is creating eight processes by the mpirun and each
process is bound to the underlying GPU computation unit by the
cudaSetDevice() interface. The scenario is that each process creates a
8K bytes buffer by the cudaMalloc() and sends/receives the 8K bytes
buffer in a circular buffer behavior by the MPI_Isend()/MPI_Irecv()
like:

P0 -> P1 -> P2 -> P3 -> P4 -> P5 -> P6 -> P7-> to P0

The sending/receiving buffer is iterated 1000 times, then to proceed
to clean up the resource allocated to the cuda device by:

cudaDeviceReset();
MPI_Finalize();

However, the sequence is actually controversial as the
cudaDeviceReset() already cleaned up the resource, including the 8K
bytes memory allocated by the cudaMalloc(), MPI_Finalize() could
access the memory allocated by cudaMalloc().  Finally, the
MPI_Finalize() accidentally triggers the kernel bug.

I tried to look up the implementation of the MPI library,
unfortunately, the exact mechanism corresponded to the
try_to_free_buffers()/set_page_dirty() is still unknown.

##############################
##### The kernel testing #####
##############################

1). I tried the patch which tries to capture the dirty page scenario when
the page is released, however, there is no warning message when the
bug is successfully reproduced. So, it eliminates the possibility that
the ext4_releasepage() removes the buffer of a dirty page.

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 3d4d1dccc8a1..9310277c8e3e 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3384,6 +3384,11 @@ static int ext4_releasepage(struct page *page,
gfp_t wait)

        trace_ext4_releasepage(page);

+       if (PageDirty(page)) {
+               WARN_ON(1);
+               return 0;
+       }
+
        /* Page has dirty journalled data -> cannot release */
        if (PageChecked(page))
                return 0;
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 930aa0d19761..3bd1a605853f 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1134,6 +1134,11 @@ static int bdev_try_to_free_page(struct
super_block *sb, struct page *page,
 {
        journal_t *journal = EXT4_SB(sb)->s_journal;

+       if (PageDirty(page)) {
+               WARN_ON(1);
+               return 0;
+       }
+
        WARN_ON(PageChecked(page));
        if (!page_has_buffers(page))
                return 0;


2). Then, I proceeded to try the patch mentioned in link[1] and found
the patch was already merged into the kernel v4.10-rc1 with commit id:

6dcc693bc57f ext4: warn when page is dirtied without buffers

According to the code:

static int ext4_set_page_dirty(struct page *page)
{
       WARN_ON_ONCE(!PageLocked(page) && !PageDirty(page));
       WARN_ON_ONCE(!page_has_buffers(page));
       return __set_page_dirty_buffers(page);
}

I also cannot find the warning message[2] with the
"WARN_ON_ONCE(!page_has_buffers(page))" when reproduced with the
latest upstream kernel.

With the patch in the current kernel, I think the first scenario,
CPU1 is doing direct IO and CPU2 is doing the reclaim, also can be
captured in the ext4_set_page_dirty(). And there is no error message
related to the warning, so, it seems not related to this case. Am I
missing anything?

> eventually read completes
>   dio_bio_complete(bio)
>     set_page_dirty_lock(page)
set_page_dirty
  int (*spd)(struct page *) = mapping->a_ops->set_page_dirty;
    return (*spd)(page);
      ext4_set_page_dirty
        WARN_ON_ONCE(!page_has_buffers(page));
>       Bummer, we've just marked the page as dirty without having buffers.
>       Eventually writeback will find it and filesystem will complain...

There could be other path triggering the bug. Any idea where to add
the debug message?

##############################
######### Reference ##########
##############################

[1]. kernel BUG at fs/ext4/inode.c:2428!
https://patchwork.ozlabs.org/patch/697715/

[2]. coredump message of latest upstream kernel
http://paste.ubuntu.com/p/FfDk9cChdX/
