Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27282C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 08:16:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D75412084D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 08:16:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D75412084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BFC18E0175; Mon, 25 Feb 2019 03:16:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76F528E016A; Mon, 25 Feb 2019 03:16:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 685A48E0175; Mon, 25 Feb 2019 03:16:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4408E016A
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 03:16:17 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id q81so7187687qkl.20
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 00:16:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=2DFpiiZvk4QPeSeg+bzkbHemWDBFpxrCNPsOIlJW6Xw=;
        b=Yxbf6J52srFMZ4MBHFluO00Du5Oyga5E/dzREYSVjh9E2kmHBeK2xhDhf98fxqh3MD
         RDGs90LEr38QMcBd1b5zwYQxHB6O9Y9XkFTETE6la8/cmQtvuCSJSexVgBcYPnbfhKVN
         0C7DcyqBmGVoQO8oobBb+l+mLzdWpaLWzd5wzEn3j8PfhEFNIEnM4xzHYmUR8KIX8gto
         LfKWRv9DDdhc20jDTNhSzegoLoY4dFPOOxL2Vj4Mz2vbjWLSf1LGNcDCRovzt9+UWZH+
         MhhIqi7RBnDVajuOS7tYOnfpReSWVpp0MdLdfWsSZpoXhh+wMVr7KSmYSi+SSgWqn5mB
         ZiHw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAua6X2c+vLgw8vdO7/igFu+WEkx61QQbwR4b1bv1jVt+lnKYGprF
	UPXQY93Mq8SY69JyCIoEMX67mDZ5PVyT/ijfWzYmz02T3o5M13JfgqnQ3I4OY17ofxpFVsqewrJ
	QlpKcxbY+ZEiN4P6ejkdD03X8TcAPAAp7m+mWZpVLqH68yqHM5HkCPzQyHmHDKJ0r7A==
X-Received: by 2002:a37:a42:: with SMTP id 63mr11891569qkk.269.1551082576978;
        Mon, 25 Feb 2019 00:16:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ7XKv685GZ0IThRo5mcnaeEMaQrbN+Og4NOW7Okk+Fqp/PlAAhBfKafYcBON0wsDBoW78Z
X-Received: by 2002:a37:a42:: with SMTP id 63mr11891539qkk.269.1551082576320;
        Mon, 25 Feb 2019 00:16:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551082576; cv=none;
        d=google.com; s=arc-20160816;
        b=dh2ONz+cJ5tDitczSIUUyM0jf04tK01mvBrBrCsYTypztigOzoo+SAg98UOO9Oc7Ea
         FmopI6kGubd22l2xhEAepIdRRAJhBSvzGXWZLB6dk8kgp2JmpXcgRu57WDQuVa4LUhsE
         5CPjtdurksZRtDTeCwsmN0uzctRuiwc2dI8LC8L9/UowUj1faQGHLljjqxoSHzUzU03P
         y8AbPH/58KauqsrbPiRNjrAONnzEcFBfqfPwMljaxsKtzxfSglfzXjdBopBgVn6wIUFC
         qdL6p3tB92DLZcWvKQ1l9yNJIGp9kAV99WE+meDMllSLSILby0wVeZjXlYyviBnKnXGP
         +ifA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=2DFpiiZvk4QPeSeg+bzkbHemWDBFpxrCNPsOIlJW6Xw=;
        b=skn9BDFEpA+qrAVflrV/LxlbLjZrB0/o3m2hLFWc/W8YPFszF6skcELmZhQ1NGMgu/
         5icZC469uh2EoNoQaVE2M4lij6guU/A3kSVt0+QFtuUbz46dpKc8mbsiK/aeuJz7CQxK
         ifrDbf/NmT+vBUNT1pkConO83cEiIrY7yTn9PNkaEW9rlEEAbHqRyh5VpEy/954DYnPz
         KR9knZAd2eDNaKFktVNZTChujaadQSnfOTPgUJPcZiRN2L05gkxZS/CdAi6/kvY6klpM
         KTltJ7GOUzkJO+yW3mTzEk0F1rJd7yygdqBV4FTO9LjloU6rZmQ7b2woGqSI63nDjoZC
         we8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g7si4729736qve.192.2019.02.25.00.16.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 00:16:16 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D2BEB356F2;
	Mon, 25 Feb 2019 08:16:14 +0000 (UTC)
Received: from xz-x1 (ovpn-12-105.pek2.redhat.com [10.72.12.105])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 840815D9D1;
	Mon, 25 Feb 2019 08:16:03 +0000 (UTC)
Date: Mon, 25 Feb 2019 16:16:00 +0800
From: Peter Xu <peterx@redhat.com>
To: Jerome Glisse <jglisse@redhat.com>
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
Message-ID: <20190225081600.GA13653@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-21-peterx@redhat.com>
 <20190221182359.GT2813@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190221182359.GT2813@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Mon, 25 Feb 2019 08:16:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 01:23:59PM -0500, Jerome Glisse wrote:
