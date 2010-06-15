Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B650A620089
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 12:56:12 -0400 (EDT)
Date: Wed, 16 Jun 2010 02:54:34 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
 and use a_ops->writepages() where possible
Message-ID: <20100615165434.GQ6138@laptop>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
 <20100615140011.GD28052@random.random>
 <20100615141122.GA27893@infradead.org>
 <20100615142219.GE28052@random.random>
 <20100615144342.GA3339@infradead.org>
 <20100615150850.GF28052@random.random>
 <20100615152526.GA3468@infradead.org>
 <20100615154516.GG28052@random.random>
 <20100615162600.GA9910@infradead.org>
 <4C17AF2D.2060904@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C17AF2D.2060904@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 12:49:49PM -0400, Rik van Riel wrote:
> On 06/15/2010 12:26 PM, Christoph Hellwig wrote:
> >On Tue, Jun 15, 2010 at 05:45:16PM +0200, Andrea Arcangeli wrote:
> >[21877.951204]  [<ffffffffa009bde4>] xfs_vm_writepage+0x84/0x160 [xfs]
> >[21877.951301]  [<ffffffff800e3603>] pageout+0x143/0x2b0
> >[21877.951308]  [<ffffffff800e514e>] shrink_page_list+0x26e/0x650
> >[21877.951314]  [<ffffffff800e5803>] shrink_inactive_list+0x2d3/0x7c0
> >[21877.951320]  [<ffffffff800e5d4b>] shrink_list+0x5b/0x110
> >[21877.951325]  [<ffffffff800e5f71>] shrink_zone+0x171/0x250
> >[21877.951330]  [<ffffffff800e60d3>] shrink_zones+0x83/0x120
> >[21877.951336]  [<ffffffff800e620e>] do_try_to_free_pages+0x9e/0x380
> >[21877.951342]  [<ffffffff800e6607>] try_to_free_pages+0x77/0xa0
> >[21877.951349]  [<ffffffff800dbfa3>] __alloc_pages_slowpath+0x2d3/0x5c0
> >[21877.951355]  [<ffffffff800dc3e1>] __alloc_pages_nodemask+0x151/0x160
> >[21877.951362]  [<ffffffff800d44b7>] __page_cache_alloc+0x27/0x50
> >[21877.951368]  [<ffffffff800d68ca>] grab_cache_page_write_begin+0x9a/0xe0
> >[21877.951376]  [<ffffffff8014bdfe>] block_write_begin+0xae/0x120
> >[21877.951396]  [<ffffffffa009ac24>] xfs_vm_write_begin+0x34/0x50 [xfs]
> 
> This is already in a filesystem.  Why does ->writepage get
> called a second time?  Shouldn't this have a gfp_mask
> without __GFP_FS set?

No, we're allowed to use __GFP_FS with i_mutex held.

> 
> >[21877.951482]  [<ffffffff800d4b31>] generic_perform_write+0xc1/0x1f0
> >[21877.951489]  [<ffffffff800d5d00>] generic_file_buffered_write+0x90/0x160
> >[21877.951512]  [<ffffffffa00a4711>] xfs_write+0x521/0xb60 [xfs]
> >[21877.951624]  [<ffffffffa009fb80>] xfs_file_aio_write+0x70/0xa0 [xfs]
> >[21877.951711]  [<ffffffff80118c42>] do_sync_write+0x102/0x160
> >[21877.951718]  [<ffffffff80118fc8>] vfs_write+0xd8/0x1c0
> >[21877.951723]  [<ffffffff8011995b>] sys_write+0x5b/0xa0
> >[21877.951729]  [<ffffffff8000c868>] system_call_fastpath+0x16/0x1b
> >[21877.951736]  [<00007fc41b0fab10>] 0x7fc41b0fab10
> >[21877.951750] BUG: unable to handle kernel paging request at 0000000108743280
> >[21877.951755] IP: [<ffffffff80034832>] dequeue_task+0x72/0x110
> >[21877.951766] PGD 31c6f067 PUD 0
> >[21877.951770] Thread overran stack, or stack corrupted
> >
> 
> 
> -- 
> All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
