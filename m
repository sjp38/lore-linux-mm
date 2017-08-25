Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0DF426810D7
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 18:31:32 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id v141so1416385ywa.9
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 15:31:32 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id o8si1921538ywi.464.2017.08.25.15.31.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 15:31:31 -0700 (PDT)
Subject: Re: + mm-madvise-fix-freeing-of-locked-page-with-madv_free.patch
 added to -mm tree
References: <599df681.NreP1dR3/HGSfpCe%akpm@linux-foundation.org>
 <20170824060957.GA29811@dhcp22.suse.cz>
 <81C11D6F-653D-4B14-A3A6-E6BB6FB5436D@vmware.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <3452db57-d847-ec8e-c9be-7710f4ddd5d4@oracle.com>
Date: Fri, 25 Aug 2017 15:31:22 -0700
MIME-Version: 1.0
In-Reply-To: <81C11D6F-653D-4B14-A3A6-E6BB6FB5436D@vmware.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>, "ebiggers@google.com" <ebiggers@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, "nyc@holomorphy.com" <nyc@holomorphy.com>

On 08/25/2017 03:02 PM, Nadav Amit wrote:
> Michal Hocko <mhocko@kernel.org> wrote:
> 
>> Hmm, I do not see this neither in linux-mm nor LKML. Strange
>>
>> On Wed 23-08-17 14:41:21, Andrew Morton wrote:
>>> From: Eric Biggers <ebiggers@google.com>
>>> Subject: mm/madvise.c: fix freeing of locked page with MADV_FREE
>>>
>>> If madvise(..., MADV_FREE) split a transparent hugepage, it called
>>> put_page() before unlock_page().  This was wrong because put_page() can
>>> free the page, e.g.  if a concurrent madvise(..., MADV_DONTNEED) has
>>> removed it from the memory mapping.  put_page() then rightfully complained
>>> about freeing a locked page.
>>>
>>> Fix this by moving the unlock_page() before put_page().
> 
> Quick grep shows that a similar flow (put_page() followed by an
> unlock_page() ) also happens in hugetlbfs_fallocate(). Isna??t it a problem as
> well?

I assume you are asking about this block of code?

                /*
                 * page_put due to reference from alloc_huge_page()
                 * unlock_page because locked by add_to_page_cache()
                 */
                put_page(page);
                unlock_page(page);

Well, there is a typo (page_put) in the comment. :(

However, in this case we have just added the huge page to a hugetlbfs
file.  The put_page() is there just to drop the reference count on the
page (taken when allocated).  It will still be non-zero as we have
successfully added it to the page cache.  So, we are not freeing the
page here, just dropping the reference count.

This should not cause a problem like that seen in madvise.
-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
