Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6680EC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 15:16:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 264302086A
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 15:16:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 264302086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB0E38E0111; Fri, 22 Feb 2019 10:16:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B61458E0109; Fri, 22 Feb 2019 10:16:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A511A8E0111; Fri, 22 Feb 2019 10:16:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7B6108E0109
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 10:16:00 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id d134so1698273qkc.17
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 07:16:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=5umS1UuQJWtrOLB/NdFl5MpqO6iQoL46ncF0W32P3Fc=;
        b=WSRfQG6ZjnEAwQc0tshew3Mljj5aBnfKL0SatAujgx2Fh/r+orr2UFkhDL2h5sQQf3
         s1at5g6Xp3Z8gWTDRk5LLSR+plELqzBLL0JBLl2KNPVbMejsDaR+jZg16dxbc7lD1Qvw
         HqwHUvIAxdVYfyBc1qjR694iIu2Iub1XCvxD3tMWKhcD1o5i1kIZhZl1L9QdATfaMYHd
         PGalYK2AWLeXjr33MlRxTLftu4O+Cjap00FdyBORhQKKgJKsV+Nv5ODVfBuSHcyWD1hg
         aG4JgZekBQeQ9X5DUyawABe3dvz6Fn53toYjXW5CY2gxw3LmDLrOCDLQJuFnKksnSdpJ
         SskA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuby+SJSY2rEEBCFGPl+fqJLAxDO7YZJJsHl+/+dc6dLYDsljEau
	AApTsKj6o+emRYWf1lPts3AY2V26sRLsL1SOU1bHwaaWD0g4AXQ0be6sNvJl6S3KH+V8WYKsd4t
	meWpMDXMm7Vkv02K8+hea/8HH30e4b8AkRpPh5asjLbeW9vozW52+mXWJcwRKW+0wBQ==
X-Received: by 2002:ac8:3770:: with SMTP id p45mr3471763qtb.275.1550848560217;
        Fri, 22 Feb 2019 07:16:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZcl/95jHDkszu0iA+jnsrHg80YZRxbAqPRfEbAgI9JsaFrfdHSynIze5Gt3VMiE9Y3eSR9
X-Received: by 2002:ac8:3770:: with SMTP id p45mr3471716qtb.275.1550848559534;
        Fri, 22 Feb 2019 07:15:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550848559; cv=none;
        d=google.com; s=arc-20160816;
        b=CpE6kKeotOFjmP/eVLqAI3ULgZbA0CMLfARTEUludmX6mSPaToJPqpuknDbBPsqgmR
         DiTr3lEYhWBR+7WwyJ0jtSOfQ32ll+mmeBAF7vynscdBHXuSViH3QJhP7W3De0qpBZRc
         1UfBlXo+3XBpvQMSGYthS0vJcasRRagEKT6gquRfuofM1Iw/qrH3UskxWJdfLwyTSh1c
         hKwqIrh+7HoLaNGJJ6OQL+zK+J8nJ7Sq9Ua1uhFaIUU4KmKuW7TzWAoTtYiJ8QYPhDbY
         he6X0Gfea4FX2bONS/2G8GPTfdoMJVdmM3YNPorQR4LzBp99wPnyukFfjlOAdtyweFVC
         WPrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=5umS1UuQJWtrOLB/NdFl5MpqO6iQoL46ncF0W32P3Fc=;
        b=ZAULcA+ay46APDqVH5fwTmRbNa32Cw/3a+bdcIZlGAX1qKHI1BtdBt7dJQKm0Z5R4v
         PnGBcsIxGXmDwdNBLjUjAROZvkymWHZ/JAbi/4empbLRS7Zpg8CQSi9SZwW84SPALB0g
         TjKe5wLSbUE97kz4aqzgwCJMX/7PmI7H2CA3aKQJtd9wGTiyqseDlHxeae2rahL4r9ZK
         sYCl8d+8218qw437IcqwtzSYTblBxz7tql6FzNSSghQf4O+9NP4uvrZvLFwa49mmakEp
         brJAvcnIwrFRlgAbeiG8SoRgCXuAjpBLrdl+N3SsxzA/kZrSkDUMwjbqfa8bPoZcbBd+
         P3dQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h4si1054552qve.14.2019.02.22.07.15.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 07:15:59 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8BA6881E0D;
	Fri, 22 Feb 2019 15:15:57 +0000 (UTC)
