Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2HJbTdT030917
	for <linux-mm@kvack.org>; Sat, 17 Mar 2007 15:37:30 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2HJbThT054920
	for <linux-mm@kvack.org>; Sat, 17 Mar 2007 13:37:29 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2HJbTsh010998
	for <linux-mm@kvack.org>; Sat, 17 Mar 2007 13:37:29 -0600
Date: Sat, 17 Mar 2007 12:37:29 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: FADV_DONTNEED on hugetlbfs files broken
Message-ID: <20070317193729.GA11449@us.ibm.com>
References: <20070317051308.GA5522@us.ibm.com> <20070317061322.GI8915@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070317061322.GI8915@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: kenchen@google.com, linux-mm@kvack.org, agl@us.ibm.com, dwg@au1.ibm.com
List-ID: <linux-mm.kvack.org>

On 16.03.2007 [23:13:22 -0700], William Lee Irwin III wrote:
> On Fri, Mar 16, 2007 at 10:13:09PM -0700, Nishanth Aravamudan wrote:
> > git commit 6649a3863232eb2e2f15ea6c622bd8ceacf96d76 "[PATCH] hugetlb:
> > preserve hugetlb pte dirty state" fixed one bug and caused another (or,
> > at least, a regression): FADV_DONTNEED no longer works on hugetlbfs
> > files. git-bisect revealed this commit to be the cause. I'm still trying
> > to figure out what the solution is (but it is also the start of the
> > weekend :) Maybe it's not a bug, but it is a change in behavior, and I
> > don't think it was clear from the commit message.
> 
> Well, setting the pages always dirty like that will prevent things
> from dropping them because they think they still need to be written
> back. It is, however, legitimate and/or permissible to ignore
> fadvise() and/or madvise(); they are by definition only advisory. I
> think this is more of a "please add back FADV_DONTNEED support"
> affair.

Yes, that could be :) Sorry if my e-mail indicated I was asking
otherwise. I don't want Ken's commit to be reverted, as that would make
hugepages very nearly unusable on x86 and x86_64. But I had found a
functional change and wanted it to be documented. If hugepages can no
longer be dropped from the page cache, then we should make sure that is
clear (and expected/desired).

Now, even if I call fsync() on the file descriptor, I still don't get
the pages out of the page cache. It seems to me like fsync() would clear
the dirty state -- although perhaps with Ken's patch, writable hugetlbfs
pages will *always* be dirty? I'm still trying to figure out what ever
clears that dirty state (in hugetlbfs or anywhere else). Seems like
hugetlbfs truncates call cancel_dirty_page(), but the comment there
indicates it's only for truncates.

> Perhaps we should ask what ramfs, tmpfs, et al would do. Or, for that
> matter, if they suffer from the same issue as Ken Chen identified for
> hugetlbfs. Perhaps the issue is not hugetlb's dirty state, but
> drop_pagecache_sb() failing to check the bdi for BDI_CAP_NO_WRITEBACK.
> Or perhaps what safety guarantees drop_pagecache_sb() is supposed to
> have or lack.

A good point, and one I hadn't considered. I'm less concerned by the
drop_pagecache_sb() path (which is /proc/sys/vm/drop_caches, yes?),
although it appears that it and the FADV_DONTNEED code both end up
calling into invalidate_mapping_pages(). I'm still pretty new to this
part of the kernel code, and am trying to follow along as best I can.

In any case, if the problem were in drop_pagecache_sb(), it seems like
it wouldn't help the DONTNEED case, since that's a level above the call
to invalidate_mapping_pages().

I'll keep looking through the code and thinking, and if anyone has any
patches they'd like me to test, I'll be glad to.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
