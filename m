Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 7E89D6B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 20:43:03 -0400 (EDT)
Date: Wed, 17 Oct 2012 02:43:00 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Fix XFS oops due to dirty pages without buffers on
 s390
Message-ID: <20121017004300.GH13227@quack.suse.cz>
References: <1349108796-32161-1-git-send-email-jack@suse.cz>
 <alpine.LSU.2.00.1210082029190.2237@eggly.anvils>
 <20121009162107.GE15790@quack.suse.cz>
 <alpine.LSU.2.00.1210091824390.30802@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1210091824390.30802@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, xfs@oss.sgi.com, Martin Schwidefsky <schwidefsky@de.ibm.com>, Mel Gorman <mgorman@suse.de>, linux-s390@vger.kernel.org

On Tue 09-10-12 19:19:09, Hugh Dickins wrote:
> On Tue, 9 Oct 2012, Jan Kara wrote:
<snip a lot>
> > > But here's where I think the problem is.  You're assuming that all
> > > filesystems go the same mapping_cap_account_writeback_dirty() (yeah,
> > > there's no such function, just a confusing maze of three) route as XFS.
> > > 
> > > But filesystems like tmpfs and ramfs (perhaps they're the only two
> > > that matter here) don't participate in that, and wait for an mmap'ed
> > > page to be seen modified by the user (usually via pte_dirty, but that's
> > > a no-op on s390) before page is marked dirty; and page reclaim throws
> > > away undirtied pages.
> >   I admit I haven't thought of tmpfs and similar. After some discussion Mel
> > pointed me to the code in mmap which makes a difference. So if I get it
> > right, the difference which causes us problems is that on tmpfs we map the
> > page writeably even during read-only fault. OK, then if I make the above
> > code in page_remove_rmap():
> > 	if ((PageSwapCache(page) ||
> > 	     (!anon && !mapping_cap_account_dirty(page->mapping))) &&
> > 	    page_test_and_clear_dirty(page_to_pfn(page), 1))
> > 		set_page_dirty(page);
> > 
> >   Things should be ok (modulo the ugliness of this condition), right?
> 
> (Setting aside my reservations above...) That's almost exactly right, but
> I think the issue of a racing truncation (which could reset page->mapping
> to NULL at any moment) means we have to be a bit more careful.  Usually
> we guard against that with page lock, but here we can rely on mapcount.
> 
> page_mapping(page), with its built-in PageSwapCache check, actually ends
> up making the condition look less ugly; and so far as I could tell,
> the extra code does get optimized out on x86 (unless CONFIG_DEBUG_VM,
> when we are left with its VM_BUG_ON(PageSlab(page))).
> 
> But please look this over very critically and test (and if you like it,
> please adopt it as your own): I'm not entirely convinced yet myself.
  Just to followup on this. The new version of the patch runs fine for
several days on our s390 build machines. I was also running fsx-linux on
tmpfs while pushing the machine to swap. fsx ran fine but I hit
WARN_ON(delalloc) in xfs_vm_releasepage(). The exact stack trace is:
 [<000003c008edb38e>] xfs_vm_releasepage+0xc6/0xd4 [xfs]
 [<0000000000213326>] shrink_page_list+0x6ba/0x734
 [<0000000000213924>] shrink_inactive_list+0x230/0x578
 [<0000000000214148>] shrink_list+0x6c/0x120
 [<00000000002143ee>] shrink_zone+0x1f2/0x238
 [<0000000000215482>] balance_pgdat+0x5f6/0x86c
 [<00000000002158b8>] kswapd+0x1c0/0x248
 [<000000000017642a>] kthread+0xa6/0xb0
 [<00000000004e58be>] kernel_thread_starter+0x6/0xc
 [<00000000004e58b8>] kernel_thread_starter+0x0/0xc

I don't think it is really related but I'll hold off the patch for a while
to investigate what's going on...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
