Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9464A6B003D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 12:20:44 -0400 (EDT)
Date: Tue, 17 Mar 2009 13:19:00 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Message-ID: <20090317121900.GD20555@random.random>
References: <1237007189.25062.91.camel@pasglop> <200903141620.45052.nickpiggin@yahoo.com.au> <20090316223612.4B2A.A69D9226@jp.fujitsu.com> <alpine.LFD.2.00.0903161739310.3082@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0903161739310.3082@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 16, 2009 at 05:44:25PM -0700, Linus Torvalds wrote:
> -		reuse = reuse_swap_page(old_page);
> +		/*
> +		 * If we can re-use the swap page _and_ the end
> +		 * result has only one user (the mapping), then
> +		 * we reuse the whole page
> +		 */
> +		if (reuse_swap_page(old_page))
> +			reuse = page_count(old_page) == 1;
>  		unlock_page(old_page);

Think if the anon page is added to swapcache and the pte is unmapped
by the VM and set non present after GUP taken the page for a O_DIRECT
read (write to memory). If a thread writes to the page while the
O_DIRECT read is running in another thread (or aio), then do_wp_page
will make a copy of the swapcache under O_DIRECT read, and part of the
read operation will get lost.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
