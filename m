Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A1C4C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 06:30:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D331F2147C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 06:30:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D331F2147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66EF18E0003; Tue, 26 Feb 2019 01:30:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61D898E0002; Tue, 26 Feb 2019 01:30:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E4708E0003; Tue, 26 Feb 2019 01:30:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2363B8E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 01:30:36 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id q193so9549697qke.12
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 22:30:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2z5nVHvBBjWuxGW4I+IHCdAoPrPixV0wY+YT+IdyC+s=;
        b=RzD8SrxGY1iPyJdmXqgfG37Hn+KnmAWCR6kRGtROI/PFCR9ycEljybzHJpxrA/yjBJ
         5r7nTpEPoboiM5V4GIGBxzG8EmjhKiD3akU0GOhYHuJo9rIPB/fe98X/hM6g8cUO6uQw
         beKCR1BIfh3E7+aaLGtrLoySJ3OfWv1qfmO3zdHrHlBcfDEZAYnI3ce8sftIVgT6mYl+
         yyO32fwXaB13+7qb/vvUNg/kleRCZnvzhvvEOKr1ZyTwTakWbY47luFdvXwORk6DCBxk
         xCAUrWySggHOPaRze1PYOJswSI5vW14cQdnqLOlib6O72pmcH+6oGIrNC9NBM6Qt/dYD
         VEuw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZjtBZQjotspuKEQ4KFgpxbIyrzARa7adEsAZoP+KpqYWhh/xOX
	ZGSLJ4i54Rei7OIzDOZw/+8SxBKxBXRmY82DB3I/zQKL3TwCPmqQfZLYIW4DwqJNGXT0wZdoIzd
	/tYNGn77Q416LGM9uo1qB3PZ1ZMl10ebDUSSL/biqt9JdE6XJkTinB9vDCMaIePZLYQ==
X-Received: by 2002:a37:b386:: with SMTP id c128mr15283173qkf.171.1551162635813;
        Mon, 25 Feb 2019 22:30:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib4Fh941vVwZyXI8yYBsw2/nPEOb5VzqgwprGvCPMffaaqr1c2cHEYCW1tOE0Y/7jUMxzXl
X-Received: by 2002:a37:b386:: with SMTP id c128mr15283149qkf.171.1551162634954;
        Mon, 25 Feb 2019 22:30:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551162634; cv=none;
        d=google.com; s=arc-20160816;
        b=Rl1wyjM7E5m5QSOjb/9NiE5PVZ105j50OqTrPBHd05Ex1BHfyhzLtKa6NeK3OVgagb
         XZrBO/NS3xjuZdgh9tysHT5mZh6hDz13Uo0lt2wIDtFUqSeXsoDQL0DzWKdgwdA8BKsU
         3x0XbtenQj+DsG58IyvZrNtJAxMVjWTA7C/dzsqUbMYszcmXnb2bb6Gj589It71HYngh
         +x6Qihsgu8SkwEOdk6wCMAdcqey7SKzQVs+iIeXz0iDZakRYkCqW/z1ZX4D08P3za68k
         Mf9SSr+VaDOndVCxRw+D5bqTt4/qt/zHslE/fkBuNeEHTWn/VTbbgYAWuD8yvgwPMA2C
         H1RA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=2z5nVHvBBjWuxGW4I+IHCdAoPrPixV0wY+YT+IdyC+s=;
        b=R3BzGM01bxwcp+AmsdoNk0e50vFuMwoH9outdyLT4REFMWIag5gxfQskIaFrPfa3KN
         FtCQcE8dRFWZF3izHNieHq3l8rxo9AM6ewsPP+yWtERbj8sQ7wic1mAQDEJy37KPV+bM
         VZKYmDL4CaqYfnq6whnh6/X0P6jnUjvYNHxg0nQS9s8hsMEkm3GhtxAFsZbOQMm1huEr
         Pb53WkSaV36jGkEFLEcSlrIrYai8n6u0/636Xyt+N6YbL96ofw4s6E6JNczWnZq1ZNi9
         y6VWv8mI+Q0JpNg+kneAX3bNBpWUFKeHJRacfPZsxN91X58v+v1dD30gpdD40lN8BEKv
         K5fA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t14si67954qvm.157.2019.02.25.22.30.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 22:30:34 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C49BAC049D49;
	Tue, 26 Feb 2019 06:30:33 +0000 (UTC)
