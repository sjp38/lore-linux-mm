Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8EFE96B0253
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 02:42:20 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so191032976pab.0
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 23:42:20 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id fn10si20714229pab.4.2015.11.08.23.42.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Nov 2015 23:42:19 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so191032731pab.0
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 23:42:19 -0800 (PST)
Date: Sun, 8 Nov 2015 23:42:16 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm/hugetlb: Unmap pages if page fault raced with hole
 punch
In-Reply-To: <5633D984.7080307@oracle.com>
Message-ID: <alpine.LSU.2.11.1511082310390.15826@eggly.anvils>
References: <1446158038-25815-1-git-send-email-mike.kravetz@oracle.com> <alpine.LSU.2.11.1510291937340.5781@eggly.anvils> <56339EBA.4070508@oracle.com> <5633D984.7080307@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>

On Fri, 30 Oct 2015, Mike Kravetz wrote:
> 
> The 'next = start' code is actually from the original truncate_hugepages
> routine.  This functionality was combined with that needed for hole punch
> to create remove_inode_hugepages().
> 
> The following code was in truncate_hugepages:
> 
> 	next = start;
> 	while (1) {
> 		if (!pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
> 			if (next == start)
> 				break;
> 			next = start;
> 			continue;
> 		}
> 
> 
> So, in the truncate case pages starting at 'start' are deleted until
> pagevec_lookup fails.  Then, we call pagevec_lookup() again.  If no
> pages are found we are done.  Else, we repeat the whole process.
> 
> Does anyone recall the reason for going back and looking for pages at
> index'es already deleted?  Git doesn't help as that was part of initial
> commit.  My thought is that truncate can race with page faults.  The
> truncate code sets inode offset before unmapping and deleting pages.
> So, faults after the new offset is set should fail.  But, I suppose a
> fault could race with setting offset and deleting of pages.  Does this
> sound right?  Or, is there some other reason I am missing?

I believe your thinking is correct.  But remember that
truncate_inode_pages_range() is shared by almost all filesystems,
and different filesystems have different internal locking conventions,
and different propensities to such a race: it's trying to cover for
all of them.

Typically, writing is well serialized (by i_mutex) against truncation,
but faulting (like reading) sails through without enough of a lock.
We resort to i_size checks to avoid the worst of it, but there's often
a corner or two in which those checks are not quite good enough -
it's easy to check i_size at the beginning, but it needs to be checked
again at the end too, and what's been done undone - can be awkward.

I hope that in the case of hugetlbfs, since you already have the
additional fault_mutex to handle races between faults and punching,
it should be possible to get away without that "pincer" restarting.

Hugh

> 
> I would like to continue having remove_inode_hugepages handle both the
> truncate and hole punch case.  So, what to make sure the code correctly
> handles both cases.
> 
> -- 
> Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
