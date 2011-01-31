Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9BA688D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 18:41:53 -0500 (EST)
Date: Tue, 1 Feb 2011 00:41:50 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: wait_split_huge_page() dependence on rmap.h
Message-ID: <20110131234150.GR16981@random.random>
References: <1296516675.7797.5110.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1296516675.7797.5110.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 31, 2011 at 03:31:15PM -0800, Dave Hansen wrote:
> wait_split_huge_page() is really only used in a few spots at the moment.
> I was trying to use it in fs/proc/task_mmu.c, but simply including
> huge_mm.h gets this:
> 
> fs/proc/task_mmu.c: In function a??smaps_pte_rangea??:
> fs/proc/task_mmu.c:392: error: dereferencing pointer to incomplete type

I like what you're doing eheh ;)

> I think it's due to the __anon_vma dereference below.  #including rmap.h
> makes it go away, but I don't think it's really the correct thing to do
> here.  Directly including rmap.h in huge_mm.h ends up with some really
> interesting header dependencies and does not work either.
> 
> Any ideas?  Should we move the existing huge_mm.h stuff to a private
> header and have a more public one that also brings in rmap.h?

Solution:

+#include <linux/rmap.h>

And avoid including an explicit #include huge_mm.h which is never
needed (not even huge_memory.c includes huge_mm.h, rmap.h is all you
need)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
