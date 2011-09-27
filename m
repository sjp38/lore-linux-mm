Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 27C109000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 12:13:18 -0400 (EDT)
Date: Tue, 27 Sep 2011 11:13:13 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH 4/5] mm: Only IPI CPUs to drain local pages if they
 exist
In-Reply-To: <CAOtvUMcvwWFxxxv7tsOj6FO-wrHAU8EYc+U=9u8yT=cz7XajBA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1109271109570.9569@router.home>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com> <1316940890-24138-5-git-send-email-gilad@benyossef.com> <1317001924.29510.160.camel@sli10-conroe> <CAOtvUMddUAATZcU_5jLgY10ocsHNnOO2GC2c4ecYO9KGt-U7VQ@mail.gmail.com>
 <alpine.DEB.2.00.1109261023400.24164@router.home> <CAOtvUMcvwWFxxxv7tsOj6FO-wrHAU8EYc+U=9u8yT=cz7XajBA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Shaohua Li <shaohua.li@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Tue, 27 Sep 2011, Gilad Ben-Yossef wrote:

> My hope is to come up with a way to do more code on the CPU doing the
> flush_all (which
> as you said is a rare and none performance critical code path anyway)
> and by that gain the ability
> to do the job without interrupting CPUs that do not need to flush
> their per cpu pages.

You may not need that for the kmem_cache_destroy(). At close time there
are no users left and no one should be accessing the cache anyways. You
could flush the whole shebang without IPIs.

Problem is that there is no guarantee that other processes will not still
try to access the cache. If you want to guarantee that then change some
settings in either struct kmem_cache or struct kmem_cache_cpu that makes
allocation and freeing impossible before flushing the per cpu pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
