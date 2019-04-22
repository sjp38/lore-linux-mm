Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E71F4C10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 12:20:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8438320811
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 12:20:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8438320811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E98896B0003; Mon, 22 Apr 2019 08:20:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E47F16B0006; Mon, 22 Apr 2019 08:20:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D5F856B0007; Mon, 22 Apr 2019 08:20:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id B515B6B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 08:20:26 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id f89so11542114qtb.4
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 05:20:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=I4vinnc6Hze8+hdDvUWgZFCYEqtSvp5lt6jZx3OW4tY=;
        b=EywovMMLFwXRoPCmR30sVtMXDT5MI0q/BFpM8mdP8GDW9WX+qOi6IByPjmgzAkTfuQ
         /xM8cI8gJq7oxRW5CgLeL5U6Ti5GMJbHGkpFI1cPPGsfjLvKiqTzTV4lg58sSYX+F7Bg
         u4PxRYMr59M+/0VNEpxD0ixaIomo8Hl5JAgmXeuxQzf3Rg84h3fL9xxJ9bdNxwElB6US
         xmJiyFF/aCPaqWRf5Ll+I1PiBr0UD9maMO3RW8X7HzTwhMx0oswwneXw04aTzafdDAao
         4ZHQZVf90vllt+p2TzvLwX1zbD3Z+yjvzd/DsfbHDnyND5Iwq+wVLofm0tbacWKo1M5A
         S0mw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVXYCAoaS4lYrVFb3L9Ck/4ODOUH6koAvZR58b4vM63YKi/ZGXC
	eV1jOVe+TDcL51J3NmydOfQ1w44j/hoKBOJBjCH0oF4JNnFN9GzJUt9hkav/g1Zw4pxOoBHtnnv
	RBtGjx6cS1gmG3cRF7TtrMoDGDzw/BY0VsS2IChkfB4GnPMRaxQ6H6Cepdo/Zg8yH2w==
X-Received: by 2002:a0c:b907:: with SMTP id u7mr15648065qvf.189.1555935626382;
        Mon, 22 Apr 2019 05:20:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzH+pfxhLNmeT1uTeyZg6t4Lvw6bgEKwFDtYsOfiOYxv7QaX7CzFXNfrrqNMVEhSMvPiUOE
X-Received: by 2002:a0c:b907:: with SMTP id u7mr15648017qvf.189.1555935625667;
        Mon, 22 Apr 2019 05:20:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555935625; cv=none;
        d=google.com; s=arc-20160816;
        b=G93l+q1w/9jPWP8BgS7m3CE1VhkXuZ2xmKl6Ens3TKe+v5u1uusIAaB0nnetOtCdW/
         +usE+TN5PkMKgKo+D/jPlneStbNubd5DjUtmZoUEmlewsi+XZVzuM7OFIl7aO+PaczMb
         8c92KV5XaBQ5u5kXzNvyNZi0+S7TMzMwSlKt5fbnpoWtnTqlDfiwchn8cPXDMcRtVjLU
         LwDTPsVU49xXCqKUO7TflzzGpOoItCxahHA3hxPN9+dw4DHQnbNw1IH8lWwQVk3aZKYU
         WwhQ0gxJB/PlJapBUSC6LesXucx9U2WMi7+FQrzNPedp07cQsYyhgX1ZtLts7c0OcDfv
         2VEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=I4vinnc6Hze8+hdDvUWgZFCYEqtSvp5lt6jZx3OW4tY=;
        b=pV4TTyvwbnKlt0F7N3+QKI//vTPAc49YNtNYiubLnV8NDLv5V7mURUKXMvxNCinajN
         pkJIIGBR+wd3F5j2x4mRgVonmLZx7o2daDVqYBMxPslPIGMhxEe4F3UVQ/wBGFPmjjch
         88yvHSLeovpgfECUFkekQRWMfgkPlAluN7yls6SXQzn2hr2CFfAs0R25UlwCWwgZNXZ6
         9ye08cOWf6+qkp+1cyJt5/QQ8pHzWU2wwJ+CRi2eWpJ/4iYVEr9I2xWDXkQ6BzoqsOmm
         7y10+H0UB2T0562WnA+0vM52ijdwZoFT9miSh4NpjLcVyvzJIJF10V07VtS0dzgdBifD
         0Wug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m31si1722125qtc.213.2019.04.22.05.20.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 05:20:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 38D87859FC;
	Mon, 22 Apr 2019 12:20:24 +0000 (UTC)
