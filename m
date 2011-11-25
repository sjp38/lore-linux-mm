Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A2ED06B0088
	for <linux-mm@kvack.org>; Fri, 25 Nov 2011 09:54:05 -0500 (EST)
Received: from canuck.infradead.org ([2001:4978:20e::1])
	by merlin.infradead.org with esmtps (Exim 4.76 #1 (Red Hat Linux))
	id 1RTxAA-0002xN-BJ
	for linux-mm@kvack.org; Fri, 25 Nov 2011 14:54:02 +0000
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1RTxAA-0002pM-2g
	for linux-mm@kvack.org; Fri, 25 Nov 2011 14:54:02 +0000
Subject: Re: [PATCH v7 3.2-rc2 9/30] uprobes: Background page replacement.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20111118110823.10512.74338.sendpatchset@srdronam.in.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
	 <20111118110823.10512.74338.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 25 Nov 2011 15:54:46 +0100
Message-ID: <1322232886.2535.7.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

On Fri, 2011-11-18 at 16:38 +0530, Srikar Dronamraju wrote:
> +static int read_opcode(struct mm_struct *mm, unsigned long vaddr,
> +                                               uprobe_opcode_t *opcode)
> +{
> +       struct page *page;
> +       void *vaddr_new;
> +       int ret;
> +
> +       ret = get_user_pages(NULL, mm, vaddr, 1, 0, 0, &page, NULL);
> +       if (ret <= 0)
> +               return ret;
> +
> +       lock_page(page);
> +       vaddr_new = kmap_atomic(page);
> +       vaddr &= ~PAGE_MASK;

BUG_ON(vaddr + uprobe_opcode_sz >= PAGE_SIZE);

> +       memcpy(opcode, vaddr_new + vaddr, uprobe_opcode_sz);
> +       kunmap_atomic(vaddr_new);
> +       unlock_page(page);
> +       put_page(page);         /* we did a get_user_pages in the beginning */
> +       return 0;
> +} 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
