Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AB6D66B0087
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 19:46:35 -0500 (EST)
Message-ID: <4B7C8DC2.3060004@codeaurora.org>
Date: Wed, 17 Feb 2010 16:45:54 -0800
From: Michael Bohan <mbohan@codeaurora.org>
MIME-Version: 1.0
Subject: Kernel panic due to page migration accessing memory holes
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

Hi,

I have encountered a kernel panic on the ARM/msm platform in the mm 
migration code on 2.6.29.  My memory configuration has two discontiguous 
banks per our ATAG definition.   These banks end up on addresses that 
are 1 MB aligned.  I am using FLATMEM (not SPARSEMEM), but my 
understanding is that SPARSEMEM should not be necessary to support this 
configuration.  Please correct me if I'm wrong.

The crash occurs in mm/page_alloc.c:move_freepages() when being passed a 
start_page that corresponds to the last several megabytes of our first 
memory bank.  The code in move_freepages_block() aligns the passed in 
page number to pageblock_nr_pages, which corresponds to 4 MB.  It then 
passes that aligned pfn as the beginning of a 4 MB range to 
move_freepages().  The problem is that since our bank's end address is 
not 4 MB aligned, the range passed to move_freepages() exceeds the end 
of our memory bank.  The code later blows up when trying to access 
uninitialized page structures.

As a temporary fix, I added some code to move_freepages_block() that 
inspects whether the range exceeds our first memory bank -- returning 0 
if it does.  This is not a clean solution, since it requires exporting 
the ARM specific meminfo structure to extract the bank information.

I see an option exists called CONFIG_HOLES_IN_ZONE, which has control 
over the definition of pfn_valid_within() used in move_freepages().  
This option seems relevant to the problem.  The ia64 architecture has a 
special version of pfn_valid() called ia64_pfn_valid() that is used in 
conjunction with this option.  It appears to inspect the page 
structure's state in a safe way that does not cause a crash, and can 
presumably be used to determine whether the page structure is 
initialized properly.  The ARM version of pfn_valid() used in the 
FLATMEM scenario does not appear to be memory hole aware, and will 
blindly return true in this case.

I have looked on linux-next, and at least the functions mentioned above 
have not changed.

I was curious if there is a stated requirement where memory banks must 
end on 4 MB aligned addresses.  Although I found this problem on ARM, it 
appears upon inspection that the problem could occur on other 
architectures as well, given the memory map assumptions stated above.  
I'm hoping that some mm experts might understand the problem in greater 
detail.

Thanks,
Michael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
