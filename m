Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F02F66B003D
	for <linux-mm@kvack.org>; Mon, 11 May 2009 15:03:22 -0400 (EDT)
Date: Mon, 11 May 2009 12:03:23 -0700
From: Andy Isaacson <adi@hexapodia.org>
Subject: Re: [PATCH 4/8] proc: export more page flags in /proc/kpageflags
Message-ID: <20090511190323.GO21505@hexapodia.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090511114554.GC4748@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, fengguang.wu@intel.com, fweisbec@gmail.com, rostedt@goodmis.org, a.p.zijlstra@chello.nl, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, andi@firstfloor.org, mpm@selenic.com, adobriyan@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 11, 2009 at 01:45:54PM +0200, Ingo Molnar wrote:
> * Andrew Morton <akpm@linux-foundation.org> wrote:
> > Yes, we could place pagemap's two auxiliary files into debugfs but 
> > it would be rather stupid to split the feature's control files 
> > across two pseudo filesystems, one of which may not even exist.  
> > Plus pagemap is not a kernel debugging feature.
> 
> That's not what i'm suggesting though.
> 
> What i'm suggesting is that there's a zillion ways to enumerate and 
> index various kernel objects, doing that in /proc is fundamentally 
> wrong.

This sounds like you're saying that /proc/<pid>/pagemap is wrong, and
I'm pretty sure I disagree with that statement.  debugfs is not a
substitute for pagemap.  pagemap+kpageflags is a significant improvement
in the memory-usage-introspection capabilities provided to Linux
applications, and if it were harder to access (by depending on debugfs)
it would be significantly less useful.

> And there's no need to create a per PID/TID directory 
> structure in /debug either, to be able to list and access objects by 
> their PID.
> 
> _Especially_ when the end result is not human-readable to begin 
> with, as it is in the pagemap/kpagecount/kpageflags case.

FWIW, we had a support script break due to /proc/<pid>/pagemap (it
tarred up /proc/[0-9]*/* and /var/log/ and application logfiles and sent
it off to support@, so once pagemap appeared the support script started
filling up disks).  I toyed around with making pagemap read(2)s return
-EINVAL unless the reader lseek(2)ed first[1], but decided we were
better off just fixing the support script to enumerate interesting proc
files, since there's no guarantee against further suprising semantics
getting added to /proc (and we'd still need to support unpatched
kernels).

So while I love the capability that kpageflags and pagemap provides, its
implementation has not been without impact.

On a slightly different tangent -- it's pretty trivial to decode pagemap
with dd(1) and hd(1), or even perl, and it's not as if (for example)
/proc/<pid>/maps is made much easier to interpret just because its
contents are presented as ASCII rather than binary, so I feel like the
design decisions of pagemap are sane and defensible.

"I think that forms some kind of argument about kpageflags, but I'm not
sure if it's for or against."  -- someone witty

[1] fun fact -- cp(1) and cat(1) get the expected behavior with such a
patch, but dd(1) always lseek(2)s its input even if no skip= was
specified.

-andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
