Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8A06B6CA9
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 22:53:56 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id bj3so11601045plb.17
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 19:53:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e188sor20366760pgc.19.2018.12.03.19.53.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 19:53:54 -0800 (PST)
Date: Mon, 3 Dec 2018 19:53:52 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node
 offline
In-Reply-To: <1543892757-4323-1-git-send-email-kernelfans@gmail.com>
Message-ID: <alpine.DEB.2.21.1812031946140.97328@chino.kir.corp.google.com>
References: <1543892757-4323-1-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Tue, 4 Dec 2018, Pingfan Liu wrote:

> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 76f8db0..8324953 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -453,6 +453,8 @@ static inline int gfp_zonelist(gfp_t flags)
>   */
>  static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
>  {
> +	if (unlikely(!node_online(nid)))
> +		nid = first_online_node;
>  	return NODE_DATA(nid)->node_zonelists + gfp_zonelist(flags);
>  }
>  

So we're passing the node id from dev_to_node() to kmalloc which 
interprets that as the preferred node and then does node_zonelist() to 
find the zonelist at allocation time.

What happens if we fix this in alloc_dr()?  Does anything else cause 
problems?

And rather than using first_online_node, would next_online_node() work?

I'm thinking about this:

diff --git a/drivers/base/devres.c b/drivers/base/devres.c
--- a/drivers/base/devres.c
+++ b/drivers/base/devres.c
@@ -100,6 +100,8 @@ static __always_inline struct devres * alloc_dr(dr_release_t release,
 					&tot_size)))
 		return NULL;
 
+	if (unlikely(!node_online(nid)))
+		nid = next_online_node(nid);
 	dr = kmalloc_node_track_caller(tot_size, gfp, nid);
 	if (unlikely(!dr))
 		return NULL;
