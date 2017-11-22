Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 639306B028B
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 08:12:49 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id l4so7759281wre.10
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 05:12:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z9si3949394ede.320.2017.11.22.05.12.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 05:12:47 -0800 (PST)
Date: Wed, 22 Nov 2017 14:12:45 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/2] mm: introduce MAP_FIXED_SAFE
Message-ID: <20171122131245.fpqtipwdxzuaj6gl@dhcp22.suse.cz>
References: <20171116101900.13621-1-mhocko@kernel.org>
 <20171116121438.6vegs4wiahod3byl@dhcp22.suse.cz>
 <b1848e34-7fcd-8ad8-6a6a-3be3dce3fda7@nvidia.com>
 <20171120090509.moagbwu7ug3y42gj@dhcp22.suse.cz>
 <9a02b37c-978a-48ef-0b22-b1e4cbb9a704@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9a02b37c-978a-48ef-0b22-b1e4cbb9a704@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-api@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Kees Cook <keescook@chromium.org>

On Tue 21-11-17 17:48:31, John Hubbard wrote:
[...]
> Hi Michal,
> 
> Yes, it really is useful for user space. I'll use CUDA as an example, but I 
> think anything that enforces a uniform virtual addressing scheme across CPUs
> and devices, probably has to do something eerily similar. CUDA does this:
> 
> a) Searches /proc/<pid>/maps for a "suitable" region of available VA space. 
> "Suitable" generally means it has to have a base address within a certain
> limited range (a particular device model might have odd limitations, for 
> example), it has to be large enough, and alignment has to be large enough
> (again, various devices may have constraints that lead us to do this).
> 
> This is of course subject to races with other threads in the process.
> 
> Let's say it finds a region starting at va.
> 
> b) Next it does: 
>     p = mmap(va, ...) 
> 
> *without* setting MAP_FIXED, of course (so va is just a hint), to attempt to
> safely reserve that region. If p != va, then in most cases, this is a failure
> (almost certainly due to another thread getting a mapping from that region
> before we did), and so this layer now has to call munmap(), before returning
> a "failure: retry" to upper layers.
> 
>     IMPROVEMENT: --> if instead, we could call this:
> 
>             p = mmap(va, ... MAP_FIXED_NO_CLOBBER ...)
> 
>         , then we could skip the munmap() call upon failure. This is a small thing, 
>         but it is useful here. (Thanks to Piotr Jaroszynski and Mark Hairgrove
>         for helping me get that detail exactly right, btw.)
> 
> c) After that, CUDA suballocates from p, via: 
>  
>      q = mmap(sub_region_start, ... MAP_FIXED ...)
> 
> Interestingly enough, "freeing" is also done via MAP_FIXED, and setting PROT_NONE
> to the subregion. Anyway, I just included (c) for general interest.

OK, I will add this to the changelog. This is basically the "Atomic
address range probing in the multithreaded programs" I've had in the
cover letter.

> I expect that as we continue working on the open source compute software stack,
> this new capability will be useful there, too.
> 
> Oh, and on the naming, when I described how your implementation worked (without
> naming it) to Piotr, he said, "oh, something like map-fixed-no-clobber?". So I
> think my miniature sociology naming data point here can bolster the case ever so
> slightly for calling it MAP_FIXED_NO_CLOBBER. haha. :)

I will be probably stubborn and go with a shorter name I have currently.
I am not very fond-of-very-long-names.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
