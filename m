Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 02B0C6B0069
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 01:42:50 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so2799667pdj.41
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 22:42:50 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id co6si13307825pac.88.2014.10.21.22.42.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 21 Oct 2014 22:42:50 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NDU00K0O000IL20@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 22 Oct 2014 06:45:36 +0100 (BST)
Message-id: <544743D6.6040103@samsung.com>
Date: Wed, 22 Oct 2014 09:42:46 +0400
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] mm, hugetlb: correct bit shift in hstate_sizelog
References: <1413915307-20536-1-git-send-email-sasha.levin@oracle.com>
In-reply-to: <1413915307-20536-1-git-send-email-sasha.levin@oracle.com>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, akpm@linux-foundation.org
Cc: n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/21/2014 10:15 PM, Sasha Levin wrote:
> hstate_sizelog() would shift left an int rather than long, triggering
> undefined behaviour and passing an incorrect value when the requested
> page size was more than 4GB, thus breaking >4GB pages.

> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  include/linux/hugetlb.h |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 65e12a2..57e0dfd 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -312,7 +312,8 @@ static inline struct hstate *hstate_sizelog(int page_size_log)
>  {
>  	if (!page_size_log)
>  		return &default_hstate;
> -	return size_to_hstate(1 << page_size_log);
> +
> +	return size_to_hstate(1UL << page_size_log);

That still could be undefined on 32-bits. Either use 1ULL or reduce SHM_HUGE_MASK on 32bits.


>  }
>  
>  static inline struct hstate *hstate_vma(struct vm_area_struct *vma)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
