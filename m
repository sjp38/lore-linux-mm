Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9B3236B0038
	for <linux-mm@kvack.org>; Thu, 14 May 2015 09:36:16 -0400 (EDT)
Received: by wgnd10 with SMTP id d10so73371816wgn.2
        for <linux-mm@kvack.org>; Thu, 14 May 2015 06:36:16 -0700 (PDT)
Received: from mail-wg0-x22b.google.com (mail-wg0-x22b.google.com. [2a00:1450:400c:c00::22b])
        by mx.google.com with ESMTPS id d8si38757761wjx.11.2015.05.14.06.36.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 06:36:15 -0700 (PDT)
Received: by wgbhc8 with SMTP id hc8so42194972wgb.3
        for <linux-mm@kvack.org>; Thu, 14 May 2015 06:36:14 -0700 (PDT)
Message-ID: <5554A4C6.9030306@gmail.com>
Date: Thu, 14 May 2015 15:36:06 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mmap.2: clarify MAP_LOCKED semantic
References: <1431527892-2996-1-git-send-email-miso@dhcp22.suse.cz> <1431527892-2996-2-git-send-email-miso@dhcp22.suse.cz>
In-Reply-To: <1431527892-2996-2-git-send-email-miso@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <miso@dhcp22.suse.cz>
Cc: mtk.manpages@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Eric B Munson <emunson@akamai.com>

On 05/13/2015 04:38 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.cz>
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

Thanks, Michal. Applied, with Reviewed-by: from Eric added.

Cheers,

Michael


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
> 


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
