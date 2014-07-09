Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 38F066B0035
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 12:53:48 -0400 (EDT)
Received: by mail-ob0-f172.google.com with SMTP id uy5so8486879obc.31
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 09:53:47 -0700 (PDT)
Received: from mail-ob0-x235.google.com (mail-ob0-x235.google.com [2607:f8b0:4003:c01::235])
        by mx.google.com with ESMTPS id pz3si64456388oec.16.2014.07.09.09.53.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 09:53:47 -0700 (PDT)
Received: by mail-ob0-f181.google.com with SMTP id wp4so8535234obc.12
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 09:53:46 -0700 (PDT)
MIME-Version: 1.0
From: Eric Miao <eric.y.miao@gmail.com>
Date: Wed, 9 Jul 2014 09:53:26 -0700
Message-ID: <CAMPhdO-j5SfHexP8hafB2EQVs91TOqp_k_SLwWmo9OHVEvNWiQ@mail.gmail.com>
Subject: Re: arm64 flushing 255GB of vmalloc space takes too long
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux Memory Management List <linux-mm@kvack.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Russell King <linux@arm.linux.org.uk>

On Tue, Jul 8, 2014 at 6:43 PM, Laura Abbott <lauraa@codeaurora.org> wrote:
>
> Hi,
>
> I have an arm64 target which has been observed hanging in __purge_vmap_area_lazy
> in vmalloc.c The root cause of this 'hang' is that flush_tlb_kernel_range is
> attempting to flush 255GB of virtual address space. This takes ~2 seconds and
> preemption is disabled at this time thanks to the purge lock. Disabling
> preemption for that time is long enough to trigger a watchdog we have setup.
>
> Triggering this is fairly easy:
> 1) Early in bootup, vmalloc > lazy_max_pages. This gives an address near the
> start of the vmalloc range.
> 2) load a module
> 3) vfree the vmalloc region from step 1
> 4) unload the module
>
> The arm64 virtual address layout looks like
> vmalloc : 0xffffff8000000000 - 0xffffffbbffff0000   (245759 MB)
> vmemmap : 0xffffffbc02400000 - 0xffffffbc03600000   (    18 MB)
> modules : 0xffffffbffc000000 - 0xffffffc000000000   (    64 MB)
>
> and the algorithm in __purge_vmap_area_lazy flushes between the lowest address.
> Essentially, if we are using a reasonable amount of vmalloc space and a module
> unload triggers a vmalloc purge, we will end up triggering our watchdog.
>
> A couple of options I thought of:
> 1) Increase the timeout of our watchdog to allow the flush to occur. Nobody
> I suggested this to likes the idea as the watchdog firing generally catches
> behavior that results in poor system performance and disabling preemption
> for that long does seem like a problem.
> 2) Change __purge_vmap_area_lazy to do less work under a spinlock. This would
> certainly have a performance impact and I don't even know if it is plausible.
> 3) Allow module unloading to trigger a vmalloc purge beforehand to help avoid
> this case. This would still be racy if another vfree came in during the time
> between the purge and the vfree but it might be good enough.
> 4) Add 'if size > threshold flush entire tlb' (I haven't profiled this yet)

We have the same problem. I'd agree with point 2 and point 4, point 1/3 do not
actually fix this issue. purge_vmap_area_lazy() could be called in other
cases.

w.r.t the threshold to flush entire tlb instead of doing that page-by-page, that
could be different from platform to platform. And considering the cost of tlb
flush on x86, I wonder why this isn't an issue on x86.

The whole __purge_vmap_area_lazy() is protected by a single spinlock, I
see no reason why a mutex cannot be used there, this allows preemption
during this likely lengthy process.

The rbtree removal seems to be heavy too - worst case would be to call
__free_vmap_area() for lazy_max_pages times. And they are all protected
by a single spinlock for the whole traversal, which is not necessary.

CC+ Russell, Catalin, Will.

We have a patch as below:

============================ >8 =========================
