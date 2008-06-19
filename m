Date: Thu, 19 Jun 2008 11:13:37 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.26-rc5-mm3
Message-ID: <20080619091337.GA15228@elte.hu>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org> <alpine.DEB.1.00.0806130006490.14928@gamma> <1213811751.11203.73.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1213811751.11203.73.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Walker <dwalker@mvista.com>
Cc: Byron Bradley <byron.bbradley@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Hua Zhong <hzhong@gmail.com>
List-ID: <linux-mm.kvack.org>

* Daniel Walker <dwalker@mvista.com> wrote:

> 
> On Fri, 2008-06-13 at 00:32 +0100, Byron Bradley wrote:
> > Looks like x86 and ARM both fail to boot if PROFILE_LIKELY, FTRACE and 
> > DYNAMIC_FTRACE are selected. If any one of those three are disabled it 
> > boots (or fails in some other way which I'm looking at now). The serial 
> > console output from both machines when they fail to boot is below, let me 
> > know if there is any other information I can provide.
> 
> I was able to reproduce a hang on x86 with those options. The patch
> below is a potential fix. I think we don't want to trace
> do_check_likely(), since the ftrace internals might use likely/unlikely
> macro's which will just cause recursion back to do_check_likely()..
> 
> Signed-off-by: Daniel Walker <dwalker@mvista.com>
> 
> ---
>  lib/likely_prof.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: linux-2.6.25/lib/likely_prof.c
> ===================================================================
> --- linux-2.6.25.orig/lib/likely_prof.c
> +++ linux-2.6.25/lib/likely_prof.c
> @@ -22,7 +22,7 @@
>  
>  static struct likeliness *likeliness_head;
>  
> -int do_check_likely(struct likeliness *likeliness, unsigned int ret)
> +int notrace do_check_likely(struct likeliness *likeliness, unsigned int ret)

the better fix would be to add likely_prof.o to this list of exceptions 
in lib/Makefile:

 ifdef CONFIG_FTRACE
 # Do not profile string.o, since it may be used in early boot or vdso
 CFLAGS_REMOVE_string.o = -pg
 # Also do not profile any debug utilities
 CFLAGS_REMOVE_spinlock_debug.o = -pg
 CFLAGS_REMOVE_list_debug.o = -pg
 CFLAGS_REMOVE_debugobjects.o = -pg
 endif

instead of adding notrace to the source.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
