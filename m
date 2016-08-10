Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4E62C6B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 04:02:15 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ez1so62763312pab.1
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 01:02:15 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id p11si47351423pao.78.2016.08.10.01.02.13
        for <linux-mm@kvack.org>;
        Wed, 10 Aug 2016 01:02:14 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <01f101d1f2da$5e943aa0$1bbcafe0$@alibaba-inc.com> <01f201d1f2dc$bd43f750$37cbe5f0$@alibaba-inc.com>
In-Reply-To: <01f201d1f2dc$bd43f750$37cbe5f0$@alibaba-inc.com>
Subject: Re: [RFC 11/11] mm, THP, swap: Delay splitting THP during swap out
Date: Wed, 10 Aug 2016 16:01:59 +0800
Message-ID: <01f301d1f2dd$78df7660$6a9e6320$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Huang Ying' <ying.huang@intel.com>
Cc: linux-mm@kvack.org

> 
> @@ -187,6 +221,14 @@ int add_to_swap(struct page *page, struct list_head *list)
>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
>  	VM_BUG_ON_PAGE(!PageUptodate(page), page);
> 
> +	if (unlikely(PageTransHuge(page))) {
> +		err = add_to_swap_trans_huge(page, list);
> +		if (err < 0)
> +			return 0;
> +		else if (err > 0)
> +			return err;
> +		/* fallback to split firstly if return 0 */

switch (err) and add vm event count according to the meaning of err? 
> +	}

thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
