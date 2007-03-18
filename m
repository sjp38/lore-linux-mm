Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2IHRZi4011859
	for <linux-mm@kvack.org>; Sun, 18 Mar 2007 13:27:35 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2IHRZBx296106
	for <linux-mm@kvack.org>; Sun, 18 Mar 2007 13:27:35 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2IHRYhs008167
	for <linux-mm@kvack.org>; Sun, 18 Mar 2007 13:27:35 -0400
Date: Sun, 18 Mar 2007 10:27:11 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: FADV_DONTNEED on hugetlbfs files broken
Message-ID: <20070318172711.GA12978@us.ibm.com>
References: <20070317051308.GA5522@us.ibm.com> <20070317061322.GI8915@holomorphy.com> <20070317193729.GA11449@us.ibm.com> <b040c32a0703180043t29c675bfr9a9554575a261f96@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b040c32a0703180043t29c675bfr9a9554575a261f96@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org, agl@us.ibm.com, dwg@au1.ibm.com
List-ID: <linux-mm.kvack.org>

On 18.03.2007 [00:43:01 -0700], Ken Chen wrote:
> On 3/17/07, Nishanth Aravamudan <nacc@us.ibm.com> wrote:
> >Yes, that could be :) Sorry if my e-mail indicated I was asking
> >otherwise. I don't want Ken's commit to be reverted, as that would
> >make hugepages very nearly unusable on x86 and x86_64. But I had
> >found a functional change and wanted it to be documented. If
> >hugepages can no longer be dropped from the page cache, then we
> >should make sure that is clear (and expected/desired).
> 
> Oh gosh, I think you are really abusing the buggy hugetlb behavior in
> the dark age of 2.6.19.  Hugetlb file does not have disk based backing
> store.  The in-core page that resides in the page cache is the only
> copy of the file.  For pages that are dirty, there are no place to
> sync them to and thus they have to stay in the page cache for the life
> of the file.

And 2.6.20, fwiw. Your explanation makes sense. Frustrating, though,
since it means segment remapping uses twice as many huge pages as it
needs to for each writable segment.

> And currently, there is no way to allocate hugetlb page in "clean"
> state because we can't mmap hugetlb page onto a disk file.  So pages
> for live file in hugetlbfs are always being written to initially and
> it is just not possible to drop them out of page cache, otherwise we
> suffer from data corruption.

Let's be clear, for the sake of the archives of the world, this is only
for *writable* allocations. In make_huge_pte():

        if (writable) {
                entry =
                    pte_mkwrite(pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
        } else {
                entry = pte_wrprotect(mk_pte(page, vma->vm_page_prot));
        }

Probably obvious to anyone, since you need to be able to dirty the page to have
it in a dirty state.

> >Now, even if I call fsync() on the file descriptor, I still don't get
> >the pages out of the page cache. It seems to me like fsync() would
> >clear the dirty state -- although perhaps with Ken's patch, writable
> >hugetlbfs pages will *always* be dirty? I'm still trying to figure
> >out what ever clears that dirty state (in hugetlbfs or anywhere
> >else). Seems like hugetlbfs truncates call cancel_dirty_page(), but
> >the comment there indicates it's only for truncates.
> 
> fsync can not drop dirty pages out of page cache because there are no
> backing store.  I believe truncate is the only way to remove hugetlb
> page out of page cache.

Which won't work here, because we don't want to lose the data. We just
want to drop the original MAP_SHARED copy of the file out of the
page_cache. I tried ftruncate()'ing the file down to 0 after we've
mapped it PRIVATE and COW'd each hugepage, but then the process
(obviously) SEGVs. We lose all hugepages in the page cache.

> >> Perhaps we should ask what ramfs, tmpfs, et al would do. Or, for
> >> that matter, if they suffer from the same issue as Ken Chen
> >> identified for hugetlbfs. Perhaps the issue is not hugetlb's dirty
> >> state, but drop_pagecache_sb() failing to check the bdi for
> >> BDI_CAP_NO_WRITEBACK.  Or perhaps what safety guarantees
> >> drop_pagecache_sb() is supposed to have or lack.
> 
> I looked, ramfs and tmpfs does the same thing.  fadvice(DONTNEED)
> doesn't do anything to live files.

Ok, thanks for looking into it, Ken.

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
