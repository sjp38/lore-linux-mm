Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6E97B6B0069
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 05:26:55 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id p9so385406lbv.35
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 02:26:54 -0700 (PDT)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id y4si566160laa.107.2014.10.01.02.26.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 01 Oct 2014 02:26:53 -0700 (PDT)
Message-ID: <542BC8D6.7060306@canonical.com>
Date: Wed, 01 Oct 2014 11:26:46 +0200
From: Maarten Lankhorst <maarten.lankhorst@canonical.com>
MIME-Version: 1.0
Subject: Re: page allocator bug in 3.16?
References: <54246506.50401@hurleysoftware.com> <CADnq5_OyRMNsc5L1a-BYbmKe94t+pun+nEh3UvFKLmpb2=1ukg@mail.gmail.com> <542484BF.7080908@hurleysoftware.com>
In-Reply-To: <542484BF.7080908@hurleysoftware.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Hurley <peter@hurleysoftware.com>, Alex Deucher <alexdeucher@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Thomas Hellstrom <thellstrom@vmware.com>, Hugh Dickens <hughd@google.com>, Linux kernel <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>

Op 25-09-14 om 23:10 schreef Peter Hurley:
> On 09/25/2014 04:33 PM, Alex Deucher wrote:
>> On Thu, Sep 25, 2014 at 2:55 PM, Peter Hurley <peter@hurleysoftware.com> wrote:
>>> After several days uptime with a 3.16 kernel (generally running
>>> Thunderbird, emacs, kernel builds, several Chrome tabs on multiple
>>> desktop workspaces) I've been seeing some really extreme slowdowns.
>>>
>>> Mostly the slowdowns are associated with gpu-related tasks, like
>>> opening new emacs windows, switching workspaces, laughing at internet
>>> gifs, etc. Because this x86_64 desktop is nouveau-based, I didn't pursue
>>> it right away -- 3.15 is the first time suspend has worked reliably.
>>>
>>> This week I started looking into what the slowdown was and discovered
>>> it's happening during dma allocation through swiotlb (the cpus can do
>>> intel iommu but I don't use it because it's not the default for most users).
>>>
>>> I'm still working on a bisection but each step takes 8+ hours to
>>> validate and even then I'm no longer sure I still have the 'bad'
>>> commit in the bisection. [edit: yup, I started over]
>>>
>>> I just discovered a smattering of these in my logs and only on 3.16-rc+ kernels:
>>> Sep 25 07:57:59 thor kernel: [28786.001300] alloc_contig_range test_pages_isolated(2bf560, 2bf562) failed
>>>
>>> This dual-Xeon box has 10GB and sysrq Show Memory isn't showing heavy
>>> fragmentation [1].
>>>
>>> Besides Mel's page allocator changes in 3.16, another suspect commit is:
>>>
>>> commit b13b1d2d8692b437203de7a404c6b809d2cc4d99
>>> Author: Shaohua Li <shli@kernel.org>
>>> Date:   Tue Apr 8 15:58:09 2014 +0800
>>>
>>>     x86/mm: In the PTE swapout page reclaim case clear the accessed bit instead of flushing the TLB
>>>
>>> Specifically, this statement:
>>>
>>>     It could cause incorrect page aging and the (mistaken) reclaim of
>>>     hot pages, but the chance of that should be relatively low.
>>>
>>> I'm wondering if this could cause worse-case behavior with TTM? I'm
>>> testing a revert of this on mainline 3.16-final now, with no results yet.
>>>
>>> Thoughts?
>> You may also be seeing this:
>> https://lkml.org/lkml/2014/8/8/445
> Thanks Alex. That is indeed the problem.
>
> Still reading the email thread to find out where the patches
> are that fix this. Although it doesn't make much sense to me
> that nouveau sets up a 1GB GART and then uses TTM which is
> trying to shove all the DMA through a 16MB CMA window
> (which turns out to be the base Ubuntu config).
>
> Regards,
> Peter Hurley
>
>
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1362261

CMA's already disabled on x86 in most recent ubuntu kernels. :-)

~Maarten

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
