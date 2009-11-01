Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 48A506B004D
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 05:56:06 -0500 (EST)
Date: Sun, 1 Nov 2009 11:56:01 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: RFC: Transparent Hugepage support
Message-ID: <20091101105601.GE11981@random.random>
References: <20091026185130.GC4868@random.random>
 <alpine.DEB.1.10.0910271630540.20363@V090114053VZO-1>
 <20091027182109.GA5753@random.random>
 <20091027202533.GB2726@sequoia.sous-sol.org>
 <alpine.DEB.1.10.0910291450580.18197@V090114053VZO-1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0910291450580.18197@V090114053VZO-1>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Chris Wright <chrisw@sous-sol.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hello Christoph,

On Thu, Oct 29, 2009 at 02:51:11PM -0400, Christoph Lameter wrote:
> How would glibc do that?

So the first important thing is to start the mapping at 2M aligned
virtual address. Second important thing is to always do sbrk
increments in 2M chunks and mmap extensions in 2M chunks with a mmap
on the next 2M (mremap right now calls split_huge_page but later we
will teach mremap and mprotect not to call split_huge_page and to
handle the pmd_trans_huge natively so they can run a bit faster).

With those two precautions all page faults will be guaranteed to map
2M pages if they're available (and then fragmentation will decrease
too as 2M pages will be retained in the mappings).

Even after split_huge_page, the pte will point to the same 2M page as
before. And when task is killed all 2M pages will be recombined in the
buddy. Page coloring will also be still guaranteed (up to the 512th
color of course) even after split_huge_page run.

But if split_huge_page is called because munmap is unmapping just a 4k
piece of a 2M page, then split_huge_page will be called to free just
that 4k piece so fragmentation will be created. So the last precaution
that glibc should use is to munmap (or madvise_dontneed) in 2M chunks
naturally aligned to make sure not to create unnecessary
fragmentation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
