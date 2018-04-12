Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 57E906B0007
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 04:04:12 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id j47so2488438wre.11
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 01:04:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n65sor824483wmg.37.2018.04.12.01.04.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Apr 2018 01:04:10 -0700 (PDT)
Subject: Re: [PATCH] mmap.2: document new MAP_FIXED_NOREPLACE flag
References: <20180411120452.1736-1-mhocko@kernel.org>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <97504dda-4252-a150-e7b5-43fe587aa055@gmail.com>
Date: Thu, 12 Apr 2018 10:04:06 +0200
MIME-Version: 1.0
In-Reply-To: <20180411120452.1736-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: mtk.manpages@gmail.com, John Hubbard <jhubbard@nvidia.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>

Hello Michal,

On 04/11/2018 02:04 PM, mhocko@kernel.org wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> 4.17+ kernels offer a new MAP_FIXED_NOREPLACE flag which allows the caller to
> atomicaly probe for a given address range.
> 
> [wording heavily updated by John Hubbard <jhubbard@nvidia.com>]
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Thanks! I've applied your patch, and done a little tweaking. The results
have already been pushed.

Cheers

Michael


> ---
> Hi,
> Andrew's sent the MAP_FIXED_NOREPLACE to Linus for the upcoming merge
> window. So here we go with the man page update.
> 
>  man2/mmap.2 | 27 +++++++++++++++++++++++++++
>  1 file changed, 27 insertions(+)
> 
> diff --git a/man2/mmap.2 b/man2/mmap.2
> index ea64eb8f0dcc..f702f3e4eba2 100644
> --- a/man2/mmap.2
> +++ b/man2/mmap.2
> @@ -261,6 +261,27 @@ Examples include
>  and the PAM libraries
>  .UR http://www.linux-pam.org
>  .UE .
> +Newer kernels
> +(Linux 4.17 and later) have a
> +.B MAP_FIXED_NOREPLACE
> +option that avoids the corruption problem; if available, MAP_FIXED_NOREPLACE
> +should be preferred over MAP_FIXED.
> +.TP
> +.BR MAP_FIXED_NOREPLACE " (since Linux 4.17)"
> +Similar to MAP_FIXED with respect to the
> +.I
> +addr
> +enforcement, but different in that MAP_FIXED_NOREPLACE never clobbers a pre-existing
> +mapped range. If the requested range would collide with an existing
> +mapping, then this call fails with
> +.B EEXIST.
> +This flag can therefore be used as a way to atomically (with respect to other
> +threads) attempt to map an address range: one thread will succeed; all others
> +will report failure. Please note that older kernels which do not recognize this
> +flag will typically (upon detecting a collision with a pre-existing mapping)
> +fall back to a "non-MAP_FIXED" type of behavior: they will return an address that
> +is different than the requested one. Therefore, backward-compatible software
> +should check the returned address against the requested address.
>  .TP
>  .B MAP_GROWSDOWN
>  This flag is used for stacks.
> @@ -487,6 +508,12 @@ is not a valid file descriptor (and
>  .B MAP_ANONYMOUS
>  was not set).
>  .TP
> +.B EEXIST
> +range covered by
> +.IR addr ,
> +.IR length
> +is clashing with an existing mapping.
> +.TP
>  .B EINVAL
>  We don't like
>  .IR addr ,
> 


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
