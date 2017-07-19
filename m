Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2228A6B02C3
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 04:23:19 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w126so2087538wme.10
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 01:23:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v128si3154042wmg.14.2017.07.19.01.23.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 01:23:17 -0700 (PDT)
Date: Wed, 19 Jul 2017 09:23:16 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: TLB batching breaks MADV_DONTNEED
Message-ID: <20170719082316.ceuzf3wt34e6jy3s@suse.de>
References: <B672524C-1D52-4215-89CB-9FF3477600C9@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <B672524C-1D52-4215-89CB-9FF3477600C9@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>

On Tue, Jul 18, 2017 at 10:05:23PM -0700, Nadav Amit wrote:
> Something seems to be really wrong with all these TLB flush batching
> mechanisms that are all around kernel. Here is another example, which was
> not addressed by the recently submitted patches.
> 
> Consider what happens when two MADV_DONTNEED run concurrently. According to
> the man page "After a successful MADV_DONTNEED operation ??? subsequent
> accesses of pages in the range will succeed, but will result in ???
> zero-fill-on-demand pages for anonymous private mappings.???
> 
> However, the test below, which does MADV_DONTNEED in two threads, reads ???8???
> and not ???0??? when reading the memory following MADV_DONTNEED. It happens
> since one of the threads clears the PTE, but defers the TLB flush for some
> time (until it finishes changing 16k PTEs). The main thread sees the PTE
> already non-present and does not flush the TLB.
> 
> I think there is a need for a batching scheme that considers whether
> mmap_sem is taken for write/read/nothing and the change to the PTE.
> Unfortunately, I do not have the time to do it right now.
> 
> Am I missing something? Thoughts?
> 

You're right that in this case, there will be a short window when the old
anonymous data is still available. Non-anonymous doesn't matter in this case
as the if the data is unmapped but available from a stale TLB entry, all it
means is that there is a delay in refetching the data from backing storage.

Technically, DONTNEED is not required to zero-fill the data but in the
case of Linux, it actually does matter because the stale entry is
pointing to page that will be freed shortly. If a caller returns and
uses a stale TLB entry to "reinitialise" the region then the writes may
be lost.

This is independent of the reclaim batching of flushes and specific to
how madvise uses zap_page_range.

The most straight-forward but overkill solution would be to take mmap_sem
for write for madvise. That would have wide-ranging consequences and likely
to be rejected.

A more reasonable solution would be to always flush the TLB range being
madvised when the VMA is a private anonymous mapping to guarantee that
a zero-fill-on-demand region exists. Other mappings do not need special
protection as a parallel access will either use a stale TLB (no permission
change so no problem) or refault the data. Special casing based on
mmap_sem does not make much sense but is also unnecessary.

Something like this completely untested patch that would point in the
general direction if a case can be found where this should be fixed. It
could be optimised to only flush the local TLB but it's probably not worth
the complexity.

diff --git a/mm/madvise.c b/mm/madvise.c
index 9976852f1e1c..78bbe09e549e 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -497,6 +497,18 @@ static long madvise_dontneed_single_vma(struct vm_area_struct *vma,
 					unsigned long start, unsigned long end)
 {
 	zap_page_range(vma, start, end - start);
+
+	/*
+	 * A parallel madvise operation could have unmapped PTEs and deferred
+	 * a flush before this madvise returns. Guarantee the TLB is flushed
+	 * so that an immediate read after madvise will return zero's for
+	 * private anonymous mappings. File-backed shared mappings do not
+	 * matter as they will either use a stale TLB entry or refault the
+	 * data in the event of a race.
+	 */
+	if (vma_is_anonymous(vma))
+		flush_tlb_range(vma, start, end);
+	
 	return 0;
 }
 


-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
