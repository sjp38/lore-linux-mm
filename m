Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 924906B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 14:33:23 -0400 (EDT)
Received: by wgra20 with SMTP id a20so37648658wgr.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 11:33:23 -0700 (PDT)
Received: from mail-wg0-x234.google.com (mail-wg0-x234.google.com. [2a00:1450:400c:c00::234])
        by mx.google.com with ESMTPS id ey12si6417211wid.87.2015.03.25.11.33.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 11:33:21 -0700 (PDT)
Received: by wgdm6 with SMTP id m6so37930987wgd.2
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 11:33:21 -0700 (PDT)
Date: Wed, 25 Mar 2015 19:33:16 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 2/2] powerpc/mm: Tracking vDSO remap
Message-ID: <20150325183316.GA9090@gmail.com>
References: <20150325121118.GA2542@gmail.com>
 <cover.1427289960.git.ldufour@linux.vnet.ibm.com>
 <b6ce07f8e1e0d654371aee70bd8eac310456d0df.1427289960.git.ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b6ce07f8e1e0d654371aee70bd8eac310456d0df.1427289960.git.ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, user-mode-linux-user@lists.sourceforge.net, linux-arch@vger.kernel.org, linux-mm@kvack.org, cov@codeaurora.org, criu@openvz.org


* Laurent Dufour <ldufour@linux.vnet.ibm.com> wrote:

> +static inline void arch_unmap(struct mm_struct *mm,
> +			struct vm_area_struct *vma,
> +			unsigned long start, unsigned long end)
> +{
> +	if (start <= mm->context.vdso_base && mm->context.vdso_base < end)
> +		mm->context.vdso_base = 0;
> +}

So AFAICS PowerPC can have multi-page vDSOs, right?

So what happens if I munmap() the middle or end of the vDSO? The above 
condition only seems to cover unmaps that affect the first page. I 
think 'affects any page' ought to be the right condition? (But I know 
nothing about PowerPC so I might be wrong.)


> +#define __HAVE_ARCH_REMAP
> +static inline void arch_remap(struct mm_struct *mm,
> +			      unsigned long old_start, unsigned long old_end,
> +			      unsigned long new_start, unsigned long new_end)
> +{
> +	/*
> +	 * mremap() doesn't allow moving multiple vmas so we can limit the
> +	 * check to old_start == vdso_base.
> +	 */
> +	if (old_start == mm->context.vdso_base)
> +		mm->context.vdso_base = new_start;
> +}

mremap() doesn't allow moving multiple vmas, but it allows the 
movement of multi-page vmas and it also allows partial mremap()s, 
where it will split up a vma.

In particular, what happens if an mremap() is done with 
old_start == vdso_base, but a shorter end than the end of the vDSO? 
(i.e. a partial mremap() with fewer pages than the vDSO size)

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
