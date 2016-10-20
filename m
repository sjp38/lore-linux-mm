Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB3726B0253
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 18:46:34 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n85so36849837pfi.7
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 15:46:34 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id v27si35975091pfj.204.2016.10.20.15.46.32
        for <linux-mm@kvack.org>;
        Thu, 20 Oct 2016 15:46:33 -0700 (PDT)
Date: Fri, 21 Oct 2016 09:46:30 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] shmem: avoid huge pages for small files
Message-ID: <20161020224630.GO23194@dastard>
References: <20161017121809.189039-1-kirill.shutemov@linux.intel.com>
 <20161017123021.rlyz44dsf4l4xnve@black.fi.intel.com>
 <20161017141245.GC27459@dhcp22.suse.cz>
 <20161017145539.GA26930@node.shutemov.name>
 <20161018142007.GL12092@dhcp22.suse.cz>
 <20161018143207.GA5833@node.shutemov.name>
 <20161018183023.GC27792@dhcp22.suse.cz>
 <alpine.LSU.2.11.1610191101250.10318@eggly.anvils>
 <20161020103946.GA3881@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161020103946.GA3881@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Oct 20, 2016 at 01:39:46PM +0300, Kirill A. Shutemov wrote:
> On Wed, Oct 19, 2016 at 11:13:54AM -0700, Hugh Dickins wrote:
> > On Tue, 18 Oct 2016, Michal Hocko wrote:
> > > On Tue 18-10-16 17:32:07, Kirill A. Shutemov wrote:
> > > > On Tue, Oct 18, 2016 at 04:20:07PM +0200, Michal Hocko wrote:
> > > > > On Mon 17-10-16 17:55:40, Kirill A. Shutemov wrote:
> > > > > > On Mon, Oct 17, 2016 at 04:12:46PM +0200, Michal Hocko wrote:
> > > > > > > On Mon 17-10-16 15:30:21, Kirill A. Shutemov wrote:
> > > > > [...]
> > > > > > > > We add two handle to specify minimal file size for huge pages:
> > > > > > > > 
> > > > > > > >   - mount option 'huge_min_size';
> > > > > > > > 
> > > > > > > >   - sysfs file /sys/kernel/mm/transparent_hugepage/shmem_min_size for
> > > > > > > >     in-kernel tmpfs mountpoint;
> > > > > > > 
> > > > > > > Could you explain who might like to change the minimum value (other than
> > > > > > > disable the feautre for the mount point) and for what reason?
> > > > > > 
> > > > > > Depending on how well CPU microarchitecture deals with huge pages, you
> > > > > > might need to set it higher in order to balance out overhead with benefit
> > > > > > of huge pages.
> > > > > 
> > > > > I am not sure this is a good argument. How do a user know and what will
> > > > > help to make that decision? Why we cannot autotune that? In other words,
> > > > > adding new knobs just in case turned out to be a bad idea in the past.
> > > > 
> > > > Well, I don't see a reasonable way to autotune it. We can just let
> > > > arch-specific code to redefine it, but the argument below still stands.
> > > > 
> > > > > > In other case, if it's known in advance that specific mount would be
> > > > > > populated with large files, you might want to set it to zero to get huge
> > > > > > pages allocated from the beginning.
> > > 
> > > Do you think this is a sufficient reason to provide a tunable with such a
> > > precision? In other words why cannot we simply start by using an
> > > internal only limit at the huge page size for the initial transition
> > > (with a way to disable THP altogether for a mount point) and only add a
> > > more fine grained tunning if there ever is a real need for it with a use
> > > case description. In other words can we be less optimistic about
> > > tunables than we used to be in the past and often found out that those
> > > were mistakes much later?
> > 
> > I'm not sure whether I'm arguing in the same or the opposite direction
> > as you, Michal, but what makes me unhappy is not so much the tunable,
> > as the proliferation of mount options.
> > 
> > Kirill, this issue is (not exactly but close enough) what the mount
> > option "huge=within_size" was supposed to be about: not wasting huge
> > pages on small files.  I'd be much happier if you made huge_min_size
> > into a /sys/kernel/mm/transparent_hugepage/shmem_within_size tunable,
> > and used it to govern "huge=within_size" mounts only.
> 
> Well, you're right that I tried originally address the issue with
> huge=within_size, but this option makes much more sense for filesystem
> with persistent storage. For ext4, it would be pretty usable option.

Ugh, no, please don't use mount options for file specific behaviours
in filesystems like ext4 and XFS. This is exactly the sort of
behaviour that should either just work automatically (i.e. be
completely controlled by the filesystem) or only be applied to files
specifically configured with persistent hints to reliably allocate
extents in a way that can be easily mapped to huge pages.

e.g. on XFS you will need to apply extent size hints to get large
page sized/aligned extent allocation to occur, and so this
persistent extent size hint should trigger the filesystem to use
large pages if supported, the hint is correctly sized and aligned,
and there are large pages available for allocation.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
