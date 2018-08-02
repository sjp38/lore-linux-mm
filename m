Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 448486B0006
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 05:15:58 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id t17-v6so592234edr.21
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 02:15:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i20-v6si2148602edb.403.2018.08.02.02.15.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 02:15:56 -0700 (PDT)
Date: Thu, 2 Aug 2018 11:15:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 1/2] slub: Avoid trying to allocate memory on offline nodes
Message-ID: <20180802091554.GE10808@dhcp22.suse.cz>
References: <20180801200418.1325826-1-jeremy.linton@arm.com>
 <20180801200418.1325826-2-jeremy.linton@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180801200418.1325826-2-jeremy.linton@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeremy Linton <jeremy.linton@arm.com>
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, vbabka@suse.cz, Punit.Agrawal@arm.com, Lorenzo.Pieralisi@arm.com, linux-arm-kernel@lists.infradead.org, bhelgaas@google.com, linux-kernel@vger.kernel.org

On Wed 01-08-18 15:04:17, Jeremy Linton wrote:
[...]
> @@ -2519,6 +2519,8 @@ static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
>  		if (unlikely(!node_match(page, searchnode))) {
>  			stat(s, ALLOC_NODE_MISMATCH);
>  			deactivate_slab(s, page, c->freelist, c);
> +			if (!node_online(searchnode))
> +				node = NUMA_NO_NODE;
>  			goto new_slab;

This is inherently racy. Numa node can get offline at any point after
you check it here. Making it race free would involve some sort of
locking and I am not really convinced this is a good idea.

>  		}
>  	}
> -- 
> 2.14.3
> 

-- 
Michal Hocko
SUSE Labs