Received: from xz-x1 (ovpn-12-23.pek2.redhat.com [10.72.12.23])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5330E26E63;
	Mon, 22 Apr 2019 12:20:14 +0000 (UTC)
Date: Mon, 22 Apr 2019 20:20:10 +0800
From: Peter Xu <peterx@redhat.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Marty McFadden <mcfadden8@llnl.gov>, Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v3 14/28] userfaultfd: wp: handle COW properly for uffd-wp
Message-ID: <20190422122010.GA25896@xz-x1>
References: <20190320020642.4000-1-peterx@redhat.com>
 <20190320020642.4000-15-peterx@redhat.com>
 <20190418202558.GK3288@redhat.com>
 <20190419062650.GF13323@xz-x1>
 <20190419150253.GA3311@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190419150253.GA3311@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Mon, 22 Apr 2019 12:20:24 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 19, 2019 at 11:02:53AM -0400, Jerome Glisse wrote:

[...]

> > > > +			if (uffd_wp_resolve) {
> > > > +				/* If the fault is resolved already, skip */
> > > > +				if (!pte_uffd_wp(*pte))
> > > > +					continue;
> > > > +				page = vm_normal_page(vma, addr, oldpte);
> > > > +				if (!page || page_mapcount(page) > 1) {
> > > > +					struct vm_fault vmf = {
> > > > +						.vma = vma,
> > > > +						.address = addr & PAGE_MASK,
> > > > +						.page = page,
> > > > +						.orig_pte = oldpte,
> > > > +						.pmd = pmd,
> > > > +						/* pte and ptl not needed */
> > > > +					};
> > > > +					vm_fault_t ret;
> > > > +
> > > > +					if (page)
> > > > +						get_page(page);
> > > > +					arch_leave_lazy_mmu_mode();
> > > > +					pte_unmap_unlock(pte, ptl);
> > > > +					ret = wp_page_copy(&vmf);
> > > > +					/* PTE is changed, or OOM */
> > > > +					if (ret == 0)
> > > > +						/* It's done by others */
> > > > +						continue;
> > > 
> > > This is wrong if ret == 0 you still need to remap the pte before
> > > continuing as otherwise you will go to next pte without the page
> > > table lock for the directory. So 0 case must be handled after
> > > arch_enter_lazy_mmu_mode() below.
> > > 
> > > Sorry i should have catch that in previous review.
> > 
> > My fault to not have noticed it since the very beginning... thanks for
> > spotting that.
> > 
> > I'm squashing below changes into the patch:
> 
> 
> Well thinking of this some more i think you should use do_wp_page() and
> not wp_page_copy() it would avoid bunch of code above and also you are
> not properly handling KSM page or page in the swap cache. Instead of
> duplicating same code that is in do_wp_page() it would be better to call
> it here.

Yeah it makes sense to me.  Then here's my plan:

- I'll need to drop previous patch "export wp_page_copy" since then
  it'll be not needed

- I'll introduce another patch to split current do_wp_page() and
  introduce function "wp_page_copy_cont" (better suggestion on the
  naming would be welcomed) which contains most of the wp handling
  that'll be needed for change_pte_range() in this patch and isolate
  the uffd handling:

static vm_fault_t do_wp_page(struct vm_fault *vmf)
	__releases(vmf->ptl)
{
	struct vm_area_struct *vma = vmf->vma;

	if (userfaultfd_pte_wp(vma, *vmf->pte)) {
		pte_unmap_unlock(vmf->pte, vmf->ptl);
		return handle_userfault(vmf, VM_UFFD_WP);
	}

	return do_wp_page_cont(vmf);
}

Then I can probably use do_wp_page_cont() in this patch.

Thanks,

-- 
Peter Xu

