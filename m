Date: Mon, 30 Jul 2007 11:29:33 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC] Allow selected nodes to be excluded from MPOL_INTERLEAVE
 masks
In-Reply-To: <1185812028.5492.79.camel@localhost>
Message-ID: <Pine.LNX.4.64.0707301128400.1013@schroedinger.engr.sgi.com>
References: <1185566878.5069.123.camel@localhost>
 <20070728151912.c541aec0.kamezawa.hiroyu@jp.fujitsu.com>
 <1185812028.5492.79.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Paul Mundt <lethal@linux-sh.org>, Nishanth Aravamudan <nacc@us.ibm.com>, ak@suse.de, akpm@linux-foundation.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jul 2007, Lee Schermerhorn wrote:

> +	return 0;
> +}
> +early_param("no_interleave_nodes", setup_no_interleave_nodes);
> +
>  /* The value user specified ....changed by config */
>  static int user_zonelist_order = ZONELIST_ORDER_DEFAULT;
>  /* string for sysctl */
> @@ -2410,8 +2435,15 @@ static int __build_all_zonelists(void *d
>  		build_zonelists(pgdat);
>  		build_zonelist_cache(pgdat);
>  
> -		if (pgdat->node_present_pages)
> +		if (pgdat->node_present_pages) {
>  			node_set_state(nid, N_MEMORY);
> +			/*
> +			 * Only nodes with memory are valid for MPOL_INTERLEAVE,
> +			 * but maybe not all of them?
> +			 */
> +			if (!node_isset(nid, no_interleave_nodes))
> +				node_set_state(nid, N_INTERLEAVE);

			else
			 printk ....

would be better since it will only list the nodes that have memory and are 
excluded from interleave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
