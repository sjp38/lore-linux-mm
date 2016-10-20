Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id ED5D06B0038
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 06:39:50 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id b81so1461129lfe.1
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 03:39:50 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id p188si200089lfp.264.2016.10.20.03.39.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 03:39:49 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id b75so6866553lfg.3
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 03:39:48 -0700 (PDT)
Date: Thu, 20 Oct 2016 13:39:46 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] shmem: avoid huge pages for small files
Message-ID: <20161020103946.GA3881@node.shutemov.name>
References: <20161017121809.189039-1-kirill.shutemov@linux.intel.com>
 <20161017123021.rlyz44dsf4l4xnve@black.fi.intel.com>
 <20161017141245.GC27459@dhcp22.suse.cz>
 <20161017145539.GA26930@node.shutemov.name>
 <20161018142007.GL12092@dhcp22.suse.cz>
 <20161018143207.GA5833@node.shutemov.name>
 <20161018183023.GC27792@dhcp22.suse.cz>
 <alpine.LSU.2.11.1610191101250.10318@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1610191101250.10318@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Oct 19, 2016 at 11:13:54AM -0700, Hugh Dickins wrote:
> On Tue, 18 Oct 2016, Michal Hocko wrote:
> > On Tue 18-10-16 17:32:07, Kirill A. Shutemov wrote:
> > > On Tue, Oct 18, 2016 at 04:20:07PM +0200, Michal Hocko wrote:
> > > > On Mon 17-10-16 17:55:40, Kirill A. Shutemov wrote:
> > > > > On Mon, Oct 17, 2016 at 04:12:46PM +0200, Michal Hocko wrote:
> > > > > > On Mon 17-10-16 15:30:21, Kirill A. Shutemov wrote:
> > > > [...]
> > > > > > > We add two handle to specify minimal file size for huge pages:
> > > > > > > 
> > > > > > >   - mount option 'huge_min_size';
> > > > > > > 
> > > > > > >   - sysfs file /sys/kernel/mm/transparent_hugepage/shmem_min_size for
> > > > > > >     in-kernel tmpfs mountpoint;
> > > > > > 
> > > > > > Could you explain who might like to change the minimum value (other than
> > > > > > disable the feautre for the mount point) and for what reason?
> > > > > 
> > > > > Depending on how well CPU microarchitecture deals with huge pages, you
> > > > > might need to set it higher in order to balance out overhead with benefit
> > > > > of huge pages.
> > > > 
> > > > I am not sure this is a good argument. How do a user know and what will
> > > > help to make that decision? Why we cannot autotune that? In other words,
> > > > adding new knobs just in case turned out to be a bad idea in the past.
> > > 
> > > Well, I don't see a reasonable way to autotune it. We can just let
> > > arch-specific code to redefine it, but the argument below still stands.
> > > 
> > > > > In other case, if it's known in advance that specific mount would be
> > > > > populated with large files, you might want to set it to zero to get huge
> > > > > pages allocated from the beginning.
> > 
> > Do you think this is a sufficient reason to provide a tunable with such a
> > precision? In other words why cannot we simply start by using an
> > internal only limit at the huge page size for the initial transition
> > (with a way to disable THP altogether for a mount point) and only add a
> > more fine grained tunning if there ever is a real need for it with a use
> > case description. In other words can we be less optimistic about
> > tunables than we used to be in the past and often found out that those
> > were mistakes much later?
> 
> I'm not sure whether I'm arguing in the same or the opposite direction
> as you, Michal, but what makes me unhappy is not so much the tunable,
> as the proliferation of mount options.
> 
> Kirill, this issue is (not exactly but close enough) what the mount
> option "huge=within_size" was supposed to be about: not wasting huge
> pages on small files.  I'd be much happier if you made huge_min_size
> into a /sys/kernel/mm/transparent_hugepage/shmem_within_size tunable,
> and used it to govern "huge=within_size" mounts only.

Well, you're right that I tried originally address the issue with
huge=within_size, but this option makes much more sense for filesystem
with persistent storage. For ext4, it would be pretty usable option.

What you propose would change the semantics of the option and it will
diverge from how it works on ext4.

I guess it may have sense, taking into account that shmem/tmpfs is
special, in sense that we always start with empty filesystem.

If everybody agree, I'll respin the patch with single tunable that manage
all huge=within_size mounts.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
