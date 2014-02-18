Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id C7C4B6B0035
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 13:53:39 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id um1so17211322pbc.33
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 10:53:39 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id gz8si19188467pac.114.2014.02.18.10.53.26
        for <linux-mm@kvack.org>;
        Tue, 18 Feb 2014 10:53:34 -0800 (PST)
Date: Tue, 18 Feb 2014 13:53:23 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [RFC, PATCHv2 0/2] mm: map few pages around fault address if
 they are in page cache
Message-ID: <20140218185323.GB5744@linux.intel.com>
References: <1392662333-25470-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CA+55aFwz+36NOk=uanDvii7zn46-s1kpMT1Lt=C0hhhn9v6w-Q@mail.gmail.com>
 <53035FE2.4080300@redhat.com>
 <100D68C7BA14664A8938383216E40DE04062DEA1@FMSMSX114.amr.corp.intel.com>
 <CA+55aFzqZ2S==NyWG67hNV1YsY-oXLjLvCR0JeiHGJOfnoGJBg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzqZ2S==NyWG67hNV1YsY-oXLjLvCR0JeiHGJOfnoGJBg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Feb 18, 2014 at 10:02:26AM -0800, Linus Torvalds wrote:
> On Tue, Feb 18, 2014 at 6:15 AM, Wilcox, Matthew R
> <matthew.r.wilcox@intel.com> wrote:
> > We don't really need to lock all the pages being returned to protect
> > against truncate.  We only need to lock the one at the highest index,
> > and check i_size while that lock is held since truncate_inode_pages_range()
> > will block on any page that is locked.
> >
> > We're still vulnerable to holepunches, but there's no locking currently
> > between holepunches and truncate, so we're no worse off now.
> 
> It's not "holepunches and truncate", it's "holepunches and page
> mapping", and I do think we currently serialize the two - the whole
> "check page->mapping still being non-NULL" before mapping it while
> having the page locked does that.

Yes, I did mean "holepunches and page faults".  But here's the race I see:

Process A			Process B
ext4_fallocate()
ext4_punch_hole()
filemap_write_and_wait_range()
mutex_lock(&inode->i_mutex);
truncate_pagecache_range()
unmap_mapping_range()
				__do_fault()
				filemap_fault()
				lock_page_or_retry()
				(page->mapping == mapping at this point)
				set_pte_at()
				unlock_page()
truncate_inode_pages_range()
(now the pte is pointing at a page that
 is no longer attached to this file)
mutex_unlock(&inode->i_mutex);

Would we solve the problem by putting in a second call to
unmap_mapping_range() after calling truncate_inode_pages_range() in
truncate_pagecache_range(), like truncate_pagecache() does?

> Besides, that per-page locking should serialize against truncate too.
> No, there is no "global" serialization, but there *is* exactly that
> page-level serialization where both truncation and hole punching end
> up making sure that the page no longer exists in the page cache and
> isn't mapped.

What I'm suggesting is going back to Kirill's earlier patch, but only
locking the page with the highest index instead of all of the pages.
truncate() will block on that page and then we'll notice that some or
all of the other pages are also now past i_size and give up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
