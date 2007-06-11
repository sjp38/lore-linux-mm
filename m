Date: Mon, 11 Jun 2007 14:25:38 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Add populated_map to account for memoryless nodes
In-Reply-To: <20070611202728.GD9920@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com>
References: <20070611202728.GD9920@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:

> @@ -2161,7 +2164,7 @@ static int node_order[MAX_NUMNODES];
>  static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
>  {
>  	enum zone_type i;
> -	int pos, j, node;
> +	int pos, j;
>  	int zone_type;		/* needs to be signed */
>  	struct zone *z;
>  	struct zonelist *zonelist;
> @@ -2171,7 +2174,7 @@ static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
>  		pos = 0;
>  		for (zone_type = i; zone_type >= 0; zone_type--) {
>  			for (j = 0; j < nr_nodes; j++) {
> -				node = node_order[j];
> +				int node = node_order[j];
>  				z = &NODE_DATA(node)->node_zones[zone_type];
>  				if (populated_zone(z)) {
>  					zonelist->zones[pos++] = z;

Unrelated modifications.

> @@ -2244,6 +2247,22 @@ static void set_zonelist_order(void)
>  		current_zonelist_order = user_zonelist_order;
>  }
>  
> +/*
> + * setup_populate_map() - record nodes whose "policy_zone" is "on-node".
> + */
> +static void setup_populated_map(int nid)
> +{
> +	pg_data_t *pgdat = NODE_DATA(nid);
> +	struct zonelist *zl = pgdat->node_zonelists + policy_zone;
> +	struct zone *z = zl->zones[0];
> +
> +	VM_BUG_ON(!z);
> +	if (z->zone_pgdat == pgdat)
> +		node_set_populated(nid);
> +	else
> +		node_not_populated(nid);
> +}


A node is only populated if it has memory in the policy zone? I would say 
a node is populated if it has any memory in any zone.

The above check may fail on x86_64 where only some nodes may have 
ZONE_NORMAL. Others only have ZONE_DMA32. Policy zone will be set to 
ZONE_NORMAL.


> +
>  static void build_zonelists(pg_data_t *pgdat)
>  {
>  	int j, node, load;
> @@ -2327,6 +2346,15 @@ static void set_zonelist_order(void)
>  	current_zonelist_order = ZONELIST_ORDER_ZONE;
>  }
>  
> +/*
> + * setup_populated_map - non-NUMA case
> + * Only node 0 should be on-line, and it MUST be populated!
> + */
> +static void setup_populated_map(int nid)
> +{
> +	node_set_populated(nid);
> +}

I'd say provide fallback functions so that node_populated() always returns 
true for !NUMA. That way it can be optimized out at compile time.

>  static void build_zonelists(pg_data_t *pgdat)
>  {
>  	int node, local_node;
> @@ -2381,6 +2409,7 @@ static int __build_all_zonelists(void *dummy)
>  	for_each_online_node(nid) {
>  		build_zonelists(NODE_DATA(nid));
>  		build_zonelist_cache(NODE_DATA(nid));
> +		setup_populated_map(nid);
>  	}

Is it possible to move the set_populated_node into build_zonelists 
somehow?

F.e. In build_zonelists_node you can check if nr_zones > 0 and then set it 
up?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
