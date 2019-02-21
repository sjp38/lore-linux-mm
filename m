Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34568C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 17:29:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1973206B6
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 17:29:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1973206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F5188E0099; Thu, 21 Feb 2019 12:29:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A3D68E0094; Thu, 21 Feb 2019 12:29:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B94C8E0099; Thu, 21 Feb 2019 12:29:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 543458E0094
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 12:29:25 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id s65so5785461qke.16
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 09:29:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=x/4y1SGuU3vIP01EEV+kQVo89592aksYPviWLqsRfRw=;
        b=oPQy2D1LDWUUyffiOCqjN6iG3Fnc1Iwpo/1a2/imX5XeWCQYSLHt/pUFcKIF5XYZfA
         ykl0ZbYNfdQwfb88tKve1n0wwlnRGKel2kXTZlY4pYsel2mEVw0svEXSJ5ZDS5bMqn8l
         bk9kNhNxeQTiEzPM4VZAcprG8kgcL6y0je1NbX7Glj4P7mP3naHS41ljIcGm+FrhmL9K
         7GN58Mt0QgWZupy1btKiUDO2cZM9ed1dLlb/k+akVhvoaL+zyvwxEzwlKFCiFSxy4gkO
         kooxj2uM4u3HCv1dCSKbcobwPqxEoAfsP8DVu16fdY780WkPYGoemeUJwixB2ea47WP4
         d4fw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubZ2ZIOEX/htwptn49EQ91imnLSygUyDgs8Rfahbj9BHWDP67uS
	hA3TImaLhm/lMDQdV3xJZgA/cVa+pInTxl+8ZP2XbGgkx09NVLGBSHOOl1ang6UE9+X4H1NLZM5
	u9PPWkH6QfT7r2Ou3LuHgnlEU33FbsJ9dwmmeuLximJiNdEE8oRe4dLE9kMNp6gx6sQ==
X-Received: by 2002:aed:3964:: with SMTP id l91mr32519881qte.33.1550770165107;
        Thu, 21 Feb 2019 09:29:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib0OEOnTzpO2XKiWmdMIG2ctm3Ky5n2cxYWDqz4yJ59ORmjRj8A+yflMl3fTLuA+9bvw+vl
X-Received: by 2002:aed:3964:: with SMTP id l91mr32519852qte.33.1550770164604;
        Thu, 21 Feb 2019 09:29:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550770164; cv=none;
        d=google.com; s=arc-20160816;
        b=oZEWepfv4NYDd/xXg42WZz5pRrbgkqw+Kur2Ji9skM/j2GXVZa6ywvX/aBCVQDUSuW
         U2AhsYfum9vXh67USvZh/J8KUrGBmJyeR3VTxSdneECb4hiP329xhsTaHF+ceUBqSmUh
         uKCj8N+bJTv1TU30iIhE5H20P3Eoknj4Uo9/lE+tJ3KBl7pVabmHyIjsDhMLP00PHndr
         zWbGOk7PWlpgG1pOoXZ0lmt47XZ+cKPK11t+X/lVrXIn6e4zg9MSwkFHM1+nnDoEsayA
         M6UHt5lIz0MQLVmzDDbPA5SBm2mbGa3Vwhpo7D0z+4mYzqhUsinotFZkzQkovQ8xH7hz
         qEIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=x/4y1SGuU3vIP01EEV+kQVo89592aksYPviWLqsRfRw=;
        b=us8jc/+svZrMVPmbBv3oUt+F8ol+qMN62nwoewFZhKl185PQMbjaBDbjRK7cvm3ey5
         Dpg5kj3btBJgBaqgLUX3vlAC39MYPGCEOuzHToJFJeZhxLdwf0Hy0rJYTh2OkXlhmI1z
         x23gbASQXLVQS/71/p4w+MiigLjUrLh0LcOYHZm8f6vDS+TXteJTLcNpCTjGKbXI7Bkq
         3CRzqtZqLMsr8ft+/bGnE6LLF+8bfPdiBaH2oXpWDzOk02NemZI+XbMtHLefg7VI3BjK
         RxpDvdouOuZ4izMSbN3n8LC6SsaP9c7oXNM6vicQBr46Xn8ggF5I7okByMqzuye6inHq
         C38Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g35si4805492qvg.175.2019.02.21.09.29.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 09:29:24 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A128430821BE;
	Thu, 21 Feb 2019 17:29:23 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 79F0319C58;
	Thu, 21 Feb 2019 17:29:21 +0000 (UTC)
Date: Thu, 21 Feb 2019 12:29:19 -0500
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
Message-ID: <20190221172919.GJ2813@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-11-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190212025632.28946-11-peterx@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Thu, 21 Feb 2019 17:29:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:16AM +0800, Peter Xu wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> This allows UFFDIO_COPY to map pages wrprotected.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Peter Xu <peterx@redhat.com>

Minor nitpick down below, but in any case:

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  fs/userfaultfd.c                 |  5 +++--
>  include/linux/userfaultfd_k.h    |  2 +-
>  include/uapi/linux/userfaultfd.h | 11 +++++-----
>  mm/userfaultfd.c                 | 36 ++++++++++++++++++++++----------
>  4 files changed, 35 insertions(+), 19 deletions(-)
> 

[...]

> diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> index d59b5a73dfb3..73a208c5c1e7 100644
> --- a/mm/userfaultfd.c
> +++ b/mm/userfaultfd.c
> @@ -25,7 +25,8 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
>  			    struct vm_area_struct *dst_vma,
>  			    unsigned long dst_addr,
>  			    unsigned long src_addr,
> -			    struct page **pagep)
> +			    struct page **pagep,
> +			    bool wp_copy)
>  {
>  	struct mem_cgroup *memcg;
>  	pte_t _dst_pte, *dst_pte;
> @@ -71,9 +72,9 @@ static int mcopy_atomic_pte(struct mm_struct *dst_mm,
>  	if (mem_cgroup_try_charge(page, dst_mm, GFP_KERNEL, &memcg, false))
>  		goto out_release;
>  
> -	_dst_pte = mk_pte(page, dst_vma->vm_page_prot);
> -	if (dst_vma->vm_flags & VM_WRITE)
> -		_dst_pte = pte_mkwrite(pte_mkdirty(_dst_pte));
> +	_dst_pte = pte_mkdirty(mk_pte(page, dst_vma->vm_page_prot));
> +	if (dst_vma->vm_flags & VM_WRITE && !wp_copy)
> +		_dst_pte = pte_mkwrite(_dst_pte);

I like parenthesis around around and :) ie:
    (dst_vma->vm_flags & VM_WRITE) && !wp_copy

I feel it is easier to read.

[...]

> @@ -416,11 +418,13 @@ static __always_inline ssize_t mfill_atomic_pte(struct mm_struct *dst_mm,
>  	if (!(dst_vma->vm_flags & VM_SHARED)) {
>  		if (!zeropage)
>  			err = mcopy_atomic_pte(dst_mm, dst_pmd, dst_vma,
> -					       dst_addr, src_addr, page);
> +					       dst_addr, src_addr, page,
> +					       wp_copy);
>  		else
>  			err = mfill_zeropage_pte(dst_mm, dst_pmd,
>  						 dst_vma, dst_addr);
>  	} else {
> +		VM_WARN_ON(wp_copy); /* WP only available for anon */

Don't you want to return with error here ?

>  		if (!zeropage)
>  			err = shmem_mcopy_atomic_pte(dst_mm, dst_pmd,
>  						     dst_vma, dst_addr,

[...]

