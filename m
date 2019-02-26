Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E47BC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 08:29:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09015217F9
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 08:29:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09015217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E51E8E0003; Tue, 26 Feb 2019 03:29:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96FE88E0002; Tue, 26 Feb 2019 03:29:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7EB3B8E0003; Tue, 26 Feb 2019 03:29:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 33A178E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 03:29:06 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id x5so4128717plv.17
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 00:29:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=kB26rNCa8noe3LKrn8Gg2Xa7JzfuruppHWXlN2ftHww=;
        b=c3qdf7fMH/rtTC2vMoIvNKXaW/RMx90K5qg+w7fSEzNcWn5zYi9HEagEKH9/2/cuRy
         bWHrAYJSgIvje5PboVskFtQqwxNTyhuHcaWr46DTpJ5LHjNKkMbhIMFS2FyB4NUltv12
         SyS5pTT9hwSDwTNs6s+pIEBZuwv/duDJ1gnSTeNsL6IYV6kqMWPtEvX27w3WHZ/DCywp
         SSxd703aXccHykq/3SsiKsd1ZGGBF2dPg7OxeSIThmYyBMTxDHzYYzNL0GFVNHX+JM1k
         MYkhQHFuTjCCuGJcWZh9W5blEBesk6vnhcLtvVgunwg/KLJHmZU1qo2P29gOCDy4ZauT
         5T6A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuZ4JYNL5wNRSYwLVsUK4WPMMhkbQt9AGzS2jkQDqXBhDeTLy07S
	GavOJ964yygQWHdUa2urt0HIYco3UOnNqBuV8LkDelSIjAP8KYWmws+FlDW6VJ7SfrDG8XDC9Wy
	YEVsQlm9K/5YMNikJ+GWwxcMiX/z4M6BKJCGKPB+SkJbfFFszffS9wLMU4is8/BlA6A==
X-Received: by 2002:a17:902:7e0f:: with SMTP id b15mr23800942plm.124.1551169745721;
        Tue, 26 Feb 2019 00:29:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaGfR4M4jGwfwU6ynRXt2o2/q/8yRbY5aYYDAqT54Ik4SfS/i7YrYHTX7jfBGLQt9sZDohn
X-Received: by 2002:a17:902:7e0f:: with SMTP id b15mr23800886plm.124.1551169744533;
        Tue, 26 Feb 2019 00:29:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551169744; cv=none;
        d=google.com; s=arc-20160816;
        b=nRuv6mStR1+WPwRy3AC9LkWwaFYEgmiXkSif+BI0qka/KAb577TaqHcr+aovLArMEl
         DgfzzkCSJDeM6gSvRT+iFNZe+igrltKXYLIFjA5UKDq0RljBPMqoKhrNH6KdYHH1FNXq
         s7TCA+SqbNNmk/O7yW7stI1vMMJb7DC6ojD/FVnZ8sF5wo4d6Nr4zm2bvhNLnrC114jJ
         ZYh0vXh0C/9aD3mHD/4O0w8VzvJuErR/6emXrZX1aBQME5E7P9xnGFYcv2rupumAvg7f
         GBDZPm1FQjMOT4OB49tEz1x/q6wJNyHR89bwB+CcdIsX71dDORJHIyuWP198bqPDwmvl
         H4YA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=kB26rNCa8noe3LKrn8Gg2Xa7JzfuruppHWXlN2ftHww=;
        b=GyB1klEaCA+U54Bw5uhIMBFlEaHA+WjQpZ9Un9xGAUEes3N5EsEZ692DLLb1H3EBJX
         DiyEvQ9AE7cf9WeTX2fkvKvNKdzQSVpXF2GWSwnHeSpffAy+zIIV2w/aSD6xjRlKoEM5
         N+TLzGBwuhZhWaWvEBfN+9RZF4E6ov8vdtMMtnVC2S55ufyGss44luENKKySffJPpDi8
         SETYGvRHWQk6v7zcpLFYUR+zBsuIm0zvZ/mwWsuFTJCAlXUq8pQQWLISVrb1Jqf3J/AZ
         5lX+oyCxu/exAh7lZsXeD4zdTEs79heus3jSWaZhS1ibbMOzOpnS9Ui9ybE17smDOTio
         QsvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x5si2298262pgr.149.2019.02.26.00.29.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 00:29:04 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1Q8SwSh134351
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 03:29:04 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qvyr1euub-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 03:29:03 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 26 Feb 2019 08:28:59 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 26 Feb 2019 08:28:54 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1Q8SrXF26935372
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 26 Feb 2019 08:28:53 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B96F2A405C;
	Tue, 26 Feb 2019 08:28:53 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5A53BA405B;
	Tue, 26 Feb 2019 08:28:52 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 26 Feb 2019 08:28:52 +0000 (GMT)
