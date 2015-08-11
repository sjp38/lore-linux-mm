Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id D4A8C6B0038
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 08:03:49 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so57733168wic.0
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 05:03:49 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id bd2si3228228wjc.130.2015.08.11.05.03.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Aug 2015 05:03:48 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so173718071wic.1
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 05:03:47 -0700 (PDT)
Date: Tue, 11 Aug 2015 15:03:45 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH, RFC 2/2] dax: use range_lock instead of i_mmap_lock
Message-ID: <20150811120345.GA2245@node.dhcp.inet.fi>
References: <1439219664-88088-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439219664-88088-3-git-send-email-kirill.shutemov@linux.intel.com>
 <20150811081909.GD2650@quack.suse.cz>
 <20150811093708.GB906@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150811093708.GB906@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

On Tue, Aug 11, 2015 at 07:37:08PM +1000, Dave Chinner wrote:
> On Tue, Aug 11, 2015 at 10:19:09AM +0200, Jan Kara wrote:
> > On Mon 10-08-15 18:14:24, Kirill A. Shutemov wrote:
> > > As we don't have struct pages for DAX memory, Matthew had to find an
> > > replacement for lock_page() to avoid fault vs. truncate races.
> > > i_mmap_lock was used for that.
> > > 
> > > Recently, Matthew had to convert locking to exclusive to address fault
> > > vs. fault races. And this kills scalability completely.
> 
> I'm assuming this locking change is in a for-next git tree branch
> somewhere as there isn't anything that I can see in a 4.2-rc6
> tree. Can you point me to the git tree that has these changes in it?

It's in -mm tree. See e4261a3ed000 in mhocko/mm.git[1]. There are also two
fixups for that commit[2][3]

[1] git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
[2] http://lkml.kernel.org/g/1438948423-128882-1-git-send-email-kirill.shutemov@linux.intel.com
[3] http://lkml.kernel.org/g/1438948482-129043-1-git-send-email-kirill.shutemov@linux.intel.com

> > > The patch below tries to recover some scalability for DAX by introducing
> > > per-mapping range lock.
> > 
> > So this grows noticeably (3 longs if I'm right) struct address_space and
> > thus struct inode just for DAX. That looks like a waste but I don't see an
> > easy solution.

We can try to convert it to pointer instead of embedding it into
struct address_space and make filesystems allocate it on S_DAX setting.
Is it better?

> > OTOH filesystems in normal mode might want to use the range lock as well to
> > provide truncate / punch hole vs page fault exclusion (XFS already has a
> > private rwsem for this and ext4 needs something as well) and at that point
> > growing generic struct inode would be acceptable for me.
> 
> It sounds to me like the way DAX has tried to solve this race is the
> wrong direction. We really need to drive the truncate/page fault
> serialisation higher up the stack towards the filesystem, not deeper
> into the mm subsystem where locking is greatly limited.

My understanding of fs locking is very limited, but I think we have
problem with this approach in fault path: to dispatch page fault properly
we need to take mmap_sem and find VMA. Only after that we have chance to
obtain any fs lock. And that's the place where we take page lock which
this range_lock intend to replace.

I don't see how we can move any lock to serialize truncate vs. fault much
higher.

> As Jan mentions, we already have this serialisation in XFS, and I
> think it would be better first step to replicate that locking model
> in each filesystem that is supports DAX. I think this is a better
> direction because it moves towards solving a whole class of problems
> fileystem face with page fault serialisation, not just for DAX.

Could you point me to that lock and locking rules for it?
 
> > My grand plan was to use the range lock to also simplify locking
> > rules for read, write and esp. direct IO but that has issues with
> > mmap_sem ordering because filesystems get called under mmap_sem in
> > page fault path. So probably just fixing the worst issue with
> > punch hole vs page fault would be good for now.
> 
> Right, I think adding a rwsem to the ext4 inode to handle the
> fault/truncate serialisation similar to XFS would be sufficient to
> allow DAX to remove the i_mmap_lock serialisation...
> 
> > Also for a patch set like this, it would be good to show some numbers - how
> > big hit do you take in the single-threaded case (the lock is more
> > expensive) and how much scalability do you get in the multithreaded case?
> 
> And also, if you remove the serialisation and run the test on XFS,
> what do you get in terms of performance and correctness?

I'll talk with Matthew on numbers.

As we don't have any HW yet, the only numbers we can possibly provide is
DAX over DRAM.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
