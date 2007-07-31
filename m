Date: Tue, 31 Jul 2007 15:12:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: make swappiness safer to use
Message-Id: <20070731151244.3395038e.akpm@linux-foundation.org>
In-Reply-To: <20070731215228.GU6910@v2.random>
References: <20070731215228.GU6910@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Jul 2007 23:52:28 +0200
Andrea Arcangeli <andrea@suse.de> wrote:

> +		swap_tendency += zone_page_state(zone, NR_ACTIVE) /
> +			(zone_page_state(zone, NR_INACTIVE) + 1)
> +			* (vm_swappiness + 1) / 100
> +			* mapped_ratio / 100;

I must say, that's a pretty ugly-looking statement.  For a start, the clause

			* (vm_swappiness + 1) / 100

always evaluates to zero.  The L->R associativity prevents that, but the
layout is super-misleading, no?

And it matters - the potential for overflow and rounding errors here is
considerable.  Let's go through it.  Probably 32-bit is the problem.


	zone_page_state(zone, NR_ACTIVE) /

	0 -> 8,000,000

		(zone_page_state(zone, NR_INACTIVE) + 1)

min: 1, max: 8,000,000

		* (vm_swappiness + 1)

min: 1, max: 101

total min: 1, total max: 800,000,000

	/ 100


total min: 0, total max: 8,000,000

		* mapped_ratio

total min: 0, total max: 800,000,000

		/ 100;

total min: 0, total max: 8,000,000

then we divide zone_page_state(zone, NR_ACTIVE) by this value.

We can get a divide-by-zero if zone_page_state(zone, NR_INACTIVE) is
sufficiently small, I think?  At least, it isn't obvious that we cannot.

I suspect that we can get a value >100, too.  Especially when we add it to
the existing value of swap_tendency, but I didn't think about it too hard.

Want to see if we can present that expression in a more logical fashion, and
be more careful about the underflows and overflows, and fix the potential
divide-by-zero?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
