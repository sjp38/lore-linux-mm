Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A9C2F6B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 03:06:35 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id t3so8706622wme.9
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 00:06:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i186si4828694wmd.88.2017.06.28.00.06.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Jun 2017 00:06:33 -0700 (PDT)
Subject: Re: [PATCH] mm/memory_hotplug: just build zonelist for new added node
References: <20170626035822.50155-1-richard.weiyang@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <855068c0-8361-9789-4208-36d43e8fd80d@suse.cz>
Date: Wed, 28 Jun 2017 09:06:31 +0200
MIME-Version: 1.0
In-Reply-To: <20170626035822.50155-1-richard.weiyang@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/26/2017 05:58 AM, Wei Yang wrote:
> In commit (9adb62a5df9c0fbef7) "mm/hotplug: correctly setup fallback
> zonelists when creating new pgdat" tries to build the correct zonelist for
> a new added node, while it is not necessary to rebuild it for already exist
> nodes.
> 
> In build_zonelists(), it will iterate on nodes with memory. For a new added
> node, it will have memory until node_states_set_node() is called in

        it will not have memory

right?

> online_pages().
> 
> This patch will avoid to rebuild the zonelists for already exist nodes.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

Sounds correct, as far as the memory hotplug mess allows.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Some style nitpicks below:

> ---
>  mm/page_alloc.c | 16 +++++++++-------
>  1 file changed, 9 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 560eafe8234d..fc8181b44fd8 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5200,15 +5200,17 @@ static int __build_all_zonelists(void *data)
>  	memset(node_load, 0, sizeof(node_load));
>  #endif
>  
> -	if (self && !node_online(self->node_id)) {
> +	/* This node is hotadded and no memory preset yet.

On multiline comments, the first line should be empty after "/*"

But I see Andrew already fixed that.

> +	 * So just build zonelists is fine, no need to touch other nodes.
> +	 */
> +	if (self && !node_online(self->node_id))
>  		build_zonelists(self);
> -	}
> -
> -	for_each_online_node(nid) {
> -		pg_data_t *pgdat = NODE_DATA(nid);
> +	else
> +		for_each_online_node(nid) {
> +			pg_data_t *pgdat = NODE_DATA(nid);
>  
> -		build_zonelists(pgdat);
> -	}
> +			build_zonelists(pgdat);
> +		}

Personally I would use { } for the else block, and thus leave them also
for the if block, not sure if this is recommended by the style guide though.

>  	/*
>  	 * Initialize the boot_pagesets that are going to be used
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
