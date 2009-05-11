Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3A16E6B004D
	for <linux-mm@kvack.org>; Mon, 11 May 2009 18:08:56 -0400 (EDT)
Date: Tue, 12 May 2009 00:08:34 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 4/8] proc: export more page flags in /proc/kpageflags
Message-ID: <20090511220834.GA26614@elte.hu>
References: <20090508105320.316173813@intel.com> <20090508111031.020574236@intel.com> <20090508114742.GB17129@elte.hu> <20090508132452.bafa287a.akpm@linux-foundation.org> <20090509104409.GB16138@elte.hu> <20090509222612.887b96e3.akpm@linux-foundation.org> <20090511114554.GC4748@elte.hu> <20090511113157.b2c56e70.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090511113157.b2c56e70.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: fengguang.wu@intel.com, fweisbec@gmail.com, rostedt@goodmis.org, a.p.zijlstra@chello.nl, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, andi@firstfloor.org, mpm@selenic.com, adobriyan@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 11 May 2009 13:45:54 +0200
> Ingo Molnar <mingo@elte.hu> wrote:
> 
> > > Yes, we could place pagemap's two auxiliary files into debugfs but 
> > > it would be rather stupid to split the feature's control files 
> > > across two pseudo filesystems, one of which may not even exist.  
> > > Plus pagemap is not a kernel debugging feature.
> > 
> > That's not what i'm suggesting though.
> > 
> > What i'm suggesting is that there's a zillion ways to enumerate 
> > and index various kernel objects, doing that in /proc is 
> > fundamentally wrong. And there's no need to create a per PID/TID 
> > directory structure in /debug either, to be able to list and 
> > access objects by their PID.
> 
> The problem with procfs was that it was growing a lot of random 
> non-process-related stuff.  We never deprecated procfs - we 
> decided that it should be retained for its original purpose and 
> that non-process-realted things shouldn't go in there.
> 
> The /proc/<pid>/pagemap file clearly _is_ process-related, and 
> /proc/<pid> is the natural and correct place for it to live.
> 
> Yes, sure, there are any number of ways in which that data could 
> be presented to userspace in other locations and via other means.  
> But there would need to be an extraordinarily good reason for 
> violating the existing paradigm/expectation/etc.

It has also been clearly demonstrated in this thread that people 
want more enumeration than just the the process dimension. 

_Especially_ for an object like pages. Often most of the memory in a 
Linux system is _not mapped to any process_. It is in the page 
cache. Still, /proc enumeration does not capture it. Why? Because 
IMO it has been done at the wrong layer, at the wrong abstraction 
level.

Yes, /proc is for process enumeration (as the name tells us 
already), but it is not really suitable as a general object 
enumerator for kernel debugging or kernel instrumentation purposes. 

By putting kernel instrumentation into /proc, we limit all _future_ 
enumeration greatly. Instead of adding just another iterator 
(walker), we now have to move the whole thing across into another 
domain (which is being resisted, and /proc is an ABI anyway).

It's all doable, but a lot harder if it's not being relized why it's 
important to do it.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
