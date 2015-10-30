Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7C2D082F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 16:59:56 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so84426439pad.1
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 13:59:56 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id en5si13491187pbd.215.2015.10.30.13.59.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Oct 2015 13:59:55 -0700 (PDT)
Subject: Re: [PATCH] mm/hugetlb: Unmap pages if page fault raced with hole
 punch
References: <1446158038-25815-1-git-send-email-mike.kravetz@oracle.com>
 <alpine.LSU.2.11.1510291937340.5781@eggly.anvils>
 <56339EBA.4070508@oracle.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <5633D984.7080307@oracle.com>
Date: Fri, 30 Oct 2015 13:56:36 -0700
MIME-Version: 1.0
In-Reply-To: <56339EBA.4070508@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>

On 10/30/2015 09:45 AM, Mike Kravetz wrote:
> On 10/29/2015 08:32 PM, Hugh Dickins wrote:
>> On Thu, 29 Oct 2015, Mike Kravetz wrote:
>>
>>> This patch is a combination of:
>>> [PATCH v2 4/4] mm/hugetlb: Unmap pages to remove if page fault raced
>>> 	with hole punch  and,
>>> [PATCH] mm/hugetlb: i_mmap_lock_write before unmapping in
>>> 	remove_inode_hugepages
>>> This patch can replace the entire series:
>>> [PATCH v2 0/4] hugetlbfs fallocate hole punch race with page faults
>>> 	and
>>> [PATCH] mm/hugetlb: i_mmap_lock_write before unmapping in
>>> 	remove_inode_hugepages
>>> It is being provided in an effort to possibly make tree management easier.
>>>
>>> Page faults can race with fallocate hole punch.  If a page fault happens
>>> between the unmap and remove operations, the page is not removed and
>>> remains within the hole.  This is not the desired behavior.
>>>
>>> If this race is detected and a page is mapped, the remove operation
>>> (remove_inode_hugepages) will unmap the page before removing.  The unmap
>>> within remove_inode_hugepages occurs with the hugetlb_fault_mutex held
>>> so that no other faults can occur until the page is removed.
>>>
>>> The (unmodified) routine hugetlb_vmdelete_list was moved ahead of
>>> remove_inode_hugepages to satisfy the new reference.
>>>
>>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>>
>> Sorry, I came here to give this a quick Ack, but find I cannot:
>> you're adding to the remove_inode_hugepages() loop (heading towards
>> 4.3 final), but its use of "next" looks wrong to me already.
> 
> You are correct, the (current) code is wrong.
> 
> The hugetlbfs fallocate code started with shmem as an example.  Some
> of the complexities of that code are not needed in hugetlbfs.  However,
> some remnants were left.
> 
> I'll create a patch to fix the existing code, then when that is acceptable
> refactor this patch.
> 
>>
>> Doesn't "next" need to be assigned from page->index much earlier?
>> If there's a hole in the file (which there very well might be, since
>> you've just implemented holepunch!), doesn't it do the wrong thing?
> 
> Yes, I think it will.
> 
>>
>> And the loop itself is a bit weird, though that probably doesn't
>> matter very much: I said before, seeing the "while (next < end)",
>> that it's a straightforward scan from start to end, and sometimes
>> it would work that way; but buried inside is "next = start; continue;"
> 
> Correct, that next = start should not be there.

The 'next = start' code is actually from the original truncate_hugepages
routine.  This functionality was combined with that needed for hole punch
to create remove_inode_hugepages().

The following code was in truncate_hugepages:

	next = start;
	while (1) {
		if (!pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
			if (next == start)
				break;
			next = start;
			continue;
		}


So, in the truncate case pages starting at 'start' are deleted until
pagevec_lookup fails.  Then, we call pagevec_lookup() again.  If no
pages are found we are done.  Else, we repeat the whole process.

Does anyone recall the reason for going back and looking for pages at
index'es already deleted?  Git doesn't help as that was part of initial
commit.  My thought is that truncate can race with page faults.  The
truncate code sets inode offset before unmapping and deleting pages.
So, faults after the new offset is set should fail.  But, I suppose a
fault could race with setting offset and deleting of pages.  Does this
sound right?  Or, is there some other reason I am missing?

I would like to continue having remove_inode_hugepages handle both the
truncate and hole punch case.  So, what to make sure the code correctly
handles both cases.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
