Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8C4636B0005
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 22:06:29 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id t7so6676670vkf.2
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 19:06:29 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id g67si12540510ywc.116.2016.06.20.19.06.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Jun 2016 19:06:28 -0700 (PDT)
Subject: Re: [PATCH v2] more mapcount page as kpage could reduce total
 replacement times than fewer mapcount one in probability.
References: <1465955818-101898-1-git-send-email-zhouxianrong@huawei.com>
From: zhouxianrong <zhouxianrong@huawei.com>
Message-ID: <2460b794-92f0-d115-c729-bcfe33663e48@huawei.com>
Date: Tue, 21 Jun 2016 09:57:54 +0800
MIME-Version: 1.0
In-Reply-To: <1465955818-101898-1-git-send-email-zhouxianrong@huawei.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, hughd@google.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, zhouchengming1@huawei.com, geliangtang@163.com, linux-kernel@vger.kernel.org, zhouxiyu@huawei.com, wanghaijun5@huawei.com

hey hugh:
     could you please give me some suggestion about this ?

On 2016/6/15 9:56, zhouxianrong@huawei.com wrote:
> From: z00281421 <z00281421@notesmail.huawei.com>
>
> more mapcount page as kpage could reduce total replacement times
> than fewer mapcount one when ksmd scan and replace among
> forked pages later.
>
> Signed-off-by: z00281421 <z00281421@notesmail.huawei.com>
> ---
>  mm/ksm.c |    8 ++++++++
>  1 file changed, 8 insertions(+)
>
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 4786b41..4d530af 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1094,6 +1094,14 @@ static struct page *try_to_merge_two_pages(struct rmap_item *rmap_item,
>  {
>  	int err;
>
> +	/*
> +	 * select more mapcount page as kpage
> +	 */
> +	if (page_mapcount(page) < page_mapcount(tree_page)) {
> +		swap(page, tree_page);
> +		swap(rmap_item, tree_rmap_item);
> +	}
> +
>  	err = try_to_merge_with_ksm_page(rmap_item, page, NULL);
>  	if (!err) {
>  		err = try_to_merge_with_ksm_page(tree_rmap_item,
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
