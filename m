Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id C0EF16B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 20:28:57 -0400 (EDT)
Received: by iedfl3 with SMTP id fl3so62614748ied.1
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 17:28:57 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id j5si833333igh.50.2015.04.29.17.28.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 17:28:57 -0700 (PDT)
Received: by igblo3 with SMTP id lo3so63550492igb.0
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 17:28:56 -0700 (PDT)
Date: Wed, 29 Apr 2015 17:28:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH] mmap.2: clarify MAP_LOCKED semantic (was: Re: Should
 mmap MAP_LOCKED fail if mm_poppulate fails?)
In-Reply-To: <20150429113818.GC16097@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1504291723001.17825@chino.kir.corp.google.com>
References: <20150114095019.GC4706@dhcp22.suse.cz> <1430223111-14817-1-git-send-email-mhocko@suse.cz> <CA+55aFxzLXx=cC309h_tEc-Gkn_zH4ipR7PsefVcE-97Uj066g@mail.gmail.com> <20150428164302.GI2659@dhcp22.suse.cz> <CA+55aFydkG-BgZzry5DrTzueVh9VvEcVJdLV8iOyUphQk=0vpw@mail.gmail.com>
 <20150428183535.GB30918@dhcp22.suse.cz> <CA+55aFyajquhGhw59qNWKGK4dBV0TPmDD7-1XqPo7DZWvO_hPg@mail.gmail.com> <20150429113818.GC16097@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-mm <linux-mm@kvack.org>, Cyril Hrubis <chrubis@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, 29 Apr 2015, Michal Hocko wrote:

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

The wording of this begs the question on the behavior of 
MAP_LOCKED | MAP_POPULATE since this same man page specifies that 
accesses to memory mapped with MAP_POPULATE will not block on page faults 
later.

I think Documentation/vm/unevictable-lru.txt would benefit from an update 
under the mmap(MAP_LOCKED) section where all this can be laid out and 
perhaps reference it from the man page?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
