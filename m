Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 956E76B027D
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 19:06:27 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a20-v6so14916076pfi.1
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 16:06:27 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id 3-v6si18678500pfl.220.2018.07.10.16.06.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 16:06:26 -0700 (PDT)
Subject: Re: [RFC PATCH v2 13/27] mm: Handle shadow stack page fault
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-14-yu-cheng.yu@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <2f3ff321-c629-3e00-59f6-8bca510650d4@linux.intel.com>
Date: Tue, 10 Jul 2018 16:06:25 -0700
MIME-Version: 1.0
In-Reply-To: <20180710222639.8241-14-yu-cheng.yu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 07/10/2018 03:26 PM, Yu-cheng Yu wrote:
> +	if (is_shstk_mapping(vma->vm_flags))
> +		entry = pte_mkdirty_shstk(entry);
> +	else
> +		entry = pte_mkdirty(entry);
> +
> +	entry = maybe_mkwrite(entry, vma);
>  	if (ptep_set_access_flags(vma, vmf->address, vmf->pte, entry, 1))
>  		update_mmu_cache(vma, vmf->address, vmf->pte);
>  	pte_unmap_unlock(vmf->pte, vmf->ptl);
> @@ -2526,7 +2532,11 @@ static int wp_page_copy(struct vm_fault *vmf)
>  		}
>  		flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
>  		entry = mk_pte(new_page, vma->vm_page_prot);
> -		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +		if (is_shstk_mapping(vma->vm_flags))
> +			entry = pte_mkdirty_shstk(entry);
> +		else
> +			entry = pte_mkdirty(entry);
> +		entry = maybe_mkwrite(entry, vma);

Do we want to lift this hunk of code and put it elsewhere?  Maybe:

	entry = pte_set_vma_features(entry, vma);

and then:

pte_t pte_set_vma_features(pte_t entry, struct vm_area_struct)
{
		/*
		 * Shadow stack PTEs are always dirty and always
		 * writable.  They have a different encoding for
		 * this than normal PTEs, though.
		 */
		if (is_shstk_mapping(vma->vm_flags))
			entry = pte_mkdirty_shstk(entry);
		else
			entry = pte_mkdirty(entry);

		entry = maybe_mkwrite(entry, vma);

	return entry;
}

>  		/*
>  		 * Clear the pte entry and flush it first, before updating the
>  		 * pte with the new entry. This will avoid a race condition
> @@ -3201,6 +3211,14 @@ static int do_anonymous_page(struct vm_fault *vmf)
>  	mem_cgroup_commit_charge(page, memcg, false, false);
>  	lru_cache_add_active_or_unevictable(page, vma);
>  setpte:
> +	/*
> +	 * If this is within a shadow stack mapping, mark
> +	 * the PTE dirty.  We don't use pte_mkdirty(),
> +	 * because the PTE must have _PAGE_DIRTY_HW set.
> +	 */
> +	if (is_shstk_mapping(vma->vm_flags))
> +		entry = pte_mkdirty_shstk(entry);
> +
>  	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, entry);

I'm not sure this is the right spot to do this.

The other code does pte_mkdirty_shstk() near where we do the
pte_mkwrite().  Why not here?  I think you might have picked this
because it's a common path used by both allocated pages and zero pages.
But, we can't have the zero pages in shadow stack areas since they can't
be read-only.  I think you need to move this up.  Can you even
consolidate it with the other two pte_mkdirt_shstk() call sites?

>  	/* No need to invalidate - it was non-present before */
> @@ -3983,6 +4001,14 @@ static int handle_pte_fault(struct vm_fault *vmf)
>  	entry = vmf->orig_pte;
>  	if (unlikely(!pte_same(*vmf->pte, entry)))
>  		goto unlock;
> +
> +	/*
> +	 * Shadow stack PTEs are copy-on-access, so do_wp_page()
> +	 * handling on them no matter if we have write fault or not.
> +	 */

I'd say this differently:

	Shadow stack PTEs can not be read-only and because of that can
	not have traditional copy-on-write semantics.  This essentially
	performs a copy-on-write operation, but on *any* access, not
	just actual writes.