Received: from xz-x1 (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5042C5C21E;
	Tue, 26 Feb 2019 06:30:24 +0000 (UTC)
Date: Tue, 26 Feb 2019 14:30:21 +0800
From: Peter Xu <peterx@redhat.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
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
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 21/26] userfaultfd: wp: add the writeprotect API to
 userfaultfd ioctl
Message-ID: <20190226063021.GI13653@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-22-peterx@redhat.com>
 <20190225210350.GD10454@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190225210350.GD10454@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Tue, 26 Feb 2019 06:30:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2019 at 11:03:51PM +0200, Mike Rapoport wrote:
> On Tue, Feb 12, 2019 at 10:56:27AM +0800, Peter Xu wrote:
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > v1: From: Shaohua Li <shli@fb.com>
> > 
> > v2: cleanups, remove a branch.
> > 
> > [peterx writes up the commit message, as below...]
> > 
> > This patch introduces the new uffd-wp APIs for userspace.
> > 
> > Firstly, we'll allow to do UFFDIO_REGISTER with write protection
> > tracking using the new UFFDIO_REGISTER_MODE_WP flag.  Note that this
> > flag can co-exist with the existing UFFDIO_REGISTER_MODE_MISSING, in
> > which case the userspace program can not only resolve missing page
> > faults, and at the same time tracking page data changes along the way.
> > 
> > Secondly, we introduced the new UFFDIO_WRITEPROTECT API to do page
> > level write protection tracking.  Note that we will need to register
> > the memory region with UFFDIO_REGISTER_MODE_WP before that.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > [peterx: remove useless block, write commit message, check against
> >  VM_MAYWRITE rather than VM_WRITE when register]
> > Signed-off-by: Peter Xu <peterx@redhat.com>
> > ---
> >  fs/userfaultfd.c                 | 82 +++++++++++++++++++++++++-------
> >  include/uapi/linux/userfaultfd.h | 11 +++++
> >  2 files changed, 77 insertions(+), 16 deletions(-)
> > 
> > diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> > index 3092885c9d2c..81962d62520c 100644
> > --- a/fs/userfaultfd.c
> > +++ b/fs/userfaultfd.c
> > @@ -304,8 +304,11 @@ static inline bool userfaultfd_must_wait(struct userfaultfd_ctx *ctx,
> >  	if (!pmd_present(_pmd))
> >  		goto out;
> > 
> > -	if (pmd_trans_huge(_pmd))
> > +	if (pmd_trans_huge(_pmd)) {
> > +		if (!pmd_write(_pmd) && (reason & VM_UFFD_WP))
> > +			ret = true;
> >  		goto out;
> > +	}
> > 
> >  	/*
> >  	 * the pmd is stable (as in !pmd_trans_unstable) so we can re-read it
> > @@ -318,6 +321,8 @@ static inline bool userfaultfd_must_wait(struct userfaultfd_ctx *ctx,
> >  	 */
> >  	if (pte_none(*pte))
> >  		ret = true;
> > +	if (!pte_write(*pte) && (reason & VM_UFFD_WP))
> > +		ret = true;
> >  	pte_unmap(pte);
> > 
> >  out:
> > @@ -1251,10 +1256,13 @@ static __always_inline int validate_range(struct mm_struct *mm,
> >  	return 0;
> >  }
> > 
> > -static inline bool vma_can_userfault(struct vm_area_struct *vma)
> > +static inline bool vma_can_userfault(struct vm_area_struct *vma,
> > +				     unsigned long vm_flags)
> >  {
> > -	return vma_is_anonymous(vma) || is_vm_hugetlb_page(vma) ||
> > -		vma_is_shmem(vma);
> > +	/* FIXME: add WP support to hugetlbfs and shmem */
> > +	return vma_is_anonymous(vma) ||
> > +		((is_vm_hugetlb_page(vma) || vma_is_shmem(vma)) &&
> > +		 !(vm_flags & VM_UFFD_WP));
> >  }
> > 
> >  static int userfaultfd_register(struct userfaultfd_ctx *ctx,
> > @@ -1286,15 +1294,8 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
> >  	vm_flags = 0;
> >  	if (uffdio_register.mode & UFFDIO_REGISTER_MODE_MISSING)
> >  		vm_flags |= VM_UFFD_MISSING;
> > -	if (uffdio_register.mode & UFFDIO_REGISTER_MODE_WP) {
> > +	if (uffdio_register.mode & UFFDIO_REGISTER_MODE_WP)
> >  		vm_flags |= VM_UFFD_WP;
> > -		/*
> > -		 * FIXME: remove the below error constraint by
> > -		 * implementing the wprotect tracking mode.
> > -		 */
> > -		ret = -EINVAL;
> > -		goto out;
> > -	}
> > 
> >  	ret = validate_range(mm, uffdio_register.range.start,
> >  			     uffdio_register.range.len);
> > @@ -1342,7 +1343,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
> > 
> >  		/* check not compatible vmas */
> >  		ret = -EINVAL;
> > -		if (!vma_can_userfault(cur))
> > +		if (!vma_can_userfault(cur, vm_flags))
> >  			goto out_unlock;
> > 
> >  		/*
> > @@ -1370,6 +1371,8 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
> >  			if (end & (vma_hpagesize - 1))
> >  				goto out_unlock;
> >  		}
> > +		if ((vm_flags & VM_UFFD_WP) && !(cur->vm_flags & VM_MAYWRITE))
> > +			goto out_unlock;
> > 
> >  		/*
> >  		 * Check that this vma isn't already owned by a
> > @@ -1399,7 +1402,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
> >  	do {
> >  		cond_resched();
> > 
> > -		BUG_ON(!vma_can_userfault(vma));
> > +		BUG_ON(!vma_can_userfault(vma, vm_flags));
> >  		BUG_ON(vma->vm_userfaultfd_ctx.ctx &&
> >  		       vma->vm_userfaultfd_ctx.ctx != ctx);
> >  		WARN_ON(!(vma->vm_flags & VM_MAYWRITE));
> > @@ -1534,7 +1537,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
> >  		 * provides for more strict behavior to notice
> >  		 * unregistration errors.
> >  		 */
> > -		if (!vma_can_userfault(cur))
> > +		if (!vma_can_userfault(cur, cur->vm_flags))
> >  			goto out_unlock;
> > 
> >  		found = true;
> > @@ -1548,7 +1551,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
> >  	do {
> >  		cond_resched();
> > 
> > -		BUG_ON(!vma_can_userfault(vma));
> > +		BUG_ON(!vma_can_userfault(vma, vma->vm_flags));
> > 
> >  		/*
> >  		 * Nothing to do: this vma is already registered into this
> > @@ -1761,6 +1764,50 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
> >  	return ret;
> >  }
> > 
> > +static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
> > +				    unsigned long arg)
> > +{
> > +	int ret;
> > +	struct uffdio_writeprotect uffdio_wp;
> > +	struct uffdio_writeprotect __user *user_uffdio_wp;
> > +	struct userfaultfd_wake_range range;
> > +
> > +	if (READ_ONCE(ctx->mmap_changing))
> > +		return -EAGAIN;
> > +
> > +	user_uffdio_wp = (struct uffdio_writeprotect __user *) arg;
> > +
> > +	if (copy_from_user(&uffdio_wp, user_uffdio_wp,
> > +			   sizeof(struct uffdio_writeprotect)))
> > +		return -EFAULT;
> > +
> > +	ret = validate_range(ctx->mm, uffdio_wp.range.start,
> > +			     uffdio_wp.range.len);
> > +	if (ret)
> > +		return ret;
> > +
> > +	if (uffdio_wp.mode & ~(UFFDIO_WRITEPROTECT_MODE_DONTWAKE |
> > +			       UFFDIO_WRITEPROTECT_MODE_WP))
> > +		return -EINVAL;
> > +	if ((uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP) &&
> > +	     (uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE))
> > +		return -EINVAL;
> 
> Why _DONTWAKE cannot be used when setting write-protection?
> I can imagine a use-case when you'd want to freeze an application,
> write-protect several regions and then let the application continue.

This is the same question as the one in the other thread, which I've
had a longer reply there, hope it could be a bit clearer (sorry for
the confusion no matter what!).  I would be more than glad to know if
there could be any smarter way to define/renaming/... the flags.

Thanks!

-- 
Peter Xu

