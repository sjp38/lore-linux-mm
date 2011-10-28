Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3E03F6B0023
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 00:06:36 -0400 (EDT)
Date: Thu, 27 Oct 2011 23:06:31 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH v2 6/6] slub: only preallocate cpus_with_slabs if
 offstack
In-Reply-To: <1319385413-29665-7-git-send-email-gilad@benyossef.com>
Message-ID: <alpine.DEB.2.00.1110272304020.14619@router.home>
References: <1319385413-29665-1-git-send-email-gilad@benyossef.com> <1319385413-29665-7-git-send-email-gilad@benyossef.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>

On Sun, 23 Oct 2011, Gilad Ben-Yossef wrote:

> We need a cpumask to track cpus with per cpu cache pages
> to know which cpu to whack during flush_all. For
> CONFIG_CPUMASK_OFFSTACK=n we allocate the mask on stack.
> For CONFIG_CPUMASK_OFFSTACK=y we don't want to call kmalloc
> on the flush_all path, so we preallocate per kmem_cache
> on cache creation and use it in flush_all.

I think the on stack alloc should be the default because we can then avoid
the field in kmem_cache and the associated logic with managing the field.
Can we do a GFP_ATOMIC allocation in flush_all()? If the alloc
fails then you can still fallback to send an IPI to all cpus.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
