Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0861F6B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 05:43:37 -0400 (EDT)
Received: by wgdm6 with SMTP id m6so57727884wgd.2
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 02:43:36 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id u15si8968621wjr.155.2015.03.26.02.43.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 02:43:35 -0700 (PDT)
Received: by wibgn9 with SMTP id gn9so76776033wib.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 02:43:34 -0700 (PDT)
Date: Thu, 26 Mar 2015 10:43:30 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 2/2] powerpc/mm: Tracking vDSO remap
Message-ID: <20150326094330.GA15407@gmail.com>
References: <20150325121118.GA2542@gmail.com>
 <cover.1427289960.git.ldufour@linux.vnet.ibm.com>
 <b6ce07f8e1e0d654371aee70bd8eac310456d0df.1427289960.git.ldufour@linux.vnet.ibm.com>
 <20150325183316.GA9090@gmail.com>
 <20150325183647.GA9331@gmail.com>
 <1427317867.6468.87.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427317867.6468.87.camel@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, user-mode-linux-devel@lists.sourceforge.net, user-mode-linux-user@lists.sourceforge.net, linux-arch@vger.kernel.org, linux-mm@kvack.org, cov@codeaurora.org, criu@openvz.org


* Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> On Wed, 2015-03-25 at 19:36 +0100, Ingo Molnar wrote:
> > * Ingo Molnar <mingo@kernel.org> wrote:
> > 
> > > > +#define __HAVE_ARCH_REMAP
> > > > +static inline void arch_remap(struct mm_struct *mm,
> > > > +			      unsigned long old_start, unsigned long old_end,
> > > > +			      unsigned long new_start, unsigned long new_end)
> > > > +{
> > > > +	/*
> > > > +	 * mremap() doesn't allow moving multiple vmas so we can limit the
> > > > +	 * check to old_start == vdso_base.
> > > > +	 */
> > > > +	if (old_start == mm->context.vdso_base)
> > > > +		mm->context.vdso_base = new_start;
> > > > +}
> > > 
> > > mremap() doesn't allow moving multiple vmas, but it allows the 
> > > movement of multi-page vmas and it also allows partial mremap()s, 
> > > where it will split up a vma.
> > 
> > I.e. mremap() supports the shrinking (and growing) of vmas. In that 
> > case mremap() will unmap the end of the vma and will shrink the 
> > remaining vDSO vma.
> > 
> > Doesn't that result in a non-working vDSO that should zero out 
> > vdso_base?
> 
> Right. Now we can't completely prevent the user from shooting itself 
> in the foot I suppose, though there is a legit usage scenario which 
> is to move the vDSO around which it would be nice to support. I 
> think it's reasonable to put the onus on the user here to do the 
> right thing.

I argue we should use the right condition to clear vdso_base: if the 
vDSO gets at least partially unmapped. Otherwise there's little point 
in the whole patch: either correctly track whether the vDSO is OK, or 
don't ...

There's also the question of mprotect(): can users mprotect() the vDSO 
on PowerPC?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
