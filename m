Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A5E696B007E
	for <linux-mm@kvack.org>; Sun, 17 Apr 2016 10:10:23 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t124so282048476pfb.1
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 07:10:23 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id 27si11385412pfj.105.2016.04.17.07.10.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Apr 2016 07:10:22 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id p185so10330740pfb.3
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 07:10:22 -0700 (PDT)
Date: Mon, 18 Apr 2016 00:08:04 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v3 06/16] zsmalloc: squeeze inuse into page->mapping
Message-ID: <20160417150804.GA575@swordfish>
References: <1459321935-3655-1-git-send-email-minchan@kernel.org>
 <1459321935-3655-7-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459321935-3655-7-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>

Hello,

On (03/30/16 16:12), Minchan Kim wrote:
[..]
> +static int get_zspage_inuse(struct page *first_page)
> +{
> +	struct zs_meta *m;
> +
> +	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
> +
> +	m = (struct zs_meta *)&first_page->mapping;
..
> +static void set_zspage_inuse(struct page *first_page, int val)
> +{
> +	struct zs_meta *m;
> +
> +	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
> +
> +	m = (struct zs_meta *)&first_page->mapping;
..
> +static void mod_zspage_inuse(struct page *first_page, int val)
> +{
> +	struct zs_meta *m;
> +
> +	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
> +
> +	m = (struct zs_meta *)&first_page->mapping;
..
>  static void get_zspage_mapping(struct page *first_page,
>  				unsigned int *class_idx,
>  				enum fullness_group *fullness)
>  {
> -	unsigned long m;
> +	struct zs_meta *m;
> +
>  	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
> +	m = (struct zs_meta *)&first_page->mapping;
..
>  static void set_zspage_mapping(struct page *first_page,
>  				unsigned int class_idx,
>  				enum fullness_group fullness)
>  {
> +	struct zs_meta *m;
> +
>  	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
>  
> +	m = (struct zs_meta *)&first_page->mapping;
> +	m->fullness = fullness;
> +	m->class = class_idx;
>  }


a nitpick: this

	struct zs_meta *m;
	VM_BUG_ON_PAGE(!is_first_page(first_page), first_page);
	m = (struct zs_meta *)&first_page->mapping;


seems to be common in several places, may be it makes sense to
factor it out and turn into a macro or a static inline helper?

other than that, looks good to me

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
