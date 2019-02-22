Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE906C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 07:11:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 835BC207E0
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 07:11:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 835BC207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 331588E00F0; Fri, 22 Feb 2019 02:11:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BA0A8E00EB; Fri, 22 Feb 2019 02:11:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 15AF68E00F0; Fri, 22 Feb 2019 02:11:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D9AFB8E00EB
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 02:11:21 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id y6so900245qke.1
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 23:11:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=h/h5YPtfWTZEGXnqlXOmjCfqgbJ04KWkQ4FSzRCZaxE=;
        b=ojy6IsZSkvkHxTVueemHrf1lOmpogAeHh9RbkHp48XwmxsKlA7xaiqtFGeBaWlvIDq
         +Ubdv5sPrQaSXECRFpvx8hbWuhXIMg7hdOGyh5N63nseEVwZdDABlbl9QtSlK4B9f/Bw
         ZeDwFEMsp/KFArW2cjxqUQ7GZvHFlPMqfb6q4vg0/X7kF511c0wjY7/98Jfp6mRT1sfi
         5JQCYrdagGZcBAe8E80rnBUckLD/Qb6/6CQDaXv4csT4are0BxjtwPFgEsG5bGa3wzE8
         uGbvLir+c6DefpSdk4AsGVks9uZtQZTL14etZ4UgFXoFCVegV/W8/H1RZrpt/kKRZ9gu
         srnQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubIf2RMLodUmu789Bz1w6L5NeEO888TleFcJ2XVM+vULMlJnxXa
	21UJRcmd3LwoZc101SB1VeXhbVny4IGF2BQ9miBicv7U+TJw8Y70Sa9FqQzpJ+3C0rEJyrToAtW
	s0swf3eqqC3/Ij3FeC1hj5LS6t79db5RslxV5q0VFsfvq7n7LaBvnoXVjBZbDfUgqDg==
X-Received: by 2002:a0c:9681:: with SMTP id a1mr2071731qvd.72.1550819481624;
        Thu, 21 Feb 2019 23:11:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbRL2bsxjigHFmhZ2EcAluK0yVYAfE0IeBjKKXXqA02cOqO3VBbNh0Q/cldEsYTkDwyU1eq
X-Received: by 2002:a0c:9681:: with SMTP id a1mr2071694qvd.72.1550819480792;
        Thu, 21 Feb 2019 23:11:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550819480; cv=none;
        d=google.com; s=arc-20160816;
        b=DByHEikTXv//h9iFwBXR25CVChr57AK9JdnjtCqPVHwtFxA0BCCTGy8eF75hn9+tQz
         Wm/Gjr8lK8GLkB4YIxga2g7aBrYGftSxUY8QNPmc35SiucrZypY5m00ep/VAewFVFq0p
         rBtpi3HYRf8rZcpCTqivGL+Ow3IN2fo6dhlTUiCZk3NlCKvq19mA5X4vVFhraV90M0dm
         +z2Ik82HBsmjNhKNnW02HtA2j7wY5ddLvVlgjl7u/yJio1wmAha93LFMmyfRnyKGIt54
         JAFB49BwziGv6Op8w3iEmnBBrEYWD4YXqFgEHOcfGjojFE8/XY8V+5HgZL3Dng+sRu3s
         30AA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=h/h5YPtfWTZEGXnqlXOmjCfqgbJ04KWkQ4FSzRCZaxE=;
        b=GunmGY060/9TjkphGO8bR1mJ2E45O8RYLK2Nk1qkjCdNgwNML91Ri2WTsYXOBzWoiI
         rkd923olkR3TPn1CEsgrwuf3deRqTGSg2VMf0Ww0XUxMFsnwNsEQzlww7/lwLdzmfiHQ
         s72p7iGGAqtjUbEhIpHbaDVTbxCBa9RqwvUyQ5WtyMpq29W16Snr3bpDm8NoAJYWmk/L
         1NfJAkmoQD2w2p47GzamFlxJ986doGauw7dtC+jX8/Y8Y3xGufRt81JB6GPs85hMnbzA
         SJu/TPTZaowmNrJ6TKuujBurCOQX3Xk+HmuBiZk6NZNmoM/1ElOLbQTQq58cYfuTp65A
         LTSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q41si433147qtc.296.2019.02.21.23.11.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 23:11:20 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 98B8C81E0E;
	Fri, 22 Feb 2019 07:11:19 +0000 (UTC)
Received: from xz-x1 (ovpn-12-57.pek2.redhat.com [10.72.12.57])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 6E4625D9D4;
	Fri, 22 Feb 2019 07:11:10 +0000 (UTC)
