Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E79156B0085
	for <linux-mm@kvack.org>; Fri,  8 Oct 2010 13:32:33 -0400 (EDT)
Date: Fri, 8 Oct 2010 19:32:29 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 2/4] HWPOISON: Copy si_addr_lsb to user
Message-ID: <20101008173229.GH13352@basil.fritz.box>
References: <1286398141-13749-1-git-send-email-andi@firstfloor.org>
 <1286398141-13749-3-git-send-email-andi@firstfloor.org>
 <20101008170941.GA3025@linux-mips.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101008170941.GA3025@linux-mips.org>
Sender: owner-linux-mm@kvack.org
To: Ralf Baechle <ralf@linux-mips.org>
Cc: Andi Kleen <andi@firstfloor.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, fengguang.wu@intel.com, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Manuel Lauss <manuel.lauss@googlemail.com>, linux-mips@linux-mips.org, tony.luck@intel.com
List-ID: <linux-mm.kvack.org>

On Fri, Oct 08, 2010 at 06:09:41PM +0100, Ralf Baechle wrote:
> > --- a/kernel/signal.c
> > +++ b/kernel/signal.c
> > @@ -2215,6 +2215,14 @@ int copy_siginfo_to_user(siginfo_t __user *to, siginfo_t *from)
> >  #ifdef __ARCH_SI_TRAPNO
> >  		err |= __put_user(from->si_trapno, &to->si_trapno);
> >  #endif
> > +#ifdef BUS_MCEERR_AO
> > +		/* 
> > +		 * Other callers might not initialize the si_lsb field,
> > +	 	 * so check explicitely for the right codes here.
> > +		 */
> > +		if (from->si_code == BUS_MCEERR_AR || from->si_code == BUS_MCEERR_AO)
> > +			err |= __put_user(from->si_addr_lsb, &to->si_addr_lsb);
> > +#endif
> 
> include/asm-generic/siginfo.h defines BUS_MCEERR_AR unconditionally and is
> getting include in all <asm/siginfo.h> so that #ifdef condition is always
> true.  struct siginfo.si_addr_lsb is defined only for the generic struct
> siginfo.  The architectures that define HAVE_ARCH_SIGINFO_T (MIPS and
> IA-64) do not define this field so the build breaks.

Oops. I see two possible solutions:

#undef BUS_MCEERR_AR in the ia64 and mips siginfo.h or simply
add the si_addr_lsb field there too (it just sits over padding
and should be harmless)

What do you prefer?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
