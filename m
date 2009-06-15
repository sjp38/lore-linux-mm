Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 822176B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 06:35:18 -0400 (EDT)
Date: Mon, 15 Jun 2009 12:36:19 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 00/22] HWPOISON: Intro (v5)
Message-ID: <20090615103619.GC20461@wotan.suse.de>
References: <20090615024520.786814520@intel.com> <4A35BD7A.9070208@linux.vnet.ibm.com> <20090615042753.GA20788@localhost> <20090615064447.GA18390@wotan.suse.de> <20090615081453.GC8665@wotan.suse.de> <20090615100954.GA7099@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090615100954.GA7099@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 15, 2009 at 06:09:54PM +0800, Wu Fengguang wrote:
> On Mon, Jun 15, 2009 at 04:14:53PM +0800, Nick Piggin wrote:
> > On Mon, Jun 15, 2009 at 08:44:47AM +0200, Nick Piggin wrote:
> > > Did we verify with filesystem maintainers (eg. btrfs) that the
> > > !ISREG test will be enough to prevent oopses?
> > 
> > BTW. this is quite a significant change I think and not
> > really documented well enough. Previously a filesystem
> > will know exactly when and why pagecache in a mapping
> > under its control will be truncated (as opposed to
> > invalidated).
> > 
> > They even have opportunity to hold locks such as i_mutex.
> > 
> > And depending on what they do, they could do interesting
> > things even with ISREG files.
> > 
> > So, I really think this needs review by filesystem
> > maintainers and it would be far safer to use invalidate
> > until it is known to be safe.
> 
> Nick, we are doing invalidate_complete_page() for !S_ISREG inodes now.
> Do you mean to do invalidate_complete_page() for all inodes for now?

That would make me a lot happier. It is obviously correct because
that is basically what page reclaim and inode reclaim and drop
caches etc does.

Note that I still don't like exporting invalidate_complete_page
fro the same reasons I don't like exporting truncate_complete_page,
so I will ask if you can do an invalidate_inode_page function
along the same lines of the truncate_inode_page one please.


> That's a good suggestion, it shall be able to do the job for most
> pages indeed.

Yes I think it will be far far safer while only introducing
another small class of pages which cannot be recovered (probably
a much smaller set most of the time than the size of the existing
set of pages which cannot be recovered).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
