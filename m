Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8BD878D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 13:45:08 -0500 (EST)
Date: Thu, 03 Mar 2011 10:45:42 -0800 (PST)
Message-Id: <20110303.104542.104052570.davem@davemloft.net>
Subject: Re: [RFC][PATCH 2/6] mm: Change flush_tlb_range() to take an
 mm_struct
From: David Miller <davem@davemloft.net>
In-Reply-To: <4D6FCE5D.4030904@tilera.com>
References: <1299102027.1310.39.camel@laptop>
	<20110302.134735.260066220.davem@davemloft.net>
	<4D6FCE5D.4030904@tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cmetcalf@tilera.com
Cc: a.p.zijlstra@chello.nl, torvalds@linux-foundation.org, aarcange@redhat.com, tglx@linutronix.de, riel@redhat.com, mingo@elte.hu, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, benh@kernel.crashing.org, hugh.dickins@tiscali.co.uk, mel@csn.ul.ie, npiggin@kernel.dk, rmk@arm.linux.org.uk, schwidefsky@de.ibm.com

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Thu, 3 Mar 2011 12:22:37 -0500

> I'm finding it hard to understand how the Sparc code handles icache
> coherence.  It seems that the Spitfire MMU is the interesting one, but the
> hard case seems to be when a process migrates around to various cores
> during execution (thus leaving incoherent icache lines everywhere), and the
> page is then freed and re-used for different executable code.  I'd think
> that there would have to be xcall IPIs to flush all the cpus' icaches, or
> to flush every core in the cpu_vm_mask plus do something at context switch,
> but I don't see any of that.  No doubt I'm missing something :-)

flush_dcache_page() remembers the cpu that wrote to the page (in the
page flags), and cross-calls to that specific cpu.

It is only that cpu which must flush his I-cache, since all other cpus
saw the write on the bus and updated their I-cache lines as a result.

See, in the sparc64 case, the incoherency issue is purely local to the
store.  The problem case is specifically the local I-cache not seeing
local writes, everything else is fine.  CPU I-caches see writes done
by other cpus, just not those done by the local cpu.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
