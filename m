Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id l2I7h4S1030575
	for <linux-mm@kvack.org>; Sun, 18 Mar 2007 00:43:04 -0700
Received: from an-out-0708.google.com (ancc31.prod.google.com [10.100.29.31])
	by zps38.corp.google.com with ESMTP id l2I7h22x006436
	for <linux-mm@kvack.org>; Sun, 18 Mar 2007 00:43:02 -0700
Received: by an-out-0708.google.com with SMTP id c31so897214anc
        for <linux-mm@kvack.org>; Sun, 18 Mar 2007 00:43:02 -0700 (PDT)
Message-ID: <b040c32a0703180043t29c675bfr9a9554575a261f96@mail.gmail.com>
Date: Sun, 18 Mar 2007 00:43:01 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: FADV_DONTNEED on hugetlbfs files broken
In-Reply-To: <20070317193729.GA11449@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070317051308.GA5522@us.ibm.com>
	 <20070317061322.GI8915@holomorphy.com>
	 <20070317193729.GA11449@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org, agl@us.ibm.com, dwg@au1.ibm.com
List-ID: <linux-mm.kvack.org>

On 3/17/07, Nishanth Aravamudan <nacc@us.ibm.com> wrote:
> Yes, that could be :) Sorry if my e-mail indicated I was asking
> otherwise. I don't want Ken's commit to be reverted, as that would make
> hugepages very nearly unusable on x86 and x86_64. But I had found a
> functional change and wanted it to be documented. If hugepages can no
> longer be dropped from the page cache, then we should make sure that is
> clear (and expected/desired).

Oh gosh, I think you are really abusing the buggy hugetlb behavior in
the dark age of 2.6.19.  Hugetlb file does not have disk based backing
store.  The in-core page that resides in the page cache is the only
copy of the file.  For pages that are dirty, there are no place to
sync them to and thus they have to stay in the page cache for the life
of the file.

And currently, there is no way to allocate hugetlb page in "clean"
state because we can't mmap hugetlb page onto a disk file.  So pages
for live file in hugetlbfs are always being written to initially and
it is just not possible to drop them out of page cache, otherwise we
suffer from data corruption.

> Now, even if I call fsync() on the file descriptor, I still don't get
> the pages out of the page cache. It seems to me like fsync() would clear
> the dirty state -- although perhaps with Ken's patch, writable hugetlbfs
> pages will *always* be dirty? I'm still trying to figure out what ever
> clears that dirty state (in hugetlbfs or anywhere else). Seems like
> hugetlbfs truncates call cancel_dirty_page(), but the comment there
> indicates it's only for truncates.

fsync can not drop dirty pages out of page cache because there are no
backing store.  I believe truncate is the only way to remove hugetlb
page out of page cache.

> > Perhaps we should ask what ramfs, tmpfs, et al would do. Or, for that
> > matter, if they suffer from the same issue as Ken Chen identified for
> > hugetlbfs. Perhaps the issue is not hugetlb's dirty state, but
> > drop_pagecache_sb() failing to check the bdi for BDI_CAP_NO_WRITEBACK.
> > Or perhaps what safety guarantees drop_pagecache_sb() is supposed to
> > have or lack.

I looked, ramfs and tmpfs does the same thing.  fadvice(DONTNEED)
doesn't do anything to live files.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
