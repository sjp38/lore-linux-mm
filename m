Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 28F536B0033
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 04:10:55 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id f7so9582025pfa.21
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 01:10:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j11si6339858pll.429.2017.12.16.01.10.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 16 Dec 2017 01:10:53 -0800 (PST)
Date: Sat, 16 Dec 2017 10:10:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2 1/2] mm, mmu_notifier: annotate mmu notifiers with
 blockable invalidate callbacks
Message-ID: <20171216091044.GE16951@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1712111409090.196232@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1712141329500.74052@chino.kir.corp.google.com>
 <20171215150429.f68862867392337f35a49848@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171215150429.f68862867392337f35a49848@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Oded Gabbay <oded.gabbay@gmail.com>, Alex Deucher <alexander.deucher@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David Airlie <airlied@linux.ie>, Joerg Roedel <joro@8bytes.org>, Doug Ledford <dledford@redhat.com>, Jani Nikula <jani.nikula@linux.intel.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Sean Hefty <sean.hefty@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 15-12-17 15:04:29, Andrew Morton wrote:
> On Thu, 14 Dec 2017 13:30:56 -0800 (PST) David Rientjes <rientjes@google.com> wrote:
> 
> > Commit 4d4bbd8526a8 ("mm, oom_reaper: skip mm structs with mmu notifiers")
> > prevented the oom reaper from unmapping private anonymous memory with the
> > oom reaper when the oom victim mm had mmu notifiers registered.
> > 
> > The rationale is that doing mmu_notifier_invalidate_range_{start,end}()
> > around the unmap_page_range(), which is needed, can block and the oom
> > killer will stall forever waiting for the victim to exit, which may not
> > be possible without reaping.
> > 
> > That concern is real, but only true for mmu notifiers that have blockable
> > invalidate_range_{start,end}() callbacks.  This patch adds a "flags" field
> > to mmu notifier ops that can set a bit to indicate that these callbacks do
> > not block.
> > 
> > The implementation is steered toward an expensive slowpath, such as after
> > the oom reaper has grabbed mm->mmap_sem of a still alive oom victim.
> 
> some tweakage, please review.
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm-mmu_notifier-annotate-mmu-notifiers-with-blockable-invalidate-callbacks-fix
> 
> make mm_has_blockable_invalidate_notifiers() return bool, use rwsem_is_locked()

Yes, that makes sense to me.

> 
> Cc: Alex Deucher <alexander.deucher@amd.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Cc: Christian KA?nig <christian.koenig@amd.com>
> Cc: David Airlie <airlied@linux.ie>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Dimitri Sivanich <sivanich@hpe.com>
> Cc: Doug Ledford <dledford@redhat.com>
> Cc: Jani Nikula <jani.nikula@linux.intel.com>
> Cc: JA(C)rA'me Glisse <jglisse@redhat.com>
> Cc: Joerg Roedel <joro@8bytes.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>
> Cc: Oded Gabbay <oded.gabbay@gmail.com>
> Cc: Paolo Bonzini <pbonzini@redhat.com>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Radim KrA?mA!A? <rkrcmar@redhat.com>
> Cc: Sean Hefty <sean.hefty@intel.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  include/linux/mmu_notifier.h |    7 ++++---
>  mm/mmu_notifier.c            |    8 ++++----
>  2 files changed, 8 insertions(+), 7 deletions(-)
> 
> diff -puN include/linux/mmu_notifier.h~mm-mmu_notifier-annotate-mmu-notifiers-with-blockable-invalidate-callbacks-fix include/linux/mmu_notifier.h
> --- a/include/linux/mmu_notifier.h~mm-mmu_notifier-annotate-mmu-notifiers-with-blockable-invalidate-callbacks-fix
> +++ a/include/linux/mmu_notifier.h
> @@ -2,6 +2,7 @@
>  #ifndef _LINUX_MMU_NOTIFIER_H
>  #define _LINUX_MMU_NOTIFIER_H
>  
> +#include <linux/types.h>
>  #include <linux/list.h>
>  #include <linux/spinlock.h>
>  #include <linux/mm_types.h>
> @@ -233,7 +234,7 @@ extern void __mmu_notifier_invalidate_ra
>  				  bool only_end);
>  extern void __mmu_notifier_invalidate_range(struct mm_struct *mm,
>  				  unsigned long start, unsigned long end);
> -extern int mm_has_blockable_invalidate_notifiers(struct mm_struct *mm);
> +extern bool mm_has_blockable_invalidate_notifiers(struct mm_struct *mm);
>  
>  static inline void mmu_notifier_release(struct mm_struct *mm)
>  {
> @@ -473,9 +474,9 @@ static inline void mmu_notifier_invalida
>  {
>  }
>  
> -static inline int mm_has_blockable_invalidate_notifiers(struct mm_struct *mm)
> +static inline bool mm_has_blockable_invalidate_notifiers(struct mm_struct *mm)
>  {
> -	return 0;
> +	return false;
>  }
>  
>  static inline void mmu_notifier_mm_init(struct mm_struct *mm)
> diff -puN mm/mmu_notifier.c~mm-mmu_notifier-annotate-mmu-notifiers-with-blockable-invalidate-callbacks-fix mm/mmu_notifier.c
> --- a/mm/mmu_notifier.c~mm-mmu_notifier-annotate-mmu-notifiers-with-blockable-invalidate-callbacks-fix
> +++ a/mm/mmu_notifier.c
> @@ -240,13 +240,13 @@ EXPORT_SYMBOL_GPL(__mmu_notifier_invalid
>   * Must be called while holding mm->mmap_sem for either read or write.
>   * The result is guaranteed to be valid until mm->mmap_sem is dropped.
>   */
> -int mm_has_blockable_invalidate_notifiers(struct mm_struct *mm)
> +bool mm_has_blockable_invalidate_notifiers(struct mm_struct *mm)
>  {
>  	struct mmu_notifier *mn;
>  	int id;
> -	int ret = 0;
> +	bool ret = false;
>  
> -	WARN_ON_ONCE(down_write_trylock(&mm->mmap_sem));
> +	WARN_ON_ONCE(!rwsem_is_locked(&mm->mmap_sem));
>  
>  	if (!mm_has_notifiers(mm))
>  		return ret;
> @@ -259,7 +259,7 @@ int mm_has_blockable_invalidate_notifier
>  				continue;
>  
>  		if (!(mn->ops->flags & MMU_INVALIDATE_DOES_NOT_BLOCK)) {
> -			ret = 1;
> +			ret = true;
>  			break;
>  		}
>  	}
> _
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
