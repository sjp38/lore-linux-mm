Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 035D46B0279
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 16:23:56 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u110so10392554wrb.14
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 13:23:55 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g11si295455wmg.151.2017.07.07.13.23.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jul 2017 13:23:54 -0700 (PDT)
Date: Fri, 7 Jul 2017 13:23:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] slub: make sure struct kmem_cache_node is initialized
 before publication
Message-Id: <20170707132351.4f10cd778fc5eb58e9cc5513@linux-foundation.org>
In-Reply-To: <20170707083408.40410-1-glider@google.com>
References: <20170707083408.40410-1-glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: dvyukov@google.com, kcc@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri,  7 Jul 2017 10:34:08 +0200 Alexander Potapenko <glider@google.com> wrote:

> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3389,8 +3389,8 @@ static int init_kmem_cache_nodes(struct kmem_cache *s)
>  			return 0;
>  		}
>  
> -		s->node[node] = n;
>  		init_kmem_cache_node(n);
> +		s->node[node] = n;
>  	}
>  	return 1;
>  }

If this matters then I have bad feelings about free_kmem_cache_nodes():

static void free_kmem_cache_nodes(struct kmem_cache *s)
{
	int node;
	struct kmem_cache_node *n;

	for_each_kmem_cache_node(s, node, n) {
		kmem_cache_free(kmem_cache_node, n);
		s->node[node] = NULL;
	}
}

Inviting a use-after-free?  I guess not, as there should be no way
to look up these items at this stage.

Could the slab maintainers please take a look at these and also have a
think about Alexander's READ_ONCE/WRITE_ONCE question?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
