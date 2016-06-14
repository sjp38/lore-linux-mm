Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 07AA26B0253
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 18:14:29 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id b126so14630495ite.3
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 15:14:29 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id nd19si26470733pab.62.2016.06.14.15.14.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jun 2016 15:14:28 -0700 (PDT)
Date: Tue, 14 Jun 2016 15:14:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] more mapcount page as kpage could reduce total
 replacement times than fewer mapcount one in probability.
Message-Id: <20160614151426.0e893a1f7b4e549a7c6e7fdf@linux-foundation.org>
In-Reply-To: <1465895857-1515-1-git-send-email-zhouxianrong@huawei.com>
References: <1465895857-1515-1-git-send-email-zhouxianrong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong@huawei.com
Cc: linux-mm@kvack.org, hughd@google.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, zhouchengming1@huawei.com, geliangtang@163.com, linux-kernel@vger.kernel.org, zhouxiyu@huawei.com, wanghaijun5@huawei.comHugh Dickins <hughd@google.com>

On Tue, 14 Jun 2016 17:17:37 +0800 <zhouxianrong@huawei.com> wrote:

> From: z00281421 <z00281421@notesmail.huawei.com>
> 
> more mapcount page as kpage could reduce total replacement 
> times than fewer mapcount one when ksmd scan and replace 
> among forked pages later.
> 

Hopefully Hugh will be able to have a think about this.

> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1094,6 +1094,21 @@ static struct page *try_to_merge_two_pages(struct rmap_item *rmap_item,
>  {
>  	int err;
>  
> +	/*
> +	 * select more mapcount page as kpage
> +	 */
> +	if (page_mapcount(page) < page_mapcount(tree_page)) {
> +		struct page *tmp_page;
> +		struct rmap_item *tmp_rmap_item;
> +
> +		tmp_page = page;
> +		page = tree_page;
> +		tree_page = tmp_page;
> +		tmp_rmap_item = rmap_item;
> +		rmap_item = tree_rmap_item;
> +		tree_rmap_item = tmp_rmap_item;
> +	}

kernel.h provides a swap() macro.

>  	err = try_to_merge_with_ksm_page(rmap_item, page, NULL);
>  	if (!err) {
>  		err = try_to_merge_with_ksm_page(tree_rmap_item,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