Date: Fri, 22 Feb 2019 15:11:06 +0800
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
Message-ID: <20190222071106.GI8904@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-11-peterx@redhat.com>
 <20190221172919.GJ2813@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190221172919.GJ2813@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Fri, 22 Feb 2019 07:11:20 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 12:29:19PM -0500, Jerome Glisse wrote:
> On Tue, Feb 12, 2019 at 10:56:16AM +0800, Peter Xu wrote:
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > This allows UFFDIO_COPY to map pages wrprotected.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > Signed-off-by: Peter Xu <peterx@redhat.com>
> 
> Minor nitpick down below, but in any case:
> 
> Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> 
> > ---
> >  fs/userfaultfd.c                 |  5 +++--
> >  include/linux/userfaultfd_k.h    |  2 +-
> >  include/uapi/linux/userfaultfd.h | 11 +++++-----
> >  mm/userfaultfd.c                 | 36 ++++++++++++++++++++++----------
> >  4 files changed, 35 insertions(+), 19 deletions(-)
> > 
> 
> [...]
> 
> > diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> > index d59b5a73dfb3..73a208c5c1e7 100644
> > --- a/mm/userfaultfd.c
> > +++ b/mm/userfaultfd.c
> > @@ -25,7 +25,8 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
> >  			    struct vm_area_struct *dst_vma,
> >  			    unsigned long dst_addr,
> >  			    unsigned long src_addr,
> > -			    struct page **pagep)
> > +			    struct page **pagep,
> > +			    bool wp_copy)
> >  {
> >  	struct mem_cgroup *memcg;
> >  	pte_t _dst_pte, *dst_pte;
> > @@ -71,9 +72,9 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
> >  	if (mem_cgroup_try_charge(page, dst_mm, GFP_KERNEL, &memcg, false))
> >  		goto out_release;
> >  
> > -	_dst_pte = mk_pte(page, dst_vma->vm_page_prot);
> > -	if (dst_vma->vm_flags & VM_WRITE)
> > -		_dst_pte = pte_mkwrite(pte_mkdirty(_dst_pte));
> > +	_dst_pte = pte_mkdirty(mk_pte(page, dst_vma->vm_page_prot));
> > +	if (dst_vma->vm_flags & VM_WRITE && !wp_copy)
> > +		_dst_pte = pte_mkwrite(_dst_pte);
> 
> I like parenthesis around around and :) ie:
>     (dst_vma->vm_flags & VM_WRITE) && !wp_copy
> 
> I feel it is easier to read.

Yeah another one. Though this line will be changed in follow up
patches, will fix anyways.

> 
> [...]
> 
> > @@ -416,11 +418,13 @@ static __always_inline ssize_t mfill_atomic_pte(struct mm_struct *dst_mm,
> >  	if (!(dst_vma->vm_flags & VM_SHARED)) {
> >  		if (!zeropage)
> >  			err = mcopy_atomic_pte(dst_mm, dst_pmd, dst_vma,
> > -					       dst_addr, src_addr, page);
> > +					       dst_addr, src_addr, page,
> > +					       wp_copy);
> >  		else
> >  			err = mfill_zeropage_pte(dst_mm, dst_pmd,
> >  						 dst_vma, dst_addr);
> >  	} else {
> > +		VM_WARN_ON(wp_copy); /* WP only available for anon */
> 
> Don't you want to return with error here ?

Makes sense to me.  Does this looks good to you to be squashed into
current patch?

diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 73a208c5c1e7..f3ea09f412d4 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -73,7 +73,7 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
                goto out_release;
 
        _dst_pte = pte_mkdirty(mk_pte(page, dst_vma->vm_page_prot));
-       if (dst_vma->vm_flags & VM_WRITE && !wp_copy)
+       if ((dst_vma->vm_flags & VM_WRITE) && !wp_copy)
                _dst_pte = pte_mkwrite(_dst_pte);
 
        dst_pte = pte_offset_map_lock(dst_mm, dst_pmd, dst_addr, &ptl);
@@ -424,7 +424,10 @@ static __always_inline ssize_t mfill_atomic_pte(struct mm_struct *dst_mm,
                        err = mfill_zeropage_pte(dst_mm, dst_pmd,
                                                 dst_vma, dst_addr);
        } else {
-               VM_WARN_ON(wp_copy); /* WP only available for anon */
+               if (unlikely(wp_copy))
+                       /* TODO: WP currently only available for anon */
+                       return -EINVAL;
+
                if (!zeropage)
                        err = shmem_mcopy_atomic_pte(dst_mm, dst_pmd,
                                                     dst_vma, dst_addr,

Thanks,

-- 
Peter Xu

