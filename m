Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7FD566B0069
	for <linux-mm@kvack.org>; Sun, 30 Nov 2014 19:15:09 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id p10so9663294pdj.25
        for <linux-mm@kvack.org>; Sun, 30 Nov 2014 16:15:09 -0800 (PST)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id ap8si26434387pad.85.2014.11.30.16.15.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 30 Nov 2014 16:15:08 -0800 (PST)
Received: from kw-mxq.gw.nic.fujitsu.com (unknown [10.0.237.131])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id BE2143EE194
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 09:15:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id C72EDAC04C1
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 09:15:04 +0900 (JST)
Received: from g01jpfmpwkw01.exch.g01.fujitsu.local (g01jpfmpwkw01.exch.g01.fujitsu.local [10.0.193.38])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E1881DB804C
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 09:15:04 +0900 (JST)
Message-ID: <547BB2F0.5040708@jp.fujitsu.com>
Date: Mon, 1 Dec 2014 09:14:40 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slab: Fix nodeid bounds check for non-contiguous node
 IDs
References: <20141130221606.GA25929@iris.ozlabs.ibm.com>
In-Reply-To: <20141130221606.GA25929@iris.ozlabs.ibm.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

(2014/12/01 7:16), Paul Mackerras wrote:
> The bounds check for nodeid in ____cache_alloc_node gives false
> positives on machines where the node IDs are not contiguous, leading
> to a panic at boot time.  For example, on a POWER8 machine the node
> IDs are typically 0, 1, 16 and 17.  This means that num_online_nodes()
> returns 4, so when ____cache_alloc_node is called with nodeid = 16 the
> VM_BUG_ON triggers.

Do you have the call trace? If you have it, please add it in the description.

> To fix this, we instead compare the nodeid with MAX_NUMNODES, and
> additionally make sure it isn't negative (since nodeid is an int).
> The check is there mainly to protect the array dereference in the
> get_node() call in the next line, and the array being dereferenced is
> of size MAX_NUMNODES.  If the nodeid is in range but invalid, the
> BUG_ON in the next line will catch that.
>
> Signed-off-by: Paul Mackerras <paulus@samba.org>

Do you need to backport it into -stable kernels?

> ---
> diff --git a/mm/slab.c b/mm/slab.c
> index eb2b2ea..f34e053 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3076,7 +3076,7 @@ static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
>   	void *obj;
>   	int x;
>

> -	VM_BUG_ON(nodeid > num_online_nodes());
> +	VM_BUG_ON(nodeid < 0 || nodeid >= MAX_NUMNODES);

How about use:
	VM_BUG_ON(!node_online(nodeid));

When allocating the memory, the node of the memory being allocated must be
online. But your code cannot check the condition.

Thanks,
Yasuaki Ishimatsu

>   	n = get_node(cachep, nodeid);
>   	BUG_ON(!n);
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
