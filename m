Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 874C86B0072
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 15:32:48 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id k14so3168589wgh.32
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 12:32:47 -0700 (PDT)
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id fo6si13814245wjc.83.2014.07.24.12.32.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 24 Jul 2014 12:32:42 -0700 (PDT)
Date: Thu, 24 Jul 2014 19:32:25 +0000
From: Serge Hallyn <serge.hallyn@ubuntu.com>
Subject: Re: [rfc 1/4] mm: Introduce may_adjust_brk helper
Message-ID: <20140724193225.GT26600@ubuntumail>
References: <20140724164657.452106845@openvz.org>
 <20140724165047.437075575@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140724165047.437075575@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, keescook@chromium.org, tj@kernel.org, akpm@linux-foundation.org, avagin@openvz.org, ebiederm@xmission.com, hpa@zytor.com, serge.hallyn@canonical.com, xemul@parallels.com, segoon@openwall.com, kamezawa.hiroyu@jp.fujitsu.com, mtk.manpages@gmail.com, jln@google.com

Quoting Cyrill Gorcunov (gorcunov@openvz.org):
> To eliminate code duplication lets introduce may_adjust_brk
> helper which we will use in brk() and prctl() syscalls.
> 
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andrew Vagin <avagin@openvz.org>
> Cc: Eric W. Biederman <ebiederm@xmission.com>
> Cc: H. Peter Anvin <hpa@zytor.com>
> Cc: Serge Hallyn <serge.hallyn@canonical.com>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: Vasiliy Kulikov <segoon@openwall.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Michael Kerrisk <mtk.manpages@gmail.com>
> Cc: Julien Tinnes <jln@google.com>
> ---
>  include/linux/mm.h |   14 ++++++++++++++
>  1 file changed, 14 insertions(+)
> 
> Index: linux-2.6.git/include/linux/mm.h
> ===================================================================
> --- linux-2.6.git.orig/include/linux/mm.h
> +++ linux-2.6.git/include/linux/mm.h
> @@ -18,6 +18,7 @@
>  #include <linux/pfn.h>
>  #include <linux/bit_spinlock.h>
>  #include <linux/shrinker.h>
> +#include <linux/resource.h>
>  
>  struct mempolicy;
>  struct anon_vma;
> @@ -1780,6 +1781,19 @@ extern struct vm_area_struct *copy_vma(s
>  	bool *need_rmap_locks);
>  extern void exit_mmap(struct mm_struct *);
>  
> +static inline int may_adjust_brk(unsigned long rlim,
> +				 unsigned long new_brk,
> +				 unsigned long start_brk,
> +				 unsigned long end_data,
> +				 unsigned long start_data)
> +{
> +	if (rlim < RLIMIT_DATA) {

In the code you're replacing, this was RLIM_INFINITY.  Did you really
mean for this to be RLIMIT_DATA, aka 2?

> +		if (((new_brk - start_brk) + (end_data - start_data)) > rlim)
> +			return -ENOSPC;
> +	}
> +	return 0;
> +}
> +
>  extern int mm_take_all_locks(struct mm_struct *mm);
>  extern void mm_drop_all_locks(struct mm_struct *mm);
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
