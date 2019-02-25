Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F316C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 21:04:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E028D20842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 21:04:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E028D20842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 41C628E0005; Mon, 25 Feb 2019 16:04:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3CDEB8E0004; Mon, 25 Feb 2019 16:04:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2482B8E0005; Mon, 25 Feb 2019 16:04:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D63098E0004
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 16:04:10 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id k10so8704987pfi.5
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 13:04:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=r8X5BIBnkqbWODYwXNyoMCDtObld0qeXunwImjun5gQ=;
        b=pnE3lwhzQn+0OfUA50jY0wWq+aeY1gAVnUYJLIzbn8F6A4QLuQB/7fF49FFQytid4H
         iuSey86jjOkSXaV4riPSvzrSyybkY4DnLi8QL6vSpbb+dl2d9S1x3Wcjbmzt/g+xlrAA
         r+dIRC64m7ZRjPnO5jzFQ2crwGAXQWwgkTEVST4DOYnD2vFrxYvUJfKwpkag71+Hr2DI
         Z2R7vpL4KwAEqQOPXDjnSY9l58z+yUtA20BZd8A0GVMex3NWdxzJ+oj6aoCic4t82eaq
         1jcnfhjrz8HlSbyvG/lwK2RhU9YWF0IIfQuMmT8vi4Ib/twOhH8wY7GnlwZO0UVowVrO
         mE7g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuZ/Sitr+WMs4DC2V6CUFjSihumQq0ZpfewkXNU7KM8kk8jc8P9v
	qePj/8pIt5EsEfwXggR6qCyw5fDSgkMV/zmKgpFtFhM2kY8h22CYQhOGbgsBVsl6BexAK4lqqa8
	XvTosJTvrSboqLCiVzaSybRN2BgT3ERPByuqiH1gLpMv8S78YAkbnKvX9XPQY0C0e5g==
X-Received: by 2002:a62:444b:: with SMTP id r72mr22484886pfa.184.1551128650446;
        Mon, 25 Feb 2019 13:04:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYopCNpLyDk9v3sGSWcmIfNCU05vxeoXx3KQStgVyBnpbVLRW4GM7PVxLDUOCjWO5DlFvET
X-Received: by 2002:a62:444b:: with SMTP id r72mr22484730pfa.184.1551128648427;
        Mon, 25 Feb 2019 13:04:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551128648; cv=none;
        d=google.com; s=arc-20160816;
        b=Lji23iYeK7jyVdGVy59JCsFz2pYqwuJwQ4qo+5zxEYYLwMjURTL0HpHkwF9sV0e8bo
         4Hna4t+cYrkTzsAbXmqbH/+c0w6wsJymgmMcG/LQAwIKZ2z+eLRHPk2y7QKDZrpLNNoq
         sB3VIa6OODAvMsfpeBcC6DySKuhgQ3+aFIXtKvukQ6Z6L1IJI5gcvjIfQpSeIMiFiFb/
         RsAo/tiLM02RgwyKGvsRI1nRR8+oqiLoOpq/YmfIllt4Jj+LvuEIUuNIHVjpErh0t7ox
         KQ4hRngYa5JTri4nYk83kgstiLHkM0VCmklei+EqNWws3Xkqhmr/eI+h1zIE32TNMSj0
         ui1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=r8X5BIBnkqbWODYwXNyoMCDtObld0qeXunwImjun5gQ=;
        b=fQ4JRx4uY2uY1lNUMo63aHBrGeiF4YZJWj+qyFqpe0q++Q0u+gHJgtvbt3m220qJfp
         CbENusWVhbdKquztvSGCu6a9mp/D2/xQJC2eWplfbsHRT2VbSoih2La7vQrEb5p7tk/J
         JM51dAv4cngUZRtRvIbZIt5E5nuoKnC/1mugHcU88HXDxDU6KE63ypjBblshQrcYw4DP
         DBM9oR0yWyqjY0kmZt/G1Z6z0wTX/vWnFBIilkSaXtiIrHHwra/agho5Hac60QRQXUpb
         tXJw4T5P6+GqP/OZNC/tJ6upBk57jxHA3HuEKYChI/E8cKgzNrAeZOXeMCgNPjIV/ntN
         IjRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e69si10666412pgc.552.2019.02.25.13.04.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 13:04:08 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1PKsQCv020372
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 16:04:07 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qvncy7kuv-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 16:04:07 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 25 Feb 2019 21:04:04 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 25 Feb 2019 21:03:57 -0000
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1PL3uni29622298
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 25 Feb 2019 21:03:56 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AE1C652057;
	Mon, 25 Feb 2019 21:03:56 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.243])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id DC8CC52051;
	Mon, 25 Feb 2019 21:03:53 +0000 (GMT)
