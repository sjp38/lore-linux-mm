Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 20AE66B0038
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 22:00:50 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so4448886pab.0
        for <linux-mm@kvack.org>; Mon, 19 Oct 2015 19:00:49 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id af1si1087198pad.198.2015.10.19.19.00.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Oct 2015 19:00:49 -0700 (PDT)
Subject: Re: [PATCH 0/3] hugetlbfs fallocate hole punch race with page faults
References: <1445033310-13155-1-git-send-email-mike.kravetz@oracle.com>
 <20151019161840.63e6afaa73aceec23e351905@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <56259EC4.9010207@oracle.com>
Date: Mon, 19 Oct 2015 18:54:12 -0700
MIME-Version: 1.0
In-Reply-To: <20151019161840.63e6afaa73aceec23e351905@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>

On 10/19/2015 04:18 PM, Andrew Morton wrote:
> On Fri, 16 Oct 2015 15:08:27 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:
> 
>> The hugetlbfs fallocate hole punch code can race with page faults.  The
>> result is that after a hole punch operation, pages may remain within the
>> hole.  No other side effects of this race were observed.
>>
>> In preparation for adding userfaultfd support to hugetlbfs, it is desirable
>> to plug or significantly shrink this hole.  This patch set uses the same
>> mechanism employed in shmem (see commit f00cdc6df7).
>>
> 
> "still buggy but not as bad as before" isn't what we strive for ;) What
> would it take to fix this for real?  An exhaustive description of the
> bug would be a good starting point, thanks.
> 

Thanks for asking, it made me look closer at ways to resolve this.

The current code in remove_inode_hugepages() does nothing with a page if
it is still mapped.  The only way it can be mapped is if we race and take
a page fault after unmapping, but before the page is removed.  This patch
set makes that window much smaller, but it still exists.

Instead of "giving up" on a mapped page, remove_inode_hugepages() can go
back and unmap it.  I'll code this up tomorrow.  Fortunately, it is
pretty easy to hit these races and verify proper behavior.

I'll create a new patch set with this combined code for a complete fix.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
