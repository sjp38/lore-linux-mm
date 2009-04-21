Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 60BA26B003D
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 06:39:40 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3LAeFCf011047
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 21 Apr 2009 19:40:15 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 847AA45DE51
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 19:40:15 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 639E645DE4F
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 19:40:15 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 50C271DB8040
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 19:40:15 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 035CC1DB803C
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 19:40:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 10/25] Calculate the alloc_flags for allocation only once
In-Reply-To: <20090421103709.GR12713@csn.ul.ie>
References: <20090421190921.F15F.A69D9226@jp.fujitsu.com> <20090421103709.GR12713@csn.ul.ie>
Message-Id: <20090421193942.F171.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 21 Apr 2009 19:40:14 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> The changelog now reads
> =====
> 
> Factor out the mapping between GFP and alloc_flags only once. Once factored
> out, it only needs to be calculated once but some care must be taken.
> 
> [neilb@suse.de says]
> As the test:
> 
> -       if (((p->flags & PF_MEMALLOC) ||
>         unlikely(test_thread_flag(TIF_MEMDIE)))
> -                       && !in_interrupt()) {
> -               if (!(gfp_mask & __GFP_NOMEMALLOC)) {
> 
> has been replaced with a slightly weaker one:
> 
> +       if (alloc_flags & ALLOC_NO_WATERMARKS) {
> 
> Without care, this would allow recursion into the allocator via direct
> reclaim. This patch ensures we do not recurse when PF_MEMALLOC is set
> but TF_MEMDIE callers are now allowed to directly reclaim where they
> would have been prevented in the past.

Excellent. :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
