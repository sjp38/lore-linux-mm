Message-Id: <20080328015238.519230000@nick.local0.net>
Date: Fri, 28 Mar 2008 12:52:38 +1100
From: npiggin@suse.de
Subject: [patch 0/7] 2.6.25-rc5-mm1: VM_MIXEDMAP, pte_special, xip series
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jared Hulbert <jaredeh@gmail.com>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

-- 
Hi,

This series introduces some important infrastructure work that I hope
can go in the next merge window. It has been quite widely reviewed and
has had a bit of testing (I have just tested XIP on brd on 2.6.25-rc5-mm1).

The overall result is that:
1. We now support XIP backed filesystems using memory that have no
   struct page allocated to them. And patches 6 and 7 actually implement
   this for s390.

   This is pretty important in a number of cases. As far as I understand,
   in the case of virtualisation (eg. s390), each guest may mount a
   readonly copy of the same filesystem (eg. the distro). Currently,
   guests need to allocate struct pages for this image. So if you have
   100 guests, you already need to allocate more memory for the struct
   pages than the size of the image. I think. (Carsten?)

   For other (eg. embedded) systems, you may have a very large non-
   volatile filesystem. If you have to have struct pages for this, then
   your RAM consumption will go up proportionally to fs size. Even
   though it is just a small proportion, the RAM can be much more costly
   eg in terms of power, so every KB less that Linux uses makes it more
   attractive to a lot of these guys.

2. VM_MIXEDMAP allows us to support mappings where you actually do want
   to refcount _some_ pages in the mapping, but not others, and support
   COW on arbitrary (non-linear) mappings. Jared needs this for his NVRAM
   filesystem in progress. Future iterations of this filesystem will
   most likely want to migrate pages between pagecache and XIP backing,
   which is where the requirement for mixed (some refcounted, some not)
   comes from.

3. pte_special also has a peripheral usage that I need for my lockless
   get_user_pages patch. That was shown to speed up "oltp" on db2 by
   10% on a 2 socket system, which is kind of significant because they
   scrounge for months to try to find 0.1% improvement on these
   workloads. I'm hoping we might finally be faster than AIX on
   pSeries with this :). My reference to lockless get_user_pages is not
   meant to justify this patchset (which doesn't include lockless gup),
   but just to show that pte_special is not some s390 specific thing that
   should be hidden in arch code or xip code: I definitely want to use it
   on at least x86 and powerpc as well.

There are basically no clashes between mainline and -mm, btw.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