Date: Mon, 25 Feb 2019 23:03:51 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        David Hildenbrand <david@redhat.com>, Hugh Dickins <hughd@google.com>,
        Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>,
        Pavel Emelyanov <xemul@virtuozzo.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
        Marty McFadden <mcfadden8@llnl.gov>,
        Andrea Arcangeli <aarcange@redhat.com>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        Denis Plotnikov <dplotnikov@virtuozzo.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>,
        "Kirill A . Shutemov" <kirill@shutemov.name>,
        "Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 21/26] userfaultfd: wp: add the writeprotect API to
 userfaultfd ioctl
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-22-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212025632.28946-22-peterx@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022521-4275-0000-0000-00000313D7D7
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022521-4276-0000-0000-000038221547
Message-Id: <20190225210350.GD10454@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-25_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=834 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902250150
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:27AM +0800, Peter Xu wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> v1: From: Shaohua Li <shli@fb.com>
> 
> v2: cleanups, remove a branch.
> 
> [peterx writes up the commit message, as below...]
> 
> This patch introduces the new uffd-wp APIs for userspace.
> 
> Firstly, we'll allow to do UFFDIO_REGISTER with write protection
> tracking using the new UFFDIO_REGISTER_MODE_WP flag.  Note that this
> flag can co-exist with the existing UFFDIO_REGISTER_MODE_MISSING, in
> which case the userspace program can not only resolve missing page
> faults, and at the same time tracking page data changes along the way.
> 
> Secondly, we introduced the new UFFDIO_WRITEPROTECT API to do page
> level write protection tracking.  Note that we will need to register
> the memory region with UFFDIO_REGISTER_MODE_WP before that.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> [peterx: remove useless block, write commit message, check against
>  VM_MAYWRITE rather than VM_WRITE when register]
> Signed-off-by: Peter Xu <peterx@redhat.com>
> ---
>  fs/userfaultfd.c                 | 82 +++++++++++++++++++++++++-------
>  include/uapi/linux/userfaultfd.h | 11 +++++
>  2 files changed, 77 insertions(+), 16 deletions(-)
> 
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index 3092885c9d2c..81962d62520c 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -304,8 +304,11 @@ static inline bool userfaultfd_must_wait(struct userfaultfd_ctx *ctx,
>  	if (!pmd_present(_pmd))
>  		goto out;
> 
> -	if (pmd_trans_huge(_pmd))
> +	if (pmd_trans_huge(_pmd)) {
> +		if (!pmd_write(_pmd) && (reason & VM_UFFD_WP))
> +			ret = true;
>  		goto out;
> +	}
> 
>  	/*
>  	 * the pmd is stable (as in !pmd_trans_unstable) so we can re-read it
> @@ -318,6 +321,8 @@ static inline bool userfaultfd_must_wait(struct userfaultfd_ctx *ctx,
>  	 */
>  	if (pte_none(*pte))
>  		ret = true;
> +	if (!pte_write(*pte) && (reason & VM_UFFD_WP))
> +		ret = true;
>  	pte_unmap(pte);
> 
>  out:
> @@ -1251,10 +1256,13 @@ static __always_inline int validate_range(struct mm_struct *mm,
>  	return 0;
>  }
> 
> -static inline bool vma_can_userfault(struct vm_area_struct *vma)
> +static inline bool vma_can_userfault(struct vm_area_struct *vma,
> +				     unsigned long vm_flags)
>  {
> -	return vma_is_anonymous(vma) || is_vm_hugetlb_page(vma) ||
> -		vma_is_shmem(vma);
> +	/* FIXME: add WP support to hugetlbfs and shmem */
> +	return vma_is_anonymous(vma) ||
> +		((is_vm_hugetlb_page(vma) || vma_is_shmem(vma)) &&
> +		 !(vm_flags & VM_UFFD_WP));
>  }
> 
>  static int userfaultfd_register(struct userfaultfd_ctx *ctx,
> @@ -1286,15 +1294,8 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
>  	vm_flags = 0;
>  	if (uffdio_register.mode & UFFDIO_REGISTER_MODE_MISSING)
>  		vm_flags |= VM_UFFD_MISSING;
> -	if (uffdio_register.mode & UFFDIO_REGISTER_MODE_WP) {
> +	if (uffdio_register.mode & UFFDIO_REGISTER_MODE_WP)
>  		vm_flags |= VM_UFFD_WP;
> -		/*
> -		 * FIXME: remove the below error constraint by
> -		 * implementing the wprotect tracking mode.
> -		 */
> -		ret = -EINVAL;
> -		goto out;
> -	}
> 
>  	ret = validate_range(mm, uffdio_register.range.start,
>  			     uffdio_register.range.len);
> @@ -1342,7 +1343,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
> 
>  		/* check not compatible vmas */
>  		ret = -EINVAL;
> -		if (!vma_can_userfault(cur))
> +		if (!vma_can_userfault(cur, vm_flags))
>  			goto out_unlock;
> 
>  		/*
> @@ -1370,6 +1371,8 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
>  			if (end & (vma_hpagesize - 1))
>  				goto out_unlock;
>  		}
> +		if ((vm_flags & VM_UFFD_WP) && !(cur->vm_flags & VM_MAYWRITE))
> +			goto out_unlock;
> 
>  		/*
>  		 * Check that this vma isn't already owned by a
> @@ -1399,7 +1402,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
>  	do {
>  		cond_resched();
> 
> -		BUG_ON(!vma_can_userfault(vma));
> +		BUG_ON(!vma_can_userfault(vma, vm_flags));
>  		BUG_ON(vma->vm_userfaultfd_ctx.ctx &&
>  		       vma->vm_userfaultfd_ctx.ctx != ctx);
>  		WARN_ON(!(vma->vm_flags & VM_MAYWRITE));
> @@ -1534,7 +1537,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
>  		 * provides for more strict behavior to notice
>  		 * unregistration errors.
>  		 */
> -		if (!vma_can_userfault(cur))
> +		if (!vma_can_userfault(cur, cur->vm_flags))
>  			goto out_unlock;
> 
>  		found = true;
> @@ -1548,7 +1551,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
>  	do {
>  		cond_resched();
> 
> -		BUG_ON(!vma_can_userfault(vma));
> +		BUG_ON(!vma_can_userfault(vma, vma->vm_flags));
> 
>  		/*
>  		 * Nothing to do: this vma is already registered into this
> @@ -1761,6 +1764,50 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
>  	return ret;
>  }
> 
> +static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
> +				    unsigned long arg)
> +{
> +	int ret;
> +	struct uffdio_writeprotect uffdio_wp;
> +	struct uffdio_writeprotect __user *user_uffdio_wp;
> +	struct userfaultfd_wake_range range;
> +
> +	if (READ_ONCE(ctx->mmap_changing))
> +		return -EAGAIN;
> +
> +	user_uffdio_wp = (struct uffdio_writeprotect __user *) arg;
> +
> +	if (copy_from_user(&uffdio_wp, user_uffdio_wp,
> +			   sizeof(struct uffdio_writeprotect)))
> +		return -EFAULT;
> +
> +	ret = validate_range(ctx->mm, uffdio_wp.range.start,
> +			     uffdio_wp.range.len);
> +	if (ret)
> +		return ret;
> +
> +	if (uffdio_wp.mode & ~(UFFDIO_WRITEPROTECT_MODE_DONTWAKE |
> +			       UFFDIO_WRITEPROTECT_MODE_WP))
> +		return -EINVAL;
> +	if ((uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP) &&
> +	     (uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE))
> +		return -EINVAL;

Why _DONTWAKE cannot be used when setting write-protection?
I can imagine a use-case when you'd want to freeze an application,
write-protect several regions and then let the application continue.

> +
> +	ret = mwriteprotect_range(ctx->mm, uffdio_wp.range.start,
> +				  uffdio_wp.range.len, uffdio_wp.mode &
> +				  UFFDIO_WRITEPROTECT_MODE_WP,
> +				  &ctx->mmap_changing);
> +	if (ret)
> +		return ret;
> +
> +	if (!(uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE)) {
> +		range.start = uffdio_wp.range.start;
> +		range.len = uffdio_wp.range.len;
> +		wake_userfault(ctx, &range);
> +	}
> +	return ret;
> +}
> +
>  static inline unsigned int uffd_ctx_features(__u64 user_features)
>  {
>  	/*
> @@ -1838,6 +1885,9 @@ static long userfaultfd_ioctl(struct file *file, unsigned cmd,
>  	case UFFDIO_ZEROPAGE:
>  		ret = userfaultfd_zeropage(ctx, arg);
>  		break;
> +	case UFFDIO_WRITEPROTECT:
> +		ret = userfaultfd_writeprotect(ctx, arg);
> +		break;
>  	}
>  	return ret;
>  }
> diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
> index 297cb044c03f..1b977a7a4435 100644
> --- a/include/uapi/linux/userfaultfd.h
> +++ b/include/uapi/linux/userfaultfd.h
> @@ -52,6 +52,7 @@
>  #define _UFFDIO_WAKE			(0x02)
>  #define _UFFDIO_COPY			(0x03)
>  #define _UFFDIO_ZEROPAGE		(0x04)
> +#define _UFFDIO_WRITEPROTECT		(0x06)
>  #define _UFFDIO_API			(0x3F)
> 
>  /* userfaultfd ioctl ids */
> @@ -68,6 +69,8 @@
>  				      struct uffdio_copy)
>  #define UFFDIO_ZEROPAGE		_IOWR(UFFDIO, _UFFDIO_ZEROPAGE,	\
>  				      struct uffdio_zeropage)
> +#define UFFDIO_WRITEPROTECT	_IOWR(UFFDIO, _UFFDIO_WRITEPROTECT, \
> +				      struct uffdio_writeprotect)
> 
>  /* read() structure */
>  struct uffd_msg {
> @@ -232,4 +235,12 @@ struct uffdio_zeropage {
>  	__s64 zeropage;
>  };
> 
> +struct uffdio_writeprotect {
> +	struct uffdio_range range;
> +	/* !WP means undo writeprotect. DONTWAKE is valid only with !WP */
> +#define UFFDIO_WRITEPROTECT_MODE_WP		((__u64)1<<0)
> +#define UFFDIO_WRITEPROTECT_MODE_DONTWAKE	((__u64)1<<1)
> +	__u64 mode;
> +};
> +
>  #endif /* _LINUX_USERFAULTFD_H */
> -- 
> 2.17.1
> 

-- 
Sincerely yours,
Mike.

