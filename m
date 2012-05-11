Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 1C34B6B004D
	for <linux-mm@kvack.org>; Thu, 10 May 2012 21:47:15 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (mailout1.samsung.com [203.254.224.24])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M3U0054V4YIN6I0@mailout1.samsung.com> for
 linux-mm@kvack.org; Fri, 11 May 2012 10:47:13 +0900 (KST)
Received: from NOINKIDAE02 ([165.213.219.102])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M3U00BG24YOP3P0@mmp1.samsung.com> for linux-mm@kvack.org;
 Fri, 11 May 2012 10:47:13 +0900 (KST)
From: Inki Dae <inki.dae@samsung.com>
References: <1335188594-17454-4-git-send-email-inki.dae@samsung.com>
 <1336544259-17222-1-git-send-email-inki.dae@samsung.com>
 <1336544259-17222-3-git-send-email-inki.dae@samsung.com>
 <CAH3drwZBb=XBYpx=Fv=Xv0hajic51V9RwzY_-CpjKDuxgAj9Qg@mail.gmail.com>
 <CAH3drwapwva24oHQOz+3qbNt2CouoVYmUXeFBs4RkL31bvbY3Q@mail.gmail.com>
 <001b01cd2e56$cd620270$68260750$%dae@samsung.com>
 <CAH3drwZOof6Dcqf_Ouxt-D77nGVs_c4w0=6sNW_kAdtZq1SPHg@mail.gmail.com>
 <20120510153133.GC4912@phenom.ffwll.local>
 <CAH3drwY_wapeORCPUMYYG62cYx7LGnCJvUZcUBeMa_hdTEOX3A@mail.gmail.com>
In-reply-to: 
 <CAH3drwY_wapeORCPUMYYG62cYx7LGnCJvUZcUBeMa_hdTEOX3A@mail.gmail.com>
Subject: RE: [PATCH 2/2 v3] drm/exynos: added userptr feature.
Date: Fri, 11 May 2012 10:47:07 +0900
Message-id: <000801cd2f17$fc176f80$f4464e80$%dae@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=ISO-8859-1
Content-transfer-encoding: quoted-printable
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Jerome Glisse' <j.glisse@gmail.com>, linux-mm@kvack.org, kyungmin.park@samsung.com, sw0312.kim@samsung.com, dri-devel@lists.freedesktop.org


