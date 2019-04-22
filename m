Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43EB4C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 14:54:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8AC620684
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 14:54:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8AC620684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 830E46B0003; Mon, 22 Apr 2019 10:54:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E1EE6B0006; Mon, 22 Apr 2019 10:54:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6AA936B0007; Mon, 22 Apr 2019 10:54:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 472C06B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 10:54:14 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id f15so11858011qtk.16
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 07:54:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=16QC4KlNooUWDwXyV9FxYmhQJlMkf/WTwy+yGx9XFgw=;
        b=nI10ZOD7/K+O69IK/kHi1OW7Ny3vy9zX+EeYzfmdK5wWfQR2RkU/y+CRIhc6qXU3/J
         eObEvrhu7c4UJdLpMdhz/eU+S2ITmwmiIjQcNm5hQOKl+N6rv+7VJJm+mIFT7qNiCYWR
         KFcYrgxkSwDm9zVK1dyiExd1aT9Xu52CMfEw+nVE7XlWzB71imCOB2JVI/bMJppifKvu
         y0m7GjCJbLIT6LZW7gQK2K8rzCTB3y1xm2yM6XeYD9iRKyqF+XUuZT7yYp/29F3U0+XC
         uwdUZekJAx1CZaCEMuBHnqTRzIwYxBwZU5tXalnIO+UVVJEtzr38wKr6Y4qS8j8VNbIP
         1bTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV7ZSC/ikVN4/+aw2q3g2DhVN527y/VVxsBAYRanamb5/tcjt58
	4LsTOtBrqQimi+iP7CZ2b7vKO6r4Tnr1PN/4dE8spYAg2aYtq63edK2EosClQuy850RhpTqDzWY
	o2D4970KEkcgKVxhFkLTg4djiC1vlvVbY8N8HA5DsyYKEytXcAc4Z66vgrVhJjMPkGA==
X-Received: by 2002:a0c:d0d0:: with SMTP id b16mr10128317qvh.139.1555944854015;
        Mon, 22 Apr 2019 07:54:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYSd0oUbb0R3IxudD3AJyytmm9/5QxzlUkqx3gNX5gnZjh1MSVw8IW3E3Mh5qdk5a0tndB
X-Received: by 2002:a0c:d0d0:: with SMTP id b16mr10128288qvh.139.1555944853391;
        Mon, 22 Apr 2019 07:54:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555944853; cv=none;
        d=google.com; s=arc-20160816;
        b=spCPbCwWXUe/fXzGpjR8Xq2V9TOzl1xPGOVyIKrNN7UpxJk+5ZLNLyicw41YAvlMxr
         N+Ka7couQdpQL2aEz0YuZnyjmVB5F2/sEKTzPhwTAJ1y5TrZMcjYi6EGPoCXiP01j5d4
         bSsKgPDjpUEjbnBivhA9nxI8ihex+i13SCxOIVdpNso8rGOojjtVzLfZae6WGTSmDt1n
         K/BhcaA9kFOjJy/LGAfls0C9SER1rirDDTneds/aWfgjHP7CqySPJjdqlNWu/TuO6yiE
         eIxtXGWRQ6pEIGkXADgWGsSI8BLApRIBTWLCiwh0Q0l8dilaTnj/1LhP5wYUXWLJAPyO
         hXJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=16QC4KlNooUWDwXyV9FxYmhQJlMkf/WTwy+yGx9XFgw=;
        b=CAk4b9fv39teXHK76owD5sFryVRntQP64sL0AZpj3CF5VuhzF0aGXpq/q9biayLjAT
         9GBktdDpGrUyQfCmzZd7mX3TiXw8yKWcAWeWRD9PjBblIBX9u1Z0JqgUXf59vJDSmEoc
         /ugB3jHPnUFysErZAt95+iOmrC6BEyq+mUBN3xekxTparSANmrwoyrzBD0v2kECgSbFe
         hLxNxRYqU2EfxqVrTNE69TfD26S2dZh8+JQtpsLHU8OduNNQyq9b7EgZYcv0QzdLGXop
         npwvYWZ17iquS7LCcatVJB4e6xWbXpU6FKymIUq2DbF3MHKLwsNulHeAhDiFP4u88GWc
         vibQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u36si1948068qte.226.2019.04.22.07.54.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 07:54:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AD10930ADBB3;
	Mon, 22 Apr 2019 14:54:11 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C410C5D9D3;
	Mon, 22 Apr 2019 14:54:04 +0000 (UTC)
