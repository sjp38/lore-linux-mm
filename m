Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 33EE18D0039
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 12:58:54 -0500 (EST)
Received: by qwa26 with SMTP id 26so1978259qwa.14
        for <linux-mm@kvack.org>; Fri, 21 Jan 2011 09:58:52 -0800 (PST)
Date: Sat, 22 Jan 2011 02:58:43 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [BUG]thp: BUG at mm/huge_memory.c:1350
Message-ID: <20110121175843.GA1534@barrios-desktop>
References: <20110120154935.GA1760@barrios-desktop>
 <20110120161436.GB21494@random.random>
 <AANLkTikHNcD3aOWKJdPtCqdJi9C34iLPxj5-L8=gqBFc@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTikHNcD3aOWKJdPtCqdJi9C34iLPxj5-L8=gqBFc@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 21, 2011 at 01:41:02AM +0900, Minchan Kim wrote:
> On Fri, Jan 21, 2011 at 1:14 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> > Hello Minchan,
> >
> > On Fri, Jan 21, 2011 at 12:49:35AM +0900, Minchan Kim wrote:
> >> Hi Andrea,
> >>
> >> I hit thg BUG 2 time during 5 booting.
> >> I applied khugepaged: fix pte_unmap for highpte x86_32 based on 2.6.38-rc1.
> >
> > This is again 32bit which rings a bell because clearly it didn't have
> > a whole lot of testing (not remotely comparable to the amount of
> > testing x86-64 had), but it's not necessarily 32bit related. It still
> > would be worth to know if it still happens after you disable
> > CONFIG_HIGHMEM (to rule out 32bit issues in not well tested kmaps).
> >
> 
> I wii try it at tomorrow.

I did it. It doesn't related with HIGHMEM. Still hang.

> 
> > The rmap walk simply didn't find an hugepmd pointing to the page. Or
> > the mapcount was left pinned after the page got somehow unmapped.
> >
> > I wonder why pages are added to swap and the system is so low on
> > memory during boot. How much memory do you have in the 32bit system?
> 
> That was my curiosity, too.
> 
> > Do you boot with something like mem=256m?  This is also the Xorg
> 
> No. I didn't limit mem size. My system has a 2G memory.
> 

I tested it again with some printk and I knew why it is out of memory.

do_page_fault(for write)
-> do_huge_pmd_anonymous_page
        -> alloc_hugepage_vma

Above is repeated by almost 400 times. It means 2M * 400 = 800M usage in my 2G system.
Fragement can cause reclaim.
Interesting one is that above is repeated by same faulty address of same process as looping.

Apparently, do_huge_pmd_anonymous_page maps pmd to entry.
Nonetheless, page faults are repeated by same address.
It seems set_pmd_at is nop.

Do you have any idea?

> > process, which is a bit more special than most and it may have device
> > drivers attached to the pages.
> 
> Both bugs are hit by Xorg.
> I doubt it.

Sometime Xorg, Sometime kswapd, Sometime plymouthd, Sometime fsck.

> 
> >
> > One critical thing is that split_huge_page must be called when
> > splitting vmas, see split_huge_page_address and
> > __vma_adjust_trans_huge, right now it's called from vma_adjust
> > only. If anything is wrong in that function, or if any place adjusting
> > the vma is not covered by that function, it may result in exactly the
> > problem you run into. If drivers are mangling over the vmas that would
> > also explain it.
> >
> > If you happen to have crash dump with vmlinux that would be the best
> > debug option for this, also if you can reproduce it in a VM that will
> > make it easier to reproduce without your hardware. Otherwise we'll
> > find another way.
> 
> I will investigate it after out of office at tomorrow. Sorry but here
> is 1:40 am. :)
> If you have a any guess or good method to investigate the bug, please reply.
> 
> >
> > Thanks a lot,
> > Andrea
> >
> 
> 
> 
> -- 
> Kind regards,
> Minchan Kim

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
