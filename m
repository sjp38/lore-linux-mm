Date: Fri, 28 Mar 2008 12:23:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/9] Pageflags: Get rid of FLAGS_RESERVED
Message-Id: <20080328122313.aa8d7c8c.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0803281159250.18120@schroedinger.engr.sgi.com>
References: <20080318181957.138598511@sgi.com>
	<20080318182035.197900850@sgi.com>
	<20080328011240.fae44d52.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0803281148110.17920@schroedinger.engr.sgi.com>
	<20080328115919.12c0445b.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0803281159250.18120@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: apw@shadowen.org, davem@davemloft.net, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, jeremy@goop.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 28 Mar 2008 12:04:00 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 28 Mar 2008, Andrew Morton wrote:
> 
> > On Fri, 28 Mar 2008 11:51:09 -0700 (PDT)
> > Christoph Lameter <clameter@sgi.com> wrote:
> > 
> > > On Fri, 28 Mar 2008, Andrew Morton wrote:
> > > 
> > > > For some reason this isn't working on mips - include/linux/bounds.h has no
> > > > #define for NR_PAGEFLAGS.
> > > 
> > > Likely an asm issue? Are there no definitions at all in 
> > > include/linux/bounds.h?
> > 
> > None - just the skeleton comments and ifdefs.
> 
> Guess the asm is different for mips:
> 
> kernel/bounds.c does:
> 
> #define DEFINE(sym, val) \
>         asm volatile("\n->" #sym " %0 " #val : : "i" (val))
> 
> mips wants something different.
> 
> #define offset(string, val) \
>         __asm__("\n@@@" string "%0" : : "i" (val))
> 
> Argh. Do an #ifdef MIPS or add a definition in an arch specific .h file 
> somewhere?

The usual way is to add asm-generic/foo.h which has the usual
implementation and then have each arch's asm/foo.h include
asm-generic/foo.h.  Architectires which have special needs would provide a
custom implementation and do not include the asm-generic file.

> The asm could be different. gas is pretty uniform but some 
> arches may not be using gas?

I'm unaware of any other assemblers being used.  If they are, they'd need
to be fairly gassy to be able to build the kernel.  Maybe Intel's ICC uses
its own assembler, dunno - hopefully it uses gas.

Why do we use gas at all here?  All we're doing is converting

->NR_PAGEFLAGS 18 __NR_PAGEFLAGS         #

into

#define NR_PAGEFLAGS 18

which can be done with sed or whatever?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
