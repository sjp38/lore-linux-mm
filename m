Subject: Re: 2.6.26-rc5-mm3
From: Daniel Walker <dwalker@mvista.com>
In-Reply-To: <20080619091337.GA15228@elte.hu>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
	 <alpine.DEB.1.00.0806130006490.14928@gamma>
	 <1213811751.11203.73.camel@localhost.localdomain>
	 <20080619091337.GA15228@elte.hu>
Content-Type: text/plain
Date: Thu, 19 Jun 2008 07:39:30 -0700
Message-Id: <1213886370.11203.80.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Byron Bradley <byron.bbradley@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Hua Zhong <hzhong@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-06-19 at 11:13 +0200, Ingo Molnar wrote:

> the better fix would be to add likely_prof.o to this list of exceptions 
> in lib/Makefile:
> 
>  ifdef CONFIG_FTRACE
>  # Do not profile string.o, since it may be used in early boot or vdso
>  CFLAGS_REMOVE_string.o = -pg
>  # Also do not profile any debug utilities
>  CFLAGS_REMOVE_spinlock_debug.o = -pg
>  CFLAGS_REMOVE_list_debug.o = -pg
>  CFLAGS_REMOVE_debugobjects.o = -pg
>  endif
> 
> instead of adding notrace to the source.
> 
> 	Ingo

Here's the fix mentioned above.

--

Remove tracing from likely profiling since it could cause recursion if
ftrace uses likely/unlikely macro's internally.

Signed-off-by: Daniel Walker <dwalker@mvista.com>

---
 lib/Makefile |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-2.6.25/lib/Makefile
===================================================================
--- linux-2.6.25.orig/lib/Makefile
+++ linux-2.6.25/lib/Makefile
@@ -15,6 +15,8 @@ CFLAGS_REMOVE_string.o = -pg
 CFLAGS_REMOVE_spinlock_debug.o = -pg
 CFLAGS_REMOVE_list_debug.o = -pg
 CFLAGS_REMOVE_debugobjects.o = -pg
+# likely profiling can cause recursion in ftrace, so don't trace it.
+CFLAGS_REMOVE_likely_prof.o = -pg
 endif
 
 lib-$(CONFIG_MMU) += ioremap.o


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
