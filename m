Received: from sunsite.ms.mff.cuni.cz (sunsite.ms.mff.cuni.cz [195.113.19.66])
	by kvack.org (8.8.7/8.8.7) with ESMTP id DAA11611
	for <linux-mm@kvack.org>; Wed, 26 May 1999 03:43:44 -0400
Date: Wed, 26 May 1999 09:44:07 +0200
From: Jakub Jelinek <jj@sunsite.ms.mff.cuni.cz>
Subject: Re: [PATCH] cache large files in the page cache
Message-ID: <19990526094407.J527@mff.cuni.cz>
References: <m17lpzsi0h.fsf@flinx.ccr.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m17lpzsi0h.fsf@flinx.ccr.net>; from Eric W. Biederman on Sun, May 23, 1999 at 02:28:14PM -0500
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Details:
> 
> This patch replaces vm_offset with vm_index, with the relationship:
> vm_offset == (vm_index << PAGE_SHIFT).  Except vm_index can hold larger
> offsets.

I have minor suggestion to the patch. Instead of using vm_index <<
PAGE_SHIFT and page->key << PAGE_CACHE_SHIFT shifts either choose different
constant names for this shifting (VM_INDEX_SHIFT and PAGE_KEY_SHIFT) or hide
these shifts by some pretty macros (you'll need two for each for both
directions in that case - if you go the macro way, maybe it would be a good
idea to make vm_index and key type some structure with a single member like
mm_segment_t for more strict typechecking). This would have the advantage of
avoiding shifting on 64bit archs, where it really is not necessary as no
filesystem will support 16000EB filesizes in the near future. I know shifts
are not expensive, on the other side count how many there will be and IMHO
it should be considered. It could make the code more readable at the same
time. VM_INDEX_SHIFT would be defined to 0 on alpha,sparc64
(merced,mips64,ppc64) and PAGE_SHIFT on other platforms. The same with
PAGE_KEY_SHIFT.

Cheers,
    Jakub
___________________________________________________________________
Jakub Jelinek | jj@sunsite.mff.cuni.cz | http://sunsite.mff.cuni.cz
Administrator of SunSITE Czech Republic, MFF, Charles University
___________________________________________________________________
UltraLinux  |  http://ultra.linux.cz/  |  http://ultra.penguin.cz/
Linux version 2.3.3 on a sparc64 machine (1343.49 BogoMips)
___________________________________________________________________
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
