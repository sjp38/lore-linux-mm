Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id D23C26B0003
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 11:38:08 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id r7-v6so1262141oti.18
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 08:38:08 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 16-v6sor620757oii.115.2018.04.11.08.38.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Apr 2018 08:38:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180411120452.1736-1-mhocko@kernel.org>
References: <20180411120452.1736-1-mhocko@kernel.org>
From: Jann Horn <jannh@google.com>
Date: Wed, 11 Apr 2018 17:37:46 +0200
Message-ID: <CAG48ez3BS5EtnrhFQUGYY9MKGOUHzFbhauJQd361uTwy2pBEeg@mail.gmail.com>
Subject: Re: [PATCH] mmap.2: document new MAP_FIXED_NOREPLACE flag
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, John Hubbard <jhubbard@nvidia.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, Apr 11, 2018 at 2:04 PM,  <mhocko@kernel.org> wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> 4.17+ kernels offer a new MAP_FIXED_NOREPLACE flag which allows the caller to
> atomicaly probe for a given address range.
>
> [wording heavily updated by John Hubbard <jhubbard@nvidia.com>]
> Signed-off-by: Michal Hocko <mhocko@suse.com>
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

This still looks wrong to me. There are legitimate uses for MAP_FIXED,
and for most users of MAP_FIXED that I'm aware of, MAP_FIXED_NOREPLACE
wouldn't work while MAP_FIXED works perfectly well.

MAP_FIXED is for when you have already reserved the targeted memory
area using another VMA; MAP_FIXED_NOREPLACE is for when you haven't.
Please don't make it sound as if MAP_FIXED is always wrong.

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

Maybe add something like ", and MAP_FIXED_NOREPLACE was specified"? I
think most manpages explicitly document which error conditions can be
triggered by which flags.
