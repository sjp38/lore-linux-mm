Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DFE1C620089
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 15:46:02 -0400 (EDT)
Date: Tue, 15 Jun 2010 15:44:27 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
 and use a_ops->writepages() where possible
Message-ID: <20100615194427.GL27466@think>
References: <20100615142219.GE28052@random.random>
 <20100615144342.GA3339@infradead.org>
 <20100615150850.GF28052@random.random>
 <20100615152526.GA3468@infradead.org>
 <20100615154516.GG28052@random.random>
 <20100615162600.GA9910@infradead.org>
 <4C17AF2D.2060904@redhat.com>
 <20100615165423.GA16868@infradead.org>
 <4C17D0C5.9030203@redhat.com>
 <20100615191716.GA6778@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100615191716.GA6778@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 03:17:16PM -0400, Christoph Hellwig wrote:
> On Tue, Jun 15, 2010 at 03:13:09PM -0400, Rik van Riel wrote:
> > Why?   How about because you know the stack is not big enough
> > to have the XFS call path on it twice? :)
> > 
> > Isn't the whole purpose of this patch series to prevent writepage
> > from being called by the VM, when invoked from a deep callstack
> > like xfs writepage?
> 
> It's not invoked from xfs writepage, but from xfs_file_aio_write via
> generic_file_buffered_write.  Which isn't actually an all that deep
> callstack, just en example of one that's alread bad enough to overflow
> the stack.

Keep in mind that both ext4 and btrfs have similar checks in their
writepage path.  I think Dave Chinner's stack analysis we very clear
here, there's no room in the stack for any filesystem and direct reclaim
to live happily together.

Circling back to an older thread:

> 32)     3184      64   xfs_vm_writepage+0xab/0x160 [xfs]
> 33)     3120     384   shrink_page_list+0x65e/0x840
> 34)     2736     528   shrink_zone+0x63f/0xe10
> 35)     2208     112   do_try_to_free_pages+0xc2/0x3c0
> 36)     2096     128   try_to_free_pages+0x77/0x80
> 37)     1968     240   __alloc_pages_nodemask+0x3e4/0x710
> 35)     2208     112   do_try_to_free_pages+0xc2/0x3c0
> 36)     2096     128   try_to_free_pages+0x77/0x80
> 37)     1968     240   __alloc_pages_nodemask+0x3e4/0x710
> 38)     1728      48   alloc_pages_current+0x8c/0xe0
> 39)     1680      16   __get_free_pages+0xe/0x50
> 40)     1664      48   __pollwait+0xca/0x110
> 41)     1616      32   unix_poll+0x28/0xc0
> 42)     1584      16   sock_poll+0x1d/0x20
> 43)     1568     912   do_select+0x3d6/0x700
> 44)      656     416   core_sys_select+0x18c/0x2c0
> 45)      240     112   sys_select+0x4f/0x110
> 46)      128     128   system_call_fastpath+0x16/0x1b

So, before xfs can hand this work off to one of its 16 btrees, push
it through the hand tuned irix simulator or even think about spreading
the work across 512 cpus (whoops, I guess that's just btrfs), we've used
up quite a lot of the stack.

I'm not against direct reclaim, but I think we have to admit that it has
to be done directly with another stack context.  Handoff to a different
thread, whatever.

When the reclaim does happen, it would be really nice if ios were done
in large-ish clusters.  Small ios reclaim less memory in more time and
slow everything down.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
