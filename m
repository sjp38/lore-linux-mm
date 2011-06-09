Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3343590011C
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 19:00:04 -0400 (EDT)
Received: from canuck.infradead.org ([2001:4978:20e::1])
	by merlin.infradead.org with esmtps (Exim 4.76 #1 (Red Hat Linux))
	id 1QUoCm-0004lq-UX
	for linux-mm@kvack.org; Thu, 09 Jun 2011 23:00:01 +0000
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1QUoCm-0007CR-Ac
	for linux-mm@kvack.org; Thu, 09 Jun 2011 23:00:00 +0000
Subject: Re: [PATCH v4 3.0-rc2-tip 2/22]  2: uprobes: Breakground page
 replacement.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110607125835.28590.25476.sendpatchset@localhost6.localdomain6>
References: 
	 <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
	 <20110607125835.28590.25476.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 10 Jun 2011 01:03:29 +0200
Message-ID: <1307660609.2497.1773.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, 2011-06-07 at 18:28 +0530, Srikar Dronamraju wrote:
> +       vaddr_old = kmap_atomic(old_page, KM_USER0);
> +       vaddr_new = kmap_atomic(new_page, KM_USER1);
> +
> +       memcpy(vaddr_new, vaddr_old, PAGE_SIZE);
> +       /* poke the new insn in, ASSUMES we don't cross page boundary */
> +       addr = vaddr;
> +       vaddr &= ~PAGE_MASK;
> +       memcpy(vaddr_new + vaddr, &opcode, uprobe_opcode_sz);
> +
> +       kunmap_atomic(vaddr_new);
> +       kunmap_atomic(vaddr_old); 


> +       vaddr_new = kmap_atomic(page, KM_USER0);
> +       vaddr &= ~PAGE_MASK;
> +       memcpy(opcode, vaddr_new + vaddr, uprobe_opcode_sz);
> +       kunmap_atomic(vaddr_new);
> 

Both sequences in resp {write,read}_opcode() assume the opcode doesn't
cross page boundaries but don't in fact have any assertions validating
this assumption.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
