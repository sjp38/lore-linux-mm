Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id D89476B0038
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 07:50:06 -0400 (EDT)
Received: by wicgj17 with SMTP id gj17so58343367wic.1
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 04:50:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r10si10554130wif.32.2015.08.07.04.50.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Aug 2015 04:50:04 -0700 (PDT)
Subject: Re: [PATCH V6 4/6] mm: mlock: Add mlock flags to enable
 VM_LOCKONFAULT usage
References: <1438184575-10537-1-git-send-email-emunson@akamai.com>
 <1438184575-10537-5-git-send-email-emunson@akamai.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55C49B69.9050805@suse.cz>
Date: Fri, 7 Aug 2015 13:50:01 +0200
MIME-Version: 1.0
In-Reply-To: <1438184575-10537-5-git-send-email-emunson@akamai.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org

On 07/29/2015 05:42 PM, Eric B Munson wrote:
> The previous patch introduced a flag that specified pages in a VMA
> should be placed on the unevictable LRU, but they should not be made
> present when the area is created.  This patch adds the ability to set
> this state via the new mlock system calls.
>
> We add MLOCK_ONFAULT for mlock2 and MCL_ONFAULT for mlockall.
> MLOCK_ONFAULT will set the VM_LOCKONFAULT modifier for VM_LOCKED.
> MCL_ONFAULT should be used as a modifier to the two other mlockall
> flags.  When used with MCL_CURRENT, all current mappings will be marked
> with VM_LOCKED | VM_LOCKONFAULT.  When used with MCL_FUTURE, the
> mm->def_flags will be marked with VM_LOCKED | VM_LOCKONFAULT.  When used
> with both MCL_CURRENT and MCL_FUTURE, all current mappings and
> mm->def_flags will be marked with VM_LOCKED | VM_LOCKONFAULT.
>
> Prior to this patch, mlockall() will unconditionally clear the
> mm->def_flags any time it is called without MCL_FUTURE.  This behavior
> is maintained after adding MCL_ONFAULT.  If a call to
> mlockall(MCL_FUTURE) is followed by mlockall(MCL_CURRENT), the
> mm->def_flags will be cleared and new VMAs will be unlocked.  This
> remains true with or without MCL_ONFAULT in either mlockall()
> invocation.
>
> munlock() will unconditionally clear both vma flags.  munlockall()
> unconditionally clears for VMA flags on all VMAs and in the
> mm->def_flags field.
>
> Signed-off-by: Eric B Munson <emunson@akamai.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Vlastimil Babka <vbabka@suse.cz>

The logic seems ok, although the fact that apply_mlockall_flags() is 
shared by both mlockall and munlockall makes it even more subtle than 
before :)

Anyway, just some nitpicks below.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

[...]

> +/*
> + * Take the MCL_* flags passed into mlockall (or 0 if called from munlockall)
> + * and translate into the appropriate modifications to mm->def_flags and/or the
> + * flags for all current VMAs.
> + *
> + * There are a couple of sublties with this.  If mlockall() is called multiple

                             ^ typo

> + * times with different flags, the values do not necessarily stack.  If mlockall
> + * is called once including the MCL_FUTURE flag and then a second time without
> + * it, VM_LOCKED and VM_LOCKONFAULT will be cleared from mm->def_flags.
> + */
>   static int apply_mlockall_flags(int flags)
>   {
>   	struct vm_area_struct * vma, * prev = NULL;
> +	vm_flags_t to_add = 0;
>
> -	if (flags & MCL_FUTURE)
> +	current->mm->def_flags &= ~(VM_LOCKED | VM_LOCKONFAULT);
> +	if (flags & MCL_FUTURE) {
>   		current->mm->def_flags |= VM_LOCKED;
> -	else
> -		current->mm->def_flags &= ~VM_LOCKED;
>
> -	if (flags == MCL_FUTURE)
> -		goto out;
> +		if (flags & MCL_ONFAULT)
> +			current->mm->def_flags |= VM_LOCKONFAULT;
> +
> +		/*
> +		 * When there were only two flags, we used to early out if only
> +		 * MCL_FUTURE was set.  Now that we have MCL_ONFAULT, we can
> +		 * only early out if MCL_FUTURE is set, but MCL_CURRENT is not.

Describing the relation to history of individual code lines in such 
detail is noise imho. The stacking subtleties is already described above.

> +		 * This is done, even though it promotes odd behavior, to
> +		 * maintain behavior from older kernels
> +		 */
> +		if (!(flags & MCL_CURRENT))
> +			goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
