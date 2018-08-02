Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id AC3BC6B0008
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 10:23:35 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id k21-v6so1675083qtj.23
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 07:23:35 -0700 (PDT)
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTPS id h8-v6si1712212qtn.23.2018.08.02.07.23.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Aug 2018 07:23:34 -0700 (PDT)
Date: Thu, 2 Aug 2018 14:23:34 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC 1/2] slub: Avoid trying to allocate memory on offline
 nodes
In-Reply-To: <20180801200418.1325826-2-jeremy.linton@arm.com>
Message-ID: <01000164fb05bba7-1804e794-a08d-4ee0-b842-c44c89647716-000000@email.amazonses.com>
References: <20180801200418.1325826-1-jeremy.linton@arm.com> <20180801200418.1325826-2-jeremy.linton@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeremy Linton <jeremy.linton@arm.com>
Cc: linux-mm@kvack.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, Punit.Agrawal@arm.com, Lorenzo.Pieralisi@arm.com, linux-arm-kernel@lists.infradead.org, bhelgaas@google.com, linux-kernel@vger.kernel.org

On Wed, 1 Aug 2018, Jeremy Linton wrote:

> diff --git a/mm/slub.c b/mm/slub.c
> index 51258eff4178..e03719bac1e2 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2519,6 +2519,8 @@ static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
>  		if (unlikely(!node_match(page, searchnode))) {
>  			stat(s, ALLOC_NODE_MISMATCH);
>  			deactivate_slab(s, page, c->freelist, c);
> +			if (!node_online(searchnode))
> +				node = NUMA_NO_NODE;
>  			goto new_slab;
>  		}
>  	}
>

Would it not be better to implement this check in the page allocator?
There is also the issue of how to fallback to the nearest node.

NUMA_NO_NODE should fallback to the current memory allocation policy but
it seems by inserting it here you would end up just with the default node
for the processor.
