Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id A03156B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 14:36:53 -0400 (EDT)
Received: by wibg7 with SMTP id g7so120384612wib.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 11:36:53 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com. [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id p8si5757906wjx.82.2015.03.25.11.36.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 11:36:52 -0700 (PDT)
Received: by wixw10 with SMTP id w10so81036556wix.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 11:36:51 -0700 (PDT)
Date: Wed, 25 Mar 2015 19:36:47 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 2/2] powerpc/mm: Tracking vDSO remap
Message-ID: <20150325183647.GA9331@gmail.com>
References: <20150325121118.GA2542@gmail.com>
 <cover.1427289960.git.ldufour@linux.vnet.ibm.com>
 <b6ce07f8e1e0d654371aee70bd8eac310456d0df.1427289960.git.ldufour@linux.vnet.ibm.com>
 <20150325183316.GA9090@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150325183316.GA9090@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, user-mode-linux-user@lists.sourceforge.net, linux-arch@vger.kernel.org, linux-mm@kvack.org, cov@codeaurora.org, criu@openvz.org


* Ingo Molnar <mingo@kernel.org> wrote:

> > +#define __HAVE_ARCH_REMAP
> > +static inline void arch_remap(struct mm_struct *mm,
> > +			      unsigned long old_start, unsigned long old_end,
> > +			      unsigned long new_start, unsigned long new_end)
> > +{
> > +	/*
> > +	 * mremap() doesn't allow moving multiple vmas so we can limit the
> > +	 * check to old_start == vdso_base.
> > +	 */
> > +	if (old_start == mm->context.vdso_base)
> > +		mm->context.vdso_base = new_start;
> > +}
> 
> mremap() doesn't allow moving multiple vmas, but it allows the 
> movement of multi-page vmas and it also allows partial mremap()s, 
> where it will split up a vma.

I.e. mremap() supports the shrinking (and growing) of vmas. In that 
case mremap() will unmap the end of the vma and will shrink the 
remaining vDSO vma.

Doesn't that result in a non-working vDSO that should zero out 
vdso_base?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
