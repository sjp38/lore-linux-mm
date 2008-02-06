Date: Wed, 6 Feb 2008 20:33:07 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] sys_remap_file_pages: fix ->vm_file accounting
In-Reply-To: <20080203182135.GA5827@tv-sign.ru>
Message-ID: <Pine.LNX.4.64.0802062023100.32204@blonde.site>
References: <20080130142014.GA2164@tv-sign.ru> <1201712101.31222.22.camel@tucsk.pomaz.szeredi.hu>
 <20080130172646.GA2355@tv-sign.ru> <1201987065.9062.6.camel@localhost.localdomain>
 <20080203182135.GA5827@tv-sign.ru>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oleg Nesterov <oleg@tv-sign.ru>
Cc: Matt Helsley <matthltc@us.ibm.com>, Miklos Szeredi <mszeredi@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, William Lee Irwin III <wli@holomorphy.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 3 Feb 2008, Oleg Nesterov wrote:
> 
> So I have to try to find another bug ;) Suppose that ->load_binary() does
> a series of do_mmap(MAP_EXECUTABLE). It is possible that mmap_region() can
> merge 2 vmas. In that case we "leak" ->num_exe_file_vmas. Unless I missed
> something, mmap_region() should do removed_exe_file_vma() when vma_merge()
> succeds (near fput(file)).

Or there's the complementary case of a VM_EXECUTABLE vma being
split in two, for example by an mprotect of a part of it.

Sorry, Matt, I don't like your patch at all.  It seems to add a fair
amount of ugliness and unmaintainablity, all for a peculiar MVFS case
(you've tried to argue other advantages, but not always convinced!).

And I found it quite hard to see where the crucial difference comes.
I guess it's that MVFS changes vma->vm_file in its ->mmap?  Well, if
MVFS does that, maybe something else does that too, but precisely to
rely on the present behaviour of /proc/pid/exe - so in fixing for
MVFS, we'd be breaking that hypothetical other?

I can understand patches to avoid mmap_sem for /proc/pid/exe, but
this one just seems too messy for too special an out-of-tree case.
(I've no last word on this, but that's my opinion.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
