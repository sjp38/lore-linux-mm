Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E1F946B004F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 08:17:00 -0400 (EDT)
Date: Wed, 5 Aug 2009 19:52:42 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [16/19] HWPOISON: Enable .remove_error_page for
	migration aware file systems
Message-ID: <20090805115242.GB6737@localhost>
References: <200908051136.682859934@firstfloor.org> <20090805093643.E0C00B15D8@basil.firstfloor.org> <20090805111231.GA19532@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090805111231.GA19532@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Andi Kleen <andi@firstfloor.org>, "tytso@mit.edu" <tytso@mit.edu>, "mfasheh@suse.com" <mfasheh@suse.com>, "aia21@cantab.net" <aia21@cantab.net>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "swhiteho@redhat.com" <swhiteho@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "npiggin@suse.de" <npiggin@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hidehiro.kawai.ez@hitachi.com" <hidehiro.kawai.ez@hitachi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 05, 2009 at 07:12:31PM +0800, Christoph Hellwig wrote:
> On Wed, Aug 05, 2009 at 11:36:43AM +0200, Andi Kleen wrote:
> > 
> > Enable removing of corrupted pages through truncation
> > for a bunch of file systems: ext*, xfs, gfs2, ocfs2, ntfs
> > These should cover most server needs.
> > 
> > I chose the set of migration aware file systems for this
> > for now, assuming they have been especially audited.
> > But in general it should be safe for all file systems
> > on the data area that support read/write and truncate.
> > 
> > Caveat: the hardware error handler does not take i_mutex
> > for now before calling the truncate function. Is that ok?
> 
> It will probably need locking, e.g. the iolock in XFS.  I'll
> need to take a look at the actual implementation of
> generic_error_remove_page to make sense of this.

In patch 13, it simply calls truncate_inode_page() for S_ISREG inodes.

Nick suggests call truncate_inode_page() with i_mutex. Sure we can
do mutex_trylock(i_mutex), but we'd appreciate it if some fs gurus
can demonstrate some bad consequences of not doing so, thanks!

> Is there any way for us to test this functionality without introducing
> real hardware problems?

We have some additional patches (ugly but works for now) that export
interfaces for injecting hwpoison to selected types pages. It can
guarantee only data/metadata pages of selected fs will be poisoned.
Based on which we can do all kinds of stress testing in user space.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
