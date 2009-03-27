Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 32AFA6B003D
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 02:03:47 -0400 (EDT)
Subject: Re: tlb_gather_mmu() and semantics of "fullmm"
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20090326.225744.250374539.davem@davemloft.net>
References: <1238132287.20197.47.camel@pasglop>
	 <20090326.224433.150749170.davem@davemloft.net>
	 <1238133267.20197.56.camel@pasglop>
	 <20090326.225744.250374539.davem@davemloft.net>
Content-Type: text/plain
Date: Fri, 27 Mar 2009 17:10:35 +1100
Message-Id: <1238134235.20197.64.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Miller <davem@davemloft.net>
Cc: hugh@veritas.com, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, npiggin@suse.de, zach@vmware.com, jeremy@goop.org
List-ID: <linux-mm.kvack.org>

On Thu, 2009-03-26 at 22:57 -0700, David Miller wrote:

> Good point.
> 
> Maybe it would work out correctly if I used current->mm?
> 
> Because if I tested it that way, only something really executing
> in userland could force the cpumask bit clears.
> 
> Any kernel thread would flush the TLB if and when it switched
> back into a real task using that mm.
> 
> Sound good?

/me thinks (not as late here but I'm getting tired regardless ;-)

So if you test current->mm, you effectively account for mm_users == 1,
so the only way the mm can be active on another processor is as a lazy
mm for a kernel thread. So your test should work properly as long
as you don't have a HW that will do speculative TLB reloads into the
TLB on that other CPU (and even if you do, you flush-on-switch-in should
get rid of any crap here).

Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
