Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 729B8C742D6
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 17:50:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FA28204FD
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 17:50:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="WmIBn4Tz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FA28204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E0F78E0161; Fri, 12 Jul 2019 13:50:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9922D8E0003; Fri, 12 Jul 2019 13:50:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 858EB8E0161; Fri, 12 Jul 2019 13:50:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 621DE8E0003
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 13:50:47 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id l14so7541082qke.16
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 10:50:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=x7UvLQTSUB1LsR4hNhBIrs6gKfi4eqgBS41bGNCZxkE=;
        b=O11SRpjZ1OodW+oPMiproAUMrboZHLF2/ce2GXZATT/TfCUP85JtdBaMt/b+JC6KEo
         TfQ/xxsOJQ/PM8FU7OCVOubJ0Ys//msRf7w6wu3l3Wjsxx0/RMRUxZiJFb8DknmNgyLV
         JM8TT01XjAFBteMZdmsgHbrQ7GdP1z6zUcUiCD5HJdro5ZlCXijeZ18ZjErqa3+FsYxK
         HYwAQUsFQ6yCMCHRCX8kpu6bD1mO9FFObnyyVB/CSkC7OYe0PVKtFyyw2MjvO+wvAl8q
         ptZI7lWHVQeV6E+G2hTrurlTVCeZMCF6mgLZ2XTaQHHHa+zFHkgxf6lOy88ufmmQEpaZ
         vIZA==
X-Gm-Message-State: APjAAAVDGZpA/mHdll34qRjoFdpYoBMwFCBBoujc9Jx/7s5HPHQWPTdz
	BsNMlNPQ9vhkVgRTuiZlKyO76S1Un7qKiKSVYynbl76qLety9WMd/sotkJigwqfP3GkcIPPu673
	PjDhVlc8HevvZBdWTP1HyCRVbFsSjH/y8Jua7UQjXla6VsRPL+RuVmQYKN4TeH8P61g==
X-Received: by 2002:ae9:eb8f:: with SMTP id b137mr7231584qkg.136.1562953847142;
        Fri, 12 Jul 2019 10:50:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzUUqbYJo/m74o9D8gosLnfdCTDfjKS2vc/GG6pYzClgsfUDRf1bg3+1ZX0iuNLkSdu0vvN
X-Received: by 2002:ae9:eb8f:: with SMTP id b137mr7231552qkg.136.1562953846487;
        Fri, 12 Jul 2019 10:50:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562953846; cv=none;
        d=google.com; s=arc-20160816;
        b=FqnPyu0t9i6kYYBxkl9Cu1CUd1J3Xr4f2W7GJ8zetY2aF2W75JBMJoE2NFdff6k4VT
         yH/eovs2D7EAgh9dCWGCzHedPJFEEPur21bU/bcPZ/bMjqd6jN2SJma1qJl0ryScYMAs
         0n0ZQ5vfE55PWrHpccN8UioQmaoJJ8SBgZFySk3LkVKMgNBvQEnAsJz5YXPGNsJ1Pfv9
         foqGiW1VyY3E+yRLkve/CTVQRdRXH3XkmRWFx8Q0ZVlSDCHGHMH1JM/vfEgLmpV8aukR
         fkG4mYrUSAvhINRIZXr26rREnjMBq2rrdke8NYE56juYnKTBTNZQBGaPOaX9EI9IlS5a
         rqFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=x7UvLQTSUB1LsR4hNhBIrs6gKfi4eqgBS41bGNCZxkE=;
        b=y72J6EQBIftFbEgPeXYwbD5PldMZ2a4khjiyPWiQG1yKGa4zaMO48Re17JVyx2zfP0
         flFVqVTmoGRlN5L604pAiaRmtZlJYCBkGFJSxbuvFgSVJtSILlP1Ggkkmcd+WotiEI0/
         qHp7IpnnTlU+ZxzlsF7fWUSwQrPyHIait7jy3WrcvuzFIQyJxof+6w5yEq13lw+MLYaC
         3yn7OpZtIF6Nmr1vvb+y4J0RHhoz2Qv0dm6WmMagcmgEwFDluhZbqygV4tPhTABUsArh
         U5WHtm+wykD8aoi7R0e22MvKg3HcdL9t5dVOEnXu4UNOi+6ss/A74f1+vNdxpX1sYoXK
         wm9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=WmIBn4Tz;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id b192si5735518qkc.367.2019.07.12.10.50.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 10:50:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=WmIBn4Tz;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6CHj40F087152;
	Fri, 12 Jul 2019 17:50:43 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=x7UvLQTSUB1LsR4hNhBIrs6gKfi4eqgBS41bGNCZxkE=;
 b=WmIBn4TzVxJx7tITkiSdrxbMpLlvOyowIFmWIQLvD8rTXOemFcj/0peG8zV3LJOZopYV
 5hKdk0m359lkfQ7nMT4n2GhVSOCH4wp95EOwzR6Ohrzx9y5528wIXvddyfPrfkytsJDI
 SNvy/mobFyaDD+GB0eg8nzsY+gbUx03fqPfGr0UgLAx4VLkrQkety9jgD4AAHLwrZpa6
 HYfIZYhjoI1JkxBBH4sfGEdHz/pHZJjw/NmTv1sSRBHGcdIShUvN18StFkQ7qAZJKrpq
 5qdQ9L3z/Q/UdLLt6fdxQ9dJx6oa3hNyB6f6Us/sRV1+OoU5AKQpKtclrhQZES7W/CVA wg== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2tjk2u71re-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 17:50:43 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6CHlfJb072667;
	Fri, 12 Jul 2019 17:50:43 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3030.oracle.com with ESMTP id 2tn1j296kb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 17:50:43 +0000
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x6CHofoJ017303;
	Fri, 12 Jul 2019 17:50:41 GMT
Received: from localhost (/10.159.245.178)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 12 Jul 2019 10:50:41 -0700
Date: Fri, 12 Jul 2019 10:50:40 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-xfs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>,
        Boaz Harrosh <boaz@plexistor.com>, stable@vger.kernel.org
Subject: Re: [PATCH 1/3] mm: Handle MADV_WILLNEED through vfs_fadvise()
Message-ID: <20190712175040.GY1404256@magnolia>
References: <20190711140012.1671-1-jack@suse.cz>
 <20190711140012.1671-2-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190711140012.1671-2-jack@suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9316 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907120180
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9316 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907120180
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 11, 2019 at 04:00:10PM +0200, Jan Kara wrote:
> Currently handling of MADV_WILLNEED hint calls directly into readahead
> code. Handle it by calling vfs_fadvise() instead so that filesystem can
> use its ->fadvise() callback to acquire necessary locks or otherwise
> prepare for the request.
> 
> Suggested-by: Amir Goldstein <amir73il@gmail.com>
> CC: stable@vger.kernel.org # Needed by "xfs: Fix stale data exposure
> 					when readahead races with hole punch"
> Signed-off-by: Jan Kara <jack@suse.cz>

Looks reasonable to me, though is this race between readahead and
truncate severe enough to try to push it as a fix for 5.3 or are you
targetting 5.4?

--D

> ---
>  mm/madvise.c | 22 ++++++++++++++++------
>  1 file changed, 16 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 628022e674a7..ae56d0ef337d 100644
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

