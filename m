Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 269666B004F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 09:50:53 -0400 (EDT)
Date: Wed, 5 Aug 2009 15:50:57 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [16/19] HWPOISON: Enable .remove_error_page for
	migration aware file systems
Message-ID: <20090805135056.GI11385@basil.fritz.box>
References: <200908051136.682859934@firstfloor.org> <20090805093643.E0C00B15D8@basil.firstfloor.org> <20090805111231.GA19532@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090805111231.GA19532@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Andi Kleen <andi@firstfloor.org>, tytso@mit.edu, mfasheh@suse.com, aia21@cantab.net, hugh.dickins@tiscali.co.uk, swhiteho@redhat.com, akpm@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, hidehiro.kawai.ez@hitachi.com
List-ID: <linux-mm.kvack.org>

On Wed, Aug 05, 2009 at 07:12:31AM -0400, Christoph Hellwig wrote:
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

Thanks for the review.

It just calls the lower end of the truncate path.

http://git.kernel.org/?p=linux/kernel/git/ak/linux-mce-2.6.git;a=commitdiff;h=b5d3322870b0f6e369809674d2c73857fd6ef480

and

http://git.kernel.org/?p=linux/kernel/git/ak/linux-mce-2.6.git;a=commitdiff;h=4c2df4fa9e4687bde815883fabc602ccc5961272

Is that ok? It should be roughly the same as normal truncate does,
except it doesn't take i_mutex currently.

We're careful to not do it for non regular inodes.

> 
> Is there any way for us to test this functionality without introducing
> real hardware problems?

Yes, there are three different injectors to chose from :)

The easiest one is usually the madvise(MADV_POISON) injector.

Just map a suitable page and

There's a test program in 

http://git.kernel.org/?p=utils/cpu/mce/mce-test.git;a=blob;f=tsrc/tinjpage.c;h=954e1edab765d1c141f693ae9767ba9d5491c1aa;hb=HEAD

that can be extended for new tests.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
