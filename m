Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B7AE66B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 18:18:23 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id bf1-v6so540002plb.2
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 15:18:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u23-v6si3571571plk.487.2018.06.20.15.18.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 15:18:20 -0700 (PDT)
Date: Wed, 20 Jun 2018 15:18:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/4] mm/memory_hotplug: Make add_memory_resource use
 __try_online_node
Message-Id: <20180620151819.3f39226998bd80f7161fcea5@linux-foundation.org>
In-Reply-To: <20180601125321.30652-2-osalvador@techadventures.net>
References: <20180601125321.30652-1-osalvador@techadventures.net>
	<20180601125321.30652-2-osalvador@techadventures.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Fri,  1 Jun 2018 14:53:18 +0200 osalvador@techadventures.net wrote:

> From: Oscar Salvador <osalvador@suse.de>
> 
> add_memory_resource() contains code to allocate a new node in case
> it is necessary.
> Since try_online_node() also hast some code for this purpose,
> let us make use of that and remove duplicate code.
> 
> This introduces __try_online_node(), which is called by add_memory_resource()
> and try_online_node().
> __try_online_node() has two new parameters, start_addr of the node,
> and if the node should be onlined and registered right away.
> This is always wanted if we are calling from do_cpu_up(), but not
> when we are calling from memhotplug code.
> Nothing changes from the point of view of the users of try_online_node(),
> since try_online_node passes start_addr=0 and online_node=true to
> __try_online_node().
> 
> ...
>
> @@ -1126,17 +1136,14 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
>  	 */
>  	memblock_add_node(start, size, nid);
>  
> -	new_node = !node_online(nid);
> -	if (new_node) {
> -		pgdat = hotadd_new_pgdat(nid, start);
> -		ret = -ENOMEM;
> -		if (!pgdat)
> -			goto error;
> -	}
> +	ret = __try_online_node (nid, start, false);
> +	new_node = !!(ret > 0);

I don't think __try_online_node() will ever return a value greater than
zero.  I assume what was meant was

	new_node = !!(ret >= 0);

which may as well be

	new_node = (ret >= 0);

since both sides have bool type.

The fact that testing didn't detect this is worrisome....

> +	if (ret < 0)
> +		goto error;
> +
>  
>  	/* call arch's memory hotadd */
>  	ret = arch_add_memory(nid, start, size, NULL, true);
> -
>  	if (ret < 0)
>  		goto error;
>  
> 
> ...
>
