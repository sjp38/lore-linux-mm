Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 563906B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 20:54:21 -0400 (EDT)
Received: by iggp10 with SMTP id p10so3483806igg.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 17:54:21 -0700 (PDT)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com. [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id d63si4027852ioe.56.2015.07.08.17.54.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 17:54:20 -0700 (PDT)
Received: by igrv9 with SMTP id v9so212797254igr.1
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 17:54:20 -0700 (PDT)
Date: Wed, 8 Jul 2015 17:54:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/memblock: WARN_ON when nid differs from overlap
 region
In-Reply-To: <1436342488-19851-1-git-send-email-weiyang@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1507081750240.16585@chino.kir.corp.google.com>
References: <1436342488-19851-1-git-send-email-weiyang@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, tj@kernel.org, linux-mm@kvack.org

On Wed, 8 Jul 2015, Wei Yang wrote:

> Each memblock_region has nid to indicates the Node ID of this range. For
> the overlap case, memblock_add_range() inserts the lower part and leave the
> upper part as indicated in the overlapped region.
> 
> If the nid of the new range differs from the overlapped region, the
> information recorded is not correct.
> 
> This patch adds a WARN_ON when the nid of the new range differs from the
> overlapped region.
> 
> ---
> 
> I am not familiar with the lower level topology, maybe this case will not
> happen. 
> 
> If current implementation is based on the assumption, that overlapped
> ranges' nid and flags are the same, I would suggest to add a comment to
> indicates this background.
> 
> If the assumption is not correct, I suggest to add a WARN_ON or BUG_ON to
> indicates this case.
> 
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> ---
>  mm/memblock.c |    3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 9318b56..09efe70 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -540,6 +540,9 @@ repeat:
>  		 * area, insert that portion.
>  		 */
>  		if (rbase > base) {
> +#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
> +			WARN_ON(nid != memblock_get_region_node(rgn));
> +#endif
>  			nr_new++;
>  			if (insert)
>  				memblock_insert_region(type, i++, base,

I think the assertion that nid should match memblock_get_region_node() of 
the overlapped region is correct.  It only functionally makes a difference 
if insert == true, but I don't think there's harm in verifying it 
regardless.

Acked-by: David Rientjes <rientjes@google.com>

I think your supplemental to the changelog suggests that you haven't seen 
this actually occur, but in the off chance that you have then it would be 
interesting to see it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