> -----Original Message-----
> From: Jerome Glisse [mailto:j.glisse@gmail.com]
> Sent: Friday, May 11, 2012 12:53 AM
> To: Jerome Glisse; Inki Dae; linux-mm@kvack.org;
kyungmin.park@samsung.com;
> sw0312.kim@samsung.com; dri-devel@lists.freedesktop.org
> Subject: Re: [PATCH 2/2 v3] drm/exynos: added userptr feature.
>=20
> On Thu, May 10, 2012 at 11:31 AM, Daniel Vetter <daniel@ffwll.ch> =
wrote:
> > On Thu, May 10, 2012 at 11:05:07AM -0400, Jerome Glisse wrote:
> >> On Wed, May 9, 2012 at 10:44 PM, Inki Dae <inki.dae@samsung.com> =
wrote:
> >> > Hi Jerome,
> >> >
> >> > Thank you again.
> >> >
> >> >> -----Original Message-----
> >> >> From: Jerome Glisse [mailto:j.glisse@gmail.com]
> >> >> Sent: Thursday, May 10, 2012 3:33 AM
> >> >> To: Inki Dae
> >> >> Cc: airlied@linux.ie; dri-devel@lists.freedesktop.org;
> >> >> kyungmin.park@samsung.com; sw0312.kim@samsung.com; linux-
> mm@kvack.org
> >> >> Subject: Re: [PATCH 2/2 v3] drm/exynos: added userptr feature.
> >> >>
> >> >> On Wed, May 9, 2012 at 10:45 AM, Jerome Glisse =
<j.glisse@gmail.com>
> wrote:
> >> >> > On Wed, May 9, 2012 at 2:17 AM, Inki Dae =
<inki.dae@samsung.com>
> wrote:
> >> >> >> this feature is used to import user space region allocated by
> malloc()
> >> >> or
> >> >> >> mmaped into a gem. and to guarantee the pages to user space =
not
> to be
> >> >> >> swapped out, the VMAs within the user space would be locked =
and
> then
> >> >> unlocked
> >> >> >> when the pages are released.
> >> >> >>
> >> >> >> but this lock might result in significant degradation of =
system
> >> >> performance
> >> >> >> because the pages couldn't be swapped out so we limit user-
> desired
> >> >> userptr
> >> >> >> size to pre-defined.
> >> >> >>
> >> >> >> Signed-off-by: Inki Dae <inki.dae@samsung.com>
> >> >> >> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> >> >> >
> >> >> >
> >> >> > Again i would like feedback from mm people (adding cc). I am =
not
> sure
> >> >> > locking the vma is the right anwser as i said in my previous =
mail,
> >> >> > userspace can munlock it in your back, maybe VM_RESERVED is
better.
> >> >> > Anyway even not considering that you don't check at all that
> process
> >> >> > don't go over the limit of locked page see mm/mlock.c
> RLIMIT_MEMLOCK
> >> >> > for how it's done. Also you mlock complete vma but the userptr =
you
> get
> >> >> > might be inside say 16M vma and you only care about 1M of =
userptr,
> if
> >> >> > you mark the whole vma as locked than anytime a new page is =
fault
> in
> >> >> > the vma else where than in the buffer you are interested then =
it
> got
> >> >> > allocated for ever until the gem buffer is destroy, i am not =
sure
> of
> >> >> > what happen to the vma on next malloc if it grows or not (i =
would
> >> >> > think it won't grow at it would have different flags than new
> >> >> > anonymous memory).
> >> >> >
> >> >> > The whole business of directly using malloced memory for gpu =
is
> fishy
> >> >> > and i would really like to get it right rather than relying on
> never
> >> >> > hitting strange things like page migration, vma merging, or =
worse
> >> >> > things like over locking pages and stealing memory.
> >> >> >
> >> >> > Cheers,
> >> >> > Jerome
> >> >>
> >> >> I had a lengthy discussion with mm people (thx a lot for that). =
I
> >> >> think we should split 2 different use case. The zero-copy upload
> case
> >> >> ie :
> >> >> app:
> >> >> =A0 =A0 ptr =3D malloc()
> >> >> =A0 =A0 ...
> >> >> =A0 =A0 glTex/VBO/UBO/...(ptr)
> >> >> =A0 =A0 free(ptr) or reuse it for other things
> >> >> For which i guess you want to avoid having to do a memcpy inside =
the
> >> >> gl library (could be anything else than gl that have same useage
> >> >> pattern).
> >> >>
> >> >
> >> > Right, in this case, we are using the userptr feature as pixman =
and
> evas
> >> > backend to use 2d accelerator.
> >> >
> >> >> ie after the upload happen you don't care about those page they =
can
> >> >> removed from the vma or marked as cow so that anything messing =
with
> >> >> those page after the upload won't change what you uploaded. Of
> course
> >> >
> >> > I'm not sure that I understood your mentions but could the pages =
be
> removed
> >> > from vma with VM_LOCKED or VM_RESERVED? once glTex/VBO/UBO/..., =
the
> VMAs to
> >> > user space would be locked. if cpu accessed significant part of =
all
> the
> >> > pages in user mode then pages to the part would be allocated by =
page
> fault
> >> > handler, after that, through userptr, the VMAs to user address =
space
> would
> >> > be locked(at this time, the remaining pages would be allocated =
also
> by
> >> > get_user_pages by calling page fault handler) I'd be glad to give =
me
> any
> >> > comments and advices if there is my missing point.
> >> >
> >> >> this is assuming that the tlb cost of doing such thing is =
smaller
> than
> >> >> the cost of memcpy the data.
> >> >>
> >> >
> >> > yes, in our test case, the tlb cost(incurred by tlb miss) was =
smaller
> than
> >> > the cost of memcpy also cpu usage. of course, this would be =
depended
> on gpu
> >> > performance.
> >> >
> >> >> Two way to do that, either you assume app can't not read back =
data
> >> >> after gl can and you do an unmap_mapping_range (make sure you =
only
> >> >> unmap fully covered page and that you copy non fully covered =
page)
> or
> >> >> you want to allow userspace to still read data or possibly =
overwrite
> >> >> them
> >> >>
> >> >> Second use case is something more like for the opencl case of
> >> >> CL_MEM_USE_HOST_PTR, in which you want to use the same page in =
the
> gpu
> >> >> and keep the userspace vma pointing to those page. I think the
> >> >> agreement on this case is that there is no way right now to do =
it
> >> >> sanely inside linux kernel. mlocking will need proper accounting
> >> >> against rtlimit but this limit might be low. Also the fork case
> might
> >> >> be problematic.
> >> >>
> >> >> For the fork case the memory is anonymous so it should be COWed =
in
> the
> >> >> fork child but relative to cl context that means the child could =
not
> >> >> use the cl context with that memory or at least if the child =
write
> to
> >> >> this memory the cl will not see those change. I guess the answer =
to
> >> >> that one is that you really need to use the cl api to read the
> object
> >> >> or get proper ptr to read it.
> >> >>
> >> >> Anyway in all case, implementing this userptr thing need a lot =
more
> >> >> code. You have to check to that the vma you are trying to use is
> >> >> anonymous and only handle this case and fallback to alloc new =
page
> and
> >> >> copy otherwise..
> >> >>
> >> >
> >> > I'd like to say thank you again you gave me comments and advices =
in
> detail.
> >> > there may be my missing points but I will check it again.
> >> >
> >> > Thanks,
> >> > Inki Dae
> >> >
> >> >> Cheers,
> >> >> Jerome
> >> >
> >>
> >> I think to sumup things there is 2 use case:
> >> 1: we want to steal anonymous page and move them to a gem/gpu =
object.
> >> So call get_user_pages on the rand and then unmap_mapping_range on =
the
> >> range we want to still page are the function you would want. That
> >> assume of course that the api case your are trying to accelerate is =
ok
> >> with having the user process loosing the content of this buffer. If
> >> it's not the other solution is to mark the range as COW and steal =
the
> >> page, if userspace try to write something new to the range it will =
get
> >> new page (from copy of old one).
> >>
> >> Let call it =A0drm_gem_from_userptr
> >>
> >> 2: you want to be able to use malloced area over long period of =
time
> >> (several minute) with the gpu and you want that userspace vma still
> >> point to those page. It the most problematic case, as i said just
> >> mlocking the vma is troublesome as malicious userspace can munlock =
it
> >> or try to abuse you to mlock too much. I believe right now there is =
no
> >> good way to handle this case. That means that page can't be swaped =
out
> >> or moved as regular anonymous page but on fork or exec this area =
still
> >> need to behave like an anonymous vma.
> >>
> >> Let call drm_gem_backed_by_userptr
> >>
> >> Inki i really think you should split this 2 usecase, and do only =
the
> >> drm_gem_from_userptr if it's enough for what you are trying to do. =
As
> >> the second case look that too many things can go wrong.
> >
> > Jumping into the discussion late: Chris Wilson stitched together a
> userptr
> > feature for i915. Iirc he started with your 1st usecase but quickly
> > noticed that doing all this setup stuff (get_user_pages alone, he =
didn't
> > include your proposed cow trick) is too expensive and it's cheaper =
to
> just
> > upload things with the cpu.
>=20
> I think use case 1 can still be usefull on desktop x86 but the object
> need to be big something like bigger 16M or probably even bigger, so
> that the cost of memcpy is bigger than the cost of tlb trashing. I am
> sure than once we are seeing 1G dataset of opencl we will want to use
> the stealing code path rather than memcpy things. Sadly API like CL
> and GL don't make provision saying that the data ptr user supplied
> might not have the content anymore so it makes the cow trick kind of
> needed but it kills usecase such as :
> scratch =3D malloc()
> for (i =3D0; i<numtex; i++){
>    readtexture(scratch, texfilename[i])
>    glteximage(scratch)
> }
> free(scratch)
>=20
> Or anything with similar access, here obviously the page backing the
> scratch area can be stole at each glteximage call.
>=20
> Anyway if you can define your api and provision that after call the
> data you provided is no longer available then use case 1 sounds doable
> and worth it to me.
>=20

