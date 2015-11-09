Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2C89F6B0255
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 18:00:50 -0500 (EST)
Received: by ykdv3 with SMTP id v3so201074614ykd.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 15:00:49 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id r79si174102ywe.347.2015.11.09.15.00.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 15:00:49 -0800 (PST)
Subject: Re: [PATCH] mm/hugetlb: Unmap pages if page fault raced with hole
 punch
References: <1446158038-25815-1-git-send-email-mike.kravetz@oracle.com>
 <alpine.LSU.2.11.1510291937340.5781@eggly.anvils>
 <56339EBA.4070508@oracle.com> <5633D984.7080307@oracle.com>
 <alpine.LSU.2.11.1511082310390.15826@eggly.anvils>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <5641244F.3060108@oracle.com>
Date: Mon, 9 Nov 2015 14:55:11 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1511082310390.15826@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>

On 11/08/2015 11:42 PM, Hugh Dickins wrote:
> On Fri, 30 Oct 2015, Mike Kravetz wrote:
>>
>> The 'next = start' code is actually from the original truncate_hugepages
>> routine.  This functionality was combined with that needed for hole punch
>> to create remove_inode_hugepages().
>>
>> The following code was in truncate_hugepages:
>>
>> 	next = start;
>> 	while (1) {
>> 		if (!pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
>> 			if (next == start)
>> 				break;
>> 			next = start;
>> 			continue;
>> 		}
>>
>>
>> So, in the truncate case pages starting at 'start' are deleted until
>> pagevec_lookup fails.  Then, we call pagevec_lookup() again.  If no
>> pages are found we are done.  Else, we repeat the whole process.
>>
>> Does anyone recall the reason for going back and looking for pages at
>> index'es already deleted?  Git doesn't help as that was part of initial
>> commit.  My thought is that truncate can race with page faults.  The
>> truncate code sets inode offset before unmapping and deleting pages.
>> So, faults after the new offset is set should fail.  But, I suppose a
>> fault could race with setting offset and deleting of pages.  Does this
>> sound right?  Or, is there some other reason I am missing?
> 
> I believe your thinking is correct.  But remember that
> truncate_inode_pages_range() is shared by almost all filesystems,
> and different filesystems have different internal locking conventions,
> and different propensities to such a race: it's trying to cover for
> all of them.
> 
> Typically, writing is well serialized (by i_mutex) against truncation,
> but faulting (like reading) sails through without enough of a lock.
> We resort to i_size checks to avoid the worst of it, but there's often
> a corner or two in which those checks are not quite good enough -
> it's easy to check i_size at the beginning, but it needs to be checked
> again at the end too, and what's been done undone - can be awkward.

Well, it looks like the hugetlb_no_page() routine is checking i_size both
before and after.  It appears to be doing the right thing to handle the
race, but I need to stare at the code some more to make sure.

Because of the way the truncate code went back and did an extra lookup
when done with the range, I assumed it was covering some race.  However,
that may not be the case.

> 
> I hope that in the case of hugetlbfs, since you already have the
> additional fault_mutex to handle races between faults and punching,
> it should be possible to get away without that "pincer" restarting.

Yes, it looks like this may work as a straight loop over the range of
pages.  I just need to study the code some more to make sure I am not
missing something.

-- 
Mike Kravetz

> 
> Hugh
> 
>>
>> I would like to continue having remove_inode_hugepages handle both the
>> truncate and hole punch case.  So, what to make sure the code correctly
>> handles both cases.
>>
>> -- 
>> Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
