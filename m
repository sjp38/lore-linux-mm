Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAB37C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 06:46:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D9F220842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 06:46:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D9F220842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF8938E0171; Mon, 25 Feb 2019 01:46:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA5058E016E; Mon, 25 Feb 2019 01:46:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C6C9D8E0171; Mon, 25 Feb 2019 01:46:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9C9AC8E016E
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 01:46:01 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id q15so7065806qki.14
        for <linux-mm@kvack.org>; Sun, 24 Feb 2019 22:46:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=SGgl74KwDCNZUxJJfTpLF78nO9GYxxc1iiiQS3g4Llg=;
        b=jyDq1mIYah9V6ZqsLsSI0D3ODCOAz8AETrBTaqGe13RkPY3FYxMRwwdQTDgZji1+dc
         bIy1Akq643YYXppyhWzhBMYNHkwAyBkswMzG8iy/bLOLTVmsOXPC/DeJvdalY/ce67Wb
         ylZiazQ8HznIN6ybRAXf30LGkOvfS5Eum13WTTwXjJUHoJEQC0MiJWIdYHaSLu8SlsMR
         cIhJCewOsFFO5yTYMlLlVazNCVTEpVIhxhY2sH4WeuA4i/8fHDPw2vLGHyTndHMjw3hi
         Xg1ngk2RrQHWukRczgKOUKgJCfXLwLvuUmqkX51mrF0GEDVFFljDMnRVGS02gP4mGNPd
         rwkg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubPw0u+GsoqiFZavty/qQOXA2spxCwivPdpjOI1LYVYCWKj0huy
	Eo7j6Z6Xe9jk2baaiRCf+FVSpiZqaK4hHF2YHr1EfVW2qBQ+Rrx/fac6rZCKMAxq4UPu79MTH8I
	OeU+rQ78sWToK7jTRypNKJebbnkqBj4W6yDs/mA334QgRcuce37foVeRWOYiM9XsCNg==
X-Received: by 2002:a37:4ca:: with SMTP id 193mr11445148qke.21.1551077161302;
        Sun, 24 Feb 2019 22:46:01 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYeWsF8zcPsy8cN9DWdXy031Af3t3fiR4mv4pk3SNLsbKy3Rm7mVtwj+Tt01mFgiAohuK5d
X-Received: by 2002:a37:4ca:: with SMTP id 193mr11445121qke.21.1551077160492;
        Sun, 24 Feb 2019 22:46:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551077160; cv=none;
        d=google.com; s=arc-20160816;
        b=Z+0EUQKdhbs1G4ACcTHDF/6wSKhr8DFc/7+2M+sX03xiy5oUjFRsvAQvin3rhjSpZ0
         lM8ykTJQvyFcGxfivSg9VJLxL+FH/zIOX9UOmKVGL6hMF+Z94x+CDHuWPUON0yKimnoS
         MUYY5Fv6bX1638vutmXGd36rhIidfKaGau3U07qwhcy+mdBq3qtLVdFzpV81oT6WO8QP
         UM1Zv3xCnTk3ixvfhUeIhvkNmWo3+uVmXWselF61ACeAatVsPhcCc2FGhUZjhePcrnn6
         J2/D/Q6A5XXdq0I1iBn5LeRpsQ7Dj6HpcOnflM/63pZC/EfuslBE9f+h3xvseO/ok3eh
         3duA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=SGgl74KwDCNZUxJJfTpLF78nO9GYxxc1iiiQS3g4Llg=;
        b=XW4z9Gt2xwl+EcAAy5BhyzjcfHWavVSZGTXnXh3SAO/+wVxqyqQGYgUgNipXtsy1r2
         tBImVJC4J5MSN37GbCqc8+pTyGtHUXmiZtlQwIF9lvLfa6EERu845uTt5vi7OILnqC/L
         35OmikQwQfLUMpsJJ0hzIa7HheLAUeRPrwEZV/6TFyo58SgN+fA4z3TpcbwJGEVRRgqS
         i9Zz94VrmZjrtX+jLrMFJuTw/Px34heWLtkQiy005DxqS9L36XoKq8sK4ShpssRAKDES
         nY/1U+6Jzyvj7wG0WcWlF83pIq8zPElFL34tByOLjVVlN2Py0n81DpbGx7B7yuFt4rqr
         m4EQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g8si233321qve.127.2019.02.24.22.46.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Feb 2019 22:46:00 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9008F5945F;
	Mon, 25 Feb 2019 06:45:59 +0000 (UTC)
Received: from xz-x1 (ovpn-12-105.pek2.redhat.com [10.72.12.105])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id B8ACB5C221;
	Mon, 25 Feb 2019 06:45:50 +0000 (UTC)
Date: Mon, 25 Feb 2019 14:45:47 +0800
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
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 10/26] userfaultfd: wp: add UFFDIO_COPY_MODE_WP
Message-ID: <20190225064547.GB28121@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-11-peterx@redhat.com>
 <20190221172919.GJ2813@redhat.com>
 <20190222071106.GI8904@xz-x1>
 <20190222151546.GC7783@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190222151546.GC7783@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Mon, 25 Feb 2019 06:45:59 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 10:15:47AM -0500, Jerome Glisse wrote:
