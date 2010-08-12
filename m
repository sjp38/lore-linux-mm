Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 852EC6B02A5
	for <linux-mm@kvack.org>; Thu, 12 Aug 2010 18:29:39 -0400 (EDT)
Date: Fri, 13 Aug 2010 00:28:58 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/2] mm: Implement writeback livelock avoidance using
 page tagging
Message-ID: <20100812222857.GC3665@quack.suse.cz>
References: <1275677231-15662-1-git-send-email-jack@suse.cz>
 <1275677231-15662-3-git-send-email-jack@suse.cz>
 <20100812183547.GA2294@infradead.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="k+w/mQv8wyuph6w0"
Content-Disposition: inline
In-Reply-To: <20100812183547.GA2294@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, npiggin@suse.de, david@fromorbit.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--k+w/mQv8wyuph6w0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu 12-08-10 14:35:47, Christoph Hellwig wrote:
> I have an oops with current Linus' tree in xfstests 217 that looks
> like it was caused by this patch:
  Thanks for report!

> 217 149s ...[ 5105.342605] XFS mounting filesystem vdb6
> [ 5105.373481] Ending clean XFS mount for filesystem: vdb6
> [ 5115.405061] XFS mounting filesystem loop0
> [ 5115.548654] Ending clean XFS mount for filesystem: loop0
> [ 5115.588067] BUG: unable to handle kernel paging request at f7f14000
> [ 5115.588067] IP: [<c07224fd>] radix_tree_range_tag_if_tagged+0x15d/0x1c0
> [ 5115.588067] *pde = 00007067 *pte = 00000000 
> [ 5115.588067] Oops: 0000 [#1] SMP 
> [ 5115.588067] last sysfs file:
> /sys/devices/virtual/block/loop0/removable
  We seem to oops at:
                while (((index >> shift) & RADIX_TREE_MAP_MASK) == 0) {
                        /*
                         * We've fully scanned this node. Go up. Because
                         * last_index is guaranteed to be in the tree, what
                         * we do below cannot wander astray.
                         */
>>>>>                   slot = open_slots[height];
                        height++;
                        shift += RADIX_TREE_MAP_SHIFT;
                }

> Entering kdb (current=0xf7868100, pid 15675) on processor 0 Oops: (null) due to oops @ 0xc07224fd
> <d>Modules linked in:
> <c>
> <d>Pid: 15675, comm: mkfs.xfs Not tainted 2.6.35+ #305 /Bochs
> <d>EIP: 0060:[<c07224fd>] EFLAGS: 00010002 CPU: 0
> EIP is at radix_tree_range_tag_if_tagged+0x15d/0x1c0
> <d>EAX: f7f14000 EBX: 00000000 ECX: 482bb4f8 EDX: 0c0748d4
> <d>ESI: 2031756d EDI: 00000000 EBP: c7d41d10 ESP: c7d41cb0
  And from the values in registers the loop seems to have went astray
because "index" was zero at the point we entered the loop... looking
around...  Ah, I see, you create files with 16TB size which creates
radix tree of such height that radix_tree_maxindex(height) == ~0UL and
if write_cache_pages() passes in ~0UL as end, we can overflow the index.
Hmm, I haven't realized that is possible.
  OK, attached is a patch that should fix the issue. There is just still an
issue that *first_indexp will overflow in this case as well and thus we
could in theory loop indefinitely. I'll have to think how to best handle
this overflow - checking in caller is kind of prone to errors...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--k+w/mQv8wyuph6w0
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-mm-Fix-overflow-in-radix_tree_range_tag_if_tagged.patch"


--k+w/mQv8wyuph6w0--
