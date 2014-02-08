Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vb0-f51.google.com (mail-vb0-f51.google.com [209.85.212.51])
	by kanga.kvack.org (Postfix) with ESMTP id 885EC6B003D
	for <linux-mm@kvack.org>; Sat,  8 Feb 2014 14:20:32 -0500 (EST)
Received: by mail-vb0-f51.google.com with SMTP id 11so3704594vbe.10
        for <linux-mm@kvack.org>; Sat, 08 Feb 2014 11:20:32 -0800 (PST)
Received: from mail-ve0-f179.google.com (mail-ve0-f179.google.com [209.85.128.179])
        by mx.google.com with ESMTPS id n8si2790091vdv.94.2014.02.08.11.20.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 08 Feb 2014 11:20:31 -0800 (PST)
Received: by mail-ve0-f179.google.com with SMTP id jx11so3817846veb.38
        for <linux-mm@kvack.org>; Sat, 08 Feb 2014 11:20:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52F68299.1040305@gentoo.org>
References: <CALCETrWu6wvb4M7UwOdqxNUfSmKV2eZ96qMufAQPF7cJD1oz2w@mail.gmail.com>
 <20140207195555.GA18916@nautica> <CALCETrWZvz85hxPGYhgHoF4yp06QkP4SxWQBSxFqmTyCqhE3LA@mail.gmail.com>
 <52F66641.4040405@gentoo.org> <CALCETrVrnX6gWNBOdVTbLZKYWXRWiOYFNgLb0+Sk-bqXsbPc7Q@mail.gmail.com>
 <52F671D0.1060907@gentoo.org> <CALCETrW5Uh9VgYo6vKVWZtK_yVxEyL6B3V2a2HVxY6H+3dSrRQ@mail.gmail.com>
 <52F68299.1040305@gentoo.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sat, 8 Feb 2014 11:20:11 -0800
