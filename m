Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 207646B000C
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 15:04:11 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x20so2228266wmc.0
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 12:04:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y81si4385282wmd.82.2018.04.05.12.04.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Apr 2018 12:04:09 -0700 (PDT)
Date: Thu, 5 Apr 2018 21:04:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm: consider non-anonymous thp as unmovable page
Message-ID: <20180405190405.GS6312@dhcp22.suse.cz>
References: <20180403083451.GG5501@dhcp22.suse.cz>
 <20180403105411.hknofkbn6rzs26oz@node.shutemov.name>
 <20180405085927.GC6312@dhcp22.suse.cz>
 <20180405122838.6a6b35psizem4tcy@node.shutemov.name>
 <20180405124830.GJ6312@dhcp22.suse.cz>
 <20180405134045.7axuun6d7ufobzj4@node.shutemov.name>
 <20180405150547.GN6312@dhcp22.suse.cz>
 <20180405155551.wchleyaf4rxooj6m@node.shutemov.name>
 <20180405160317.GP6312@dhcp22.suse.cz>
 <7C2DE363-E113-4284-B94F-814F386743DF@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7C2DE363-E113-4284-B94F-814F386743DF@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org

On Thu 05-04-18 13:58:43, Zi Yan wrote:
> On 5 Apr 2018, at 12:03, Michal Hocko wrote:
> 
> > On Thu 05-04-18 18:55:51, Kirill A. Shutemov wrote:
> >> On Thu, Apr 05, 2018 at 05:05:47PM +0200, Michal Hocko wrote:
> >>> On Thu 05-04-18 16:40:45, Kirill A. Shutemov wrote:
> >>>> On Thu, Apr 05, 2018 at 02:48:30PM +0200, Michal Hocko wrote:
> >>> [...]
> >>>>> RIght, I confused the two. What is the proper layer to fix that then?
> >>>>> rmap_walk_file?
> >>>>
> >>>> Maybe something like this? Totally untested.
> >>>
> >>> This looks way too complex. Why cannot we simply split THP page cache
> >>> during migration?
> >>
> >> This way we unify the codepath for archictures that don't support THP
> >> migration and shmem THP.
> >
> > But why? There shouldn't be really nothing to prevent THP (anon or
> > shemem) to be migratable. If we cannot migrate it at once we can always
> > split it. So why should we add another thp specific handling all over
> > the place?
> 
> Then, it would be much easier if your "unclutter thp migration" patches is merged,
> plus the patch below:

Good point. Except I would prefer a less convoluted condition

> diff --git a/mm/migrate.c b/mm/migrate.c
> index 60531108021a..b4087aa890f5 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1138,7 +1138,9 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
>         int rc = MIGRATEPAGE_SUCCESS;
>         struct page *newpage;
> 
> -       if (!thp_migration_supported() && PageTransHuge(page))
> +       if ((!thp_migration_supported() ||
> +            (thp_migration_supported() && !PageAnon(page))) &&
> +           PageTransHuge(page))
>                 return -ENOMEM;

What about this?
diff --git a/mm/migrate.c b/mm/migrate.c
index 5d0dc7b85f90..cd02e2bdf37c 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1138,7 +1138,11 @@ static ICE_noinline int unmap_and_move(new_page_t get_new_page,
 	int rc = MIGRATEPAGE_SUCCESS;
 	struct page *newpage;
 
-	if (!thp_migration_supported() && PageTransHuge(page))
+	/*
+	 * THP pagecache or generally non-migrateable THP need to be split
+	 * up before migration
+	 */
+	if (PageTransHuge(page) && (!thp_migration_supported() || !PageAnon(page)))
 		return -ENOMEM;
 
 	newpage = get_new_page(page, private);


-- 
Michal Hocko
SUSE Labs
