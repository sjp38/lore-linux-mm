Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id F08036B0038
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 17:53:26 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 4so8404315itv.4
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 14:53:26 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id q10si249555ite.31.2017.09.15.14.53.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Sep 2017 14:53:25 -0700 (PDT)
Subject: Re: [patch] mremap.2: Add description of old_size == 0 functionality
References: <20170915213745.6821-1-mike.kravetz@oracle.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <a6e59a7f-fd15-9e49-356e-ed439f17e9df@oracle.com>
Date: Fri, 15 Sep 2017 14:53:19 -0700
MIME-Version: 1.0
In-Reply-To: <20170915213745.6821-1-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mtk.manpages@gmail.com
Cc: linux-man@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org

CC: linux-mm

On 09/15/2017 02:37 PM, Mike Kravetz wrote:
> Since at least the 2.6 time frame, mremap would create a new mapping
> of the same pages if 'old_size == 0'.  It would also leave the original
> mapping.  This was used to create a 'duplicate mapping'.
> 
> Document the behavior and return codes.  But, also mention that the
> functionality is deprecated and discourage its use.
> 
> A recent change was made to mremap so that an attempt to create a
> duplicate a private mapping will fail.
> 
> commit dba58d3b8c5045ad89c1c95d33d01451e3964db7
> Author: Mike Kravetz <mike.kravetz@oracle.com>
> Date:   Wed Sep 6 16:20:55 2017 -0700
> 
>     mm/mremap: fail map duplication attempts for private mappings
> 
> This return code is also documented here.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  man2/mremap.2 | 23 ++++++++++++++++++++++-
>  1 file changed, 22 insertions(+), 1 deletion(-)
> 
> diff --git a/man2/mremap.2 b/man2/mremap.2
> index 98643c640..98df7d5fa 100644
> --- a/man2/mremap.2
> +++ b/man2/mremap.2
> @@ -58,6 +58,21 @@ may be provided; see the description of
>  .B MREMAP_FIXED
>  below.
>  .PP
> +If the value of \fIold_size\fP is zero, and \fIold_address\fP refers to
> +a private anonymous mapping, then
> +.BR mremap ()
> +will create a new mapping of the same pages. \fInew_size\fP
> +will be the size of the new mapping and the location of the new mapping
> +may be specified with \fInew_address\fP, see the description of
> +.B MREMAP_FIXED
> +below.  If a new mapping is requested via this method, then the
> +.B MREMAP_MAYMOVE
> +flag must also be specified.  This functionality is deprecated, and no
> +new code should be written to use this feature.  A better method of
> +obtaining multiple mappings of the same private anonymous memory is via the
> +.BR memfd_create()
> +system call.
> +.PP
>  In Linux the memory is divided into pages.
>  A user process has (one or)
>  several linear virtual memory segments.
> @@ -174,7 +189,12 @@ and
>  or
>  .B MREMAP_FIXED
>  was specified without also specifying
> -.BR MREMAP_MAYMOVE .
> +.BR MREMAP_MAYMOVE ;
> +or \fIold_size\fP was zero and \fIold_address\fP does not refer to a
> +private anonymous mapping;
> +or \fIold_size\fP was zero and the
> +.BR MREMAP_MAYMOVE
> +flag was not specified.
>  .TP
>  .B ENOMEM
>  The memory area cannot be expanded at the current virtual address, and the
> @@ -210,6 +230,7 @@ if the area cannot be populated.
>  .BR brk (2),
>  .BR getpagesize (2),
>  .BR getrlimit (2),
> +.BR memfd_create(2),
>  .BR mlock (2),
>  .BR mmap (2),
>  .BR sbrk (2),
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
