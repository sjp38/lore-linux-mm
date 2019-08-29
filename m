Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D386C3A5A3
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 15:49:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 324E42173E
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 15:49:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="o60jjx3G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 324E42173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAD476B0273; Thu, 29 Aug 2019 11:49:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5E3A6B0274; Thu, 29 Aug 2019 11:49:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 999ED6B0275; Thu, 29 Aug 2019 11:49:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0115.hostedemail.com [216.40.44.115])
	by kanga.kvack.org (Postfix) with ESMTP id 76C3C6B0273
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 11:49:44 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 31EFD824CA32
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 15:49:44 +0000 (UTC)
X-FDA: 75875900688.22.body08_720c67a434a61
X-HE-Tag: body08_720c67a434a61
X-Filterd-Recvd-Size: 5727
Received: from aserp2120.oracle.com (aserp2120.oracle.com [141.146.126.78])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 15:49:43 +0000 (UTC)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7TFiF1v031211;
	Thu, 29 Aug 2019 15:49:41 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2019-08-05;
 bh=a3VcsoTcsM17daz5ifjQxU9eyu5QEXdo1iwDaIZe2bc=;
 b=o60jjx3GsEg7PlWXOQ6rtoNfNOXXy4eVCzlRk7Wc2ya+08DkgzUaEMEIOdt5Bo9+GzYw
 02L5GnBE2xvZP3uuirO7ApWJShyL47YyDnxfaJb08fOpwVpiHE5S3qXA0s36WU5b1MOZ
 i5fAcKyo4w7wWXvsFiQHsPgW8S8yIZ+OxtF6mecjIpk/TknOhpIxYswF2Y8fQ4h96UmQ
 LXbqvXwQ5hivvY4pHBeifDz1JYA9YtcgKqvxqT+xEGlxcF/HU40Y3mz83ds/8DTFtpsb
 ldO+jbpkNN2rJgDq30uL7CzNZZLEA9+QZBRX25Rmrna460o17a30WVoAb7jgEznlLIKc Kg== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2120.oracle.com with ESMTP id 2uphcyg6r8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 29 Aug 2019 15:49:41 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7TFiFGf129148;
	Thu, 29 Aug 2019 15:49:41 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3020.oracle.com with ESMTP id 2upc8uurw6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 29 Aug 2019 15:49:41 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x7TFnd39010514;
	Thu, 29 Aug 2019 15:49:39 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 29 Aug 2019 08:49:38 -0700
Date: Thu, 29 Aug 2019 08:49:37 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Jan Kara <jack@suse.cz>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        Amir Goldstein <amir73il@gmail.com>, Boaz Harrosh <boaz@plexistor.com>,
        linux-fsdevel@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH 1/3] mm: Handle MADV_WILLNEED through vfs_fadvise()
Message-ID: <20190829154937.GC5354@magnolia>
References: <20190829131034.10563-1-jack@suse.cz>
 <20190829131034.10563-2-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190829131034.10563-2-jack@suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9364 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908290168
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9364 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908290168
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 29, 2019 at 03:10:32PM +0200, Jan Kara wrote:
> Currently handling of MADV_WILLNEED hint calls directly into readahead
> code. Handle it by calling vfs_fadvise() instead so that filesystem can
> use its ->fadvise() callback to acquire necessary locks or otherwise
> prepare for the request.
> 
> Suggested-by: Amir Goldstein <amir73il@gmail.com>
> Reviewed-by: Boaz Harrosh <boazh@netapp.com>
> CC: stable@vger.kernel.org
> Signed-off-by: Jan Kara <jack@suse.cz>

Looks ok,
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
>  mm/madvise.c | 22 ++++++++++++++++------
>  1 file changed, 16 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 968df3aa069f..bac973b9f2cc 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -14,6 +14,7 @@
>  #include <linux/userfaultfd_k.h>
>  #include <linux/hugetlb.h>
>  #include <linux/falloc.h>
> +#include <linux/fadvise.h>
>  #include <linux/sched.h>
>  #include <linux/ksm.h>
>  #include <linux/fs.h>
> @@ -275,6 +276,7 @@ static long madvise_willneed(struct vm_area_struct *vma,
>  			     unsigned long start, unsigned long end)
>  {
>  	struct file *file = vma->vm_file;
> +	loff_t offset;
>  
>  	*prev = vma;
>  #ifdef CONFIG_SWAP
> @@ -298,12 +300,20 @@ static long madvise_willneed(struct vm_area_struct *vma,
>  		return 0;
>  	}
>  
> -	start = ((start - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
> -	if (end > vma->vm_end)
> -		end = vma->vm_end;
> -	end = ((end - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
> -
> -	force_page_cache_readahead(file->f_mapping, file, start, end - start);
> +	/*
> +	 * Filesystem's fadvise may need to take various locks.  We need to
> +	 * explicitly grab a reference because the vma (and hence the
> +	 * vma's reference to the file) can go away as soon as we drop
> +	 * mmap_sem.
> +	 */
> +	*prev = NULL;	/* tell sys_madvise we drop mmap_sem */
> +	get_file(file);
> +	up_read(&current->mm->mmap_sem);
> +	offset = (loff_t)(start - vma->vm_start)
> +			+ ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
> +	vfs_fadvise(file, offset, end - start, POSIX_FADV_WILLNEED);
> +	fput(file);
> +	down_read(&current->mm->mmap_sem);
>  	return 0;
>  }
>  
> -- 
> 2.16.4
> 

