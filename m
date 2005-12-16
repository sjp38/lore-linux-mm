Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.12.10/8.12.10) with ESMTP id jBGL6gec209416
	for <linux-mm@kvack.org>; Fri, 16 Dec 2005 21:06:42 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jBGL6fgi232964
	for <linux-mm@kvack.org>; Fri, 16 Dec 2005 22:06:41 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id jBGL6fWp030526
	for <linux-mm@kvack.org>; Fri, 16 Dec 2005 22:06:41 +0100
Date: Fri, 16 Dec 2005 22:06:44 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [rfc] guest page hinting patches, take #2.
Message-ID: <20051216210644.GA11062@skybase.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

Hi folks,
the first set of patches for the guest page hinting project went
by more or less unnoticed. So I updated the patches against latest
and greatest which is 2.6.15-rc5-mm3. A few bugs have been fixed and
I keep the fingers crossed that I got the update to the -mm tree
right without introducing too many new bugs. Runs ok on my z/VM
system but the real test has been done with linux 2.6.13 + patches,
latest version of the millicode and latest z/VM nucleus. In that
combination it now runs rock solid under heavy stress, and it works
as expected. We have a lot of volatile pages, the hypervisor removes
them on demand and delivers the discard faults. The test with
2.6.15-rc5-mm3 is pending but I'd say the state of affairs is good
enough for another try to get some review. The first sniff test
with the -mm tree showed no unpleasant surprises.

There are again 6 patches, to reduce the complexity a bit:
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

blue skies,
  Martin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
