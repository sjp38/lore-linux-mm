Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.6/8.13.6) with ESMTP id k3OCY8F1020298
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 12:34:08 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3OCZCGv102290
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 14:35:13 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k3OCY8sx005179
	for <linux-mm@kvack.org>; Mon, 24 Apr 2006 14:34:08 +0200
Date: Mon, 24 Apr 2006 14:34:12 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Page host virtual assist patches.
Message-ID: <20060424123412.GA15817@skybase>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, akpm@osdl.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

Third version of the page host virtual assist patches. The code has
been reduced in size, and (hopefully) the last races have been fixed.

The basic idea of host virtual assist (hva) is to give a host system
which virtualizes the memory of its guest systems on a per page basis
usage information for the guest pages. The host can then use this
information to optimize the management of guest pages, in particular
the paging. This optimizations can be used for unused (free) guest
pages, for clean page cache pages, and for clean swap cache pages.
The content of free pages can be replace with zeroes and the content
of clean page cache / swap cache pages can be reloaded by the guest
from the backing store.

There are 8 patches that implement hva:

1) Hva state changes for free pages.
2) Hva state changes for page cache pages.
3) Hva state changes for swap cache pages.
4) Keep mlocked pages in stable state.
5) Add support for writable page table entries.
6) Optimization for minor faults.
7) Discarded page list.
8) s390 architecture support for hva.

>From my point of view the patches have reached a state where they
can be considered for wider propagation. Unfortunatly I did not
get any feedback for the prior two versions of the patches, neither
negative nor positive.
I'm currently running -rc1-mm3 with the patches enabled on my s390
test systems and on my thinkpad (without CONFIG_PAGE_HVA). It works
as advertised on s390 and for i386 I could not find any negative
effects. The only noticable changes for i386 is that a bit of code
has moved out of try_to_unmap_one to the callers of the function
to make it usable for hva as well (see patch #02 page_hva_unmap_all
for details). This increases the size of the kernel image by a few
bytes.

Any chance to get the patches included into the -mm tree?

-- 
blue skies,
  Martin.

Martin Schwidefsky
Linux for zSeries Development & Services
IBM Deutschland Entwicklung GmbH

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
