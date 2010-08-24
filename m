Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DFBFE6008D8
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 03:29:31 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7O7TTlq030307
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 24 Aug 2010 16:29:29 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2419445DE51
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 16:29:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0212145DE4E
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 16:29:29 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D47181DB803C
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 16:29:28 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 94E891DB8038
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 16:29:28 +0900 (JST)
Date: Tue, 24 Aug 2010 16:24:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/6] mm: stack based kmap_atomic
Message-Id: <20100824162427.58e2eb88.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100819202753.656285068@chello.nl>
References: <20100819201317.673172547@chello.nl>
	<20100819202753.656285068@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Russell King <rmk@arm.linux.org.uk>, David Howells <dhowells@redhat.com>, Ralf Baechle <ralf@linux-mips.org>, David Miller <davem@davemloft.net>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Aug 2010 22:13:19 +0200
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Keep the current interface but ignore the KM_type and use a stack
> based approach.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
 
> +DECLARE_PER_CPU(int, __kmap_atomic_idx);
> +
> +static inline int kmap_atomic_idx_push(void)
> +{
> +	int idx = __get_cpu_var(__kmap_atomic_idx)++;
> +#ifdef CONFIG_DEBUG_HIGHMEM
> +	BUG_ON(idx > KM_TYPE_NR);
> +#endif
> +	return idx;
> +}
> +
> +static inline int kmap_atomic_idx_pop(void)
> +{
> +	int idx = --__get_cpu_var(__kmap_atomic_idx);
> +#ifdef CONFIG_DEBUG_HIGHMEM
> +	BUG_ON(idx < 0);
> +#endif
> +	return idx;
> +}
> +
>  #else /* CONFIG_HIGHMEM */
> 

I may don't understand anything... Is irq already disabled ?
And Is it documented that kmap_atomic shouln't be used under NMI or something
special interrupts ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
