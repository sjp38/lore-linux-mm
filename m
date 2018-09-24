Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 48FE38E0001
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 10:30:30 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g18-v6so9476647edg.14
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 07:30:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a27-v6si8306384edb.300.2018.09.24.07.30.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 07:30:29 -0700 (PDT)
Date: Mon, 24 Sep 2018 16:30:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/migrate: Split only transparent huge pages when
 allocation fails
Message-ID: <20180924143027.GE18685@dhcp22.suse.cz>
References: <1537798495-4996-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1537798495-4996-1-git-send-email-anshuman.khandual@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

On Mon 24-09-18 19:44:55, Anshuman Khandual wrote:
> When unmap_and_move[_huge_page] function fails due to lack of memory, the
> splitting should happen only for transparent huge pages not for HugeTLB
> pages. PageTransHuge() returns true for both THP and HugeTLB pages. Hence
> the conditonal check should test PagesHuge() flag to make sure that given
> pages is not a HugeTLB one.

Well spotted! Have you actually seen this happening or this is review
driven? I am wondering what would be the real effect of this mismatch?
I have tried to follow to code path but I suspect
split_huge_page_to_list would fail for hugetlbfs pages. If there is a
more serious effect then we should mark the patch for stable as well.

> 
> Fixes: 94723aafb9 ("mm: unclutter THP migration")
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/migrate.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index d6a2e89..d2297fe 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1411,7 +1411,7 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
>  				 * we encounter them after the rest of the list
>  				 * is processed.
>  				 */
> -				if (PageTransHuge(page)) {
> +				if (PageTransHuge(page) && !PageHuge(page)) {
>  					lock_page(page);
>  					rc = split_huge_page_to_list(page, from);
>  					unlock_page(page);
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs
