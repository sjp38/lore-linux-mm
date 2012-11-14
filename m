Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 62EEA6B006C
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 08:24:46 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so325501eek.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 05:24:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAKMK7uG+txQf8ZX78jvNZAU_vUhkX3tryrSbK91iHfueVt=hvw@mail.gmail.com>
References: <CAKMK7uG+txQf8ZX78jvNZAU_vUhkX3tryrSbK91iHfueVt=hvw@mail.gmail.com>
Date: Wed, 14 Nov 2012 21:24:44 +0800
Message-ID: <CAA_GA1frN8A=npcmBB89Wg7ii0cvqN6SfSJ-7nB7XkSeT4vSyA@mail.gmail.com>
Subject: Re: Regression due to "mm: fix-up zone present pages"
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, "Lu, HuaX" <huax.lu@intel.com>, "Sun, Yi" <yi.sun@intel.com>, "Jin, Gordon" <gordon.jin@intel.com>, Jianguo Wu <wujianguo@huawei.com>, Jiang Liu <jiang.liu@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, intel-gfx <intel-gfx@lists.freedesktop.org>, dri-devel <dri-devel@lists.freedesktop.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "Luck, Tony" <tony.luck@intel.com>, Mel Gorman <mel@csn.ul.ie>, Yinghai Lu <yinghai@kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>

On Wed, Nov 14, 2012 at 6:09 PM, Daniel Vetter <daniel.vetter@ffwll.ch> wrote:
> Hi all,
>
> Our QA noticed a regression in one of our i915/GEM testcases in 3.7:
>
> https://bugs.freedesktop.org/show_bug.cgi?id=56859
>
> Direct link to dmesg of the machine:
> https://bugs.freedesktop.org/attachment.cgi?id=70052 Note that the
> machine is 32bit, which seems to be important since Chris Wilson
> confirmed the bug on his 32bit Sandybridge machine, whereas mine here
> with a 64bit kernel works flawlessly.
>
> The testcase is gem_tiled_swapping:
>
> http://cgit.freedesktop.org/xorg/app/intel-gpu-tools/tree/tests/gem_tiled_swapping.c
>
> Quick high-level description of the workload:
>
> It allocates a working set larger than available memory, then fills it
> by writing it through the gpu gart (required to get a linear view of
> tiled buffers) and afterwards reads it to check whether anything got
> corrupted. Since the working set is too large to fit into ram, this
> will force all buffers through swap. We've written this testcase to
> exercise the reswizzle swapin path since some platforms have a tiling
> layout depending upon physical pfn (awesome feature btw), but not snb.
> So within the kernel this workload simply grabs the backing storage
> from shmemfs with shmem_read_mapping_page_gfp and then binds them into
> the gpu pagetables (the GTT). This happens in the i915_gem_fault
> fucntion. Unbinding in this workload happens either directly (if the
> gem code can't get enough memory) or through our shrinker
> (i915_gem_inactive_shrink). Swapout is then left to shmemfs to handle.
> All the above stuff is in drivers/gpu/drm/i915_gem.c
>
> Testcase fails because it detects a mismatch between what has been
> written and what has been read back.
>
> Our qa people bisected the regression to
>
> commit 7f1290f2f2a4d2c3f1b7ce8e87256e052ca23125
> Author: Jianguo Wu <wujianguo@huawei.com>
> Date:   Mon Oct 8 16:33:06 2012 -0700
>
>     mm: fix-up zone present pages
>
> and confirmed the revert on top of the latest drm-intel-nightly branch
> (which is based on top of 3.7-rc2 and contains the -next stuff for
> 3.8). They've also tested the for-QA branch which had latest Linus
> upstream merged in, which did not fix the problem. For reference the
> intel trees are at (but I don't think it matters really that it's not
> plain upstream, nothing really changed in the relevant i915/gem paths
> compared to upstream):
>
> http://cgit.freedesktop.org/~danvet/drm-intel
>
> I have no idea how that early boot zone init fix could even corrupt
> swapping in such a fashion, so ideas highly welcome. QA people are
> cc'ed, and hopefully I haven't missed anyone else on the cc list.
>

You can take a look at this thread:
[PATCH] mm: fix a regression with HIGHMEM introduced by changeset 7f1290f2f2a4d
http://lkml.org/lkml/2012/11/5/866

I think it's the same problem.

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
