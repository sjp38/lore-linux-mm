Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 740056B0006
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 14:33:08 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id z124so3383634ywd.21
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 11:33:08 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id w131si3476973qkw.40.2018.04.12.11.33.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Apr 2018 11:33:07 -0700 (PDT)
Subject: Re: [PATCH] mmap.2: MAP_FIXED is okay if the address range has been
 reserved
References: <20180412153941.170849-1-jannh@google.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <b617740b-fd07-e248-2ba0-9e99b0240594@nvidia.com>
Date: Thu, 12 Apr 2018 11:33:04 -0700
MIME-Version: 1.0
In-Reply-To: <20180412153941.170849-1-jannh@google.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>, mtk.manpages@gmail.com, linux-man@vger.kernel.org, mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On 04/12/2018 08:39 AM, Jann Horn wrote:
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

Yes, that's clearer and provides more information than before.

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

Here, I got lost: the sentence suddenly jumps into explaining non-MAP_FIXED
behavior, in the MAP_FIXED section. Maybe if you break up the sentence, and
possibly omit non-MAP_FIXED discussion, it will help. 

> +and take appropriate action if the kernel places the new mapping at a
> +different address.
>  .TP
>  .BR MAP_FIXED_NOREPLACE " (since Linux 4.17)"
>  .\" commit a4ff8e8620d3f4f50ac4b41e8067b7d395056843
> 

thanks,
-- 
John Hubbard
NVIDIA
