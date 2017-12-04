Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7A4736B0268
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 06:31:26 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id b82so3976813wmd.5
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 03:31:26 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q27si10801330edd.522.2017.12.04.03.31.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Dec 2017 03:31:25 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vB4BT6YE154943
	for <linux-mm@kvack.org>; Mon, 4 Dec 2017 06:31:23 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2en46wvc06-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 04 Dec 2017 06:31:23 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 4 Dec 2017 11:31:21 -0000
Date: Mon, 4 Dec 2017 13:31:13 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] mmap.2: MAP_FIXED updated documentation
References: <20171204021411.4786-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171204021411.4786-1-jhubbard@nvidia.com>
Message-Id: <20171204113113.GA13465@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: Michael Kerrisk <mtk.manpages@gmail.com>, linux-man <linux-man@vger.kernel.org>, linux-api@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, Jann Horn <jannh@google.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, John Hubbard <jhubbard@nvidia.com>

On Sun, Dec 03, 2017 at 06:14:11PM -0800, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> Previously, MAP_FIXED was "discouraged", due to portability
> issues with the fixed address. In fact, there are other, more
> serious issues. Also, in some limited cases, this option can
> be used safely.
> 
> Expand the documentation to discuss both the hazards, and how
> to use it safely.
> 
> The "Portability issues" wording is lifted directly from
> Matthew Wilcox's review. The notes about other libraries
> creating mappings is also from Matthew (lightly edited).
> 
> The suggestion to explain how to use MAP_FIXED safely is
> from Jann Horn.
> 
> Suggested-by: Matthew Wilcox <willy@infradead.org>
> Suggested-by: Jann Horn <jannh@google.com>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> ---
> 
> Changed from v1:
> 
>     -- Covered topics recommended by Matthew Wilcox
>        and Jann Horn, in their recent review: the hazards
>        of overwriting pre-exising mappings, and some notes
>        about how to use MAP_FIXED safely.
> 
>     -- Rewrote the commit description accordingly.
> 
>  man2/mmap.2 | 38 ++++++++++++++++++++++++++++++++++++--
>  1 file changed, 36 insertions(+), 2 deletions(-)
> 
> diff --git a/man2/mmap.2 b/man2/mmap.2
> index 385f3bfd5..9038256d4 100644
> --- a/man2/mmap.2
> +++ b/man2/mmap.2
> @@ -222,8 +222,42 @@ part of the existing mapping(s) will be discarded.
>  If the specified address cannot be used,
>  .BR mmap ()
>  will fail.
> -Because requiring a fixed address for a mapping is less portable,
> -the use of this option is discouraged.
> +.IP
> +This option is extremely hazardous (when used on its own) and moderately
> +non-portable.
> +.IP
> +Portability issues: a process's memory map may change significantly from one
> +run to the next, depending on library versions, kernel versions and random
> +numbers.
> +.IP
> +Hazards: this option forcibly removes pre-existing mappings, making it easy
> +for a multi-threaded process to corrupt its own address space.
> +.IP
> +For example, thread A looks through /proc/<pid>/maps and locates an available
> +address range, while thread B simultaneously acquires part or all of that same
> +address range. Thread A then calls mmap(MAP_FIXED), effectively overwriting
> +thread B's mapping.
> +.IP
> +Thread B need not create a mapping directly; simply making a library call
> +that, internally, uses dlopen(3) to load some other shared library, will
> +suffice. The dlopen(3) call will map the library into the process's address
> +space. Furthermore, almost any library call may be implemented using this
> +technique.
> +Examples include brk(2), malloc(3), pthread_create(3), and the PAM libraries
> +(http://www.linux-pam.org).
> +.IP
> +Given the above limitations, one of the very few ways to use this option
> +safely is: mmap() a region, without specifying MAP_FIXED. Then, within that
> +region, call mmap(MAP_FIXED) to suballocate regions. This avoids both the
> +portability problem (because the first mmap call lets the kernel pick the
> +address), and the address space corruption problem (because the region being
> +overwritten is already owned by the calling thread).

Maybe "address space corruption problem caused by implicit calls to mmap"?
The region allocated with the first mmap is not exactly owned by the
thread and a multi-thread application can still corrupt its memory if
different threads use mmap(MAP_FIXED) for overlapping regions.

My 2 cents.

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
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
