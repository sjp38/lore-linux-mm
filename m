Date: Tue, 31 Jul 2007 15:51:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: make swappiness safer to use
Message-Id: <20070731155109.228b4f19.akpm@linux-foundation.org>
In-Reply-To: <20070731224052.GW6910@v2.random>
References: <20070731215228.GU6910@v2.random>
	<20070731151244.3395038e.akpm@linux-foundation.org>
	<20070731224052.GW6910@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 1 Aug 2007 00:40:52 +0200
Andrea Arcangeli <andrea@suse.de> wrote:

> > Want to see if we can present that expression in a more logical fashion, and
> > be more careful about the underflows and overflows, and fix the potential
> > divide-by-zero?
> 
> I may be missing something,

Yeah, I misread the paranthesisation. sorry.

I nice way of coding this would be:

	/*
	 * comment goes here
	 */
	adjust = zone_page_state(zone, NR_ACTIVE) /
			(zone_page_state(zone, NR_INACTIVE) + 1);

	/*
	 * comment goes here 
	 */
	adjust *= (vm_swappiness + 1) / 100;

	/*
	 * comment goes here 
	 */
	adjust *= mapped_ratio / 100;

	/*
	 * comment goes here
	 */
	swap_tendency += adjust;

so there's no confusion over parenthesisation or associativity, and the
reader can see the logic as it unfolds.  The compiler should do exactly the
same thing.

It is worth expending the extra effort and screen space for clarity in that
part of the kernel, given the amount of trouble it causes, and the amount
of time people spend sweating over it.   Those would want to be good 
comments, too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
