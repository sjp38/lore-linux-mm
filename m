Subject: Re: [RFC:Patch: 008/008](memory hotplug) remove_pgdat() function
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20080731210326.2A51.E1E9C6FF@jp.fujitsu.com>
References: <20080731203549.2A3F.E1E9C6FF@jp.fujitsu.com>
	 <20080731210326.2A51.E1E9C6FF@jp.fujitsu.com>
Content-Type: text/plain
Date: Sat, 06 Sep 2008 16:21:35 +0200
Message-Id: <1220710895.8687.12.camel@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-07-31 at 21:04 +0900, Yasunori Goto wrote:

> +int remove_pgdat(int nid)
> +{
> +	struct pglist_data *pgdat = NODE_DATA(nid);
> +
> +	if (cpus_busy_on_node(nid))
> +		return -EBUSY;
> +
> +	if (sections_busy_on_node(pgdat))
> +		return -EBUSY;
> +
> +	node_set_offline(nid);
> +	synchronize_sched();
> +	synchronize_srcu(&pgdat_remove_srcu);
> +
> +	free_pgdat(nid, pgdat);
> +
> +	return 0;
> +}

FWIW synchronize_sched() is the wrong function to use here,
synchronize_rcu() is the right one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
