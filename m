Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6FB916B0253
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 19:36:29 -0500 (EST)
Received: by padhx2 with SMTP id hx2so115058544pad.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 16:36:29 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id yp1si30755410pbc.152.2015.11.13.16.36.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Nov 2015 16:36:28 -0800 (PST)
Received: by padhx2 with SMTP id hx2so115058345pad.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 16:36:28 -0800 (PST)
Date: Fri, 13 Nov 2015 16:36:21 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm/hugetlb: Unmap pages if page fault raced with hole
 punch
In-Reply-To: <564272AD.10203@oracle.com>
Message-ID: <alpine.LSU.2.11.1511131629330.1310@eggly.anvils>
References: <1446158038-25815-1-git-send-email-mike.kravetz@oracle.com> <alpine.LSU.2.11.1510291937340.5781@eggly.anvils> <56339EBA.4070508@oracle.com> <5633D984.7080307@oracle.com> <alpine.LSU.2.11.1511082310390.15826@eggly.anvils> <5641244F.3060108@oracle.com>
 <564272AD.10203@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>

On Tue, 10 Nov 2015, Mike Kravetz wrote:
> On 11/09/2015 02:55 PM, Mike Kravetz wrote:
> > On 11/08/2015 11:42 PM, Hugh Dickins wrote:
> >> On Fri, 30 Oct 2015, Mike Kravetz wrote:
> >>>
> >>> The 'next = start' code is actually from the original truncate_hugepages
> >>> routine.  This functionality was combined with that needed for hole punch
> >>> to create remove_inode_hugepages().
> >>>
> >>> The following code was in truncate_hugepages:
> >>>
> >>> 	next = start;
> >>> 	while (1) {
> >>> 		if (!pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
> >>> 			if (next == start)
> >>> 				break;
> >>> 			next = start;
> >>> 			continue;
> >>> 		}
> >>>
> >>>
> >>> So, in the truncate case pages starting at 'start' are deleted until
> >>> pagevec_lookup fails.  Then, we call pagevec_lookup() again.  If no
> >>> pages are found we are done.  Else, we repeat the whole process.
> >>>
> >>> Does anyone recall the reason for going back and looking for pages at
> >>> index'es already deleted?  Git doesn't help as that was part of initial
> >>> commit.  My thought is that truncate can race with page faults.  The
> >>> truncate code sets inode offset before unmapping and deleting pages.
> >>> So, faults after the new offset is set should fail.  But, I suppose a
> >>> fault could race with setting offset and deleting of pages.  Does this
> >>> sound right?  Or, is there some other reason I am missing?
> >>
> >> I believe your thinking is correct.  But remember that
> >> truncate_inode_pages_range() is shared by almost all filesystems,
> >> and different filesystems have different internal locking conventions,
> >> and different propensities to such a race: it's trying to cover for
> >> all of them.
> >>
> >> Typically, writing is well serialized (by i_mutex) against truncation,
> >> but faulting (like reading) sails through without enough of a lock.
> >> We resort to i_size checks to avoid the worst of it, but there's often
> >> a corner or two in which those checks are not quite good enough -
> >> it's easy to check i_size at the beginning, but it needs to be checked
> >> again at the end too, and what's been done undone - can be awkward.
> > 
> > Well, it looks like the hugetlb_no_page() routine is checking i_size both
> > before and after.  It appears to be doing the right thing to handle the
> > race, but I need to stare at the code some more to make sure.
> > 
> > Because of the way the truncate code went back and did an extra lookup
> > when done with the range, I assumed it was covering some race.  However,
> > that may not be the case.
> > 
> >>
> >> I hope that in the case of hugetlbfs, since you already have the
> >> additional fault_mutex to handle races between faults and punching,
> >> it should be possible to get away without that "pincer" restarting.
> > 
> > Yes, it looks like this may work as a straight loop over the range of
> > pages.  I just need to study the code some more to make sure I am not
> > missing something.
> 
> I have convinced myself that hugetlb_no_page is coded such that page
> faults can not race with truncate.  hugetlb_no_page handles the case
> where there is no PTE for a faulted in address.  The general flow in
> hugetlb_no_page for the no page found case is:
> - check index against i_size, end if beyond
> - allocate huge page
> - take page table lock for huge page
> - check index against i_size again,  if beyond free page and return
> - add huge page to page table
> - unlock page table lock for huge page
> 
> The flow for the truncate operation in hugetlb_vmtruncate is:
> - set i_size
> - take inode/mapping write lock
> - hugetlb_vmdelete_list() which removes page table entries.  The page
>   table lock will be taken for each huge page in the range
> - release inode/mapping write lock
> - remove_inode_hugepages() to actually remove pages
> 
> The truncate/page fault race we are concerned with is if a page is faulted
> in after hugetlb_vmtruncate sets i_size and unmaps the page, but before
> actually removing the page.  Obviously, any entry into hugetlb_no_page
> after i_size is set will check the value and not allow the fault.  In
> addition, if the value of i_size is set before the second check in
> hugetlb_no_page, it will do the right thing.  Therefore, the only place to
> race is after the second i_size check in hugetlb_no_page.
> 
> Note that the second check for i_size is with the page table lock for
> the huge page held.  It is not possible for hugetlb_vmtruncate to unmap
> the huge page before the page fault completes, as it must acquire the page
> table lock.  This is the same as a fault happening before the truncate
> operation starts and is handled correctly by hugetlb_vmtruncate.
> 
> Another way to look at this is by asking the question, Is it possible to
> fault on a page in the truncate range after it is unmapped by
> hugetlb_vmtruncate/hugetlb_vmdelete_list?  To unmap a page,
> hugetlb_vmtruncate will:
> - set i_size
> - take page table lock for huge page
> - unmap page
> - release page table lock for page
> 
> In order to fault in the page, it must take the same page table lock and
> check i_size.  I do not know of any way for the faulting code to get an
> old value for i_size.
> 
> Please let me know if my reasoning is incorrect.  I will code up a new
> (simpler) version of remove_inode_hugepages with the assumption that
> truncate can not race with page faults.
> 
> Also, I wrote a fairly simple test to have truncate race with page faults.
> It was quite easy to hit the second check in hugetlb_no_page where it
> notices index is beyond i_size and backs out of the fault.  Even after
> adding delays in strategic locations of the fault and truncate code, I
> could not cause a race as observed by remove_inode_hugepages.

Thank you for working it out and writing it down, Mike: I agree with you.

Easy for someone like me to come along and "optimize" something
("ooh, looks like no pte there so let's not take the page table lock"),
but in fact (perhaps) break it.  But that's a criticism of me, not the
code: we couldn't write anything if that were an argument against it!

Ack to your v3 patch coming up now.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
