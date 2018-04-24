Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 954F86B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 15:18:52 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id f19so7253920pgv.4
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 12:18:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t65sor637458pgc.62.2018.04.24.12.18.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Apr 2018 12:18:51 -0700 (PDT)
Date: Tue, 24 Apr 2018 22:18:50 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC v4 PATCH] mm: shmem: make stat.st_blksize return huge page
 size if THP is on
Message-ID: <20180424191850.hasxjzxuwuhtvulp@kshutemo-mobl1>
References: <1524542450-92577-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180424112359.svngcdudzodobvmu@kshutemo-mobl1.Home>
 <213eae6a-e003-5369-d73a-1da8920b3dd4@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <213eae6a-e003-5369-d73a-1da8920b3dd4@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: kirill.shutemov@linux.intel.com, hughd@google.com, mhocko@kernel.org, hch@infradead.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 24, 2018 at 08:14:37AM -0600, Yang Shi wrote:
> 
> 
> On 4/24/18 5:23 AM, Kirill A. Shutemov wrote:
> > On Tue, Apr 24, 2018 at 12:00:50PM +0800, Yang Shi wrote:
> > > Since tmpfs THP was supported in 4.8, hugetlbfs is not the only
> > > filesystem with huge page support anymore. tmpfs can use huge page via
> > > THP when mounting by "huge=" mount option.
> > > 
> > > When applications use huge page on hugetlbfs, it just need check the
> > > filesystem magic number, but it is not enough for tmpfs. Make
> > > stat.st_blksize return huge page size if it is mounted by appropriate
> > > "huge=" option to give applications a hint to optimize the behavior with
> > > THP.
> > > 
> > > Some applications may not do wisely with THP. For example, QEMU may mmap
> > > file on non huge page aligned hint address with MAP_FIXED, which results
> > > in no pages are PMD mapped even though THP is used. Some applications
> > > may mmap file with non huge page aligned offset. Both behaviors make THP
> > > pointless.
> > > 
> > > statfs.f_bsize still returns 4KB for tmpfs since THP could be split, and it
> > > also may fallback to 4KB page silently if there is not enough huge page.
> > > Furthermore, different f_bsize makes max_blocks and free_blocks
> > > calculation harder but without too much benefit. Returning huge page
> > > size via stat.st_blksize sounds good enough.
> > > 
> > > Since PUD size huge page for THP has not been supported, now it just
> > > returns HPAGE_PMD_SIZE.
> > > 
> > > Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> > > Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > > Cc: Hugh Dickins <hughd@google.com>
> > > Cc: Michal Hocko <mhocko@kernel.org>
> > > Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> > > Suggested-by: Christoph Hellwig <hch@infradead.org>
> > > ---
> > > v3 --> v4:
> > > * Rework the commit log per the education from Michal and Kirill
> > > * Fix build error if CONFIG_TRANSPARENT_HUGEPAGE is disabled
> > > v2 --> v3:
> > > * Use shmem_sb_info.huge instead of global variable per Michal's comment
> > > v2 --> v1:
> > > * Adopted the suggestion from hch to return huge page size via st_blksize
> > >    instead of creating a new flag.
> > > 
> > >   mm/shmem.c | 6 ++++++
> > >   1 file changed, 6 insertions(+)
> > > 
> > > diff --git a/mm/shmem.c b/mm/shmem.c
> > > index b859192..19b8055 100644
> > > --- a/mm/shmem.c
> > > +++ b/mm/shmem.c
> > > @@ -988,6 +988,7 @@ static int shmem_getattr(const struct path *path, struct kstat *stat,
> > >   {
> > >   	struct inode *inode = path->dentry->d_inode;
> > >   	struct shmem_inode_info *info = SHMEM_I(inode);
> > > +	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
> > >   	if (info->alloced - info->swapped != inode->i_mapping->nrpages) {
> > >   		spin_lock_irq(&info->lock);
> > > @@ -995,6 +996,11 @@ static int shmem_getattr(const struct path *path, struct kstat *stat,
> > >   		spin_unlock_irq(&info->lock);
> > >   	}
> > >   	generic_fillattr(inode, stat);
> > > +#ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
> > > +	if (sbinfo->huge > 0)
> > No ifdeffery, please.
> > 
> > And we probably want to check if shmem_huge is 'force'.
> > 
> > Something like this?
> > 
> > 	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE) &&
> > 		 (shmem_huge == SHMEM_HUGE_FORCE || sbinfo->huge))
> 
> BTW, it sounds we also need check shmem_huge != SHMEM_HUGE_DENY, right?
> Otherwise it still return huge page size, but in fact no huge page can be
> allocated with 'deny'.
> 
> So, how about:
> 
> if (IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE) &&
>          (shmem_huge == SHMEM_HUGE_FORCE || sbinfo->huge) &&
>          shmem_huge != SHMEM_HUGE_DENY)

I think at this point it worth moving it to a helper function.

-- 
 Kirill A. Shutemov
