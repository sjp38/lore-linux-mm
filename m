Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 480C56B0253
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 09:59:09 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id b126so18437670ite.3
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 06:59:09 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0138.outbound.protection.outlook.com. [104.47.2.138])
        by mx.google.com with ESMTPS id i131si896292oif.128.2016.06.08.06.59.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 Jun 2016 06:59:08 -0700 (PDT)
Date: Wed, 8 Jun 2016 16:59:00 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [RFC PATCH] mm, memcg: use consistent gfp flags during readahead
Message-ID: <20160608135900.GB30465@esperanza>
References: <1465301556-26431-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1465301556-26431-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Jun 07, 2016 at 02:12:36PM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Vladimir has noticed that we might declare memcg oom even during
> readahead because read_pages only uses GFP_KERNEL (with mapping_gfp
> restriction) while __do_page_cache_readahead uses
> page_cache_alloc_readahead which adds __GFP_NORETRY to prevent from
> OOMs. This gfp mask discrepancy is really unfortunate and easily
> fixable. Drop page_cache_alloc_readahead() which only has one user
> and outsource the gfp_mask logic into readahead_gfp_mask and propagate
> this mask from __do_page_cache_readahead down to read_pages.
> 
> This alone would have only very limited impact as most filesystems
> are implementing ->readpages and the common implementation
> mpage_readpages does GFP_KERNEL (with mapping_gfp restriction) again.
> We can tell it to use readahead_gfp_mask instead as this function is
> called only during readahead as well. The same applies to
> read_cache_pages.
> 
> ext4 has its own ext4_mpage_readpages but the path which has pages !=
> NULL can use the same gfp mask.
> Btrfs, cifs, f2fs and orangefs are doing a very similar pattern to
> mpage_readpages so the same can be applied to them as well.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> 
> Hi,
> an alternative solution for ->readpages part would be add the gfp mask
> as a new argument. This would be a larger change and I am not even sure
> it would be so much better. An explicit usage of the readahead gfp mask
> sounds like easier to track. If there is a general agreement this is a
> proper way to go I can rework the patch to do so, of course.
> 
> Does this make sense?
...
> diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
> index dc54a4b60eba..c75b66a64982 100644
> --- a/fs/ext4/readpage.c
> +++ b/fs/ext4/readpage.c
> @@ -166,7 +166,7 @@ int ext4_mpage_readpages(struct address_space *mapping,
>  			page = list_entry(pages->prev, struct page, lru);
>  			list_del(&page->lru);
>  			if (add_to_page_cache_lru(page, mapping, page->index,
> -				  mapping_gfp_constraint(mapping, GFP_KERNEL)))
> +				  readahead_gfp_mask(mapping)))
>  				goto next_page;
>  		}
>  

ext4 (at least) might issue other allocations in ->readpages, e.g.
bio_alloc with GFP_KERNEL.

I wonder if it would be better to set GFP_NOFS context on task_struct in
read_pages() and handle it in alloc_pages. You've been planning doing
something like this anyway, haven't you?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
