Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id B24BB6B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 13:56:06 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Fri, 23 Aug 2013 11:56:06 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id CFB633E40042
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 11:55:37 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7NHu1bA158256
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 11:56:02 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7NHtxHu017253
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 11:56:00 -0600
Date: Fri, 23 Aug 2013 10:28:59 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/4] zswap bugfix: memory leaks when re-swapon
Message-ID: <20130823152859.GB5439@variantweb.net>
References: <CAL1ERfPzB=CvKJ6kAq2YYTkkg-EgSOWRyfSFWkvKp8ZdQkCDxA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAL1ERfPzB=CvKJ6kAq2YYTkkg-EgSOWRyfSFWkvKp8ZdQkCDxA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang.kh@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Bob Liu <bob.liu@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, weijie.yang@samsung.com

On Fri, Aug 23, 2013 at 07:03:37PM +0800, Weijie Yang wrote:
> zswap_tree is not freed when swapoff, and it got re-kzalloc in swapon,
> memory leak occurs.
> Add check statement in zswap_frontswap_init so that zswap_tree is
> inited only once.
> 
> ---
>  mm/zswap.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/zswap.c b/mm/zswap.c
> index deda2b6..1cf1c07 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -826,6 +826,11 @@ static void zswap_frontswap_init(unsigned type)
>  {
>  	struct zswap_tree *tree;
> 
> +	if (zswap_trees[type]) {
> +		BUG_ON(zswap_trees[type]->rbroot != RB_ROOT);  /* invalidate_area set it */

Lets leave this BUG_ON() out.  If we want to make sure that the rbtree has
been properly emptied out, we should do it in
zswap_frontswap_invalidate_area() after the while loop and make it a
WARN_ON() since the problem is not fatal.

Seth

> +		return;
> +	}
> +
>  	tree = kzalloc(sizeof(struct zswap_tree), GFP_KERNEL);
>  	if (!tree)
>  		goto err;
> -- 
> 1.7.0.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
