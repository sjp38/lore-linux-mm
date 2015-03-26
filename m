Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id EB8B76B006C
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 14:55:56 -0400 (EDT)
Received: by wibg7 with SMTP id g7so23256968wib.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 11:55:56 -0700 (PDT)
Received: from mail-wg0-x22b.google.com (mail-wg0-x22b.google.com. [2a00:1450:400c:c00::22b])
        by mx.google.com with ESMTPS id co6si11387208wjb.54.2015.03.26.11.55.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 11:55:55 -0700 (PDT)
Received: by wgbcc7 with SMTP id cc7so74015418wgb.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 11:55:55 -0700 (PDT)
Date: Thu, 26 Mar 2015 19:55:50 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v4 2/2] powerpc/mm: Tracking vDSO remap
Message-ID: <20150326185550.GA25547@gmail.com>
References: <20150326141730.GA23060@gmail.com>
 <cover.1427390952.git.ldufour@linux.vnet.ibm.com>
 <7fdae652993cf88bdd633d65e5a8f81c7ad8a1e3.1427390952.git.ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7fdae652993cf88bdd633d65e5a8f81c7ad8a1e3.1427390952.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, user-mode-linux-user@lists.sourceforge.net, linux-arch@vger.kernel.org, linux-mm@kvack.org, cov@codeaurora.org, criu@openvz.org


* Laurent Dufour <ldufour@linux.vnet.ibm.com> wrote:

> +{
> +	unsigned long vdso_end, vdso_start;
> +
> +	if (!mm->context.vdso_base)
> +		return;
> +	vdso_start = mm->context.vdso_base;
> +
> +#ifdef CONFIG_PPC64
> +	/* Calling is_32bit_task() implies that we are dealing with the
> +	 * current process memory. If there is a call path where mm is not
> +	 * owned by the current task, then we'll have need to store the
> +	 * vDSO size in the mm->context.
> +	 */
> +	BUG_ON(current->mm != mm);
> +	if (is_32bit_task())
> +		vdso_end = vdso_start + (vdso32_pages << PAGE_SHIFT);
> +	else
> +		vdso_end = vdso_start + (vdso64_pages << PAGE_SHIFT);
> +#else
> +	vdso_end = vdso_start + (vdso32_pages << PAGE_SHIFT);
> +#endif
> +	vdso_end += (1<<PAGE_SHIFT); /* data page */
> +
> +	/* Check if the vDSO is in the range of the remapped area */
> +	if ((vdso_start <= old_start && old_start < vdso_end) ||
> +	    (vdso_start < old_end && old_end <= vdso_end)  ||
> +	    (old_start <= vdso_start && vdso_start < old_end)) {
> +		/* Update vdso_base if the vDSO is entirely moved. */
> +		if (old_start == vdso_start && old_end == vdso_end &&
> +		    (old_end - old_start) == (new_end - new_start))
> +			mm->context.vdso_base = new_start;
> +		else
> +			mm->context.vdso_base = 0;
> +	}
> +}

Oh my, that really looks awfully complex, as you predicted, and right 
in every mremap() call.

I'm fine with your original, imperfect, KISS approach. Sorry about 
this detour ...

Reviewed-by: Ingo Molnar <mingo@kernel.org>

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
