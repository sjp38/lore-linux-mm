Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C20D16B2313
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 20:47:25 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id o23so5073669pll.0
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 17:47:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 23sor28138786pfr.25.2018.11.20.17.47.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Nov 2018 17:47:24 -0800 (PST)
Date: Tue, 20 Nov 2018 17:47:21 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC PATCH 3/3] mm, fault_around: do not take a reference to a
 locked page
In-Reply-To: <20181120134323.13007-4-mhocko@kernel.org>
Message-ID: <alpine.LSU.2.11.1811201721470.2061@eggly.anvils>
References: <20181120134323.13007-1-mhocko@kernel.org> <20181120134323.13007-4-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Hildenbrand <david@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Tue, 20 Nov 2018, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> filemap_map_pages takes a speculative reference to each page in the
> range before it tries to lock that page. While this is correct it
> also can influence page migration which will bail out when seeing
> an elevated reference count. The faultaround code would bail on
> seeing a locked page so we can pro-actively check the PageLocked
> bit before page_cache_get_speculative and prevent from pointless
> reference count churn.
> 
> Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
> Suggested-by: Jan Kara <jack@suse.cz>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Hugh Dickins <hughd@google.com>

though I think this patch is more useful to the avoid atomic ops,
and unnecessary dirtying of the cacheline, than to avoid the very
transient elevation of refcount, which will not affect page migration
very much.

> ---
>  mm/filemap.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 81adec8ee02c..c76d6a251770 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2553,6 +2553,9 @@ void filemap_map_pages(struct vm_fault *vmf,
>  			goto next;
>  
>  		head = compound_head(page);
> +
> +		if (PageLocked(head))
> +			goto next;
>  		if (!page_cache_get_speculative(head))
>  			goto next;
>  
> -- 
> 2.19.1
