Date: Mon, 11 Jun 2007 15:42:37 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v2] Add populated_map to account for memoryless nodes
In-Reply-To: <20070611221036.GA14458@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com>
References: <20070611202728.GD9920@us.ibm.com>
 <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com>
 <20070611221036.GA14458@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:

> Already done in the original patch (node_populated() returns (node == 0)
> if MAX_NUMODES <= 1), I think.

Ah good.

> @@ -2299,6 +2303,18 @@ static void build_zonelists(pg_data_t *pgdat)
>  		/* calculate node order -- i.e., DMA last! */
>  		build_zonelists_in_zone_order(pgdat, j);
>  	}
> +
> +	/*
> +	 * record nodes whose first fallback zone is "on-node" as
> +	 * populated
> +	 */
> +	z = pgdat->node_zonelists->zones[0];
> +
> +	VM_BUG_ON(!z);
> +	if (z->zone_pgdat == pgdat)
> +		node_set_populated(local_node);
> +	else
> +		node_not_populated(local_node);
>  }
>  
>  /* Construct the zonelist performance cache - see further mmzone.h */
> 

Could be much simpler:

if (pgdat->node_present_pages)
	node_set_populated(local_node);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
