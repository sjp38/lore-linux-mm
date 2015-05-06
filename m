Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id B0C4E6B0038
	for <linux-mm@kvack.org>; Wed,  6 May 2015 08:21:11 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so9536626wgy.2
        for <linux-mm@kvack.org>; Wed, 06 May 2015 05:21:11 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mz2si1969547wic.40.2015.05.06.05.21.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 06 May 2015 05:21:10 -0700 (PDT)
Date: Wed, 6 May 2015 14:21:09 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] mmap.2: clarify MAP_LOCKED semantic (was: Re: Should
 mmap MAP_LOCKED fail if mm_poppulate fails?)
Message-ID: <20150506122108.GJ14550@dhcp22.suse.cz>
References: <20150114095019.GC4706@dhcp22.suse.cz>
 <1430223111-14817-1-git-send-email-mhocko@suse.cz>
 <CA+55aFxzLXx=cC309h_tEc-Gkn_zH4ipR7PsefVcE-97Uj066g@mail.gmail.com>
 <20150428164302.GI2659@dhcp22.suse.cz>
 <CA+55aFydkG-BgZzry5DrTzueVh9VvEcVJdLV8iOyUphQk=0vpw@mail.gmail.com>
 <20150428183535.GB30918@dhcp22.suse.cz>
 <CA+55aFyajquhGhw59qNWKGK4dBV0TPmDD7-1XqPo7DZWvO_hPg@mail.gmail.com>
 <20150429113818.GC16097@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150429113818.GC16097@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Michael Kerrisk <mtk.manpages@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Cyril Hrubis <chrubis@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

If there are no objections here I will resubmit this and MAP_POPULATE
patches in few days.

On Wed 29-04-15 13:38:18, Michal Hocko wrote:
> On Tue 28-04-15 11:38:35, Linus Torvalds wrote:
> > On Tue, Apr 28, 2015 at 11:35 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > >
> > > I am still not sure I see the problem here.
> > 
> > Basically, I absolutely hate the notion of us doing something
> > unsynchronized, when I can see us undoing a mmap that another thread
> > is doing. It's wrong.
> 
> OK, I have checked the mmap(2) man page and there is no single mention
> about multi-threaded usage. So even though I personally think that
> user fault handlers which do mmap(MAP_FIXED) without synchronization
> to parallel mmaps are broken by definition we cannot simply rule them
> out and it is not the kernel job to make them broken even more or in a
> subtly different way.
> So here is an RFC for the man page patch. I am not very good in the
> format but man doesn't complain about any formating issues.
> ---
> From 903ed733187afaa4d27fef3c24f413304494411c Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Wed, 29 Apr 2015 11:02:19 +0200
> Subject: [RFC PATCH] mmap.2: clarify MAP_LOCKED semantic
> 
> MAP_LOCKED had a subtly different semantic from mmap(2)+mlock(2) since
> it has been introduced.
> mlock(2) fails if the memory range cannot get populated to guarantee
> that no future major faults will happen on the range. mmap(MAP_LOCKED) on
> the other hand silently succeeds even if the range was populated only
> partially.
> 
> Fixing this subtle difference in the kernel is rather awkward because
> the memory population happens after mm locks have been dropped and so
> the cleanup before returning failure (munlock) could operate on something
> else than the originally mapped area.
> 
> E.g. speculative userspace page fault handler catching SEGV and doing
> mmap(fault_addr, MAP_FIXED|MAP_LOCKED) might discard portion of a racing
> mmap and lead to lost data. Although it is not clear whether such a
> usage would be valid, mmap page doesn't explicitly describe requirements
> for threaded applications so we cannot exclude this possibility.
> 
> This patch makes the semantic of MAP_LOCKED explicit and suggest using
> mmap + mlock as the only way to guarantee no later major page faults.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  man2/mmap.2 | 13 ++++++++++++-
>  1 file changed, 12 insertions(+), 1 deletion(-)
> 
> diff --git a/man2/mmap.2 b/man2/mmap.2
> index 54d68cf87e9e..1486be2e96b3 100644
> --- a/man2/mmap.2
> +++ b/man2/mmap.2
> @@ -235,8 +235,19 @@ See the Linux kernel source file
>  for further information.
>  .TP
>  .BR MAP_LOCKED " (since Linux 2.5.37)"
> -Lock the pages of the mapped region into memory in the manner of
> +Mark the mmaped region to be locked in the same way as
>  .BR mlock (2).
> +This implementation will try to populate (prefault) the whole range but
> +the mmap call doesn't fail with
> +.B ENOMEM
> +if this fails. Therefore major faults might happen later on. So the semantic
> +is not as strong as
> +.BR mlock (2).
> +.BR mmap (2)
> ++
> +.BR mlock (2)
> +should be used when major faults are not acceptable after the initialization
> +of the mapping.
>  This flag is ignored in older kernels.
>  .\" If set, the mapped pages will not be swapped out.
>  .TP
> -- 
> 2.1.4
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