> On Fri, Feb 22, 2019 at 03:11:06PM +0800, Peter Xu wrote:
> > On Thu, Feb 21, 2019 at 12:29:19PM -0500, Jerome Glisse wrote:
> > > On Tue, Feb 12, 2019 at 10:56:16AM +0800, Peter Xu wrote:
> > > > From: Andrea Arcangeli <aarcange@redhat.com>
> > > > 
> > > > This allows UFFDIO_COPY to map pages wrprotected.
> > > > 
> > > > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > > > Signed-off-by: Peter Xu <peterx@redhat.com>
> > > 
> > > Minor nitpick down below, but in any case:
> > > 
> > > Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> > > 
> > > > ---
> > > >  fs/userfaultfd.c                 |  5 +++--
> > > >  include/linux/userfaultfd_k.h    |  2 +-
> > > >  include/uapi/linux/userfaultfd.h | 11 +++++-----
> > > >  mm/userfaultfd.c                 | 36 ++++++++++++++++++++++----------
> > > >  4 files changed, 35 insertions(+), 19 deletions(-)
> > > > 
> > > 
> > > [...]
> > > 
> > > > diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> > > > index d59b5a73dfb3..73a208c5c1e7 100644
> > > > --- a/mm/userfaultfd.c
> > > > +++ b/mm/userfaultfd.c
> > > > @@ -25,7 +25,8 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
> > > >  			    struct vm_area_struct *dst_vma,
> > > >  			    unsigned long dst_addr,
> > > >  			    unsigned long src_addr,
> > > > -			    struct page **pagep)
> > > > +			    struct page **pagep,
> > > > +			    bool wp_copy)
> > > >  {
> > > >  	struct mem_cgroup *memcg;
> > > >  	pte_t _dst_pte, *dst_pte;
> > > > @@ -71,9 +72,9 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
> > > >  	if (mem_cgroup_try_charge(page, dst_mm, GFP_KERNEL, &memcg, false))
> > > >  		goto out_release;
> > > >  
> > > > -	_dst_pte = mk_pte(page, dst_vma->vm_page_prot);
> > > > -	if (dst_vma->vm_flags & VM_WRITE)
> > > > -		_dst_pte = pte_mkwrite(pte_mkdirty(_dst_pte));
> > > > +	_dst_pte = pte_mkdirty(mk_pte(page, dst_vma->vm_page_prot));
> > > > +	if (dst_vma->vm_flags & VM_WRITE && !wp_copy)
> > > > +		_dst_pte = pte_mkwrite(_dst_pte);
> > > 
> > > I like parenthesis around around and :) ie:
> > >     (dst_vma->vm_flags & VM_WRITE) && !wp_copy
> > > 
> > > I feel it is easier to read.
> > 
> > Yeah another one. Though this line will be changed in follow up
> > patches, will fix anyways.
> > 
> > > 
> > > [...]
> > > 
> > > > @@ -416,11 +418,13 @@ static __always_inline ssize_t mfill_atomic_pte(struct mm_struct *dst_mm,
> > > >  	if (!(dst_vma->vm_flags & VM_SHARED)) {
> > > >  		if (!zeropage)
> > > >  			err = mcopy_atomic_pte(dst_mm, dst_pmd, dst_vma,
> > > > -					       dst_addr, src_addr, page);
> > > > +					       dst_addr, src_addr, page,
> > > > +					       wp_copy);
> > > >  		else
> > > >  			err = mfill_zeropage_pte(dst_mm, dst_pmd,
> > > >  						 dst_vma, dst_addr);
> > > >  	} else {
> > > > +		VM_WARN_ON(wp_copy); /* WP only available for anon */
> > > 
> > > Don't you want to return with error here ?
> > 
> > Makes sense to me.  Does this looks good to you to be squashed into
> > current patch?
> > 
> > diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> > index 73a208c5c1e7..f3ea09f412d4 100644
> > --- a/mm/userfaultfd.c
> > +++ b/mm/userfaultfd.c
> > @@ -73,7 +73,7 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
> >                 goto out_release;
> >  
> >         _dst_pte = pte_mkdirty(mk_pte(page, dst_vma->vm_page_prot));
> > -       if (dst_vma->vm_flags & VM_WRITE && !wp_copy)
> > +       if ((dst_vma->vm_flags & VM_WRITE) && !wp_copy)
> >                 _dst_pte = pte_mkwrite(_dst_pte);
> >  
> >         dst_pte = pte_offset_map_lock(dst_mm, dst_pmd, dst_addr, &ptl);
> > @@ -424,7 +424,10 @@ static __always_inline ssize_t mfill_atomic_pte(struct mm_struct *dst_mm,
> >                         err = mfill_zeropage_pte(dst_mm, dst_pmd,
> >                                                  dst_vma, dst_addr);
> >         } else {
> > -               VM_WARN_ON(wp_copy); /* WP only available for anon */
> > +               if (unlikely(wp_copy))
> > +                       /* TODO: WP currently only available for anon */
> > +                       return -EINVAL;
> > +
> >                 if (!zeropage)
> >                         err = shmem_mcopy_atomic_pte(dst_mm, dst_pmd,
> >                                                      dst_vma, dst_addr,
> 
> I would keep a the VM_WARN_ON or maybe a ONCE variant so that we at
> least have a chance to be inform if for some reasons that code path
> is taken. With that my r-b stands.

Yeah *ONCE() is good to me too (both can avoid DOS attack from
userspace) and I don't have strong opinion on whether we should fail
on this specific ioctl if it happens.  For now I'll just take the
advise and the r-b together.  Thanks,

-- 
Peter Xu

