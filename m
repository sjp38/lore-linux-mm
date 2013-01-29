Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 9E8C16B0007
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 21:03:13 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id hz10so60390pad.23
        for <linux-mm@kvack.org>; Mon, 28 Jan 2013 18:03:12 -0800 (PST)
Date: Mon, 28 Jan 2013 18:03:16 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 6/11] ksm: remove old stable nodes more thoroughly
In-Reply-To: <20130128154407.16a623a4.akpm@linux-foundation.org>
Message-ID: <alpine.LNX.2.00.1301281747210.4947@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils> <alpine.LNX.2.00.1301251800550.29196@eggly.anvils> <20130128154407.16a623a4.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 28 Jan 2013, Andrew Morton wrote:
> On Fri, 25 Jan 2013 18:01:59 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
> 
> > +static int remove_all_stable_nodes(void)
> > +{
> > +	struct stable_node *stable_node;
> > +	int nid;
> > +	int err = 0;
> > +
> > +	for (nid = 0; nid < nr_node_ids; nid++) {
> > +		while (root_stable_tree[nid].rb_node) {
> > +			stable_node = rb_entry(root_stable_tree[nid].rb_node,
> > +						struct stable_node, node);
> > +			if (remove_stable_node(stable_node)) {
> > +				err = -EBUSY;
> 
> It's a bit rude to overwrite remove_stable_node()'s return value.

Well.... yes, but only the tiniest bit rude :)

> 
> > +				break;	/* proceed to next nid */
> > +			}
> > +			cond_resched();
> 
> Why is this here?

Because we don't have a limit on the length of this loop, and if
every node which remove_stable_node() finds is already stale, and
has no rmap_item still attached, then there would be no rescheduling
point in the unbounded loop without this one.  I was taught to worry
about bad latencies even in unpreemptible kernels.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