Date: Tue, 26 Feb 2019 10:28:50 +0200
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
Subject: Re: [PATCH v2 10/26] userfaultfd: wp: add UFFDIO_COPY_MODE_WP
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-11-peterx@redhat.com>
 <20190225155836.GD24917@rapoport-lnx>
 <20190226050942.GF13653@xz-x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226050942.GF13653@xz-x1>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022608-0016-0000-0000-0000025AFA6C
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022608-0017-0000-0000-000032B55B4A
Message-Id: <20190226082850.GC11981@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-26_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902260065
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 01:09:42PM +0800, Peter Xu wrote:
> On Mon, Feb 25, 2019 at 05:58:37PM +0200, Mike Rapoport wrote:
> > On Tue, Feb 12, 2019 at 10:56:16AM +0800, Peter Xu wrote:
> > > From: Andrea Arcangeli <aarcange@redhat.com>
> > > 
> > > This allows UFFDIO_COPY to map pages wrprotected.
> >                                        write protected please :)
> 
> Sure!
> 
> > > 
> > > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > > Signed-off-by: Peter Xu <peterx@redhat.com>
> > 
> > Except for two additional nits below
> > 
> > Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
> > 
> > > ---
> > >  fs/userfaultfd.c                 |  5 +++--
> > >  include/linux/userfaultfd_k.h    |  2 +-
> > >  include/uapi/linux/userfaultfd.h | 11 +++++-----
> > >  mm/userfaultfd.c                 | 36 ++++++++++++++++++++++----------
> > >  4 files changed, 35 insertions(+), 19 deletions(-)
> > > 
> > > diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> > > index b397bc3b954d..3092885c9d2c 100644
> > > --- a/fs/userfaultfd.c
> > > +++ b/fs/userfaultfd.c
> > > @@ -1683,11 +1683,12 @@ static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
> > >  	ret = -EINVAL;
> > >  	if (uffdio_copy.src + uffdio_copy.len <= uffdio_copy.src)
> > >  		goto out;
> > > -	if (uffdio_copy.mode & ~UFFDIO_COPY_MODE_DONTWAKE)
> > > +	if (uffdio_copy.mode & ~(UFFDIO_COPY_MODE_DONTWAKE|UFFDIO_COPY_MODE_WP))
> > >  		goto out;
> > >  	if (mmget_not_zero(ctx->mm)) {
> > >  		ret = mcopy_atomic(ctx->mm, uffdio_copy.dst, uffdio_copy.src,
> > > -				   uffdio_copy.len, &ctx->mmap_changing);
> > > +				   uffdio_copy.len, &ctx->mmap_changing,
> > > +				   uffdio_copy.mode);
> > >  		mmput(ctx->mm);
> > >  	} else {
> > >  		return -ESRCH;
> > > diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
> > > index c6590c58ce28..765ce884cec0 100644
> > > --- a/include/linux/userfaultfd_k.h
> > > +++ b/include/linux/userfaultfd_k.h
> > > @@ -34,7 +34,7 @@ extern vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason);
> > > 
> > >  extern ssize_t mcopy_atomic(struct mm_struct *dst_mm, unsigned long dst_start,
> > >  			    unsigned long src_start, unsigned long len,
> > > -			    bool *mmap_changing);
> > > +			    bool *mmap_changing, __u64 mode);
> > >  extern ssize_t mfill_zeropage(struct mm_struct *dst_mm,
> > >  			      unsigned long dst_start,
> > >  			      unsigned long len,
> > > diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
> > > index 48f1a7c2f1f0..297cb044c03f 100644
> > > --- a/include/uapi/linux/userfaultfd.h
> > > +++ b/include/uapi/linux/userfaultfd.h
> > > @@ -203,13 +203,14 @@ struct uffdio_copy {
> > >  	__u64 dst;
> > >  	__u64 src;
> > >  	__u64 len;
> > > +#define UFFDIO_COPY_MODE_DONTWAKE		((__u64)1<<0)
> > >  	/*
> > > -	 * There will be a wrprotection flag later that allows to map
> > > -	 * pages wrprotected on the fly. And such a flag will be
> > > -	 * available if the wrprotection ioctl are implemented for the
> > > -	 * range according to the uffdio_register.ioctls.
> > > +	 * UFFDIO_COPY_MODE_WP will map the page wrprotected on the
> > > +	 * fly. UFFDIO_COPY_MODE_WP is available only if the
> > > +	 * wrprotection ioctl are implemented for the range according
> > 
> >                              ^ is
> 
> Will fix.
> 
> > 
> > > +	 * to the uffdio_register.ioctls.
> > >  	 */
> > > -#define UFFDIO_COPY_MODE_DONTWAKE		((__u64)1<<0)
> > > +#define UFFDIO_COPY_MODE_WP			((__u64)1<<1)
> > >  	__u64 mode;
> > > 
> > >  	/*
> > > diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> > > index d59b5a73dfb3..73a208c5c1e7 100644
> > > --- a/mm/userfaultfd.c
> > > +++ b/mm/userfaultfd.c
> > > @@ -25,7 +25,8 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
> > >  			    struct vm_area_struct *dst_vma,
> > >  			    unsigned long dst_addr,
> > >  			    unsigned long src_addr,
> > > -			    struct page **pagep)
> > > +			    struct page **pagep,
> > > +			    bool wp_copy)
> > >  {
> > >  	struct mem_cgroup *memcg;
> > >  	pte_t _dst_pte, *dst_pte;
> > > @@ -71,9 +72,9 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
> > >  	if (mem_cgroup_try_charge(page, dst_mm, GFP_KERNEL, &memcg, false))
> > >  		goto out_release;
> > > 
> > > -	_dst_pte = mk_pte(page, dst_vma->vm_page_prot);
> > > -	if (dst_vma->vm_flags & VM_WRITE)
> > > -		_dst_pte = pte_mkwrite(pte_mkdirty(_dst_pte));
> > > +	_dst_pte = pte_mkdirty(mk_pte(page, dst_vma->vm_page_prot));
> > > +	if (dst_vma->vm_flags & VM_WRITE && !wp_copy)
> > > +		_dst_pte = pte_mkwrite(_dst_pte);
> > > 
> > >  	dst_pte = pte_offset_map_lock(dst_mm, dst_pmd, dst_addr, &ptl);
> > >  	if (dst_vma->vm_file) {
> > > @@ -399,7 +400,8 @@ static __always_inline ssize_t mfill_atomic_pte(struct mm_struct *dst_mm,
> > >  						unsigned long dst_addr,
> > >  						unsigned long src_addr,
> > >  						struct page **page,
> > > -						bool zeropage)
> > > +						bool zeropage,
> > > +						bool wp_copy)
> > >  {
> > >  	ssize_t err;
> > > 
> > > @@ -416,11 +418,13 @@ static __always_inline ssize_t mfill_atomic_pte(struct mm_struct *dst_mm,
> > >  	if (!(dst_vma->vm_flags & VM_SHARED)) {
> > >  		if (!zeropage)
> > >  			err = mcopy_atomic_pte(dst_mm, dst_pmd, dst_vma,
> > > -					       dst_addr, src_addr, page);
> > > +					       dst_addr, src_addr, page,
> > > +					       wp_copy);
> > >  		else
> > >  			err = mfill_zeropage_pte(dst_mm, dst_pmd,
> > >  						 dst_vma, dst_addr);
> > >  	} else {
> > > +		VM_WARN_ON(wp_copy); /* WP only available for anon */
> > >  		if (!zeropage)
> > >  			err = shmem_mcopy_atomic_pte(dst_mm, dst_pmd,
> > >  						     dst_vma, dst_addr,
> > > @@ -438,7 +442,8 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
> > >  					      unsigned long src_start,
> > >  					      unsigned long len,
> > >  					      bool zeropage,
> > > -					      bool *mmap_changing)
> > > +					      bool *mmap_changing,
> > > +					      __u64 mode)
> > >  {
> > >  	struct vm_area_struct *dst_vma;
> > >  	ssize_t err;
> > > @@ -446,6 +451,7 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
> > >  	unsigned long src_addr, dst_addr;
> > >  	long copied;
> > >  	struct page *page;
> > > +	bool wp_copy;
> > > 
> > >  	/*>  	 * Sanitize the command parameters:
> > > @@ -502,6 +508,14 @@ static __always_inline ssize_t __mcopy_atomic(struct mm_struct *dst_mm,
> > >  	    dst_vma->vm_flags & VM_SHARED))
> > >  		goto out_unlock;
> > > 
> > > +	/*
> > > +	 * validate 'mode' now that we know the dst_vma: don't allow
> > > +	 * a wrprotect copy if the userfaultfd didn't register as WP.
> > > +	 */
> > > +	wp_copy = mode & UFFDIO_COPY_MODE_WP;
> > > +	if (wp_copy && !(dst_vma->vm_flags & VM_UFFD_WP))
> > > +		goto out_unlock;
> 
> [1]
> 
> > > +
> > >  	/*
> > >  	 * If this is a HUGETLB vma, pass off to appropriate routine
> > >  	 */
> > 
> > I think for hugetlb we should return an error if wp_copy==true.
> > It might be worth adding wp_copy parameter to __mcopy_atomic_hugetlb() in
> > advance and return the error from there, in a hope it will also support
> > UFFD_WP some day :)
> 
> Now we should have failed even earlier if someone wants to register a
> hugetlbfs VMA with UFFD_WP because now vma_can_userfault() only allows
> anonymous memory for it:
> 
> static inline bool vma_can_userfault(struct vm_area_struct *vma,
> 				     unsigned long vm_flags)
> {
> 	/* FIXME: add WP support to hugetlbfs and shmem */
> 	return vma_is_anonymous(vma) ||
> 		((is_vm_hugetlb_page(vma) || vma_is_shmem(vma)) &&
> 		 !(vm_flags & VM_UFFD_WP));
> }
> 
> And, as long as a VMA is not tagged with UFFD_WP, the page copy will
> fail with -EINVAL directly above at [1] when setting the wp_copy flag.
> So IMHO we should have already covered the case.
> 
> Considering these, I would think we could simply postpone the changes
> to __mcopy_atomic_hugetlb() until adding hugetlbfs support on uffd-wp.
> Mike, what do you think?

Ok, fair enough.
 
> Thanks!
> 
> -- 
> Peter Xu
> 

-- 
Sincerely yours,
Mike.

