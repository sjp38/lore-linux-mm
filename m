Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id ED0DB6B0038
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 12:13:16 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id 15so1441658vkd.11
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 09:13:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j77sor131808vkd.104.2017.12.13.09.13.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Dec 2017 09:13:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171213092550.2774-1-mhocko@kernel.org>
References: <20171213092550.2774-1-mhocko@kernel.org>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 13 Dec 2017 09:13:13 -0800
Message-ID: <CAGXu5jKjjsyYJTWTqzO0mQKM+9mCH=jY_x90wJpoXbsDcLSv+Q@mail.gmail.com>
Subject: Re: [PATCH v2 0/2] mm: introduce MAP_FIXED_SAFE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Michal Hocko <mhocko@suse.com>

On Wed, Dec 13, 2017 at 1:25 AM, Michal Hocko <mhocko@kernel.org> wrote:
>
> Hi,
> I am resending with some minor updates based on Michael's review and
> ask for inclusion. There haven't been any fundamental objections for
> the RFC [1] nor the previous version [2].  The biggest discussion
> revolved around the naming. There were many suggestions flowing
> around MAP_REQUIRED, MAP_EXACT, MAP_FIXED_NOCLOBBER, MAP_AT_ADDR,
> MAP_FIXED_NOREPLACE etc...

With this named MAP_FIXED_NOREPLACE (the best consensus we've got on a
name), please consider this series:

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

>
> I am afraid we can bikeshed this to death and there will still be
> somebody finding yet another better name. Therefore I've decided to
> stick with my original MAP_FIXED_SAFE. Why? Well, because it keeps the
> MAP_FIXED prefix which should be recognized by developers and _SAFE
> suffix should also be clear that all dangerous side effects of the old
> MAP_FIXED are gone.
>
> If somebody _really_ hates this then feel free to nack and resubmit
> with a different name you can find a consensus for. I am sorry to be
> stubborn here but I would rather have this merged than go over few more
> iterations changing the name just because it seems like a good idea
> now. My experience tells me that chances are that the name will turn out
> to be "suboptimal" anyway over time.
>
> Some more background:
> This has started as a follow up discussion [3][4] resulting in the
> runtime failure caused by hardening patch [5] which removes MAP_FIXED
> from the elf loader because MAP_FIXED is inherently dangerous as it
> might silently clobber an existing underlying mapping (e.g. stack). The
> reason for the failure is that some architectures enforce an alignment
> for the given address hint without MAP_FIXED used (e.g. for shared or
> file backed mappings).
>
> One way around this would be excluding those archs which do alignment
> tricks from the hardening [6]. The patch is really trivial but it has
> been objected, rightfully so, that this screams for a more generic
> solution. We basically want a non-destructive MAP_FIXED.
>
> The first patch introduced MAP_FIXED_SAFE which enforces the given
> address but unlike MAP_FIXED it fails with EEXIST if the given range
> conflicts with an existing one. The flag is introduced as a completely
> new one rather than a MAP_FIXED extension because of the backward
> compatibility. We really want a never-clobber semantic even on older
> kernels which do not recognize the flag. Unfortunately mmap sucks wrt.
> flags evaluation because we do not EINVAL on unknown flags. On those
> kernels we would simply use the traditional hint based semantic so the
> caller can still get a different address (which sucks) but at least not
> silently corrupt an existing mapping. I do not see a good way around
> that. Except we won't export expose the new semantic to the userspace at
> all.
>
> It seems there are users who would like to have something like that.
> Jemalloc has been mentioned by Michael Ellerman [7]
>
> Florian Weimer has mentioned the following:
> : glibc ld.so currently maps DSOs without hints.  This means that the kernel
> : will map right next to each other, and the offsets between them a completely
> : predictable.  We would like to change that and supply a random address in a
> : window of the address space.  If there is a conflict, we do not want the
> : kernel to pick a non-random address. Instead, we would try again with a
> : random address.
>
> John Hubbard has mentioned CUDA example
> : a) Searches /proc/<pid>/maps for a "suitable" region of available
> : VA space.  "Suitable" generally means it has to have a base address
> : within a certain limited range (a particular device model might
> : have odd limitations, for example), it has to be large enough, and
> : alignment has to be large enough (again, various devices may have
> : constraints that lead us to do this).
> :
> : This is of course subject to races with other threads in the process.
> :
> : Let's say it finds a region starting at va.
> :
> : b) Next it does:
> :     p = mmap(va, ...)
> :
> : *without* setting MAP_FIXED, of course (so va is just a hint), to
> : attempt to safely reserve that region. If p != va, then in most cases,
> : this is a failure (almost certainly due to another thread getting a
> : mapping from that region before we did), and so this layer now has to
> : call munmap(), before returning a "failure: retry" to upper layers.
> :
> :     IMPROVEMENT: --> if instead, we could call this:
> :
> :             p = mmap(va, ... MAP_FIXED_SAFE ...)
> :
> :         , then we could skip the munmap() call upon failure. This
> :         is a small thing, but it is useful here. (Thanks to Piotr
> :         Jaroszynski and Mark Hairgrove for helping me get that detail
> :         exactly right, btw.)
> :
> : c) After that, CUDA suballocates from p, via:
> :
> :      q = mmap(sub_region_start, ... MAP_FIXED ...)
> :
> : Interestingly enough, "freeing" is also done via MAP_FIXED, and
> : setting PROT_NONE to the subregion. Anyway, I just included (c) for
> : general interest.
>
> Atomic address range probing in the multithreaded programs in general
> sounds like an interesting thing to me.
>
> The second patch simply replaces MAP_FIXED use in elf loader by
> MAP_FIXED_SAFE. I believe other places which rely on MAP_FIXED should
> follow. Actually real MAP_FIXED usages should be docummented properly
> and they should be more of an exception.
>
> Diffstat says
>  arch/alpha/include/uapi/asm/mman.h     |  1 +
>  arch/metag/kernel/process.c            |  6 +++++-
>  arch/mips/include/uapi/asm/mman.h      |  2 ++
>  arch/parisc/include/uapi/asm/mman.h    |  2 ++
>  arch/sparc/include/uapi/asm/mman.h     |  1 -
>  arch/xtensa/include/uapi/asm/mman.h    |  2 ++
>  fs/binfmt_elf.c                        | 12 ++++++++----
>  include/uapi/asm-generic/mman-common.h |  1 +
>  mm/mmap.c                              | 11 +++++++++++
>  9 files changed, 32 insertions(+), 6 deletions(-)
>
> [1] http://lkml.kernel.org/r/20171116101900.13621-1-mhocko@kernel.org
> [2] http://lkml.kernel.org/r/20171129144219.22867-1-mhocko@kernel.org
> [3] http://lkml.kernel.org/r/20171107162217.382cd754@canb.auug.org.au
> [4] http://lkml.kernel.org/r/1510048229.12079.7.camel@abdul.in.ibm.com
> [5] http://lkml.kernel.org/r/20171023082608.6167-1-mhocko@kernel.org
> [6] http://lkml.kernel.org/r/20171113094203.aofz2e7kueitk55y@dhcp22.suse.cz
> [7] http://lkml.kernel.org/r/87efp1w7vy.fsf@concordia.ellerman.id.au
>



-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
