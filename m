Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.12.10/8.12.10) with ESMTP id j8TDEdO0184756
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 13:14:39 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8TDEd9P116626
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 15:14:39 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id j8TDEd7C004251
	for <linux-mm@kvack.org>; Thu, 29 Sep 2005 15:14:39 +0200
Date: Thu, 29 Sep 2005 15:14:49 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [RFC] Guest page hinting patches.
Message-ID: <20050929131449.GA5700@skybase.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

Hi folks,
the guest page hinting code I was talking about on the OLS finally runs
stable on our test system so I created a first set of patches for review.
There are 6 patches against 2.6.13 (yes I know I need to upgrade to
something more recent). I tried to split the patches into meaningful
parts to reduce the complexity of the whole thing a bit.

The patches:
1) Base patch. Introduces most of the common code. It adds two new page
   flags for serializing page state changes and to identify discarded
   pages. I would like to avoid adding page flags but failed to see a
   different solution in both cases. Another point of discussion would
   be the page->mapping/__remove_from_page_cache hack.
2) Mlock and friends. Adds special handling for mlocked pages. I use a
   field in the struct address_space to identify mlocked pages. Any
   betters ideas?
3) Support writable ptes. Adds another page flag (this makes 3 new page
   flags in total ..)
4) Minor fault vs. page state changes. 
5) Discarded page list. Ugly problem of virtual vs. absolute addresses
   on the discard fault. We tried talking the s390 architecture folks
   into providing virtual guest addresses but it seems that this is not
   possible with the current hardware.
6) s390 guest support for guest page hinting.

The patches do not include support for the host side of the equation.
For s390 this is implemented in the z/VM hypervisor. 

So, what do you think?

blue skies,
  Martin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
