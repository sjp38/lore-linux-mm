Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id E4F756B0038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 11:48:41 -0400 (EDT)
Received: by igr7 with SMTP id 7so19922421igr.0
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 08:48:41 -0700 (PDT)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id e16si2577567igo.1.2015.07.24.08.48.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 24 Jul 2015 08:48:41 -0700 (PDT)
Date: Fri, 24 Jul 2015 10:48:39 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC v2 4/4] mm: fallback for offline nodes in
 alloc_pages_node
In-Reply-To: <1437749126-25867-4-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.11.1507241047110.6461@east.gentwo.org>
References: <1437749126-25867-1-git-send-email-vbabka@suse.cz> <1437749126-25867-4-git-send-email-vbabka@suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Fri, 24 Jul 2015, Vlastimil Babka wrote:

> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 531c72d..104a027 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -321,8 +321,12 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
>  						unsigned int order)
>  {
>  	/* Unknown node is current (or closest) node */
> -	if (nid == NUMA_NO_NODE)
> +	if (nid == NUMA_NO_NODE) {
>  		nid = numa_mem_id();
> +	} else if (!node_online(nid)) {
> +		VM_WARN_ON(!node_online(nid));
> +		nid = numa_mem_id();
> +	}

I would think you would only want this for debugging purposes. The
overwhelming majority of hardware out there has no memory
onlining/offlining capability after all and this adds the overhead to each
call to alloc_pages_node.

Make this dependo n CONFIG_VM_DEBUG or some such thing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