Date: Mon, 22 Apr 2019 10:54:02 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
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
Message-ID: <20190422145402.GB3450@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
 <20190320020642.4000-15-peterx@redhat.com>
 <20190418202558.GK3288@redhat.com>
 <20190419062650.GF13323@xz-x1>
 <20190419150253.GA3311@redhat.com>
 <20190422122010.GA25896@xz-x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190422122010.GA25896@xz-x1>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Mon, 22 Apr 2019 14:54:12 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 22, 2019 at 08:20:10PM +0800, Peter Xu wrote:
> On Fri, Apr 19, 2019 at 11:02:53AM -0400, Jerome Glisse wrote:
> 
> [...]
> 
> > > > > +			if (uffd_wp_resolve) {
> > > > > +				/* If the fault is resolved already, skip */
> > > > > +				if (!pte_uffd_wp(*pte))
> > > > > +					continue;
> > > > > +				page = vm_normal_page(vma, addr, oldpte);
> > > > > +				if (!page || page_mapcount(page) > 1) {
> > > > > +					struct vm_fault vmf = {
> > > > > +						.vma = vma,
> > > > > +						.address = addr & PAGE_MASK,
> > > > > +						.page = page,
> > > > > +						.orig_pte = oldpte,
> > > > > +						.pmd = pmd,
> > > > > +						/* pte and ptl not needed */
> > > > > +					};
> > > > > +					vm_fault_t ret;
> > > > > +
> > > > > +					if (page)
> > > > > +						get_page(page);
> > > > > +					arch_leave_lazy_mmu_mode();
> > > > > +					pte_unmap_unlock(pte, ptl);
> > > > > +					ret = wp_page_copy(&vmf);
> > > > > +					/* PTE is changed, or OOM */
> > > > > +					if (ret == 0)
> > > > > +						/* It's done by others */
> > > > > +						continue;
> > > > 
> > > > This is wrong if ret == 0 you still need to remap the pte before
> > > > continuing as otherwise you will go to next pte without the page
> > > > table lock for the directory. So 0 case must be handled after
> > > > arch_enter_lazy_mmu_mode() below.
> > > > 
> > > > Sorry i should have catch that in previous review.
> > > 
> > > My fault to not have noticed it since the very beginning... thanks for
> > > spotting that.
> > > 
> > > I'm squashing below changes into the patch:
> > 
> > 
> > Well thinking of this some more i think you should use do_wp_page() and
> > not wp_page_copy() it would avoid bunch of code above and also you are
> > not properly handling KSM page or page in the swap cache. Instead of
> > duplicating same code that is in do_wp_page() it would be better to call
> > it here.
> 
> Yeah it makes sense to me.  Then here's my plan:
> 
> - I'll need to drop previous patch "export wp_page_copy" since then
>   it'll be not needed
> 
> - I'll introduce another patch to split current do_wp_page() and
>   introduce function "wp_page_copy_cont" (better suggestion on the
>   naming would be welcomed) which contains most of the wp handling
>   that'll be needed for change_pte_range() in this patch and isolate
>   the uffd handling:
> 
> static vm_fault_t do_wp_page(struct vm_fault *vmf)
> 	__releases(vmf->ptl)
> {
> 	struct vm_area_struct *vma = vmf->vma;
> 
> 	if (userfaultfd_pte_wp(vma, *vmf->pte)) {
> 		pte_unmap_unlock(vmf->pte, vmf->ptl);
> 		return handle_userfault(vmf, VM_UFFD_WP);
> 	}
> 
> 	return do_wp_page_cont(vmf);
> }
> 
> Then I can probably use do_wp_page_cont() in this patch.

Instead i would keep the do_wp_page name and do:
    static vm_fault_t do_userfaultfd_wp_page(struct vm_fault *vmf) {
        ... // what you have above
        return do_wp_page(vmf);
    }

Naming wise i think it would be better to keep do_wp_page() as
is.

Cheers,
Jérôme

