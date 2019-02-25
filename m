Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33819C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:52:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E011220C01
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:52:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E011220C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 782A38E000D; Mon, 25 Feb 2019 15:52:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70ADA8E000C; Mon, 25 Feb 2019 15:52:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 584CC8E000D; Mon, 25 Feb 2019 15:52:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 134A88E000C
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 15:52:52 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id o7so8606581pfi.23
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 12:52:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=DGKFPYI0bzXsd2m0ZTP4ppeZCt9rc3k6wsJd17A/5+g=;
        b=a0n+XB9nS0anvLwNoi48CFo/CaWFeLAmH+tD37kXZRuJLDSk+XREj/lW9QaosgBGKp
         7Pb6Uah0v/rPlzo6bDfc/NsgD99J/7ztwpXn7UaYldSthVrrVMoWMaOFekSF2GlB7jMj
         dyg+aP+qGfXG274iQRUz9dVq5urf47z+xOvbAN2fSpfueaoLsTMwF3HTU9p72+kA/xTe
         +CLpkW97o7WM3erAXmVabeU7MyWIItMC3CbA0hzMAU/HNo22VsGApPrVof4w0icLPh9w
         wtCiWqzNOQROKcuRP1kcOMADDv/le5DW8A1OPwEGcnAEmbIaBKvIvX9mOhzo1HQ3n2HU
         WKpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubfkuzZynvpyJ0ylmhtqpUTFzfqbrrURInmuCaUAbaaDtmQEkvF
	+LkK0z4N2uWn336ETkAUYYEa6ZpUjDyLOmTD0nFBlbEEhmMnl1dPlc4j6rRUs0PXD+HAU1e84CF
	QqkjuejwTCfq/6FwNzcqIUamWifmxMrNVrkyZa6JZTHt1pKvhaSNgZ0JvhybxN97NYA==
X-Received: by 2002:aa7:8059:: with SMTP id y25mr21927120pfm.74.1551127971700;
        Mon, 25 Feb 2019 12:52:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ9MmLCbordxLToR50hOiohpYBC7t4C6wDbd1fM1wGgj9b4/3KjQEULqIOwVgxo68rxY574
X-Received: by 2002:aa7:8059:: with SMTP id y25mr21927064pfm.74.1551127970916;
        Mon, 25 Feb 2019 12:52:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551127970; cv=none;
        d=google.com; s=arc-20160816;
        b=i+cve7/whiF1xwvGn2bzn92THUuMPe1UlznMExAG1IHQYVply2mBaH4LpMVsMwRksp
         lDaEmOap0iwa330D80CvWbmZGt1qkksptoAW8yYf6XOq2VXpYIMeS0+eybt5F0vYzEby
         Dd8myPJwptN/FBs6xSsBln8DuOFDVKd3LOeXBTldLz1dOSrrLVfaa+6HFu+k0qJI28eE
         D6gAELSrKTo7907Pg/++WKgLbUM6F6aEzh0oRez5JA7XQBVvK7khjysPV9H9tMC9RbsV
         MdgnzWgEqhhDEtVb1GqgW0BwqJ7+1UJ3zvjVhqKYb6lM136VZB/K5NkgeLzcgA/Mnl0+
         P13g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=DGKFPYI0bzXsd2m0ZTP4ppeZCt9rc3k6wsJd17A/5+g=;
        b=lz/TnLg6cqaF3APeVoXT/7yhzFA4VCk9g9difqEEhldNvrEaJb7CjV3BHbdhTmxmbX
         ymzhlrcoeYjXyOnlUbgBw+NMHEVEX76CgLVmtgBwP6XOVDzsb37APWPlwbux0q+ei9ke
         mxtOthwT152aSUuHFbQApN4TAZZVl6u1KFYXfbG6Hl+C3zZ2HILFVO354OUfk9ZkrxAQ
         IfMMiEOzi76AT8cbEN9J2bm/VUOhD5IQaCi7pH4Himp0/nQJiFo2KGqCTrYCaH+08lhk
         RTuRxAKIRSs885+cOHZ+6+KLQZIZshpvtlu/Z/yOGHiXC8Hp6SKkZmIWhWXreMrr8qQc
         iImg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t11si4965821plq.264.2019.02.25.12.52.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 12:52:50 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1PKiA92140040
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 15:52:50 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qvnamy8as-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 15:52:49 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 25 Feb 2019 20:52:47 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 25 Feb 2019 20:52:41 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1PKqeR561276406
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 25 Feb 2019 20:52:40 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2EBB2A4040;
	Mon, 25 Feb 2019 20:52:40 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 12FBCA4051;
	Mon, 25 Feb 2019 20:52:37 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.243])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 25 Feb 2019 20:52:36 +0000 (GMT)
