Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 9066C6B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 00:13:57 -0400 (EDT)
Date: Wed, 8 Jun 2011 00:12:17 -0400
From: Stephen Wilson <wilsons@start.ca>
Subject: Re: [PATCH v4 3.0-rc2-tip 3/22]  3: uprobes: Adding and remove a
 uprobe in a rb tree.
Message-ID: <20110608041217.GA4879@wicker.gateway.2wire.net>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <20110607125850.28590.10861.sendpatchset@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110607125850.28590.10861.sendpatchset@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Josh Stone <jistone@redhat.com>


Hi Srikar,

On Tue, Jun 07, 2011 at 06:28:50PM +0530, Srikar Dronamraju wrote:
> +/* Called with uprobes_treelock held */
> +static struct uprobe *__find_uprobe(struct inode * inode,
> +			 loff_t offset, struct rb_node **close_match)
> +{
> +	struct uprobe r = { .inode = inode, .offset = offset };
> +	struct rb_node *n = uprobes_tree.rb_node;
> +	struct uprobe *uprobe;
> +	int match, match_inode;
> +
> +	while (n) {
> +		uprobe = rb_entry(n, struct uprobe, rb_node);
> +		match = match_uprobe(uprobe, &r, &match_inode);
> +		if (close_match && match_inode)
> +			*close_match = n;
> +
> +		if (!match) {
> +			atomic_inc(&uprobe->ref);
> +			return uprobe;
> +		}
> +		if (match < 0)
> +			n = n->rb_left;
> +		else
> +			n = n->rb_right;
> +
> +	}
> +	return NULL;
> +}
> +

I think there is a simple mistake in the search logic here.  In particular, I
think the arguments to match_uprobe() should be swapped to give:

	match = match_uprobe(&r, uprobe, NULL)

Otherwise, when we do not have an exact match, the next node to be considered
is the left child of 'uprobe' even though 'uprobe' is "smaller" than r (and
vice versa for the "larger" case).

> +static struct uprobe *__insert_uprobe(struct uprobe *uprobe)
> +{
> +	struct rb_node **p = &uprobes_tree.rb_node;
> +	struct rb_node *parent = NULL;
> +	struct uprobe *u;
> +	int match;
> +
> +	while (*p) {
> +		parent = *p;
> +		u = rb_entry(parent, struct uprobe, rb_node);
> +		match = match_uprobe(u, uprobe, NULL);
> +		if (!match) {
> +			atomic_inc(&u->ref);
> +			return u;
> +		}
> +
> +		if (match < 0)
> +			p = &parent->rb_left;
> +		else
> +			p = &parent->rb_right;
> +
> +	}

I think the match_uprobe() arguments should be swapped here as well for
similar reasons as above.

Also, changing the argument order seems to solve the issue reported by
Josh Stone where only the uprobe with the lowest address was responding
(thou I did not test with perf, just lightly with the trace_event
interface).  In particular, iteration using rb_next() appears to work as
expected, thus allowing all breakpoints to be registered in
mmap_uprobe().

> +	u = NULL;
> +	rb_link_node(&uprobe->rb_node, parent, p);
> +	rb_insert_color(&uprobe->rb_node, &uprobes_tree);
> +	/* get access + drop ref */
> +	atomic_set(&uprobe->ref, 2);
> +	return u;
> +}

-- 
steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
