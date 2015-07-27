Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 91EC56B0253
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 17:13:47 -0400 (EDT)
Received: by igbpg9 with SMTP id pg9so110304493igb.0
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 14:13:47 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id g84si16462134ioi.123.2015.07.27.14.13.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jul 2015 14:13:47 -0700 (PDT)
Received: by pachj5 with SMTP id hj5so57171303pac.3
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 14:13:46 -0700 (PDT)
Date: Mon, 27 Jul 2015 14:12:54 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2] ipc: Use private shmem or hugetlbfs inodes for shm
 segments.
In-Reply-To: <55B69D67.4070002@tycho.nsa.gov>
Message-ID: <alpine.LSU.2.11.1507271411270.2122@eggly.anvils>
References: <1437741275-5388-1-git-send-email-sds@tycho.nsa.gov> <alpine.LSU.2.11.1507271212180.1028@eggly.anvils> <55B69D67.4070002@tycho.nsa.gov>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Smalley <sds@tycho.nsa.gov>
Cc: Hugh Dickins <hughd@google.com>, prarit@redhat.com, david@fromorbit.com, mstevens@fedoraproject.org, manfred@colorfullife.com, esandeen@redhat.com, wagi@monom.org, linux-kernel@vger.kernel.org, eparis@redhat.com, linux-mm@kvack.org, linux-security-module@vger.kernel.org, dave@stgolabs.net, nyc@holomorphy.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, selinux@tycho.nsa.gov

On Mon, 27 Jul 2015, Stephen Smalley wrote:
> On 07/27/2015 03:32 PM, Hugh Dickins wrote:
> > On Fri, 24 Jul 2015, Stephen Smalley wrote:
> >> --- a/fs/hugetlbfs/inode.c
> >> +++ b/fs/hugetlbfs/inode.c
> >> @@ -1010,6 +1010,8 @@ struct file *hugetlb_file_setup(const char *name, size_t size,
> >>  	inode = hugetlbfs_get_inode(sb, NULL, S_IFREG | S_IRWXUGO, 0);
> >>  	if (!inode)
> >>  		goto out_dentry;
> >> +	if (creat_flags == HUGETLB_SHMFS_INODE)
> >> +		inode->i_flags |= S_PRIVATE;
> > 
> > I wonder if you would do better just to set S_PRIVATE unconditionally
> > there.
> > 
> > hugetlb_file_setup() has two callsites, neither of which exposes an fd.
> > One of them is shm.c's newseg(), which is getting us into the lockdep
> > trouble that you're fixing here.
> > 
> > The other is mmap.c's mmap_pgoff().  Now I don't think that will ever
> > get into lockdep trouble (no mutex or rwsem has been taken at that
> > point), but might your change above introduce (perhaps now or perhaps
> > in future) an inconsistency between how SElinux checks are applied to
> > a SHM area, and how they are applied to a MAP_ANONYMOUS|MAP_HUGETLB
> > area, and how they are applied to a straight MAP_ANONYMOUS area?
> > 
> > I think your patch as it stands brings SHM into line with
> > MAP_ANONYMOUS, but leaves MAP_ANONYMOUS|MAP_HUGETLB going the old way.
> > Perhaps an anomaly would appear when mprotect() is used?
> > 
> > It's up to you: I think your patch is okay as is,
> > but I just wonder if it has a surprise in store for the future.
> 
> That sounds reasonable, although there is the concern that
> hugetlb_file_setup() might be used in the future for files that are
> exposed as fds, unless we rename it to hugetlb_kernel_file_setup() or

Good idea.

> similar to match shmem_kernel_file_setup().  Also should probably be
> done as a separate change on top since it isn't directly related to
> ipc/shm or fixing this lockdep.

Fair enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
