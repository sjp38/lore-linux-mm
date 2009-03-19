Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9CBEE6B003D
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 18:25:53 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 466FD82C629
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 18:32:54 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id w9RCrtnaf+Cg for <linux-mm@kvack.org>;
	Thu, 19 Mar 2009 18:32:48 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id DAA7882C63E
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 18:32:44 -0400 (EDT)
Date: Thu, 19 Mar 2009 18:22:38 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 20/35] Use a pre-calculated value for
 num_online_nodes()
In-Reply-To: <20090319212912.GB24586@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0903191817250.31984@qirst.com>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <1237196790-7268-21-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0903161207500.32577@qirst.com> <20090316163626.GJ24293@csn.ul.ie> <alpine.DEB.1.10.0903161247170.17730@qirst.com>
 <20090318150833.GC4629@csn.ul.ie> <alpine.DEB.1.10.0903181256440.15570@qirst.com> <20090318180152.GB24462@csn.ul.ie> <alpine.DEB.1.10.0903181508030.10154@qirst.com> <alpine.DEB.1.10.0903191642160.22425@qirst.com> <20090319212912.GB24586@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Mar 2009, Mel Gorman wrote:

> This patch actually alters the API. node_set_online() called when
> MAX_NUMNODES == 1 will now fail to compile. That situation wouldn't make
> any sense anyway but is it intentional?

Yes MAX_NUMNODES means that this is not a NUMA configuration. Setting an
ode online would make no sense. Node 0 is always online.

> For reference here is the patch I had for a similar goal which kept the
> API as it was. I'll drop it if you prefer your own version.

Lets look through it and get the best pieces from both.

>  static inline void node_set_state(int node, enum node_states state)
>  {
>  	__node_set(node, &node_states[state]);
> +	if (state == N_ONLINE)
> +		nr_online_nodes = num_node_state(N_ONLINE);
>  }

That assumes uses of node_set_state N_ONLINE. Are there such users or are
all using node_set_online()?

> @@ -449,7 +457,8 @@ static inline int num_node_state(enum node_states state)
>  	node;					\
>  })
>
> -#define num_online_nodes()	num_node_state(N_ONLINE)
> +
> +#define num_online_nodes()	(nr_online_nodes)
>  #define num_possible_nodes()	num_node_state(N_POSSIBLE)
>  #define node_online(node)	node_state((node), N_ONLINE)
>  #define node_possible(node)	node_state((node), N_POSSIBLE)

Hmmmm... Yes we could get rid of those.

I'd also like to see nr_possible_nodes(). nr_possible_nodes is important
if you want to check if the system could ever bring up a second node
(which would make the current optimization not viable) whereas
nr_online_nodes is the check for how many nodes are currently online.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
