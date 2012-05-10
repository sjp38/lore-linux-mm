Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id AB1946B00F4
	for <linux-mm@kvack.org>; Thu, 10 May 2012 11:30:26 -0400 (EDT)
Received: by wibhn9 with SMTP id hn9so565110wib.8
        for <linux-mm@kvack.org>; Thu, 10 May 2012 08:30:25 -0700 (PDT)
Date: Thu, 10 May 2012 17:31:33 +0200
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH 2/2 v3] drm/exynos: added userptr feature.
Message-ID: <20120510153133.GC4912@phenom.ffwll.local>
References: <1335188594-17454-4-git-send-email-inki.dae@samsung.com>
 <1336544259-17222-1-git-send-email-inki.dae@samsung.com>
 <1336544259-17222-3-git-send-email-inki.dae@samsung.com>
 <CAH3drwZBb=XBYpx=Fv=Xv0hajic51V9RwzY_-CpjKDuxgAj9Qg@mail.gmail.com>
 <CAH3drwapwva24oHQOz+3qbNt2CouoVYmUXeFBs4RkL31bvbY3Q@mail.gmail.com>
 <001b01cd2e56$cd620270$68260750$%dae@samsung.com>
 <CAH3drwZOof6Dcqf_Ouxt-D77nGVs_c4w0=6sNW_kAdtZq1SPHg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAH3drwZOof6Dcqf_Ouxt-D77nGVs_c4w0=6sNW_kAdtZq1SPHg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Inki Dae <inki.dae@samsung.com>, linux-mm@kvack.org, kyungmin.park@samsung.com, sw0312.kim@samsung.com, dri-devel@lists.freedesktop.org

