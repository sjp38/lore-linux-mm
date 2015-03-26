Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 55C0C6B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 05:48:50 -0400 (EDT)
Received: by wgs2 with SMTP id 2so57933662wgs.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 02:48:49 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id qa2si27308343wic.10.2015.03.26.02.48.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 02:48:49 -0700 (PDT)
Received: by wiaa2 with SMTP id a2so14270462wia.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 02:48:48 -0700 (PDT)
Date: Thu, 26 Mar 2015 10:48:44 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 2/2] powerpc/mm: Tracking vDSO remap
Message-ID: <20150326094844.GB15407@gmail.com>
References: <20150325121118.GA2542@gmail.com>
 <cover.1427289960.git.ldufour@linux.vnet.ibm.com>
 <b6ce07f8e1e0d654371aee70bd8eac310456d0df.1427289960.git.ldufour@linux.vnet.ibm.com>
 <20150325183316.GA9090@gmail.com>
 <1427317797.6468.86.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427317797.6468.86.camel@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, user-mode-linux-user@lists.sourceforge.net, linux-arch@vger.kernel.org, linux-mm@kvack.org, cov@codeaurora.org, criu@openvz.org


* Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> > > +#define __HAVE_ARCH_REMAP
> > > +static inline void arch_remap(struct mm_struct *mm,
> > > +			      unsigned long old_start, unsigned long old_end,
> > > +			      unsigned long new_start, unsigned long new_end)
> > > +{
> > > +	/*
> > > +	 * mremap() doesn't allow moving multiple vmas so we can limit the
> > > +	 * check to old_start == vdso_base.
> > > +	 */
> > > +	if (old_start == mm->context.vdso_base)
> > > +		mm->context.vdso_base = new_start;
> > > +}
> > 
> > mremap() doesn't allow moving multiple vmas, but it allows the 
> > movement of multi-page vmas and it also allows partial mremap()s, 
> > where it will split up a vma.
> > 
> > In particular, what happens if an mremap() is done with 
> > old_start == vdso_base, but a shorter end than the end of the vDSO? 
> > (i.e. a partial mremap() with fewer pages than the vDSO size)
> 
> Is there a way to forbid splitting ? Does x86 deal with that case at 
> all or it doesn't have to for some other reason ?

So we use _install_special_mapping() - maybe PowerPC does that too? 
That adds VM_DONTEXPAND which ought to prevent some - but not all - of 
the VM API weirdnesses.

On x86 we'll just dump core if someone unmaps the vdso.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