> On Tue, Feb 12, 2019 at 10:56:26AM +0800, Peter Xu wrote:
> > From: Shaohua Li <shli@fb.com>
> > 
> > Add API to enable/disable writeprotect a vma range. Unlike mprotect,
> > this doesn't split/merge vmas.
> > 
> > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: Kirill A. Shutemov <kirill@shutemov.name>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: Shaohua Li <shli@fb.com>
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > [peterx:
> >  - use the helper to find VMA;
> >  - return -ENOENT if not found to match mcopy case;
> >  - use the new MM_CP_UFFD_WP* flags for change_protection
> >  - check against mmap_changing for failures]
> > Signed-off-by: Peter Xu <peterx@redhat.com>
> 
> I have a question see below but anyway:
> 
> Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

Thanks!

> 
> > ---
> >  include/linux/userfaultfd_k.h |  3 ++
> >  mm/userfaultfd.c              | 54 +++++++++++++++++++++++++++++++++++
> >  2 files changed, 57 insertions(+)
> > 
> > diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
> > index 765ce884cec0..8f6e6ed544fb 100644
> > --- a/include/linux/userfaultfd_k.h
> > +++ b/include/linux/userfaultfd_k.h
> > @@ -39,6 +39,9 @@ extern ssize_t mfill_zeropage(struct mm_struct *dst_mm,
> >  			      unsigned long dst_start,
> >  			      unsigned long len,
> >  			      bool *mmap_changing);
> > +extern int mwriteprotect_range(struct mm_struct *dst_mm,
> > +			       unsigned long start, unsigned long len,
> > +			       bool enable_wp, bool *mmap_changing);
> >  
> >  /* mm helpers */
> >  static inline bool is_mergeable_vm_userfaultfd_ctx(struct vm_area_struct *vma,
> > diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> > index fefa81c301b7..529d180bb4d7 100644
> > --- a/mm/userfaultfd.c
> > +++ b/mm/userfaultfd.c
> > @@ -639,3 +639,57 @@ ssize_t mfill_zeropage(struct mm_struct *dst_mm, unsigned long start,
> >  {
> >  	return __mcopy_atomic(dst_mm, start, 0, len, true, mmap_changing, 0);
> >  }
> > +
> > +int mwriteprotect_range(struct mm_struct *dst_mm, unsigned long start,
> > +			unsigned long len, bool enable_wp, bool *mmap_changing)
> > +{
> > +	struct vm_area_struct *dst_vma;
> > +	pgprot_t newprot;
> > +	int err;
> > +
> > +	/*
> > +	 * Sanitize the command parameters:
> > +	 */
> > +	BUG_ON(start & ~PAGE_MASK);
> > +	BUG_ON(len & ~PAGE_MASK);
> > +
> > +	/* Does the address range wrap, or is the span zero-sized? */
> > +	BUG_ON(start + len <= start);
> > +
> > +	down_read(&dst_mm->mmap_sem);
> > +
> > +	/*
> > +	 * If memory mappings are changing because of non-cooperative
> > +	 * operation (e.g. mremap) running in parallel, bail out and
> > +	 * request the user to retry later
> > +	 */
> > +	err = -EAGAIN;
> > +	if (mmap_changing && READ_ONCE(*mmap_changing))
> > +		goto out_unlock;
> > +
> > +	err = -ENOENT;
> > +	dst_vma = vma_find_uffd(dst_mm, start, len);
> > +	/*
> > +	 * Make sure the vma is not shared, that the dst range is
> > +	 * both valid and fully within a single existing vma.
> > +	 */
> > +	if (!dst_vma || (dst_vma->vm_flags & VM_SHARED))
> > +		goto out_unlock;
> > +	if (!userfaultfd_wp(dst_vma))
> > +		goto out_unlock;
> > +	if (!vma_is_anonymous(dst_vma))
> > +		goto out_unlock;
> 
> Don't you want to distinguish between no VMA ie ENOENT and vma that
> can not be write protected (VM_SHARED, not userfaultfd, not anonymous) ?

Here we'll return ENOENT for all these errors which is actually trying
to follow existing MISSING codes.  Mike noticed some errno issues
during reviewing the first version and suggested that we'd better
follow the old rules which makes perfect sense to me.  E.g., in
__mcopy_atomic() we'll return ENOENT for either (1) VMA not found, (2)
not UFFD VMA, (3) range check failures.  Checking against anonymous
and VM_SHARED are special for uffd-wp but I'm simply using this same
errno since after all all these errors will stop us from finding a
valid VMA before going anywhere further.

Thanks,

-- 
Peter Xu

