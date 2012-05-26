Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 1D7596B0081
	for <linux-mm@kvack.org>; Sat, 26 May 2012 19:56:29 -0400 (EDT)
Date: Sun, 27 May 2012 01:54:47 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: mm: kernel BUG at mm/memory.c:1230
Message-ID: <20120526235447.GA4016@redhat.com>
References: <1337884054.3292.22.camel@lappy>
 <20120524120727.6eab2f97.akpm@linux-foundation.org>
 <CA+1xoqcbZWLpvHkOsZY7rijsaryFDvh=pqq=QyDDgo_NfPyCpA@mail.gmail.com>
 <alpine.LSU.2.00.1205261317310.2488@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1205261317310.2488@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, viro <viro@zeniv.linux.org.uk>, oleg@redhat.com, "a.p.zijlstra" <a.p.zijlstra@chello.nl>, mingo <mingo@kernel.org>, Dave Jones <davej@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

Hello everyone,

On Sat, May 26, 2012 at 01:26:48PM -0700, Hugh Dickins wrote:
> I've been round this loop before with that particular VM_BUG_ON.
> 
> At first I thought like Andrew, that it's glaringly wrong on the exit
> path; but then changed my mind.
> 
> When munmapping, we certainly can arrive here with an unaligned addr
> and next; but in that case rwsem_is_locked.
> 
> Whereas in exiting, rwsem is not locked, but we're going linearly upwards,
> and whenever we walk into a pmd_trans_huge area, both addr and next should
> be hpage aligned: the vma bounds are unsuited to THP if they're unaligned.
> 
> Other cases equally should not arise: madvise MADV_DONTNEED should
> have rwsem_is_locked; and truncation or hole-punching shouldn't be
> possible on a pure-anonymous (!vma->vm_ops) area considered for THP.
> 
> But I cannot remember what brought me here before: a crash in testing
> on one of my machines, which further investigation root-caused elsewhere?
> or a report from someone else? or noticed when auditing another problem?
> I'm frustrated not to recall.

I agree it's not a false positive.

The reason I introduced that VM_BUG_ON was to verify if any
vma_adjust_trans_huge() was missing anywhere (so that it doesn't crash
later in split_huge_page with an obscure mapcount != page_mapcount
BUG_ON, there it would be much less obvious to see why it crashed than
here).

We should printk addr, end and the vma->vm_start/vm_end to debug this
further.

> > I'm not sure if that's indeed the issue or not, but note that this is
> > the first time I've managed to trigger that with the fuzzer, and it's
> > not that easy to reproduce. Which is a bit odd for code that was there
> > for 4 months...
> 
> I'm keeping off the linux-next for the moment; I'll worry about this
> more if it shows up when we try 3.5-rc1.  Your fuzzing tells that my
> logic above is wrong, but maybe it's just a passing defect in next.

If it's a missing vma_adjust_trans_huge() it shouldn't go unnoticed
even with DEBUG_VM=n, so I agree that if it only happens on linux-next
it's worth trying to reproduce it with 3.5-rc/3.4 too just in
case. It's actually the first time I hear of this bugcheck triggering.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
