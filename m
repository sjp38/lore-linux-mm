Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m170Ge4g002541
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 19:16:40 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m170Geqj137284
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 19:16:40 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m170Gesl009988
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 19:16:40 -0500
Subject: Re: [PATCH] sys_remap_file_pages: fix ->vm_file accounting
From: Matt Helsley <matthltc@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0802062023100.32204@blonde.site>
References: <20080130142014.GA2164@tv-sign.ru>
	 <1201712101.31222.22.camel@tucsk.pomaz.szeredi.hu>
	 <20080130172646.GA2355@tv-sign.ru>
	 <1201987065.9062.6.camel@localhost.localdomain>
	 <20080203182135.GA5827@tv-sign.ru>
	 <Pine.LNX.4.64.0802062023100.32204@blonde.site>
Content-Type: text/plain
Date: Wed, 06 Feb 2008 16:16:38 -0800
Message-Id: <1202343398.9062.253.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Oleg Nesterov <oleg@tv-sign.ru>, Miklos Szeredi <mszeredi@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, William Lee Irwin III <wli@holomorphy.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-02-06 at 20:33 +0000, Hugh Dickins wrote:
> On Sun, 3 Feb 2008, Oleg Nesterov wrote:
> > 
> > So I have to try to find another bug ;) Suppose that ->load_binary() does
> > a series of do_mmap(MAP_EXECUTABLE). It is possible that mmap_region() can
> > merge 2 vmas. In that case we "leak" ->num_exe_file_vmas. Unless I missed
> > something, mmap_region() should do removed_exe_file_vma() when vma_merge()
> > succeds (near fput(file)).
> 
> Or there's the complementary case of a VM_EXECUTABLE vma being
> split in two, for example by an mprotect of a part of it.
> 
> Sorry, Matt, I don't like your patch at all.  It seems to add a fair
> amount of ugliness and unmaintainablity, all for a peculiar MVFS case

I thought that getting rid of the separate versions of proc_exe_link()
improved maintainability. Do you have any specific details on what you
think makes the code introduced by the patch unmaintainable?

> (you've tried to argue other advantages, but not always convinced!).

Yup -- looking at how the VM_EXECUTABLE flag affects the vma walk it's
clear one of my arguments was wrong. So I can't blame you for being
unconvinced by that. :)

I still think it would help any stacking filesystems that can't use the
solution adopted by unionfs.

> And I found it quite hard to see where the crucial difference comes.
> I guess it's that MVFS changes vma->vm_file in its ->mmap?  Well, if

Yup.

> MVFS does that, maybe something else does that too, but precisely to
> rely on the present behaviour of /proc/pid/exe - so in fixing for
> MVFS, we'd be breaking that hypothetical other?

	I'm not completely certain that I understand your point. Are you
suggesting that some hypothetical code would want to use this "quirk"
of /proc/pid/exe for a legitimate purpose?

	Assuming that is your point, I thought my non-hypothetical java example
clearly demonstrated that at least one non-hypothetical program doesn't
expect the "quirk" and breaks because of it. Frankly,
given /proc/pid/exe's output in the non-stacking case, I can't see how
its output in the stacking case we're discussing could be considered
anything but buggy.

Cheers,
	-Matt Helsley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
