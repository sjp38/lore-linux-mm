Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B15386B0069
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 13:31:14 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id h1so3186448plh.23
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 10:31:14 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id v8si3576994plp.37.2017.11.30.10.31.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 10:31:13 -0800 (PST)
Subject: Re: [PATCH v2] mmap.2: document new MAP_FIXED_SAFE flag
References: <20171129144219.22867-1-mhocko@kernel.org>
 <20171129144524.23518-1-mhocko@kernel.org>
 <20171130082405.b77eknaiblgmpa4s@dhcp22.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <1a96e274-a986-12b7-6e47-fc6355cbf637@nvidia.com>
Date: Thu, 30 Nov 2017 10:31:12 -0800
MIME-Version: 1.0
In-Reply-To: <20171130082405.b77eknaiblgmpa4s@dhcp22.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Michael Kerrisk <mtk.manpages@gmail.com>
Cc: linux-api@vger.kernel.org, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Florian Weimer <fweimer@redhat.com>

On 11/30/2017 12:24 AM, Michal Hocko wrote:
> Updated version based on feedback from John.
> ---
> From ade1eba229b558431581448e7d7838f0e1fe2c49 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Wed, 29 Nov 2017 15:32:08 +0100
> Subject: [PATCH] mmap.2: document new MAP_FIXED_SAFE flag
> 
> 4.16+ kernels offer a new MAP_FIXED_SAFE flag which allows the caller to
> atomicaly probe for a given address range.
> 
> [wording heavily updated by John Hubbard <jhubbard@nvidia.com>]
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  man2/mmap.2 | 22 ++++++++++++++++++++++
>  1 file changed, 22 insertions(+)
> 
> diff --git a/man2/mmap.2 b/man2/mmap.2
> index 385f3bfd5393..923bbb290875 100644
> --- a/man2/mmap.2
> +++ b/man2/mmap.2
> @@ -225,6 +225,22 @@ will fail.
>  Because requiring a fixed address for a mapping is less portable,
>  the use of this option is discouraged.
>  .TP
> +.BR MAP_FIXED_SAFE " (since Linux 4.16)"
> +Similar to MAP_FIXED with respect to the
> +.I
> +addr
> +enforcement, but different in that MAP_FIXED_SAFE never clobbers a pre-existing
> +mapped range. If the requested range would collide with an existing
> +mapping, then this call fails with
> +.B EEXIST.
> +This flag can therefore be used as a way to atomically (with respect to other
> +threads) attempt to map an address range: one thread will succeed; all others
> +will report failure. Please note that older kernels which do not recognize this
> +flag will typically (upon detecting a collision with a pre-existing mapping)
> +fall back a "non-MAP_FIXED" type of behavior: they will return an address that

...and now I've created my own typo: please make that "fall back to a"  (the 
"to" was missing).

Sorry about the churn. It turns out that the compiler doesn't catch these. :)

thanks,
John Hubbard


> +is different than the requested one. Therefore, backward-compatible software
> +should check the returned address against the requested address.
> +.TP
>  .B MAP_GROWSDOWN
>  This flag is used for stacks.
>  It indicates to the kernel virtual memory system that the mapping
> @@ -449,6 +465,12 @@ is not a valid file descriptor (and
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
