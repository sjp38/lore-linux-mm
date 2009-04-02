Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EA5496B003D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 15:39:35 -0400 (EDT)
Date: Thu, 2 Apr 2009 12:39:20 -0700
From: Chris Wright <chrisw@redhat.com>
Subject: Re: [PATCH 0/4] ksm - dynamic page sharing driver for linux
Message-ID: <20090402193920.GF10392@x200.localdomain>
References: <1238457560-7613-1-git-send-email-ieidus@redhat.com> <alpine.LNX.2.00.0904022114040.4265@swampdragon.chaosbits.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.0904022114040.4265@swampdragon.chaosbits.net>
Sender: owner-linux-mm@kvack.org
To: Jesper Juhl <jj@chaosbits.net>
Cc: Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

* Jesper Juhl (jj@chaosbits.net) wrote:
> Do you rely only on the checksum or do you actually compare pages to check 
> they are 100% identical before sharing?

Checksum has absolutely nothing to do w/ finding if two pages match.
It's only used as a heuristic to suggest whether a single page has
changed.  If that page is changing we won't bother trying to find a
match for it.  Here's an example of the life of a page w.r.t checksum.

1. checksum = uninitialized
2. first time page is found, checksum it (checksum = A).
   if checksum has changed (uninitialize != A) don't go any further w/ that page
3. next time page is found, checksum it (checksum = B).
   if checksum has change (A != B) don't go any further w/ that page
4. next time page is found, checksum it (checksum = B).
   if checksum has changed (B == B)...it hasn't, continue processing the
   page

later if a match is found in the tree (which is sorted by _contents_,
i.e. memcmp) we'll attempt to merge the pages which at it's very core
does:

	if (pages_identical(oldpage, newpage))
		ret = replace_page(vma, oldpage, newpage, orig_pte, newprot);

pages_identical?  you guessed it...just does:

	r = memcmp(addr1, addr2, PAGE_SIZE)

thanks,
-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
