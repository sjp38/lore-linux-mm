Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1C9736B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 22:27:05 -0500 (EST)
Received: by pablj1 with SMTP id lj1so25046945pab.9
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 19:27:04 -0800 (PST)
Received: from out11.biz.mail.alibaba.com (out11.biz.mail.alibaba.com. [205.204.114.131])
        by mx.google.com with ESMTP id fe2si7640297pdb.221.2015.02.27.19.27.02
        for <linux-mm@kvack.org>;
        Fri, 27 Feb 2015 19:27:04 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
Subject: Re: [RFC 2/3] hugetlbfs: coordinate global and subpool reserve accounting
Date: Sat, 28 Feb 2015 11:25:24 +0800
Message-ID: <013001d05306$31c8b250$955a16f0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mike Kravetz' <mike.kravetz@oracle.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, davidlohr@hp.com, 'Aneesh Kumar' <aneesh.kumar@linux.vnet.ibm.com>, 'Joonsoo Kim' <iamjoonsoo.kim@lge.com>

> @@ -3444,10 +3445,14 @@ int hugetlb_reserve_pages(struct inode *inode,
>  	 * Check enough hugepages are available for the reservation.
>  	 * Hand the pages back to the subpool if there are not
>  	 */

Better if comment is updated correspondingly.
Hillf
> -	ret = hugetlb_acct_memory(h, chg);
> -	if (ret < 0) {
> -		hugepage_subpool_put_pages(spool, chg);
> -		goto out_err;
> +	if (subpool_reserved(spool))
> +		ret = 0;
> +	else {
> +		ret = hugetlb_acct_memory(h, chg);
> +		if (ret < 0) {
> +			hugepage_subpool_put_pages(spool, chg);
> +			goto out_err;
> +		}
>  	}
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
