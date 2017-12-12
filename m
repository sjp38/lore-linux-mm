Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id F3E006B0069
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 02:55:56 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c82so5679513wme.8
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 23:55:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x9si11879539wrx.93.2017.12.11.23.55.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Dec 2017 23:55:54 -0800 (PST)
Date: Tue, 12 Dec 2017 08:55:50 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5] mmap.2: MAP_FIXED updated documentation
Message-ID: <20171212075550.GI4779@dhcp22.suse.cz>
References: <20171212002331.6838-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171212002331.6838-1-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, linux-man <linux-man@vger.kernel.org>, linux-api@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Jann Horn <jannh@google.com>, Matthew Wilcox <willy@infradead.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Cyril Hrubis <chrubis@suse.cz>, Pavel Machek <pavel@ucw.cz>, John Hubbard <jhubbard@nvidia.com>

On Mon 11-12-17 16:23:31, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
>     -- Expand the documentation to discuss the hazards in
>        enough detail to allow avoiding them.
> 
>     -- Mention the upcoming MAP_FIXED_SAFE flag.
> 
>     -- Enhance the alignment requirement slightly.
> 
> CC: Michael Ellerman <mpe@ellerman.id.au>
> CC: Jann Horn <jannh@google.com>
> CC: Matthew Wilcox <willy@infradead.org>
> CC: Michal Hocko <mhocko@kernel.org>
> CC: Mike Rapoport <rppt@linux.vnet.ibm.com>
> CC: Cyril Hrubis <chrubis@suse.cz>
> CC: Michal Hocko <mhocko@suse.com>
> CC: Pavel Machek <pavel@ucw.cz>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks! I plan to submit my MAP_FIXED_FOO today and will send this
together with my mman update.

> ---
> 
> Changes since v4:
> 
>     -- v2 ("mmap.2: MAP_FIXED is no longer discouraged") was applied already,
>        so v5 is a merge, including rewording of the paragraph transitions.
> 
>     -- We seem to have consensus about what to say about alignment
>        now, and this includes that new wording.
> 
> Changes since v3:
> 
>     -- Removed the "how to use this safely" part, and
>        the SHMLBA part, both as a result of Michal Hocko's
>        review.
> 
>     -- A few tiny wording fixes, at the not-quite-typo level.
> 
> Changes since v2:
> 
>     -- Fixed up the "how to use safely" example, in response
>        to Mike Rapoport's review.
> 
>     -- Changed the alignment requirement from system page
>        size, to SHMLBA. This was inspired by (but not yet
>        recommended by) Cyril Hrubis' review.
> 
>     -- Formatting: underlined /proc/<pid>/maps
> 
> Changes since v1:
> 
>     -- Covered topics recommended by Matthew Wilcox
>        and Jann Horn, in their recent review: the hazards
>        of overwriting pre-exising mappings, and some notes
>        about how to use MAP_FIXED safely.
> 
>     -- Rewrote the commit description accordingly.
> 
>  man2/mmap.2 | 32 ++++++++++++++++++++++++++++++--
>  1 file changed, 30 insertions(+), 2 deletions(-)
> 
> diff --git a/man2/mmap.2 b/man2/mmap.2
> index a5a8eb47a..400cfda2d 100644
> --- a/man2/mmap.2
> +++ b/man2/mmap.2
> @@ -212,8 +212,9 @@ Don't interpret
>  .I addr
>  as a hint: place the mapping at exactly that address.
>  .I addr
> -must be a multiple of the page size.
> -If the memory region specified by
> +must be suitably aligned: for most architectures a multiple of page
> +size is sufficient; however, some architectures may impose additional
> +restrictions. If the memory region specified by
>  .I addr
>  and
>  .I len
> @@ -226,6 +227,33 @@ Software that aspires to be portable should use this option with care, keeping
>  in mind that the exact layout of a process' memory map is allowed to change
>  significantly between kernel versions, C library versions, and operating system
>  releases.
> +.IP
> +Furthermore, this option is extremely hazardous (when used on its own), because
> +it forcibly removes pre-existing mappings, making it easy for a multi-threaded
> +process to corrupt its own address space.
> +.IP
> +For example, thread A looks through
> +.I /proc/<pid>/maps
> +and locates an available
> +address range, while thread B simultaneously acquires part or all of that same
> +address range. Thread A then calls mmap(MAP_FIXED), effectively overwriting
> +the mapping that thread B created.
> +.IP
> +Thread B need not create a mapping directly; simply making a library call
> +that, internally, uses
> +.I dlopen(3)
> +to load some other shared library, will
> +suffice. The dlopen(3) call will map the library into the process's address
> +space. Furthermore, almost any library call may be implemented using this
> +technique.
> +Examples include brk(2), malloc(3), pthread_create(3), and the PAM libraries
> +(http://www.linux-pam.org).
> +.IP
> +Newer kernels
> +(Linux 4.16 and later) have a
> +.B MAP_FIXED_SAFE
> +option that avoids the corruption problem; if available, MAP_FIXED_SAFE
> +should be preferred over MAP_FIXED.
>  .TP
>  .B MAP_GROWSDOWN
>  This flag is used for stacks.
> -- 
> 2.15.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
