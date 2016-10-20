Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id ECACA6B0069
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 18:33:37 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 128so36915085pfz.1
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 15:33:37 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id rf4si39100191pab.9.2016.10.20.15.33.36
        for <linux-mm@kvack.org>;
        Thu, 20 Oct 2016 15:33:37 -0700 (PDT)
Date: Fri, 21 Oct 2016 09:33:08 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/5] lib: radix-tree: native accounting and tracking of
 special entries
Message-ID: <20161020223308.GN23194@dastard>
References: <20161019172428.7649-1-hannes@cmpxchg.org>
 <20161019172428.7649-4-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161019172428.7649-4-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Jones <davej@codemonkey.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Oct 19, 2016 at 01:24:26PM -0400, Johannes Weiner wrote:
> Add an internal tag to identify special entries that are accounted in
> node->special in addition to node->count.
> 
> With this in place, the next patch can restore refault detection in
> single-page files. It will also move the shadow count from the upper
> bits of count to the new special counter, and then shrink count to a
> char as well; the growth of struct radix_tree_node is temporary.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/radix-tree.h | 10 ++++++----
>  lib/radix-tree.c           | 14 ++++++++++----
>  2 files changed, 16 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index 756b2909467e..2e1c9added23 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -68,7 +68,8 @@ enum radix_tree_tags {
>  	/* Freely allocatable radix tree user tags */
>  	RADIX_TREE_NR_USER_TAGS = 3,
>  	/* Radix tree internal tags */
> -	RADIX_TREE_NR_TAGS = RADIX_TREE_NR_USER_TAGS,
> +	RADIX_TREE_TAG_SPECIAL = RADIX_TREE_NR_USER_TAGS,
> +	RADIX_TREE_NR_TAGS,
>  };
>  
>  #ifndef RADIX_TREE_MAP_SHIFT
> @@ -90,9 +91,10 @@ enum radix_tree_tags {
>  #define RADIX_TREE_COUNT_MASK	((1UL << RADIX_TREE_COUNT_SHIFT) - 1)
>  
>  struct radix_tree_node {
> -	unsigned char	shift;	/* Bits remaining in each slot */
> -	unsigned char	offset;	/* Slot offset in parent */
> -	unsigned int	count;
> +	unsigned char	shift;		/* Bits remaining in each slot */
> +	unsigned char	offset;		/* Slot offset in parent */
> +	unsigned int	count;		/* Total entry count */
> +	unsigned char	special;	/* Special entry count */

How about putting the new char field into the implicit hole between
offset and count? pahole is your friend here:

struct radix_tree_node {
        unsigned char              shift;                /*     0     1 */
        unsigned char              offset;               /*     1     1 */

        /* XXX 2 bytes hole, try to pack */

        unsigned int               count;                /*     4     4 */
.....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
