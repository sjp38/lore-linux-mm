Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7BD528D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 13:56:35 -0500 (EST)
Message-ID: <4D6FE462.4080002@tilera.com>
Date: Thu, 3 Mar 2011 13:56:34 -0500
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/6] mm: Change flush_tlb_range() to take an mm_struct
References: <1299102027.1310.39.camel@laptop>	<20110302.134735.260066220.davem@davemloft.net>	<4D6FCE5D.4030904@tilera.com> <20110303.104542.104052570.davem@davemloft.net>
In-Reply-To: <20110303.104542.104052570.davem@davemloft.net>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: a.p.zijlstra@chello.nl, torvalds@linux-foundation.org, aarcange@redhat.com, tglx@linutronix.de, riel@redhat.com, mingo@elte.hu, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, benh@kernel.crashing.org, hugh.dickins@tiscali.co.uk, mel@csn.ul.ie, npiggin@kernel.dk, rmk@arm.linux.org.uk, schwidefsky@de.ibm.com

On 3/3/2011 1:45 PM, David Miller wrote:
>> I'm finding it hard to understand how the Sparc code handles icache
>> coherence.  It seems that the Spitfire MMU is the interesting one, but the
>> hard case seems to be when a process migrates around to various cores
>> during execution (thus leaving incoherent icache lines everywhere), and the
>> page is then freed and re-used for different executable code.  I'd think
>> that there would have to be xcall IPIs to flush all the cpus' icaches, or
>> to flush every core in the cpu_vm_mask plus do something at context switch,
>> but I don't see any of that.  No doubt I'm missing something :-)
> flush_dcache_page() remembers the cpu that wrote to the page (in the
> page flags), and cross-calls to that specific cpu.
>
> It is only that cpu which must flush his I-cache, since all other cpus
> saw the write on the bus and updated their I-cache lines as a result.
>
> See, in the sparc64 case, the incoherency issue is purely local to the
> store.  The problem case is specifically the local I-cache not seeing
> local writes, everything else is fine.  CPU I-caches see writes done
> by other cpus, just not those done by the local cpu.

Thanks, that makes sense.  Our architecture has no bus to snoop, so we
couldn't take advantage of that approach.

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