On Thu, May 10, 2012 at 11:05:07AM -0400, Jerome Glisse wrote:
> On Wed, May 9, 2012 at 10:44 PM, Inki Dae <inki.dae@samsung.com> wrote:
> > Hi Jerome,
> >
> > Thank you again.
> >
> >> -----Original Message-----
> >> From: Jerome Glisse [mailto:j.glisse@gmail.com]
> >> Sent: Thursday, May 10, 2012 3:33 AM
> >> To: Inki Dae
> >> Cc: airlied@linux.ie; dri-devel@lists.freedesktop.org;
> >> kyungmin.park@samsung.com; sw0312.kim@samsung.com; linux-mm@kvack.org
> >> Subject: Re: [PATCH 2/2 v3] drm/exynos: added userptr feature.
> >>
> >> On Wed, May 9, 2012 at 10:45 AM, Jerome Glisse <j.glisse@gmail.com> wrote:
> >> > On Wed, May 9, 2012 at 2:17 AM, Inki Dae <inki.dae@samsung.com> wrote:
> >> >> this feature is used to import user space region allocated by malloc()
> >> or
> >> >> mmaped into a gem. and to guarantee the pages to user space not to be
> >> >> swapped out, the VMAs within the user space would be locked and then
> >> unlocked
> >> >> when the pages are released.
> >> >>
> >> >> but this lock might result in significant degradation of system
> >> performance
> >> >> because the pages couldn't be swapped out so we limit user-desired
> >> userptr
> >> >> size to pre-defined.
> >> >>
> >> >> Signed-off-by: Inki Dae <inki.dae@samsung.com>
> >> >> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> >> >
> >> >
> >> > Again i would like feedback from mm people (adding cc). I am not sure
> >> > locking the vma is the right anwser as i said in my previous mail,
> >> > userspace can munlock it in your back, maybe VM_RESERVED is better.
> >> > Anyway even not considering that you don't check at all that process
> >> > don't go over the limit of locked page see mm/mlock.c RLIMIT_MEMLOCK
> >> > for how it's done. Also you mlock complete vma but the userptr you get
> >> > might be inside say 16M vma and you only care about 1M of userptr, if
> >> > you mark the whole vma as locked than anytime a new page is fault in
> >> > the vma else where than in the buffer you are interested then it got
> >> > allocated for ever until the gem buffer is destroy, i am not sure of
> >> > what happen to the vma on next malloc if it grows or not (i would
> >> > think it won't grow at it would have different flags than new
> >> > anonymous memory).
> >> >
> >> > The whole business of directly using malloced memory for gpu is fishy
> >> > and i would really like to get it right rather than relying on never
> >> > hitting strange things like page migration, vma merging, or worse
> >> > things like over locking pages and stealing memory.
> >> >
> >> > Cheers,
> >> > Jerome
> >>
> >> I had a lengthy discussion with mm people (thx a lot for that). I
> >> think we should split 2 different use case. The zero-copy upload case
> >> ie :
> >> app:
> >>     ptr = malloc()
> >>     ...
> >>     glTex/VBO/UBO/...(ptr)
> >>     free(ptr) or reuse it for other things
> >> For which i guess you want to avoid having to do a memcpy inside the
> >> gl library (could be anything else than gl that have same useage
> >> pattern).
> >>
> >
> > Right, in this case, we are using the userptr feature as pixman and evas
> > backend to use 2d accelerator.
> >
> >> ie after the upload happen you don't care about those page they can
> >> removed from the vma or marked as cow so that anything messing with
> >> those page after the upload won't change what you uploaded. Of course
> >
> > I'm not sure that I understood your mentions but could the pages be removed
> > from vma with VM_LOCKED or VM_RESERVED? once glTex/VBO/UBO/..., the VMAs to
> > user space would be locked. if cpu accessed significant part of all the
> > pages in user mode then pages to the part would be allocated by page fault
> > handler, after that, through userptr, the VMAs to user address space would
> > be locked(at this time, the remaining pages would be allocated also by
> > get_user_pages by calling page fault handler) I'd be glad to give me any
> > comments and advices if there is my missing point.
> >
> >> this is assuming that the tlb cost of doing such thing is smaller than
> >> the cost of memcpy the data.
> >>
> >
> > yes, in our test case, the tlb cost(incurred by tlb miss) was smaller than
> > the cost of memcpy also cpu usage. of course, this would be depended on gpu
> > performance.
> >
> >> Two way to do that, either you assume app can't not read back data
> >> after gl can and you do an unmap_mapping_range (make sure you only
> >> unmap fully covered page and that you copy non fully covered page) or
> >> you want to allow userspace to still read data or possibly overwrite
> >> them
> >>
> >> Second use case is something more like for the opencl case of
> >> CL_MEM_USE_HOST_PTR, in which you want to use the same page in the gpu
> >> and keep the userspace vma pointing to those page. I think the
> >> agreement on this case is that there is no way right now to do it
> >> sanely inside linux kernel. mlocking will need proper accounting
> >> against rtlimit but this limit might be low. Also the fork case might
> >> be problematic.
> >>
> >> For the fork case the memory is anonymous so it should be COWed in the
> >> fork child but relative to cl context that means the child could not
> >> use the cl context with that memory or at least if the child write to
> >> this memory the cl will not see those change. I guess the answer to
> >> that one is that you really need to use the cl api to read the object
> >> or get proper ptr to read it.
> >>
> >> Anyway in all case, implementing this userptr thing need a lot more
> >> code. You have to check to that the vma you are trying to use is
> >> anonymous and only handle this case and fallback to alloc new page and
> >> copy otherwise..
> >>
> >
> > I'd like to say thank you again you gave me comments and advices in detail.
> > there may be my missing points but I will check it again.
> >
> > Thanks,
> > Inki Dae
> >
> >> Cheers,
> >> Jerome
> >
> 
> I think to sumup things there is 2 use case:
> 1: we want to steal anonymous page and move them to a gem/gpu object.
> So call get_user_pages on the rand and then unmap_mapping_range on the
> range we want to still page are the function you would want. That
> assume of course that the api case your are trying to accelerate is ok
> with having the user process loosing the content of this buffer. If
> it's not the other solution is to mark the range as COW and steal the
> page, if userspace try to write something new to the range it will get
> new page (from copy of old one).
> 
> Let call it  drm_gem_from_userptr
> 
> 2: you want to be able to use malloced area over long period of time
> (several minute) with the gpu and you want that userspace vma still
> point to those page. It the most problematic case, as i said just
> mlocking the vma is troublesome as malicious userspace can munlock it
> or try to abuse you to mlock too much. I believe right now there is no
> good way to handle this case. That means that page can't be swaped out
> or moved as regular anonymous page but on fork or exec this area still
> need to behave like an anonymous vma.
> 
> Let call drm_gem_backed_by_userptr
> 
> Inki i really think you should split this 2 usecase, and do only the
> drm_gem_from_userptr if it's enough for what you are trying to do. As
> the second case look that too many things can go wrong.

Jumping into the discussion late: Chris Wilson stitched together a userptr
feature for i915. Iirc he started with your 1st usecase but quickly
noticed that doing all this setup stuff (get_user_pages alone, he didn't
include your proposed cow trick) is too expensive and it's cheaper to just
upload things with the cpu.

So he needs to keep around these mappings for essentially forever to
amortize the setup cost, which boils down to your 2nd use-case. I've
refused to merge that code since, like you point out, too much stuff can
go wrong when we pin arbitrary ranges of userspace.

One example which would only affect ARM platforms is that this would
horribly break CMA: Userspace malloc is allocated as GFP_MOVEABLE, and CMA
relies on migrating moveable pages out of the CMA region to handle large
contigious allocations. Currently the page migrate code simply backs down
and waits a bit if it encounters a page locked by get_user_pages, assuming
that this is due to io and will complete shortly. If you hold onto such
pages for a long time, that retry will eventually fail and break CMA.

There are other problems affecting also desktop machines, but I've figured
I'll pick something that really hurts on arm ;-)

Yours, Daniel
-- 
Daniel Vetter
Mail: daniel@ffwll.ch
Mobile: +41 (0)79 365 57 48

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
