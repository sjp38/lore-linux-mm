Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EF4256B004F
	for <linux-mm@kvack.org>; Fri,  3 Jul 2009 19:19:27 -0400 (EDT)
Subject: Re: handle_mm_fault() calling convention cleanup..
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <alpine.LFD.2.01.0906211331480.3240@localhost.localdomain>
References: <alpine.LFD.2.01.0906211331480.3240@localhost.localdomain>
Content-Type: text/plain
Date: Sat, 04 Jul 2009 09:35:07 +1000
Message-Id: <1246664107.7551.11.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-arch@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Sun, 2009-06-21 at 13:42 -0700, Linus Torvalds wrote:
> Just a heads up that I committed the patches that I sent out two months 
> ago to make the fault handling routines use the finer-grained fault flags 
> (FAULT_FLAG_xyzzy) rather than passing in a boolean for "write".
> 
> That was originally for the NOPAGE_RETRY patches, but it's a general 
> cleanup too. I have this suspicion that we should extend this to 
> "get_user_pages()" too, instead of having those boolean "write" and 
> "force" flags (and GUP_FLAGS_xyzzy as opposed to FAULT_FLAGS_yyzzy).

BTW. I'd like to extend these if there's no objection one of these days
to also pass whether it was an exec fault, and pass the full flags to
ptep_set_access_flags().

That would (finally) give us a better hook for architectures that need
to do it to handle i$/d$ coherency. Right now, I go dig for the current
fault type inside the current pt_regs from ptep_set_access_flags() which
is positively ugly.

Ben.

> We should probably also get rid of the insane FOLL_xyz flags too. Right 
> now the code in fact depends on FOLL_WRITE being the same as 
> FAULT_FLAGS_WRITE, and while that is a simple dependency, it's just crazy 
> how we have all these different flags for what ends up often boiling down 
> to the same fundamental issue in the end (even if not all versions of the 
> flags are necessarily always valid for all uses).
> 
> I fixed up all architectures that I noticed (at least microblaze had been 
> added since the original patches in April), but arch maintainers should 
> double-check. Arch maintainers might also want to check whether the 
> mindless conversion of
> 
> 	'is_write' => 'is_write ? FAULT_FLAGS_WRITE : 0'
> 
> might perhaps be written in some more natural way (for example, maybe 
> you'd like to get rid of 'iswrite' as a variable entirely, and replace it 
> with a 'fault_flags' variable).
> 
> It's pushed out and tested on x86-64, but it really was such a mindless 
> conversion that I hope it works on all architectures. But I thought I'd 
> better give people a shout-out regardless.
> 
> 		Linus
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