Received: from redhat.com (ovpn-126-14.rdu2.redhat.com [10.10.126.14])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 3B3EA60BF1;
	Fri, 22 Feb 2019 15:15:49 +0000 (UTC)
Date: Fri, 22 Feb 2019 10:15:47 -0500
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
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 10/26] userfaultfd: wp: add UFFDIO_COPY_MODE_WP
Message-ID: <20190222151546.GC7783@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-11-peterx@redhat.com>
 <20190221172919.GJ2813@redhat.com>
 <20190222071106.GI8904@xz-x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190222071106.GI8904@xz-x1>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Fri, 22 Feb 2019 15:15:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 03:11:06PM +0800, Peter Xu wrote:
> On Thu, Feb 21, 2019 at 12:29:19PM -0500, Jerome Glisse wrote:
> > On Tue, Feb 12, 2019 at 10:56:16AM +0800, Peter Xu wrote:
> > > From: Andrea Arcangeli <aarcange@redhat.com>
> > > 
> > > This allows UFFDIO_COPY to map pages wrprotected.
> > > 
> > > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > > Signed-off-by: Peter Xu <peterx@redhat.com>
> > 
> > Minor nitpick down below, but in any case:
> > 
> > Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> > 
> > > ---
> > >  fs/userfaultfd.c                 |  5 +++--
> > >  include/linux/userfaultfd_k.h    |  2 +-
> > >  include/uapi/linux/userfaultfd.h | 11 +++++-----
> > >  mm/userfaultfd.c                 | 36 ++++++++++++++++++++++----------
> > >  4 files changed, 35 insertions(+), 19 deletions(-)
> > > 
> > 
> > [...]
> > 
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
> > 
> > I like parenthesis around around and :) ie:
> >     (dst_vma->vm_flags & VM_WRITE) && !wp_copy
> > 
> > I feel it is easier to read.
> 
> Yeah another one. Though this line will be changed in follow up
> patches, will fix anyways.
> 
> > 
> > [...]
> > 
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
> > 
> > Don't you want to return with error here ?
> 
> Makes sense to me.  Does this looks good to you to be squashed into
> current patch?
> 
> diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> index 73a208c5c1e7..f3ea09f412d4 100644
> --- a/mm/userfaultfd.c
> +++ b/mm/userfaultfd.c
> @@ -73,7 +73,7 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
>                 goto out_release;
>  
>         _dst_pte = pte_mkdirty(mk_pte(page, dst_vma->vm_page_prot));
> -       if (dst_vma->vm_flags & VM_WRITE && !wp_copy)
> +       if ((dst_vma->vm_flags & VM_WRITE) && !wp_copy)
>                 _dst_pte = pte_mkwrite(_dst_pte);
>  
>         dst_pte = pte_offset_map_lock(dst_mm, dst_pmd, dst_addr, &ptl);
> @@ -424,7 +424,10 @@ static __always_inline ssize_t mfill_atomic_pte(struct mm_struct *dst_mm,
>                         err = mfill_zeropage_pte(dst_mm, dst_pmd,
>                                                  dst_vma, dst_addr);
>         } else {
> -               VM_WARN_ON(wp_copy); /* WP only available for anon */
> +               if (unlikely(wp_copy))
> +                       /* TODO: WP currently only available for anon */
> +                       return -EINVAL;
> +
>                 if (!zeropage)
>                         err = shmem_mcopy_atomic_pte(dst_mm, dst_pmd,
>                                                      dst_vma, dst_addr,

I would keep a the VM_WARN_ON or maybe a ONCE variant so that we at
least have a chance to be inform if for some reasons that code path
is taken. With that my r-b stands.

Cheers,
Jérôme

