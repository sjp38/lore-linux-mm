Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A8E40280300
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 18:15:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p69so8192089pfk.10
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 15:15:27 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id o10si3085649pgq.604.2017.08.29.15.15.25
        for <linux-mm@kvack.org>;
        Tue, 29 Aug 2017 15:15:26 -0700 (PDT)
Date: Wed, 30 Aug 2017 08:15:22 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v2 15/30] xfs: Define usercopy region in xfs_inode slab
 cache
Message-ID: <20170829221522.GE10621@dastard>
References: <1503956111-36652-1-git-send-email-keescook@chromium.org>
 <1503956111-36652-16-git-send-email-keescook@chromium.org>
 <20170828214957.GJ4757@magnolia>
 <CAGXu5j+pvxRjASUuBE49+uH34Mw26a4mtcWrZd=CEqcRHjetvA@mail.gmail.com>
 <20170829044707.GP4757@magnolia>
 <CAGXu5jJX1DA9D1LtrKkNoBXKZEYhbSE148YmUOP=WXsBCFsCyw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jJX1DA9D1LtrKkNoBXKZEYhbSE148YmUOP=WXsBCFsCyw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, LKML <linux-kernel@vger.kernel.org>, David Windsor <dave@nullcore.net>, linux-xfs@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Tue, Aug 29, 2017 at 11:48:49AM -0700, Kees Cook wrote:
> On Mon, Aug 28, 2017 at 9:47 PM, Darrick J. Wong
> <darrick.wong@oracle.com> wrote:
> > On Mon, Aug 28, 2017 at 02:57:14PM -0700, Kees Cook wrote:
> >> On Mon, Aug 28, 2017 at 2:49 PM, Darrick J. Wong
> >> <darrick.wong@oracle.com> wrote:
> >> > On Mon, Aug 28, 2017 at 02:34:56PM -0700, Kees Cook wrote:
> >> >> From: David Windsor <dave@nullcore.net>
> >> >>
> >> >> The XFS inline inode data, stored in struct xfs_inode_t field
> >> >> i_df.if_u2.if_inline_data and therefore contained in the xfs_inode slab
> >> >> cache, needs to be copied to/from userspace.
> >> >>
> >> >> cache object allocation:
> >> >>     fs/xfs/xfs_icache.c:
> >> >>         xfs_inode_alloc(...):
> >> >>             ...
> >> >>             ip = kmem_zone_alloc(xfs_inode_zone, KM_SLEEP);
> >> >>
> >> >>     fs/xfs/libxfs/xfs_inode_fork.c:
> >> >>         xfs_init_local_fork(...):
> >> >>             ...
> >> >>             if (mem_size <= sizeof(ifp->if_u2.if_inline_data))
> >> >>                     ifp->if_u1.if_data = ifp->if_u2.if_inline_data;
> >> >
> >> > Hmm, what happens when mem_size > sizeof(if_inline_data)?  A slab object
> >> > will be allocated for ifp->if_u1.if_data which can then be used for
> >> > readlink in the same manner as the example usage trace below.  Does
> >> > that allocated object have a need for a usercopy annotation like
> >> > the one we're adding for if_inline_data?  Or is that already covered
> >> > elsewhere?
> >>
> >> Yeah, the xfs helper kmem_alloc() is used in the other case, which
> >> ultimately boils down to a call to kmalloc(), which is entirely
> >> whitelisted by an earlier patch in the series:
> >>
> >> https://lkml.org/lkml/2017/8/28/1026
> >
> > Ah.  It would've been helpful to have the first three patches cc'd to
> > the xfs list.  So basically this series establishes the ability to set
> 
> I went back and forth on that, and given all the things it touched, it
> seemed like too large a CC list. :) I can explicitly add the xfs list
> to the first three for any future versions.

If you are touching multiple filesystems, you really should cc the
entire patchset to linux-fsdevel, similar to how you sent the entire
patchset to lkml. That way the entire series will end up on a list
that almost all fs developers read. LKML is not a list you can rely
on all filesystem developers reading (or developers in any other
subsystem, for that matter)...

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
