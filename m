Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 395046B000D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 08:04:36 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id h24-v6so6520412ede.9
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 05:04:36 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cu1-v6si1688469ejb.5.2018.11.13.05.04.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 05:04:34 -0800 (PST)
Date: Tue, 13 Nov 2018 14:04:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/hugetl.c: keep the page mapping info when
 free_huge_page() hit the VM_BUG_ON_PAGE
Message-ID: <20181113130433.GB16182@dhcp22.suse.cz>
References: <CAJtqMcZp5AVva2yOM4gJET8Gd_j_BGJDLTkcqRdJynVCiRRFxQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJtqMcZp5AVva2yOM4gJET8Gd_j_BGJDLTkcqRdJynVCiRRFxQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yongkai Wu <nic.wuyk@gmail.com>
Cc: mike.kravetz@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 13-11-18 20:38:16, Yongkai Wu wrote:
> It is better to keep page mapping info when free_huge_page() hit the
> VM_BUG_ON_PAGE,
> so we can get more infomation from the coredump for further analysis.

The patch seems to be whitespace damaged. Put that aside, have you
actually seen a case where preservning the page state would help to nail
down any bug.

I am not objecting to the patch, it actually makes some sense to me, I
am just curious about a background motivation.
 
> Signed-off-by: Yongkai Wu <nic_w@163.com>
> ---
>  mm/hugetlb.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index c007fb5..ba693bb 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1248,10 +1248,11 @@ void free_huge_page(struct page *page)
>   (struct hugepage_subpool *)page_private(page);
>   bool restore_reserve;
> 
> +        VM_BUG_ON_PAGE(page_count(page), page);
> +        VM_BUG_ON_PAGE(page_mapcount(page), page);
> +
>   set_page_private(page, 0);
>   page->mapping = NULL;
> - VM_BUG_ON_PAGE(page_count(page), page);
> - VM_BUG_ON_PAGE(page_mapcount(page), page);
>   restore_reserve = PagePrivate(page);
>   ClearPagePrivate(page);
> 
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs
