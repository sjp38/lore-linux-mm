Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 05A406B009D
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 16:01:08 -0500 (EST)
Date: Tue, 22 Nov 2011 21:00:18 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v4 2/5] arm: Move arm over to generic on_each_cpu_mask
Message-ID: <20111122210018.GF9581@n2100.arm.linux.org.uk>
References: <1321960128-15191-1-git-send-email-gilad@benyossef.com> <1321960128-15191-3-git-send-email-gilad@benyossef.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1321960128-15191-3-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Sasha Levin <levinsasha928@gmail.com>

On Tue, Nov 22, 2011 at 01:08:45PM +0200, Gilad Ben-Yossef wrote:
> -static void on_each_cpu_mask(void (*func)(void *), void *info, int wait,
> -	const struct cpumask *mask)
> -{
> -	preempt_disable();
> -
> -	smp_call_function_many(mask, func, info, wait);
> -	if (cpumask_test_cpu(smp_processor_id(), mask))
> -		func(info);
> -
> -	preempt_enable();
> -}

What hasn't been said in the descriptions (I couldn't find it) is that
there's a semantic change between the new generic version and this version -
that is, we run the function with IRQs disabled on the local CPU, whereas
the version above runs it with IRQs potentially enabled.

Luckily, for TLB flushing this is probably not a problem, but it's
something that should've been pointed out in the patch description.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
