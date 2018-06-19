Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CCA166B000A
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 23:13:00 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s7-v6so9588141pfm.4
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 20:13:00 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id b83-v6si16609661pfk.342.2018.06.18.20.12.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 20:12:59 -0700 (PDT)
Date: Mon, 18 Jun 2018 21:12:57 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v14 00/74] Convert page cache to XArray
Message-ID: <20180619031257.GA12527@linux.intel.com>
References: <20180617020052.4759-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180617020052.4759-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

On Sat, Jun 16, 2018 at 06:59:38PM -0700, Matthew Wilcox wrote:
> The XArray is a replacement for the radix tree.  For the moment it uses
> the same data structures, enabling a gradual replacement.  This patch
> set implements the XArray and converts the page cache to use it.
> 
> A version of these patches has been running under xfstests for over
> 48 hours, so I have some confidence in them.  The DAX changes have now
> also had a reasonable test outing.  This is based on next-20180615 and
> is available as a git tree at
> git://git.infradead.org/users/willy/linux-dax.git xarray-20180615
> 
> I shall create a git branch from -rc1 and ask for that to be included in
> -next.  I'm a little concerned I still have no reviews on some of the
> later patches.
> 
> Changes since v13:
>  - Actually fixed bug in workingset conversion that led to exceptional
>    entries not being deleted from the XArray.  Not sure how I dropped
>    that patch for v13.  Thanks to David Sterba for noticing.
>  - Fixed bug in DAX writeback conversion that failed to wake up waiters.
>    Thanks to Ross for testing, and to Dan & Jeff for helping me get a
>    setup working to reproduce the problem.
>  - Converted the new dax_lock_page / dax_unlock_page functions.
>  - Moved XArray test suite entirely into the test_xarray kernel module
>    to match other test suites.  It can still be built in userspace as
>    part of the radix tree test suite.
>  - Changed email address.
>  - Moved a few functions into different patches to make the test-suite
>    additions more logical.
>  - Fixed a bug in XA_BUG_ON (oh the irony) where it evaluated the
>    condition twice.
>  - Constified xa_head() / xa_parent() / xa_entry() and their _locked
>    variants.
>  - Moved xa_parent() to xarray.h so it can be used from the workingset code.
>  - Call the xarray testsuite from the radix tree test suite to ensure
>    that I remember to run both test suites ;-)
>  - Added some more tests to the test suite.

Hit another deadlock.  This one reproduces 100% of the time in my setup with
XFS + DAX + generic/340.  It doesn't reproduce for me at all with
next-20180615.  Here's the output from "echo w > /proc/sysrq-trigger":

[   92.849119] sysrq: SysRq : Show Blocked State
[   92.850506]   task                        PC stack   pid father
[   92.852299] holetest        D    0  1651   1466 0x00000000
[   92.853912] Call Trace:
[   92.854610]  __schedule+0x2c5/0xad0
[   92.855612]  schedule+0x36/0x90
[   92.856602]  get_unlocked_entry+0xce/0x120
[   92.857756]  ? dax_insert_entry+0x2b0/0x2b0
[   92.858931]  grab_mapping_entry+0x19e/0x250
[   92.860119]  dax_iomap_pte_fault+0x115/0x1140
[   92.860836]  dax_iomap_fault+0x37/0x40
[   92.861235]  __xfs_filemap_fault+0x2de/0x310
[   92.861681]  xfs_filemap_fault+0x2c/0x30
[   92.862113]  __do_fault+0x26/0x160
[   92.862531]  __handle_mm_fault+0xc96/0x1320
[   92.863059]  handle_mm_fault+0x1ba/0x3c0
[   92.863534]  __do_page_fault+0x2b4/0x590
[   92.864029]  do_page_fault+0x38/0x2c0
[   92.864472]  do_async_page_fault+0x2c/0xb0
[   92.864985]  ? async_page_fault+0x8/0x30
[   92.865459]  async_page_fault+0x1e/0x30
[   92.865941] RIP: 0033:0x401442
[   92.866322] Code: Bad RIP value.
[   92.866739] RSP: 002b:00007fa29c9feec0 EFLAGS: 00010212
[   92.867366] RAX: 00007fa29ca00400 RBX: 0000000000001000 RCX: 0000000000008000
[   92.868219] RDX: 0000000000000009 RSI: 0000000000000000 RDI: 0000000000000000
[   92.869082] RBP: 00007fa29c9ff700 R08: 00007fa29c9ff700 R09: 00007fa29c9ff700
[   92.869939] R10: 0000000000000070 R11: 00007fa29e571ba0 R12: 00007fa29ca00000
[   92.870804] R13: 00007fffd5f24160 R14: 0000000000000400 R15: 00007fffd5f240b0

This looks very similar to the one I reported last week with generic/269.

- Ross
