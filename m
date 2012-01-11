Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id E93166B0068
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 02:05:17 -0500 (EST)
From: Milton Miller <miltonm@bga.com>
Subject: Re: [PATCH v6 2/8] arm: move arm over to generic on_each_cpu_mask
In-Reply-To: <1326040026-7285-3-git-send-email-gilad@benyossef.com>
References: <1326040026-7285-3-git-send-email-gilad@benyossef.com>
Date: Wed, 11 Jan 2012 01:04:11 -0600
Message-ID: <1326265451_1659@mail4.comsite.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org
Cc: Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Sasha Levin <levinsasha928@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.org>, Kosaki Motohiro <kosaki.motohiro@gmail.com>

On Sun Jan 08 2012 about 11:28:02 EST, Gilad Ben-Yossef wrote:
> Note that the generic version is a little different then the Arm one:
> 
> 1. It has the mask as first parameter
> 2. It calls the function on the calling CPU with interrupts disabled,
> but this should be OK since the function is called on the other CPUs
> with interrupts disabled anyway.

While the split is good for review, since this function uses the same
name we will need to combine 1-3 to avoid a bisection build error.



-		on_each_cpu_mask(ipi_flush_tlb_page, &ta, 1, mm_cpumask(vma->vm_mm));
+		on_each_cpu_mask(mm_cpumask(vma->vm_mm), ipi_flush_tlb_page,
+			&ta, 1);

Since you are only rearranging the arguments and not adding any
characters, my first thought would be just leave the line long.
However, looking at the 80 column wrap I see how "mm));" is more
clearly wrapped text vs ", 1);".

My suggestion is to create a local var to shorten the line, probably 
struct mm_struct *mm, but a cpumask_var_t would also work.

Overall a minor point, I'm ok if this doesn't happen.

milton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
