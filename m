Date: Fri, 16 Mar 2007 23:13:22 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: FADV_DONTNEED on hugetlbfs files broken
Message-ID: <20070317061322.GI8915@holomorphy.com>
References: <20070317051308.GA5522@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070317051308.GA5522@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: kenchen@google.com, linux-mm@kvack.org, agl@us.ibm.com, dwg@au1.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, Mar 16, 2007 at 10:13:09PM -0700, Nishanth Aravamudan wrote:
> git commit 6649a3863232eb2e2f15ea6c622bd8ceacf96d76 "[PATCH] hugetlb:
> preserve hugetlb pte dirty state" fixed one bug and caused another (or,
> at least, a regression): FADV_DONTNEED no longer works on hugetlbfs
> files. git-bisect revealed this commit to be the cause. I'm still trying
> to figure out what the solution is (but it is also the start of the
> weekend :) Maybe it's not a bug, but it is a change in behavior, and I
> don't think it was clear from the commit message.

Well, setting the pages always dirty like that will prevent things from
dropping them because they think they still need to be written back. It
is, however, legitimate and/or permissible to ignore fadvise() and/or
madvise(); they are by definition only advisory. I think this is more of
a "please add back FADV_DONTNEED support" affair.

Perhaps we should ask what ramfs, tmpfs, et al would do. Or, for that
matter, if they suffer from the same issue as Ken Chen identified for
hugetlbfs. Perhaps the issue is not hugetlb's dirty state, but
drop_pagecache_sb() failing to check the bdi for BDI_CAP_NO_WRITEBACK.
Or perhaps what safety guarantees drop_pagecache_sb() is supposed to
have or lack.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
