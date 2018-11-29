Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 79E896B52DF
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 08:51:39 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id w19-v6so1459067plq.1
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 05:51:39 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id r11si2120548pgg.327.2018.11.29.05.51.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 05:51:38 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH] hugetlbfs: Call VM_BUG_ON_PAGE earlier in free_huge_page
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <1543491843-23438-1-git-send-email-nic_w@163.com>
Date: Thu, 29 Nov 2018 06:51:28 -0700
Content-Transfer-Encoding: 7bit
Message-Id: <0B408D50-D101-4457-B779-5951DEE0435A@oracle.com>
References: <1543491843-23438-1-git-send-email-nic_w@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yongkai Wu <nic.wuyk@gmail.com>
Cc: mike.kravetz@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, nic_w@163.com

Reviewed-by: William Kucharski <william.kucharski@oracle.com>

> On Nov 29, 2018, at 4:44 AM, Yongkai Wu <nic.wuyk@gmail.com> wrote:
> 
> A stack trace was triggered by VM_BUG_ON_PAGE(page_mapcount(page),
> page) in free_huge_page().  Unfortunately, the page->mapping field
> was set to NULL before this test.  This made it more difficult to
> determine the root cause of the problem.
> 
> Move the VM_BUG_ON_PAGE tests earlier in the function so that if
> they do trigger more information is present in the page struct.
> 
> Signed-off-by: Yongkai Wu <nic_w@163.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
> mm/hugetlb.c | 5 +++--
> 1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 7f2a28a..14ef274 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1248,10 +1248,11 @@ void free_huge_page(struct page *page)
> 		(struct hugepage_subpool *)page_private(page);
> 	bool restore_reserve;
> 
> -	set_page_private(page, 0);
> -	page->mapping = NULL;
> 	VM_BUG_ON_PAGE(page_count(page), page);
> 	VM_BUG_ON_PAGE(page_mapcount(page), page);
> +
> +	set_page_private(page, 0);
> +	page->mapping = NULL;
> 	restore_reserve = PagePrivate(page);
> 	ClearPagePrivate(page);
> 
> -- 
> 1.8.3.1
> 
