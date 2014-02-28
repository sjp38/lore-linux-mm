Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id CAE3A6B0073
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 06:52:26 -0500 (EST)
Received: by mail-we0-f173.google.com with SMTP id w61so458886wes.32
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 03:52:26 -0800 (PST)
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com. [195.75.94.110])
        by mx.google.com with ESMTPS id fu7si1356729wjb.118.2014.02.28.03.52.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 28 Feb 2014 03:52:25 -0800 (PST)
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Fri, 28 Feb 2014 11:52:23 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 8562617D804E
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 11:52:54 +0000 (GMT)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1SBq8VZ64421952
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 11:52:08 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1SCqKXn011583
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 05:52:20 -0700
Message-ID: <53107872.7030904@de.ibm.com>
Date: Fri, 28 Feb 2014 12:52:18 +0100
From: Christian Borntraeger <borntraeger@de.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm, s390: Ignore MADV_HUGEPAGE on s390 to prevent
 SIGSEGV in qemu
References: <cover.1393516106.git.athorlton@sgi.com> <c856e298ae180842638bdf85d74436ad8bbb84e4.1393516106.git.athorlton@sgi.com>
In-Reply-To: <c856e298ae180842638bdf85d74436ad8bbb84e4.1393516106.git.athorlton@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux390@de.ibm.com, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On 27/02/14 18:23, Alex Thorlton wrote:
> As Christian pointed out, the recent 'Revert "thp: make MADV_HUGEPAGE
> check for mm->def_flags"' breaks qemu, it does QEMU_MADV_HUGEPAGE for
> all kvm pages but this doesn't work after s390_enable_sie/thp_split_mm.
> 
> Paolo suggested that instead of failing on the call to madvise, we
> simply ignore the call (return 0).
> 
> Reported-by: Christian Borntraeger <borntraeger@de.ibm.com>
> Suggested-by: Paolo Bonzini <pbonzini@redhat.com>
> Suggested-by: Oleg Nesterov <oleg@redhat.com>
> Signed-off-by: Alex Thorlton <athorlton@sgi.com>
> Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Christian Borntraeger <borntraeger@de.ibm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: linux390@de.ibm.com
> Cc: linux-s390@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: linux-api@vger.kernel.org
> 
> ---
>  mm/huge_memory.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index a4310a5..61d234d 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1970,6 +1970,15 @@ int hugepage_madvise(struct vm_area_struct *vma,
>  {
>  	switch (advice) {
>  	case MADV_HUGEPAGE:
> +#ifdef CONFIG_S390
> +		/*
> +		 * qemu blindly sets MADV_HUGEPAGE on all allocations, but s390
> +		 * can't handle this properly after s390_enable_sie, so we simply
> +		 * ignore the madvise to prevent qemu from causing a SIGSEGV.
> +		 */
> +		if (mm_has_pgste(vma->vm_mm))
> +			return 0;
> +#endif
>  		/*
>  		 * Be somewhat over-protective like KSM for now!
>  		 */
> 


Tested-by: Christian Borntraeger <borntraeger@de.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
