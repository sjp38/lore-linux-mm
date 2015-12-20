From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 1/2] x86/mm/pat: Change untrack_pfn() to handle unmapped
 vma
Date: Sun, 20 Dec 2015 10:21:38 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1512201007340.28591@nanos>
References: <1449678368-31793-1-git-send-email-toshi.kani@hpe.com> <1449678368-31793-2-git-send-email-toshi.kani@hpe.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449678368-31793-2-git-send-email-toshi.kani@hpe.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Toshi Kani <toshi.kani@hpe.com>
Cc: mingo@redhat.com, hpa@zytor.com, bp@alien8.de, stsp@list.ru, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@suse.de>
List-Id: linux-mm.kvack.org

Toshi,

On Wed, 9 Dec 2015, Toshi Kani wrote:
> diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
> index 188e3e0..f3e391e 100644
> --- a/arch/x86/mm/pat.c
> +++ b/arch/x86/mm/pat.c
> @@ -966,8 +966,14 @@ int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
>  
>  /*
>   * untrack_pfn is called while unmapping a pfnmap for a region.
> - * untrack can be called for a specific region indicated by pfn and size or
> - * can be for the entire vma (in which case pfn, size are zero).
> + * untrack_pfn can be called for a specific region indicated by pfn and
> + * size or can be for the entire vma (in which case pfn, size are zero).
> + *
> + * NOTE: mremap may move a virtual address of VM_PFNMAP, but keeps the
> + * pfn and cache type.  In this case, untrack_pfn() is called with the
> + * old vma after its translation has removed.  Hence, when follow_phys()
> + * fails, track_pfn() keeps the pfn tracked and clears VM_PAT from the
> + * old vma.
>   */
>  void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
>  		 unsigned long size)
> @@ -981,14 +987,13 @@ void untrack_pfn(struct vm_area_struct *vma, unsigned long pfn,
>  	/* free the chunk starting from pfn or the whole chunk */
>  	paddr = (resource_size_t)pfn << PAGE_SHIFT;
>  	if (!paddr && !size) {
> -		if (follow_phys(vma, vma->vm_start, 0, &prot, &paddr)) {
> -			WARN_ON_ONCE(1);
> -			return;
> -		}
> +		if (follow_phys(vma, vma->vm_start, 0, &prot, &paddr))
> +			goto out;

Shouldn't we have an explicit call in the mremap code which clears the
PAT flag on the mm instead of removing this sanity check?
  
Because that's what we end up with there. We just clear the PAT flag.

I rather prefer to do that explicitely, so the following call to
untrack_pfn() from move_vma()->do_munmap() ... will see the PAT flag
cleared. untrack_moved_pfn() or such.

Thanks,

	tglx
