Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 6B1786B00E7
	for <linux-mm@kvack.org>; Tue, 15 May 2012 10:31:31 -0400 (EDT)
Received: by ggm4 with SMTP id 4so4550837ggm.14
        for <linux-mm@kvack.org>; Tue, 15 May 2012 07:31:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <000701cd3253$cfab8050$6f0280f0$%dae@samsung.com>
References: <1336544259-17222-1-git-send-email-inki.dae@samsung.com>
	<1336976268-14328-1-git-send-email-inki.dae@samsung.com>
	<1336976268-14328-3-git-send-email-inki.dae@samsung.com>
	<CAH3drwb13T2RXgEuauGchoZUDAgL+wrv3SR66sZNyGk_6tRTFw@mail.gmail.com>
	<000701cd3253$cfab8050$6f0280f0$%dae@samsung.com>
Date: Tue, 15 May 2012 10:31:29 -0400
Message-ID: <CAH3drwZcBY71FpFAhqAaXWCWR4vBPi2PRqh034DBJ_NiffQztA@mail.gmail.com>
Subject: Re: [PATCH 2/2 v4] drm/exynos: added userptr feature.
From: Jerome Glisse <j.glisse@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Inki Dae <inki.dae@samsung.com>
Cc: airlied@linux.ie, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, minchan@kernel.org, kosaki.motohiro@gmail.com, kyungmin.park@samsung.com, sw0312.kim@samsung.com, jy0922.shim@samsung.com

On Tue, May 15, 2012 at 12:33 AM, Inki Dae <inki.dae@samsung.com> wrote:
> Hi Jerome,
>
>> -----Original Message-----
>> From: Jerome Glisse [mailto:j.glisse@gmail.com]
>> Sent: Tuesday, May 15, 2012 4:27 AM
>> To: Inki Dae
>> Cc: airlied@linux.ie; dri-devel@lists.freedesktop.org; minchan@kernel.org;
>> kosaki.motohiro@gmail.com; kyungmin.park@samsung.com;
>> sw0312.kim@samsung.com; jy0922.shim@samsung.com
>> Subject: Re: [PATCH 2/2 v4] drm/exynos: added userptr feature.
>>
>> On Mon, May 14, 2012 at 2:17 AM, Inki Dae <inki.dae@samsung.com> wrote:
>> > this feature is used to import user space region allocated by malloc()
>> or
>> > mmaped into a gem. for this, we uses get_user_pages() to get all the
>> pages
>> > to VMAs within user address space. However we should pay attention to
>> use
>> > this userptr feature like below.
>> >
>> > The migration issue.
>> > - Pages reserved by CMA for some device using DMA could be used by
>> > kernel and if the device driver wants to use those pages
>> > while being used by kernel then the pages are copied into
>> > other ones allocated to migrate them and then finally,
>> > the device driver can use the pages for itself.
>> > Thus, migrated, the pages being accessed by DMA could be changed
>> > to other so this situation may incur that DMA accesses any pages
>> > it doesn't want.
>> >
>> > The COW issue.
>> > - while DMA of a device is using the pages to VMAs, if current
>> > process was forked then the pages being accessed by the DMA
>> > would be copied into child's pages.(Copy On Write) so
>> > these pages may not have coherrency with parent's ones if
>> > child process wrote something on those pages so we need to
>> > flag VM_DONTCOPY to prevent pages from being COWed.
>>
>> Note that this is a massive change in behavior of anonymous mapping
>> this effectively completely change the linux API from application
>> point of view on your platform. Any application that have memory
>> mapped by your ioctl will have different fork behavior that other
>> application. I think this should be stressed, it's one of the thing i
>> am really uncomfortable with i would rather not have the dont copy
>> flag and have the page cowed and have the child not working with the
>> 3d/2d/drm driver. That would means that your driver (opengl
>> implementation for instance) would have to detect fork and work around
>> it, nvidia closed source driver do that.
>>
>
> First of all, thank you for your comments.
>
> Right, VM_DONTCOPY flag would change original behavior of user. Do you think
> this way has no problem but no generic way? anyway our issue was that the
> pages to VMAs are copied into child's ones(COW) so we prevented those pages
> from being COWed with using VM_DONTCOPY flag.
>
> For this, I have three questions below
>
> 1. in case of not using VM_DONTCOPY flag, you think that the application
> using our userptr feature has COW issue; parent's pages being accessed by
> DMA of some device would be copied into child's ones if the child wrote
> something on the pages. after that, DMA of a device could access pages user
> doesn't want. I'm not sure but I think such behavior has no any problem and
> is generic behavior and it's role of user to do fork or not. Do you think
> such COW behavior could create any issue I don't aware of so we have to
> prevent that somehow?

My point is the father will keep the page that the GPU know about as
long as the father dont destroy the associated object. But if the
child expect to be able to use the same GPU object and still be able
to change the content through its anonymous mapping than i would
consider this behavior buggy (ie application have wrong expectation).
So i am all for only the father is able to keep its memory mapped into
GPU address space through same GEM object.

> 2. so we added VM_DONTCOPY flag to prevent the pages from being COWed but
> this changes original behavior of user. Do you think this is not generic way
> or could create any issue also?

I would say don't add the flag and consider application that do fork
as special case in userspace. See below for how i would handle it.

> 3. and last one, what is the difference between to flag VM_DONTCOPY and to
> detect fork? I mean the device driver should do something to need after
> detecting fork. and I'm not sure but I think the something may also change
> original behavior of user.
>
> Please let me know if there is my missing point.

I would detect fork by storing process id along gem object. So
something like (userspace code that could be in your pixman library):

struct gpu_object_process {
  struct list list;
  uint32_t gem_handle;
  unsigned process_id;
};

struct gpu_object {
  struct list gpu_object_process;
  void *ptr;
  unsigned size;
  ...
}

When creating a GPU object from userptr you fill the above structure
in the userspace code. Then whenever you library want to use this
object it call something like:

int gpu_object_validate(struct gpu_object *bo)

Which check if there is the current process id in the
gpu_object_process list, if there is one then use the gem object
handle, otherwise you create a new GEM object using this userptr and
same size and other properties.

Note you really need this only in case you expect application using
you library to fork and still expect to use your gpu accelerated
library in the same way.

So doing this you conserve proper unix fork behavior, child change to
anonymous memory don't reflect into the father anonymous memory and
that should be the expected behavior even regarding GPU object. Of
course this means there would be memcpy btw father and child on write
but that's the expected behavior of fork.

Note also that i don't expect any of your graphic application to use
fork so in most case your  gpu_object_process list would be only one
element.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
