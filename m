Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B3FE86B0033
	for <linux-mm@kvack.org>; Sun, 26 Nov 2017 09:48:48 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id k3so9557126wmg.6
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 06:48:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x17sor2978303wmh.14.2017.11.26.06.48.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 26 Nov 2017 06:48:46 -0800 (PST)
Date: Sun, 26 Nov 2017 15:48:42 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 04/30] x86, kaiser: disable global pages by default with
 KAISER
Message-ID: <20171126144842.7ojxbo5wsu44w4ti@gmail.com>
References: <20171110193058.BECA7D88@viggo.jf.intel.com>
 <20171110193105.02A90543@viggo.jf.intel.com>
 <1510688325.1080.1.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1510688325.1080.1.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, bp@suse.de, tglx@linutronix.de, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


* Rik van Riel <riel@redhat.com> wrote:

> On Fri, 2017-11-10 at 11:31 -0800, Dave Hansen wrote:
> > From: Dave Hansen <dave.hansen@linux.intel.com>
> > 
> > Global pages stay in the TLB across context switches.  Since all
> > contexts
> > share the same kernel mapping, these mappings are marked as global
> > pages
> > so kernel entries in the TLB are not flushed out on a context switch.
> > 
> > But, even having these entries in the TLB opens up something that an
> > attacker can use [1].
> > 
> > That means that even when KAISER switches page tables on return to
> > user
> > space the global pages would stay in the TLB cache.
> > 
> > Disable global pages so that kernel TLB entries can be flushed before
> > returning to user space. This way, all accesses to kernel addresses
> > from
> > userspace result in a TLB miss independent of the existence of a
> > kernel
> > mapping.
> > 
> > Replace _PAGE_GLOBAL by __PAGE_KERNEL_GLOBAL and keep _PAGE_GLOBAL
> > available so that it can still be used for a few selected kernel
> > mappings
> > which must be visible to userspace, when KAISER is enabled, like the
> > entry/exit code and data.
> 
> Nice changelog.
> 
> Why am I pointing this out?
> 
> > +++ b/arch/x86/include/asm/pgtable_types.h	2017-11-10
> > 11:22:06.626244956 -0800
> > @@ -179,8 +179,20 @@ enum page_cache_mode {
> >  #define PAGE_READONLY_EXEC	__pgprot(_PAGE_PRESENT |
> > _PAGE_USER |	\
> >  					 _PAGE_ACCESSED)
> >  
> > +/*
> > + * Disable global pages for anything using the default
> > + * __PAGE_KERNEL* macros.  PGE will still be enabled
> > + * and _PAGE_GLOBAL may still be used carefully.
> > + */
> > +#ifdef CONFIG_KAISER
> > +#define __PAGE_KERNEL_GLOBAL	0
> > +#else
> > +#define __PAGE_KERNEL_GLOBAL	_PAGE_GLOBAL
> > +#endif
> > +					
> 
> The comment above could use a little more info
> on why things are done that way, though :)

Good point - I've updated these comments to say:

/*
 * Disable global pages for anything using the default
 * __PAGE_KERNEL* macros.
 *
 * PGE will still be enabled and _PAGE_GLOBAL may still be used carefully
 * for a few selected kernel mappings which must be visible to userspace,
 * when KAISER is enabled, like the entry/exit code and data.
 */
#ifdef CONFIG_KAISER
#define __PAGE_KERNEL_GLOBAL	0
#else
#define __PAGE_KERNEL_GLOBAL	_PAGE_GLOBAL
#endif

... and I've added your Reviewed-by tag which I assume now applies?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
