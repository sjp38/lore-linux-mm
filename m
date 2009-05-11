Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4FD8F6B003D
	for <linux-mm@kvack.org>; Mon, 11 May 2009 07:45:36 -0400 (EDT)
Date: Mon, 11 May 2009 13:45:54 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 4/8] proc: export more page flags in /proc/kpageflags
Message-ID: <20090511114554.GC4748@elte.hu>
References: <20090508105320.316173813@intel.com> <20090508111031.020574236@intel.com> <20090508114742.GB17129@elte.hu> <20090508132452.bafa287a.akpm@linux-foundation.org> <20090509104409.GB16138@elte.hu> <20090509222612.887b96e3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090509222612.887b96e3.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: fengguang.wu@intel.com, fweisbec@gmail.com, rostedt@goodmis.org, a.p.zijlstra@chello.nl, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, andi@firstfloor.org, mpm@selenic.com, adobriyan@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Sat, 9 May 2009 12:44:09 +0200 Ingo Molnar <mingo@elte.hu> wrote:
> 
> > And because it was so crappy to be in /proc we are now also 
> > treating it as a hard ABI, not as a debugfs interface - for that 
> > single app that is using it.
> 
> We'd probably make better progress here were someone to explain 
> what pagemap actually is.
> 
> pagemap is a userspace interface via which application developers 
> (including embedded) can analyse, understand and optimise their 
> use of memory.

IMHO that's really a fancy sentence for: 'to debug how their app 
interacts with the kernel'. Yes, it can be said without the word 
'debug' or 'instrumentation' in it. Maybe it could also be written 
without having any r's in it.

Doing any of that does not change the meaning of the feature though.

> It is not debugging feature at all, let alone a kernel debugging 
> feature.  For this reason it is not appropriate that its 
> interfaces be presented in debugfs.
> 
> Furthermore the main control file for pagemap is in 
> /proc/<pid>/pagemap.  pagemap _cannot_ be put in debugfs because 
> debugfs doesn't maintain the per-process subdirectories in which 
> to place it.  /proc/<pid>/ is exactly the place where the pagemap 
> file should appear.

only if done in a stupid way.

The thing is, nor are all active inodes enumerated in /debug and not 
in /proc either. And we've stopped stuffing new instrumentation into 
/proc about a decade ago and introduced debugfs for that.

_Especially_ when some piece of instrumentation is clearly growing 
in scope and nature, as here.

> Yes, we could place pagemap's two auxiliary files into debugfs but 
> it would be rather stupid to split the feature's control files 
> across two pseudo filesystems, one of which may not even exist.  
> Plus pagemap is not a kernel debugging feature.

That's not what i'm suggesting though.

What i'm suggesting is that there's a zillion ways to enumerate and 
index various kernel objects, doing that in /proc is fundamentally 
wrong. And there's no need to create a per PID/TID directory 
structure in /debug either, to be able to list and access objects by 
their PID.

_Especially_ when the end result is not human-readable to begin 
with, as it is in the pagemap/kpagecount/kpageflags case.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
