Date: Mon, 08 Sep 2008 12:07:14 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [RFC:Patch: 008/008](memory hotplug) remove_pgdat() function
In-Reply-To: <1220710895.8687.12.camel@twins.programming.kicks-ass.net>
References: <20080731210326.2A51.E1E9C6FF@jp.fujitsu.com> <1220710895.8687.12.camel@twins.programming.kicks-ass.net>
Message-Id: <20080908120324.B3DA.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> On Thu, 2008-07-31 at 21:04 +0900, Yasunori Goto wrote:
> 
> > +int remove_pgdat(int nid)
> > +{
> > +	struct pglist_data *pgdat = NODE_DATA(nid);
> > +
> > +	if (cpus_busy_on_node(nid))
> > +		return -EBUSY;
> > +
> > +	if (sections_busy_on_node(pgdat))
> > +		return -EBUSY;
> > +
> > +	node_set_offline(nid);
> > +	synchronize_sched();
> > +	synchronize_srcu(&pgdat_remove_srcu);
> > +
> > +	free_pgdat(nid, pgdat);
> > +
> > +	return 0;
> > +}
> 
> FWIW synchronize_sched() is the wrong function to use here,
> synchronize_rcu() is the right one.

Thanks. I'll fix it.


-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
