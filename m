Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id B12836B0008
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 18:44:09 -0500 (EST)
Date: Mon, 28 Jan 2013 15:44:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/11] ksm: remove old stable nodes more thoroughly
Message-Id: <20130128154407.16a623a4.akpm@linux-foundation.org>
In-Reply-To: <alpine.LNX.2.00.1301251800550.29196@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
	<alpine.LNX.2.00.1301251800550.29196@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 25 Jan 2013 18:01:59 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> +static int remove_all_stable_nodes(void)
> +{
> +	struct stable_node *stable_node;
> +	int nid;
> +	int err = 0;
> +
> +	for (nid = 0; nid < nr_node_ids; nid++) {
> +		while (root_stable_tree[nid].rb_node) {
> +			stable_node = rb_entry(root_stable_tree[nid].rb_node,
> +						struct stable_node, node);
> +			if (remove_stable_node(stable_node)) {
> +				err = -EBUSY;

It's a bit rude to overwrite remove_stable_node()'s return value.

> +				break;	/* proceed to next nid */
> +			}
> +			cond_resched();

Why is this here?

> +		}
> +	}
> +	return err;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
