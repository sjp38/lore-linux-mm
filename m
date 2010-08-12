Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8434A6B02A5
	for <linux-mm@kvack.org>; Thu, 12 Aug 2010 14:35:58 -0400 (EDT)
Date: Thu, 12 Aug 2010 14:35:47 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/2] mm: Implement writeback livelock avoidance using
 page tagging
Message-ID: <20100812183547.GA2294@infradead.org>
References: <1275677231-15662-1-git-send-email-jack@suse.cz>
 <1275677231-15662-3-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1275677231-15662-3-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, npiggin@suse.de, david@fromorbit.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I have an oops with current Linus' tree in xfstests 217 that looks
like it was caused by this patch:

217 149s ...[ 5105.342605] XFS mounting filesystem vdb6
[ 5105.373481] Ending clean XFS mount for filesystem: vdb6
[ 5115.405061] XFS mounting filesystem loop0
[ 5115.548654] Ending clean XFS mount for filesystem: loop0
[ 5115.588067] BUG: unable to handle kernel paging request at f7f14000
[ 5115.588067] IP: [<c07224fd>]
radix_tree_range_tag_if_tagged+0x15d/0x1c0
[ 5115.588067] *pde = 00007067 *pte = 00000000 
[ 5115.588067] Oops: 0000 [#1] SMP 
[ 5115.588067] last sysfs file:
/sys/devices/virtual/block/loop0/removable

Entering kdb (current=0xf7868100, pid 15675) on processor 0 Oops: (null) due to oops @ 0xc07224fd
<d>Modules linked in:
<c>
<d>Pid: 15675, comm: mkfs.xfs Not tainted 2.6.35+ #305 /Bochs
<d>EIP: 0060:[<c07224fd>] EFLAGS: 00010002 CPU: 0
EIP is at radix_tree_range_tag_if_tagged+0x15d/0x1c0
<d>EAX: f7f14000 EBX: 00000000 ECX: 482bb4f8 EDX: 0c0748d4
<d>ESI: 2031756d EDI: 00000000 EBP: c7d41d10 ESP: c7d41cb0
<d> DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
<0>Process mkfs.xfs (pid: 15675, ti=c7d40000 task=f7868100
task.ti=c7d40000)
<0>Stack: ffffffff f774a1d8 f774a598 f774aa98 cfd9c598 e7c89458 00000001 00000000
<0> c01e0caf c01e0caf 00000046 00000010 00000000 e7c89568 c7d41d28 c355ad50
<0> ffffffff 00000208 00000007 c7d41cb0 00000003 ffffffff c355ad5c ffffffff
<0>Call Trace:
<0> [<c01e0caf>] ? tag_pages_for_writeback+0x1f/0xc0
<0> [<c01e0caf>] ? tag_pages_for_writeback+0x1f/0xc0
<0> [<c01e0cd3>] ? tag_pages_for_writeback+0x43/0xc0
<0> [<c01e172b>] ? write_cache_pages+0x23b/0x370
<0> [<c01e0980>] ? __writepage+0x0/0x30
<0> [<c0528979>] ? xfs_vm_writepages+0x29/0x50
[0]more> 
Only 'q' or 'Q' are processed at more prompt, input ignored
<0> [<c0528979>] ? xfs_vm_writepages+0x29/0x50
<0> [<c05296e0>] ? xfs_vm_writepage+0x0/0x630
<0> [<c01e187f>] ? generic_writepages+0x1f/0x30
<0> [<c0528992>] ? xfs_vm_writepages+0x42/0x50
<0> [<c01e18a7>] ? do_writepages+0x17/0x30
<0> [<c01da57c>] ? __filemap_fdatawrite_range+0x5c/0x70
<0> [<c01da8a6>] ? filemap_fdatawrite+0x26/0x30
<0> [<c01da8dd>] ? filemap_write_and_wait+0x2d/0x50
<0> [<c052e812>] ? xfs_flushinval_pages+0x72/0xe0
<0> [<c0506c9c>] ? xfs_ilock+0x7c/0xd0
<0> [<c052d7d7>] ? xfs_file_aio_read+0x307/0x340
<0> [<c020e69c>] ? do_sync_read+0x9c/0xd0
<0> [<c0189636>] ? up_read+0x16/0x30
<0> [<c020e957>] ? vfs_read+0x97/0x140
<0> [<c020e600>] ? do_sync_read+0x0/0xd0
<0> [<c0181c18>] ? __task_pid_nr_ns+0x88/0xd0
<0> [<c020f1c3>] ? sys_pread64+0x63/0x80
<0> [<c09cb7ed>] ? syscall_call+0x7/0xb
<0>Code: f0 83 c3 01 d3 e3 39 5d e0 72 51 8b 45 08 39 45 e4 73 49 89 d8
d3 e8 a8 3f 0f 85 47 ff ff ff 8b 75 ec 8d 04 96 90 83 c1 06 89 df <8b>
30 d3 ef 83 c2 01 83 c0 04 83 e7 3f 74 ec e9 27 ff ff ff 8b 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
