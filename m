Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C7ACF6B0005
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 14:32:45 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id n8so13643wmh.7
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 11:32:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a9sor14468wmg.7.2018.04.12.11.32.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Apr 2018 11:32:44 -0700 (PDT)
Subject: Re: [PATCH] mmap.2: MAP_FIXED is okay if the address range has been
 reserved
References: <20180412153941.170849-1-jannh@google.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <3ff7472c-23c8-402b-ddfb-871a749c5016@gmail.com>
Date: Thu, 12 Apr 2018 20:32:40 +0200
MIME-Version: 1.0
In-Reply-To: <20180412153941.170849-1-jannh@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>, linux-man@vger.kernel.org, mhocko@kernel.org, jhubbard@nvidia.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: mtk.manpages@gmail.com

Hello Jann,

On 04/12/2018 05:39 PM, Jann Horn wrote:
> Clarify that MAP_FIXED is appropriate if the specified address range has
> been reserved using an existing mapping, but shouldn't be used otherwise.
> 
> Signed-off-by: Jann Horn <jannh@google.com>
> ---
>  man2/mmap.2 | 19 +++++++++++--------
>  1 file changed, 11 insertions(+), 8 deletions(-)
> 
> diff --git a/man2/mmap.2 b/man2/mmap.2
> index bef8b4432..80c9ec285 100644
> --- a/man2/mmap.2
> +++ b/man2/mmap.2
> @@ -253,8 +253,9 @@ Software that aspires to be portable should use this option with care,
>  keeping in mind that the exact layout of a process's memory mappings
>  is allowed to change significantly between kernel versions,
>  C library versions, and operating system releases.
> -Furthermore, this option is extremely hazardous (when used on its own),
> -because it forcibly removes preexisting mappings,
> +This option should only be used when the specified memory region has
> +already been reserved using another mapping; otherwise, it is extremely
> +hazardous because it forcibly removes preexisting mappings,
>  making it easy for a multithreaded process to corrupt its own address space.
>  .IP
>  For example, suppose that thread A looks through
> @@ -284,13 +285,15 @@ and the PAM libraries
>  .UR http://www.linux-pam.org
>  .UE .
>  .IP
> -Newer kernels
> -(Linux 4.17 and later) have a
> +For cases in which the specified memory region has not been reserved using an
> +existing mapping, newer kernels (Linux 4.17 and later) provide an option
>  .B MAP_FIXED_NOREPLACE
> -option that avoids the corruption problem; if available,
> -.B MAP_FIXED_NOREPLACE
> -should be preferred over
> -.BR MAP_FIXED .
> +that should be used instead; older kernels require the caller to use
> +.I addr
> +as a hint (without
> +.BR MAP_FIXED )
> +and take appropriate action if the kernel places the new mapping at a
> +different address.
>  .TP
>  .BR MAP_FIXED_NOREPLACE " (since Linux 4.17)"
>  .\" commit a4ff8e8620d3f4f50ac4b41e8067b7d395056843

Thanks! Nice patch! Applied.

Cheers,

Michael



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