How about forcing VM_DONTCOPY not to copy the vma on fork? this flag may
prevent doing COW. and I was talked that get_user_pages call avoid the =
pages
from being swapped out, not using mlock. if all the pages from
get_user_pages are MOVABLE then CMA would try to migrate movable pages =
into
reserved space for DMA once device driver tries allocation through dma =
api
so if we could prevent the pages from being moved by CMA and we limit
maximum size for userptr(accessed by only root user) then I guess that =
we
could avoid these issues. there may be many things I don't care so =
please
give me any comments and advices.

Thanks,
Inki Dae


> > So he needs to keep around these mappings for essentially forever to
> > amortize the setup cost, which boils down to your 2nd use-case. I've
> > refused to merge that code since, like you point out, too much stuff =
can
> > go wrong when we pin arbitrary ranges of userspace.
> >
> > One example which would only affect ARM platforms is that this would
> > horribly break CMA: Userspace malloc is allocated as GFP_MOVEABLE, =
and
> CMA
> > relies on migrating moveable pages out of the CMA region to handle =
large
> > contigious allocations. Currently the page migrate code simply backs
> down
> > and waits a bit if it encounters a page locked by get_user_pages,
> assuming
> > that this is due to io and will complete shortly. If you hold onto =
such
> > pages for a long time, that retry will eventually fail and break =
CMA.
> >
> > There are other problems affecting also desktop machines, but I've
> figured
> > I'll pick something that really hurts on arm ;-)
> >
> > Yours, Daniel
> > --
> > Daniel Vetter
> > Mail: daniel@ffwll.ch
> > Mobile: +41 (0)79 365 57 48
>=20
> Yes, what i also wanted to stress is that get_user_pages is not
> enough, we are not doing something over the period of an ioctl in
> which case everything is fine and doable, but are stealing page and
> expect to use them at random point in the future with no kind of
> synchronization with userspace. Anyway i think we agree that this
> second use case is way complex and many things can go wrong, i still
> think that for opencl we might want to able to do it but by them i am
> expecting we will take advantage of iommu being able to pagefault from
> process pagetable like the next AMD iommu can.
>=20
> Cheers,
> Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