Message-ID: <CALCETrUOPPSb9cOgz1NMqR63Y=kXL1r8nw_WnPyZqTAuweLuaA@mail.gmail.com>
Subject: Re: [V9fs-developer] finit_module broken on 9p because kernel_read
 doesn't work?
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Yao <ryao@gentoo.org>
Cc: Dominique Martinet <dominique.martinet@cea.fr>, Will Deacon <will.deacon@arm.com>, V9FS Developers <v9fs-developer@lists.sourceforge.net>, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, Rusty Russell <rusty@rustcorp.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sat, Feb 8, 2014 at 11:16 AM, Richard Yao <ryao@gentoo.org> wrote:
> On 02/08/2014 02:13 PM, Andy Lutomirski wrote:
>> On Sat, Feb 8, 2014 at 10:05 AM, Richard Yao <ryao@gentoo.org> wrote:
>>> On 02/08/2014 12:55 PM, Andy Lutomirski wrote:
>>>> On Sat, Feb 8, 2014 at 9:15 AM, Richard Yao <ryao@gentoo.org> wrote:
>>>>> On 02/08/2014 01:51 AM, Andy Lutomirski wrote:
>>>>>> On Fri, Feb 7, 2014 at 11:55 AM, Dominique Martinet
>>>>>> <dominique.martinet@cea.fr> wrote:
>>>>>> Hi,
>>>>>>>
>>>>>>> Andy Lutomirski wrote on Fri, Feb 07, 2014:
>>>>>>>> I can't get modules to load from 9p.  The problem seems to be that a call like:
>>>>>>>>
>>>>>>>> kernel_read(f.file, 0, (char *)(info->hdr),, 115551);
>>>>>>>>
>>>>>>>> is filling the buffer with mostly zeros (or, more likely, just doing
>>>>>>>> nothing at all).  The call is in module.c, and the fs is mounted with:
>>>>>>>>
>>>>>>>> mount -t 9p -o ro,version=9p2000.L,trans=virtio,access=any hostroot /newroot/
>>>>>>>>
>>>>>>>> This is really easy to test: grab a copy of virtme
>>>>>>>> (https://git.kernel.org/cgit/utils/kernel/virtme/virtme.git/), build
>>>>>>>> an appropriate kernel, and run it with virtme-runkernel.  Then try to
>>>>>>>> insmod any module built for that kernel.  It won't work.
>>>>>>>>
>>>>>>>> Oddly, running executables from the same fs works, and *copying* a
>>>>>>>> module to tmpfs and insmoding it there also works.
>>>>>>>>
>>>>>>>> I'm kind of at a loss debugging this myself.  I'd expect that if
>>>>>>>> kernel_read were that broken on 9p, then I'd see more obvious
>>>>>>>> problems.
>>>>>>>>
>>>>>>>> This problem exists in at least 3.12 and a recent -linus tree.
>>>>>>>
>>>>>>> That's been reported a couple of times[1] since two months ago, there's a
>>>>>>> fix that might or might or might not make it in the tree (Eric?) there:
>>>>>>> http://www.spinics.net/lists/linux-virtualization/msg21716.html
>>>>>>>
>>>>>>> I'm pretty confident that will do it for you, but would be good to hear
>>>>>>> you confirm it again :)
>>>>>>
>>>>>> That fixes it for me.  I think it can't be a module address in
>>>>>> finit_module, though -- it's an intermediate vmalloc buffer.  It
>>>>>> could, however (in principle) be an address in module data, so the
>>>>>> full check is probably good.
>>>>>>
>>>>>> Can one of you send this to Linus and tag it for -stable?  I can
>>>>>> trigger this bug without getting an OOPS, which means that 9p is
>>>>>> overwriting random memory, which puts it in the category of rather bad
>>>>>> bugs.  I suspect that this is because I don't have
>>>>>> CONFIG_DEBUG_VIRTUAL set.
>>>>>>
>>>>>> (I can't immediately spot any code that would trigger this from user
>>>>>> space without being root, so it's probably not a security bug.)
>>>>>>
>>>>>> --Andy
>>>>>>
>>>>>
>>>>> I have already submitted it for inclusion a couple of times.
>>>>>
>>>>> The first time was my first time doing any sort of Linux patch
>>>>> submission. At the time, I was unaware of ./scripts/get_maintainer.pl
>>>>> and sent the patch to only a subset of the correct people. Consequently,
>>>>> it was not submitted properly for acceptance by the subsystem maintainer.
>>>>>
>>>>> The second time was a week ago. I had taken advice from Greg
>>>>> Koah-Hartman to use ./scripts/get_maintainer.pl to determine the correct
>>>>> recipients. It was initially accepted by the subsystem maintainer and
>>>>> then rejected. This patch uses is_vmalloc_or_module_addr(), which is not
>>>>> exported for use in kernel modules. Using it causes a build failure when
>>>>> CONFIG_NET_9P_VIRTIO=m is set in .config.
>>>>>
>>>>> I will make a third attempt to mainline this over the next week. Later
>>>>> today, I will submit a patch exporting is_vmalloc_or_module_addr().
>>>>> After it has been accepted into mainline, I will resubmit this patch,
>>>>> which should then be accepted. This should bring this patch into Linus'
>>>>> tree sometime in the next few weeks.
>>>>
>>>> I would consider asking some mm people (cc'd) how this is supposed to
>>>> work -- that is, what the appropriate way of mapping a kernel virtual
>>>> address to a struct page is.
>>>>
>>>> I suspect that the answer might be unpleasant: what happens if the
>>>> address is neither in the linear map nor in vmalloc space?  For
>>>> example, it could be ioremapped.  (I have no idea under what useful
>>>> conditions the 9pnet code wants to zero-copy a buffer, but I suspect
>>>> that there are exactly zero performance-critical users of kernel_read
>>>> and kernel_write.  Presumably this is for skbs or something.)  I
>>>> suspect that the right fix is to just fall back to non-zero-copy if
>>>> the page is neither vmalloc'd nor linear-mapped, which should be
>>>> doable without new exports.
>>>>
>>>> --Andy
>>>>
>>>
>>> That is only possible if someone calls
>>> p9_client_read()/p9_client_write() on an ioremapped address, which is an
>>> entirely different problem.
>>>
>>
>> At the very least, calling vmalloc_to_page on a non-vmalloc module
>> address sounds wrong, so I don't think that exporting
>> is_vmalloc_or_module_address buys you anything.
>>
>> --Andy
>>
> The patch does not do what you describe, so we are okay.

Are we looking at the same patch?

+ if (is_vmalloc_or_module_addr(data))
+ pages[index++] = vmalloc_to_page(data);

if (is_vmalloc_or_module_addr(data) && !is_vmalloc_addr(data)), the
vmalloc_to_page(data) sounds unhealthy.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
