Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C94AC00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:24:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C87E620700
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:24:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C87E620700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60E748E0094; Thu, 21 Feb 2019 13:24:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 595A08E0002; Thu, 21 Feb 2019 13:24:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45E278E0094; Thu, 21 Feb 2019 13:24:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 15C1E8E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 13:24:11 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id o34so27064104qtf.19
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 10:24:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=tyoDOqsf25UeRldQQlfwxQXDrPQ135adDg11AnskF6g=;
        b=eCvi8yeGCJ9lvjpNvHK4ALWxz8Y8rnj6mtyM1BNUrN5+XuTxd9QkIYe5NKmCE/ksln
         hdfOkh6OpsHJQyYi1Ot3lRqHyAv2PfT0W6CQGvhSpCVE7x5aOnaGiTTNA48MUfOzYBaH
         Ax/5AyK3CAXcsaJeBO5U1JoxgkTWLrKOH/FFesTF27CEy3gzgmCWGURr7axWj5EdfWnF
         IDcRTB3ZlQTyBtx7ntgVGeRwokarMzCfWP2hzUrC/VnsVUhJfPm17DXFeE0+Bh99Ct8j
         dVvGB92TkolxVZSU2YdCzmWrH2olLK1uiaG5AGQAbFV9wSUN0FMGazA3OPost4fYB8U2
         cJbw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuY9pdL5uxkkpmXZNgOqLSaTRYBQAulrMajLt7PcsAdmZ7abvpKV
	QoBcVWI52m+3/d4JlgXMnp9nCJ2ugrnRvfTY2h7v5Mmj8bzZBl/0EnddieAPNGqBeHJYwM4FH0p
	gAjhKgm1nG1+yZS3JecBXVl2VIr8ionHuqqB0n2DA+Du3BoMZkZtCBI3Wc7uQN/auog==
X-Received: by 2002:a37:8f02:: with SMTP id r2mr30193583qkd.246.1550773450847;
        Thu, 21 Feb 2019 10:24:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia720rDO9os3k8hXxUNgEJDvx+ZLqEiI3gpRInJj19GNSwMvhzazLWnrnc8DMb9SW4BlZrx
X-Received: by 2002:a37:8f02:: with SMTP id r2mr30193542qkd.246.1550773450044;
        Thu, 21 Feb 2019 10:24:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550773450; cv=none;
        d=google.com; s=arc-20160816;
        b=Dr9SNOTs9NUlXqVNyEFhggBjY3iJXE79C59F/iAk5DT0C3uD4UiP2uqf0JtcVUuJZr
         oDaZRDrIOLl36I5IDcL68ilJ4iD+3DCEW1grqj+B0hQnvEiYUk5E09IS+85av115X45Z
         k3OuEN1W0PwpFOMTIn6tEYKnxoNk8w23FCHk/ytHpm2sTT99y3b2dWLxyVXmqSsDnN6I
         VAraxxZAvCGpan4SoN29NM4W+MvWJ8F2iP2WGMGoQbuTD6JesSW9mU0wkvrXotlO2K/f
         F5/6INZ4YWDU5vLTBfHHSgkEU2fGOPfelKRz2g9Nid14KoRCAZdb7QPBmvBsJfSyY+7G
         L/8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=tyoDOqsf25UeRldQQlfwxQXDrPQ135adDg11AnskF6g=;
        b=bGGIWmwfvr57qgMSCBBS8dQskkOb2UL2r5J5dkjHnMomCt3eH5kONq0skKgQYEwSBu
         t4TfcPrNs33EqQXQ+QueLJWXxgNsZfkVp+vmsabq+eAqG8eUBzxSC0PVCvwStOuq5Uwq
         jHOmR2qTam9QBMxeJO42d8Qn8sjRdTpVdK5e0cnpd6ypG9GT+ZNLo92c0gtD36L1bmJb
         MFndMs9DjACMJ82OIRprBztx7XF9ozHn+gIQo4fYQmlSNEw1/Dzu5bv094iYftbq+OKW
         9nj42uFJ1s5XSo4D2e5eX2Z8JbVlNDsTrTWy99Z3uvap+/vN2XzTMX2dkvTiiYuvhZ5r
         muBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f44si1269189qta.142.2019.02.21.10.24.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 10:24:10 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1464E5945C;
	Thu, 21 Feb 2019 18:24:09 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 15F5C60C80;
	Thu, 21 Feb 2019 18:24:01 +0000 (UTC)
Date: Thu, 21 Feb 2019 13:23:59 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH v2 20/26] userfaultfd: wp: support write protection for
 userfault vma range
Message-ID: <20190221182359.GT2813@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-21-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190212025632.28946-21-peterx@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 21 Feb 2019 18:24:09 +0000 (UTC)
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

I have a question see below but anyway:

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

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

Don't you want to distinguish between no VMA ie ENOENT and vma that
can not be write protected (VM_SHARED, not userfaultfd, not anonymous) ?

