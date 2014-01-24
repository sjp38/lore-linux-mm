Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 072B06B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 02:24:43 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id md12so2905702pbc.2
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 23:24:43 -0800 (PST)
Received: from m53-178.qiye.163.com (m53-178.qiye.163.com. [123.58.178.53])
        by mx.google.com with ESMTP id fu1si17818pbc.134.2014.01.23.23.24.40
        for <linux-mm@kvack.org>;
        Thu, 23 Jan 2014 23:24:41 -0800 (PST)
Message-ID: <52E21535.5010102@ubuntukylin.com>
Date: Fri, 24 Jan 2014 15:24:37 +0800
From: Li Wang <liwang@ubuntukylin.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM ATTEND] Fadvise Extensions for Directory Level Cache
 Cleaning and POSIX_FADV_NOREUSE
References: <CABDjeFeXqJPAKFFz9vG1pgqEjNJpW3ciLH3LfGCjPYrAcL6xRQ@mail.gmail.com>
In-Reply-To: <CABDjeFeXqJPAKFFz9vG1pgqEjNJpW3ciLH3LfGCjPYrAcL6xRQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qing Wei <weiqing369@gmail.com>
Cc: lsf-pc <lsf-pc@lists.linux-foundation.org>, "inux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>


On 2014/1/23 21:19, Qing Wei wrote:
> Hi,
>
> On 01/20/2014 10:56 PM, Li Wang wrote:
>
>
>     Hello,
>       It will be appreciated if I have a chance to discuss the fadvise
>     extension topic at the incoming LSF/MM summit. I am also very
>     interested in the topics on VFS, MM, SSD optimization as well as ext4,
>     xfs, ceph and so on.
>      In the last year, I have been involved in Ceph development, the
>     features done/ongoing include punch hole support, inline data
>     support, cephfs quota support, cephfs fuse file lock support etc, as
>     well as some bug fixes and performance evaluations.
>
>     The proposal is below, comments/suggestions are welcome.
>
>     Fadvise Extensions for Directory Level Cache Cleaning and
>     POSIX_FADV_NOREUSE
>
>     1 Motivation
>
>     1.1 Directory Level Cache Cleaning
>
>     VFS relies on LRU-like page cache eviction algorithm to reclaim cache
>     space, since LRU is not aware of application semantics, it may
>     incorrectly evict going-to-be referenced pages out, resulting in
>     severe
>     performance degradation due to cache thrashing, especially under high
>     memory pressure situation. Applications have the most semantic
>     knowledge, they can always do better if they are given a chance. This
>     motivates to endow the applications more abilities to manipulate the
>     vfs cache.
>
>     Currently, Linux support file system wide cache cleaning by virtue of
>     proc interface 'drop-caches', but it is very coarse granularity and
>     was originally proposed for debugging. The other is to do file-level
>     page cache cleaning through 'fadvise', however, since there is no
>     way of
>     determining whether a path name is in the dentry cache, simply calling
>     fadvise(name, DONTNEED) will very likely pollute the cache rather
>     than cleaning it. Even there is a cache query API available, it will
>     incur heavy system call overhead, especially in massive small-file
>     situations. This motivates to extend fadvise() to support directory
>     level cache cleaning. Currently, the original implementation is
>     available at https://lkml.org/lkml/2013/12/30/147, and received some
>     constructive comments. We think there are some designs need be put
>     under discussion, and we summarize them in Section 2.1.
>
>     1.2 POSIX_FADV_NOREUSE
>
>     POSIX_FADV_NOREUSE is useful for backup and data streaming
>     applications.
>     There are already some efforts on POSIX_FADV_NOREUSE implementation,
>     the latest seems to be https://lkml.org/lkml/2012/2/11/133. The
>     alternative ways can be (a) Use fadvise(DONTNEED) instead; (b) Use
>     container-based approach, such as setting memory.file.limit_in_bytes.
>     However, both (a) and (b) have limitations. (a) may impolitely destroy
>     other application's work set, which is not a desirable behavior;
>     (b) is
>     kind of rude, and the threshold may have to be  carefully tuned,
>     otherwise it may cause applications to start swapping  or even worse.
>     In addition, we are not sure if it shares the same issue  with (a).
>     This motivates to develop a simple yet efficient POSIX_FADV_NOREUSE
>     implementation.
>
>     2 Designs to be discussed
>
>     Since these are both suggestive interfaces, the overall idea
>     behind our
>     design is to minimize the modification to current MM magic, stay the
>     implementation as simple as possible.
>
>     2.1 Directory Level Cache Cleaning
>
>     For directory level cache cleaning, fadivse(fd, DONTNEED) will clean
>     all the page caches as well as unreferenced dentry caches and inode
>     caches inside the directory fd.
>
>     (1) For page cache cleaning, the policy in our original design is to
>     collect those inodes not on any LRU list into our private list for
>     further cleaning. However, as pointed out by Andrew and Dave, most
>     inodes are actually on the LRU list, hence this policy will leave many
>     inodes fail to be processed. And, since we want to reuse the
>     inode->i_lru rather than adding a new list_head field into inode, we
>     will encounter a problem that we can not determine whether an inode is
>     on superblock LRU list or on our private list. While a fadvise()
>     caller
>     A is trying to collect an inode, it may happen that another fadvise()
>     caller B has already gathered the inode into his private LRU list,
>     then
>     it will end up that A grabs inode from B's list, and the worse
>     thing is,
>     the operations on B'list are not synchronized within multiple
>     fadvise()
>     callers. To address this, We have two candidates,
>
>     (a) Introduce a new inode state I_PRIVATE, indicating the inode is
>     on a
>     private list. While collecting one inode into private list, the
>     flag is
>     set on it, and cleared after finishing page cache invalidation.
>     Fadvise() caller will check the flag prior to collecting one inode
>     into
>     his private list. This avoids the race between one fadvise() caller is
>     adding a new inode to his list and another caller is grabbing a inode
>     from this list.
>
>     (b) Introduce a global list as well as a global lock. The inodes to be
>     manipulated are always collected into the global list, protected
>     by the
>     global lock. Given the cache cleaning is not a frequent operation, the
>     performance impact is negligible.
>
>     (2) For dentry cache cleaning, shrink_dcache_parent() meets most
>     of our
>     demands except it does not take permission into account, the caller
>     should not touch the dentries and inodes which he does not own
>     appropriate permission. There are also two ways to perform the check,
>
>     (a) Check if the caller has permission on parent directory, i.e,
>     inode_permission(dentry->d_parent->d_inode, MAY_WRITE | MAY_EXEC)
>
>     (b) Check if the caller has permission on corresponding inode, i.e,
>     (inode_owner_or_capable(dentry->d_inode) || capable(CAP_SYS_ADMIN))
>
>     (3) For dentry cache cleaning, if dentries are freed, there seems no
>     easy way to walk all inodes inside a specific directory, our idea lies
>     in that before freeing those unreferenced dentries, gather the inodes
>     referenced by them into a private list, __iget() the inodes and mark
>     I_PRIVATE on (if the I_PRIVATE scheme is acceptable). Thereafter from
>     where we can still find those inodes to further free them.
>
>     (4) For inode cache cleaning, in most situations, iput_final()
>     will put
>     unreferenced inodes into superblock lru list rather than freeing them.
>     To free the inodes in our private list, it seems there is not a handy
>     API to use. The process could be, for each inode in our list, hold the
>     inode lock, clear I_PRIVATE, detach from list, atomic decrease its
>     reference count. If the reference count reaches zero, there are two
>     possible ways,
>
>     (a) Introduce a new inode state I_FORCE_FREE, and mark it on, then
>     pass
>     the inode into iput_final(). iput_final() is with tiny
>     modifications to
>     be able to recognize the flag, who will then invoke evict() to
>     free the
>     inode rather than adding it to super block LRU list.
>
>     (b) Wrap iput_final() into __iput_final(struct inode *inode, bool
>     force_free), we call __iput_final(inode, TRUE), define iput_final() to
>     static inline __iput_final(inode, FALSE).
>
>     2.2 POSIX_FADV_NOREUSE Implementation
>
>     Our key idea behind is to translate 'The application will access the
>     page once' into 'The access leaves no side-effect on the page'. For
>     current MM implementation, normal access will has side-effect on the
>     page accessed, i.e, it will increase the temperature of the page,
>     in a way of from inactive to active or from unreferenced to
>     referenced.
>     Against normal access, NOREUSE is intended to tell the MM system that
>     the access will leave the page as it is. This can be detailed as
>     follows,
>
>     (a) If a page is accessed for the first time, after NOREUSE access, it
>     is kept inactive and unreferenced, then it will potentially get
>     reclaimed soon since it has a lowest temperature, unless a later
>     NON-NOREUSE access increases its temperature. Here we do not
>     explicitly immediately free the page after access, this is for three
>     reasons, the first is the semantics of NOREUSE differs from DONTNEED,
>      NOREUSE does not mean the page should be dropped  immediately; the
>     second is synchronously freeing the page will more or less slow down
>     the read performance; And the last, a near-future reference of the
>     page
>     by other applications will have a chance to hit in the cache.
>
>     (b) If a page is accessed before, in other words, it is active or
>     referenced, then it may belong to the work set of other applications,
>     and will very likely be accessed again. NOREUSE just makes a silent
>     access, without changing any status of the page.
>
>     Another assumption is that file wide NOREUSE is enough to capture most
>      of the usages, the fine granularity of interval-level NOREUSE is not
>     desirable given its rare use and its implementation complexity. So
>     this
>     results in the following simple NOREUSE implementation,
>
>     (1) Introduce a new fmode FMODE_NOREUSE, set it on when calling
>     fadvise(NOREUSE)
>
> So when will this flag be cleared? Do you need clear it while setting
> FMODE_RANDOM, FMODE_NORMAL, FMODE_SEQ etc, like
> https://lkml.org/lkml/2012/2/11/13 
> <https://lkml.org/lkml/2012/2/11/133> does?
It could be under discussion. FMODE_RANDOM, FMODE_NORMAL,
FMODE_SEQ and WILLNEED are all supposed to guide read ahead,
something happen before read. NOREUSE is supposed to suggest something
after read, so they seems to not to contradict with each other. For example,
FMODE_SEQ | FMODE_NOUSE could give better indication of  the behavior
of rsync. For DONTNEED, it is done synchronously, it seems not to 
contradict
with NOREUSE neither.
>
>     (2) do_generic_file_read():
>     From:
>     if (prev_index != index || offset != prev_offset)
>         mark_page_accessed(page);
>     To:
>     if ((prev_index != index || offset != prev_offset) && !(filp->f_mode &
>     FMODE_NOREUSE))
>         mark_page_accessed(page);
>         There are no more than ten LOC to go.
>
>     Cheers,
>     Li Wang
>
>
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
