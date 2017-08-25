Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id D4D506810D7
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 19:41:48 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id d124so964242vkf.11
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 16:41:48 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 89si3186695uag.384.2017.08.25.16.41.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 16:41:47 -0700 (PDT)
Subject: Re: + mm-madvise-fix-freeing-of-locked-page-with-madv_free.patch
 added to -mm tree
References: <599df681.NreP1dR3/HGSfpCe%akpm@linux-foundation.org>
 <20170824060957.GA29811@dhcp22.suse.cz>
 <81C11D6F-653D-4B14-A3A6-E6BB6FB5436D@vmware.com>
 <3452db57-d847-ec8e-c9be-7710f4ddd5d4@oracle.com>
 <10E0D3D9-F7D4-4A0F-AD2F-9E40F3DE6CCC@vmware.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <c51c78c4-8bac-c5e2-c740-3fc92d602436@oracle.com>
Date: Fri, 25 Aug 2017 16:41:36 -0700
MIME-Version: 1.0
In-Reply-To: <10E0D3D9-F7D4-4A0F-AD2F-9E40F3DE6CCC@vmware.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: "ebiggers@google.com" <ebiggers@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, "nyc@holomorphy.com" <nyc@holomorphy.com>

On 08/25/2017 03:51 PM, Nadav Amit wrote:
> Mike Kravetz <mike.kravetz@oracle.com> wrote:
> 
>> On 08/25/2017 03:02 PM, Nadav Amit wrote:
>>> Michal Hocko <mhocko@kernel.org> wrote:
>>>
>>>> Hmm, I do not see this neither in linux-mm nor LKML. Strange
>>>>
>>>> On Wed 23-08-17 14:41:21, Andrew Morton wrote:
>>>>> From: Eric Biggers <ebiggers@google.com>
>>>>> Subject: mm/madvise.c: fix freeing of locked page with MADV_FREE
>>>>>
>>>>> If madvise(..., MADV_FREE) split a transparent hugepage, it called
>>>>> put_page() before unlock_page().  This was wrong because put_page() can
>>>>> free the page, e.g.  if a concurrent madvise(..., MADV_DONTNEED) has
>>>>> removed it from the memory mapping.  put_page() then rightfully complained
>>>>> about freeing a locked page.
>>>>>
>>>>> Fix this by moving the unlock_page() before put_page().
>>>
>>> Quick grep shows that a similar flow (put_page() followed by an
>>> unlock_page() ) also happens in hugetlbfs_fallocate(). Isna??t it a problem as
>>> well?
>>
>> I assume you are asking about this block of code?
> 
> Yes.
> 
>>
>>                /*
>>                 * page_put due to reference from alloc_huge_page()
>>                 * unlock_page because locked by add_to_page_cache()
>>                 */
>>                put_page(page);
>>                unlock_page(page);
>>
>> Well, there is a typo (page_put) in the comment. :(
>>
>> However, in this case we have just added the huge page to a hugetlbfs
>> file.  The put_page() is there just to drop the reference count on the
>> page (taken when allocated).  It will still be non-zero as we have
>> successfully added it to the page cache.  So, we are not freeing the
>> page here, just dropping the reference count.
>>
>> This should not cause a problem like that seen in madvise.
> 
> Thanks for the quick response.
> 
> I am not too familiar with this piece of code, so just for the matter of
> understanding: what prevents the page from being removed from the page cache
> shortly after it is added (even if it is highly unlikely)? The page lock? The
> inode lock?

Someone would need to acquire the inode lock to remove the page.  This
is held until we exit the routine.  Also note that put_page for this
type of huge page almost always results in the page being put back
on a free list within the hugetlb(fs) subsystem.  It is not returned
to the 'normal' memory allocators for general use.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
