Received: from localhost.localdomain ([127.0.0.1]:51436 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20037436AbXA2V5R (ORCPT <rfc822;linux-mm@kvack.org>);
	Mon, 29 Jan 2007 21:57:17 +0000
Date: Mon, 29 Jan 2007 21:27:19 +0000
From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [patch] mm: mremap correct rmap accounting
Message-ID: <20070129212719.GA12262@linux-mips.org>
References: <45B61967.5000302@yahoo.com.au> <Pine.LNX.4.64.0701232041330.2461@blonde.wat.veritas.com> <45BD6A7B.7070501@yahoo.com.au> <Pine.LNX.4.64.0701291901550.8996@blonde.wat.veritas.com> <Pine.LNX.4.64.0701291123460.3611@woody.linux-foundation.org> <20070129120325.26707d26.akpm@osdl.org> <Pine.LNX.4.64.0701291216340.3611@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0701291216340.3611@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, "Maciej W. Rozycki" <macro@linux-mips.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 29, 2007 at 12:18:29PM -0800, Linus Torvalds wrote:

(adding Maciej who is using R4000 for much of his MIPS hacking to cc ...)

> > Can we convert those bits of mips to just have a single zero-page, like
> > everyone else?
> > 
> > Is that trick a correctness thing, or a performance thing?  If the latter,
> > how useful is it, and how common are the chips which use it?
> 
> It was a performance thing, iirc. Apparently a fairly big deal: pages 
> kicking each other out of the cache due to idiotic cache design. But I 
> forget any details.

R4000 and R4400 SC and MC versions suffer from virtual aliases but have a
hardware mechanism to detect them and will throw a virtual coherency
exception if so.  So in theory for these processors the entire burden of
handling cache aliases can be left to like ten lines of exception handling
code.  A real world machine may encounter millions of these exceptions in
a relativly short time which sucks performancewise, so aliasing avoidance
by careful selection of addresses and cacheflushes is needed.

So to make that more explicit, it's not needed for correctness but it's
a performance - and sometimes a fairly big one - thing.

(The easy solution for the issue would be raising the pagesize to the next
higher supported values, 16kB or 64kB.  Now for the true idiocy of this
exception-based scheme - it happens that the hardware checks three bits for
aliasing as if the CPU had 32kB direct mapped caches even though these
types only have 8kB (R4000) rsp 16kB (R4400) primary caches.  This means
ramping up the page size to 16kB wouldn't suffice - it would have to be
64kB to eleminate aliases which is impractical for memory reasons on many
systems.

Anyway, no other MIPS processor has this "virtual coherency exception"
and so I don't have an affected system at hand right now.  So I hacked
a 2.6.20-rc6 kernel for another machine to do R4x00 style ZERO_PAGE
handling - and the system did survive a quick 10min testing just fine
until a test case which Nick had mailed to me killed the system as
predicted.  I blame obsoletion of the chips and lucky choice of workload
for this issue only ever having been reported once and that report was
probably ignored because it was sufficiently obscure.

> MIPS in general is a f*cking pain in the *ss. They have a few chips that 
> are sane, but just an incredible amount of totally braindamaged ones. 
> They're not the only ones with virtual caches, but they're certainly 
> well-represented there. Sad.

Eh...  MIPS isn't the architecture with VIVT data caches.  It's other
arch maintainers that get their sleep robbed by truly st00pid caches.

  Ralf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
