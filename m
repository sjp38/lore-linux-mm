Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BF8416B002D
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 20:25:50 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] mm: munlock use mapcount to avoid terrible overhead
References: <alpine.LSU.2.00.1110181700400.3361@sister.anvils>
Date: Tue, 18 Oct 2011 17:25:48 -0700
In-Reply-To: <alpine.LSU.2.00.1110181700400.3361@sister.anvils> (Hugh
	Dickins's message of "Tue, 18 Oct 2011 17:02:56 -0700 (PDT)")
Message-ID: <m262jlzv1v.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hugh Dickins <hughd@google.com> writes:

> A process spent 30 minutes exiting, just munlocking the pages of a large
> anonymous area that had been alternately mprotected into page-sized vmas:
> for every single page there's an anon_vma walk through all the other
> little vmas to find the right one.

We had the same problem recently after a mmap+touch workload: in this
case it was hugepaged walking all these anon_vmas and the list was over
100k long. 

Had some data on this at plumbers:
http://halobates.de/plumbers-fork-locks_v2.pdf

> A general fix to that would be a lot more complicated (use prio_tree on
> anon_vma?), but there's one very simple thing we can do to speed up the
> common case: if a page to be munlocked is mapped only once, then it is
> our vma that it is mapped into, and there's no need whatever to walk
> through all the others.

I think we need a generic fix, this problem does not only happen
in munmap. 


-Andi
-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
