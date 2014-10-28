Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 540B9900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 06:42:58 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id a1so463718wgh.18
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 03:42:57 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id t8si6784183wiy.69.2014.10.28.03.42.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 28 Oct 2014 03:42:55 -0700 (PDT)
Date: Tue, 28 Oct 2014 11:42:45 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v9 11/12] x86, mpx: cleanup unused bound tables
In-Reply-To: <544F300B.7050002@intel.com>
Message-ID: <alpine.DEB.2.11.1410281044420.5308@nanos>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-12-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.11.1410241451280.5308@nanos> <544DB873.1010207@intel.com> <alpine.DEB.2.11.1410272138540.5308@nanos>
 <544F300B.7050002@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ren Qiaowei <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org

On Tue, 28 Oct 2014, Ren Qiaowei wrote:
> On 10/28/2014 04:49 AM, Thomas Gleixner wrote:
> > On Mon, 27 Oct 2014, Ren Qiaowei wrote:
> > > If so, I guess that there are some questions needed to be considered:
> > > 
> > > 1) Almost all palces which call do_munmap() will need to add
> > > mpx_pre_unmap/post_unmap calls, like vm_munmap(), mremap(), shmdt(), etc..
> > 
> > What's the problem with that?
> > 
> 
> For example:
> 
> shmdt()
>     down_write(mm->mmap_sem);
>     vma = find_vma();
>     while (vma)
>         do_munmap();
>     up_write(mm->mmap_sem);
> 
> We could not simply add mpx_pre_unmap() before do_munmap() or down_write().
> And seems like it is a little hard for shmdt() to be changed to match this
> solution, right?

Everything which does not fall in place right away seems to be a
little hard, heavy weight or whatever excuses you have for it.

It's not that hard, really. We can simply split out the search code
into a seperate function and use it for both problems.

Yes, it is quite some work to do, but its straight forward.

> > > 3) According to Dave, those bounds tables related to adjacent VMAs within
> > > the
> > > start and the end possibly don't have to be fully unmmaped, and we only
> > > need
> > > free the part of backing physical memory.
> > 
> > Care to explain why that's a problem?
> > 
> 
> I guess you mean one new field mm->bd_remove_vmas should be added into staruct
> mm, right?

That was just to demonstrate the approach. I'm giving you a hint how
to do it, I'm not telling you what the exact solution will be. If I
need to do that, then I can implement it myself right away.

> For those VMAs which we only need to free part of backing physical memory, we
> could not clear bounds directory entries and should also mark the range of
> backing physical memory within this vma. If so, maybe there are too many new
> fields which will be added into mm struct, right?

If we need more data to carry over from pre to post, we can allocate a
proper data structure and just add a pointer to that to mm. And it's
not written in stone, that you need to carry that information from pre
to post. You could do the unmap/zap work in the pre phase already and
reduce mpx_post_unmap() to up_write(mm->bt_sem).

I gave you an idea and the center point of that idea is to have a
separate rwsem to protect against the various races, fault handling
etc. You still have to think about the implementation details.

Thanks,

	tglx






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