Date: Mon, 25 Feb 2019 22:52:34 +0200
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
        "Dr . David Alan Gilbert" <dgilbert@redhat.com>,
        Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH v2 20/26] userfaultfd: wp: support write protection for
 userfault vma range
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-21-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212025632.28946-21-peterx@redhat.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022520-0008-0000-0000-000002C4CB5D
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022520-0009-0000-0000-00002231122F
Message-Id: <20190225205233.GC10454@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-25_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902250149
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:26AM +0800, Peter Xu wrote:
> From: Shaohua Li <shli@fb.com>
> 
> Add API to enable/disable writeprotect a vma range. Unlike mprotect,
> this doesn't split/merge vmas.
> 
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Shaohua Li <shli@fb.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> [peterx:
>  - use the helper to find VMA;
>  - return -ENOENT if not found to match mcopy case;
>  - use the new MM_CP_UFFD_WP* flags for change_protection
>  - check against mmap_changing for failures]
> Signed-off-by: Peter Xu <peterx@redhat.com>
> ---
>  include/linux/userfaultfd_k.h |  3 ++
>  mm/userfaultfd.c              | 54 +++++++++++++++++++++++++++++++++++
>  2 files changed, 57 insertions(+)
> 
> diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
> index 765ce884cec0..8f6e6ed544fb 100644
> --- a/include/linux/userfaultfd_k.h
> +++ b/include/linux/userfaultfd_k.h
> @@ -39,6 +39,9 @@ extern ssize_t mfill_zeropage(struct mm_struct *dst_mm,
>  			      unsigned long dst_start,
>  			      unsigned long len,
>  			      bool *mmap_changing);
> +extern int mwriteprotect_range(struct mm_struct *dst_mm,
> +			       unsigned long start, unsigned long len,
> +			       bool enable_wp, bool *mmap_changing);
> 
>  /* mm helpers */
>  static inline bool is_mergeable_vm_userfaultfd_ctx(struct vm_area_struct *vma,
> diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> index fefa81c301b7..529d180bb4d7 100644
> --- a/mm/userfaultfd.c
> +++ b/mm/userfaultfd.c
> @@ -639,3 +639,57 @@ ssize_t mfill_zeropage(struct mm_struct *dst_mm, unsigned long start,
>  {
>  	return __mcopy_atomic(dst_mm, start, 0, len, true, mmap_changing, 0);
>  }
> +
> +int mwriteprotect_range(struct mm_struct *dst_mm, unsigned long start,
> +			unsigned long len, bool enable_wp, bool *mmap_changing)
> +{
> +	struct vm_area_struct *dst_vma;
> +	pgprot_t newprot;
> +	int err;
> +
> +	/*
> +	 * Sanitize the command parameters:
> +	 */
> +	BUG_ON(start & ~PAGE_MASK);
> +	BUG_ON(len & ~PAGE_MASK);
> +
> +	/* Does the address range wrap, or is the span zero-sized? */
> +	BUG_ON(start + len <= start);

I'd replace these BUG_ON()s with

	if (WARN_ON())
		 return -EINVAL;

> +
> +	down_read(&dst_mm->mmap_sem);
> +
> +	/*
> +	 * If memory mappings are changing because of non-cooperative
> +	 * operation (e.g. mremap) running in parallel, bail out and
> +	 * request the user to retry later
> +	 */
> +	err = -EAGAIN;
> +	if (mmap_changing && READ_ONCE(*mmap_changing))
> +		goto out_unlock;
> +
> +	err = -ENOENT;
> +	dst_vma = vma_find_uffd(dst_mm, start, len);
> +	/*
> +	 * Make sure the vma is not shared, that the dst range is
> +	 * both valid and fully within a single existing vma.
> +	 */
> +	if (!dst_vma || (dst_vma->vm_flags & VM_SHARED))
> +		goto out_unlock;
> +	if (!userfaultfd_wp(dst_vma))
> +		goto out_unlock;
> +	if (!vma_is_anonymous(dst_vma))
> +		goto out_unlock;
> +
> +	if (enable_wp)
> +		newprot = vm_get_page_prot(dst_vma->vm_flags & ~(VM_WRITE));
> +	else
> +		newprot = vm_get_page_prot(dst_vma->vm_flags);
> +
> +	change_protection(dst_vma, start, start + len, newprot,
> +			  enable_wp ? MM_CP_UFFD_WP : MM_CP_UFFD_WP_RESOLVE);
> +
> +	err = 0;
> +out_unlock:
> +	up_read(&dst_mm->mmap_sem);
> +	return err;
> +}
> -- 
> 2.17.1
> 

-- 
Sincerely yours,
Mike.

