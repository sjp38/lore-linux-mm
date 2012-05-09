Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 31DC26B004D
	for <linux-mm@kvack.org>; Wed,  9 May 2012 14:32:57 -0400 (EDT)
Received: by yenm7 with SMTP id m7so861137yen.14
        for <linux-mm@kvack.org>; Wed, 09 May 2012 11:32:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAH3drwZBb=XBYpx=Fv=Xv0hajic51V9RwzY_-CpjKDuxgAj9Qg@mail.gmail.com>
References: <1335188594-17454-4-git-send-email-inki.dae@samsung.com>
	<1336544259-17222-1-git-send-email-inki.dae@samsung.com>
	<1336544259-17222-3-git-send-email-inki.dae@samsung.com>
	<CAH3drwZBb=XBYpx=Fv=Xv0hajic51V9RwzY_-CpjKDuxgAj9Qg@mail.gmail.com>
Date: Wed, 9 May 2012 14:32:55 -0400
Message-ID: <CAH3drwapwva24oHQOz+3qbNt2CouoVYmUXeFBs4RkL31bvbY3Q@mail.gmail.com>
Subject: Re: [PATCH 2/2 v3] drm/exynos: added userptr feature.
From: Jerome Glisse <j.glisse@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Inki Dae <inki.dae@samsung.com>
Cc: airlied@linux.ie, dri-devel@lists.freedesktop.org, kyungmin.park@samsung.com, sw0312.kim@samsung.com, linux-mm@kvack.org

On Wed, May 9, 2012 at 10:45 AM, Jerome Glisse <j.glisse@gmail.com> wrote:
> On Wed, May 9, 2012 at 2:17 AM, Inki Dae <inki.dae@samsung.com> wrote:
>> this feature is used to import user space region allocated by malloc() or
>> mmaped into a gem. and to guarantee the pages to user space not to be
>> swapped out, the VMAs within the user space would be locked and then unlocked
>> when the pages are released.
>>
>> but this lock might result in significant degradation of system performance
>> because the pages couldn't be swapped out so we limit user-desired userptr
>> size to pre-defined.
>>
>> Signed-off-by: Inki Dae <inki.dae@samsung.com>
>> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
>
>
> Again i would like feedback from mm people (adding cc). I am not sure
> locking the vma is the right anwser as i said in my previous mail,
> userspace can munlock it in your back, maybe VM_RESERVED is better.
> Anyway even not considering that you don't check at all that process
> don't go over the limit of locked page see mm/mlock.c RLIMIT_MEMLOCK
> for how it's done. Also you mlock complete vma but the userptr you get
> might be inside say 16M vma and you only care about 1M of userptr, if
> you mark the whole vma as locked than anytime a new page is fault in
> the vma else where than in the buffer you are interested then it got
> allocated for ever until the gem buffer is destroy, i am not sure of
> what happen to the vma on next malloc if it grows or not (i would
> think it won't grow at it would have different flags than new
> anonymous memory).
>
> The whole business of directly using malloced memory for gpu is fishy
> and i would really like to get it right rather than relying on never
> hitting strange things like page migration, vma merging, or worse
> things like over locking pages and stealing memory.
>
> Cheers,
> Jerome

I had a lengthy discussion with mm people (thx a lot for that). I
think we should split 2 different use case. The zero-copy upload case
ie :
app:
    ptr = malloc()
    ...
    glTex/VBO/UBO/...(ptr)
    free(ptr) or reuse it for other things
For which i guess you want to avoid having to do a memcpy inside the
gl library (could be anything else than gl that have same useage
pattern).

ie after the upload happen you don't care about those page they can
removed from the vma or marked as cow so that anything messing with
those page after the upload won't change what you uploaded. Of course
this is assuming that the tlb cost of doing such thing is smaller than
the cost of memcpy the data.

Two way to do that, either you assume app can't not read back data
after gl can and you do an unmap_mapping_range (make sure you only
unmap fully covered page and that you copy non fully covered page) or
you want to allow userspace to still read data or possibly overwrite
them

Second use case is something more like for the opencl case of
CL_MEM_USE_HOST_PTR, in which you want to use the same page in the gpu
and keep the userspace vma pointing to those page. I think the
agreement on this case is that there is no way right now to do it
sanely inside linux kernel. mlocking will need proper accounting
against rtlimit but this limit might be low. Also the fork case might
be problematic.

For the fork case the memory is anonymous so it should be COWed in the
fork child but relative to cl context that means the child could not
use the cl context with that memory or at least if the child write to
this memory the cl will not see those change. I guess the answer to
that one is that you really need to use the cl api to read the object
or get proper ptr to read it.

Anyway in all case, implementing this userptr thing need a lot more
code. You have to check to that the vma you are trying to use is
anonymous and only handle this case and fallback to alloc new page and
copy otherwise..

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
