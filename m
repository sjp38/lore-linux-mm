Subject: Re: [patch 3/3] mm: variable length argument support
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070807122008.fcd175d6.akpm@linux-foundation.org>
References: <20070613100334.635756997@chello.nl>
	 <20070613100835.014096712@chello.nl> <20070807190357.GA31139@aepfle.de>
	 <20070807122008.fcd175d6.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 07 Aug 2007 21:26:36 +0200
Message-Id: <1186514797.11797.173.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Olaf Hering <olaf@aepfle.de>, linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Ollie Wild <aaw@google.com>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-08-07 at 12:20 -0700, Andrew Morton wrote:
> On Tue, 7 Aug 2007 21:03:57 +0200
> Olaf Hering <olaf@aepfle.de> wrote:
> 
> > On Wed, Jun 13, Peter Zijlstra wrote:
> > 
> > > From: Ollie Wild <aaw@google.com>
> > > 
> > > Remove the arg+env limit of MAX_ARG_PAGES by copying the strings directly
> > > from the old mm into the new mm.
> > 
> > > +++ linux-2.6-2/include/linux/binfmts.h	2007-06-13 11:52:46.000000000 +0200
> > > @@ -6,11 +6,13 @@
> > >  struct pt_regs;
> > >  
> > >  /*
> > > - * MAX_ARG_PAGES defines the number of pages allocated for arguments
> > > - * and envelope for the new program. 32 should suffice, this gives
> > > - * a maximum env+arg of 128kB w/4KB pages!
> > > + * These are the maximum length and maximum number of strings passed to the
> > > + * execve() system call.  MAX_ARG_STRLEN is essentially random but serves to
> > > + * prevent the kernel from being unduly impacted by misaddressed pointers.
> > > + * MAX_ARG_STRINGS is chosen to fit in a signed 32-bit integer.
> > >   */
> > > -#define MAX_ARG_PAGES 32
> > > +#define MAX_ARG_STRLEN (PAGE_SIZE * 32)
> > > +#define MAX_ARG_STRINGS 0x7FFFFFFF
> > 
> > This adds a new usage of PAGE_SIZE to an exported header.
> > How can this be fixed for 2.6.23?
> 
> Put #ifdef __KERNEL__ around it?

Sounds like a good idea, since its new there should not yet be anybody
using it.

If anything, someone used to use MAX_ARG_PAGES in userspace, which we
just now broke. Olaf said he'd grep a distro source base to find out :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
