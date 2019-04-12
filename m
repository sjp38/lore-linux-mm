Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A2B6C10F14
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 18:52:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BCC320869
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 18:52:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="IcH1Vq4J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BCC320869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C25276B000C; Fri, 12 Apr 2019 14:52:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD4ED6B000D; Fri, 12 Apr 2019 14:52:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC7036B0010; Fri, 12 Apr 2019 14:52:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6FD776B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 14:52:21 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 18so7051344pgx.11
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 11:52:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=o7pYXYebwcZB9VG+SfqHk39wa19WyWkdp0pR+i/f4wo=;
        b=MMtvz9QNs6Us55LRc1YOv809IRJdXa2+Mn+ZD2TeF1yKvIRcVsHsAE4akRdj0EVbag
         RVYZWSSt1fYTUXHYT2yFBhk0s/B/zdjMxmeVQf+fqOfDNxi1YK33c4kbsacqNqW9+4h6
         mntAUodL0KUqyQrs2c96jYKRH+btR9umjtQQPgq8Ow+9DouGYlLZkt504FBN7z2AB+rr
         c427bYbgZR28YCaY80POgp+0CAHFk+MKvvYGwpe+iK74uJCRxcgS41QQ0DP47AzWFj1j
         u3iJdr1d5ZYp8E9VL59JBC3qHdoNiOjspynlddR67SwnM83fj5HKzE/qjQc7sXEY+qu0
         3hGg==
X-Gm-Message-State: APjAAAWELNlPvZARI248+cc2FSgcIOE/kfZJIvc+mpgkV1UZv+kfqd09
	WiRKj2O6ZWL5RRACbKlwzfjqq2mnzBQi4+XkeoX7fKFhONOMXNi0legSdAVjde4RaJX2Dhn1yFw
	FJYM4i1n9fQXZniZ6QING2UDh3rcC5kvg4SqIBe6m4m3LQ0bw4GIWmi6r1s87yZ03Mg==
X-Received: by 2002:a63:df43:: with SMTP id h3mr56159035pgj.294.1555095140948;
        Fri, 12 Apr 2019 11:52:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqymaj4yHMSLLZJjq1DULfKzeBfhKvcFtsHlw/WHz0fBBIY4NUFmk83SyqGxEXinOwUwpQoX
X-Received: by 2002:a63:df43:: with SMTP id h3mr56158972pgj.294.1555095140058;
        Fri, 12 Apr 2019 11:52:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555095140; cv=none;
        d=google.com; s=arc-20160816;
        b=vrJJhDluz4oVymedK1ZNnrRy2YrS8X3eY+obaRGaH7KjLc/MxWsrBNBfWyEO8lKxoO
         yQPdHHulcN7uBqgK4B/LEAuYGZs97vsbDu/p0kz+xsgjJsnc3q9kMno6hfz3Kc3Lhsn9
         t3cavbA0wN7Tw3U70Ewm7YJphn/P+K3cvD0UJpM9j5Urx91qDiJr0NGUzLvCVOuTIvnU
         q3YHKDL1OJznLDThsHH4ApFp2eTCEGjF7xw/FnR88PTGqnGYPyGyXSVE5O/YXuyd6djJ
         0Yhnb6ZU743xntaNGwTGl1k81VzUM3XBXufH0q1yXOUWZTKku/xQWl4iBMAAts5NECOQ
         fODw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=o7pYXYebwcZB9VG+SfqHk39wa19WyWkdp0pR+i/f4wo=;
        b=rAZjztZRJ8hko/tQiX7tluzXRjzUcY0a8Tv9Bb2tMwsy4ILisTnJNYh1EzeY6CKGfG
         1fYE5eGLYo9mCFp4/lQL3CffobKDLYJZcsb7q4EapktBM67eT4WeM7PZ0OETbx5tadYv
         pIOM0JI0T5fJwX4L2UnJ+eta+3zAfvePkC2hjXIppJk+XFpO1Bb0pKj8RTW7zb3mhrtK
         H/qsmMTqYeqWr4GkGeU3+OsvFA6WViGLcJzYR6M3PielUkkrrX3unH6wWtKxMHROSoSI
         Yo8fzShyK2ptOpqMLmlZOzHdOB4H28ykAbQcEhG3lQ272mwQNgCf63advaKgyxIf8IvS
         SiSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=IcH1Vq4J;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id v2si6971000plp.191.2019.04.12.11.52.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 11:52:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=IcH1Vq4J;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cb0de600000>; Fri, 12 Apr 2019 11:52:16 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 12 Apr 2019 11:52:19 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 12 Apr 2019 11:52:19 -0700
Received: from rcampbell-dev.nvidia.com (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 12 Apr
 2019 18:52:18 +0000
Subject: Re: [PATCH 1/9] mm: Allow the [page|pfn]_mkwrite callbacks to drop
 the mmap_sem
To: Thomas Hellstrom <thellstrom@vmware.com>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Linux-graphics-maintainer <Linux-graphics-maintainer@vmware.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
CC: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox
	<willy@infradead.org>, Will Deacon <will.deacon@arm.com>, Peter Zijlstra
	<peterz@infradead.org>, Rik van Riel <riel@surriel.com>, Minchan Kim
	<minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Huang Ying
	<ying.huang@intel.com>, Souptick Joarder <jrdr.linux@gmail.com>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>
References: <20190412160338.64994-1-thellstrom@vmware.com>
 <20190412160338.64994-2-thellstrom@vmware.com>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <cba8a123-8d8d-c22b-e670-d87ae3ec46a2@nvidia.com>
Date: Fri, 12 Apr 2019 11:52:18 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190412160338.64994-2-thellstrom@vmware.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL103.nvidia.com (172.20.187.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1555095136; bh=o7pYXYebwcZB9VG+SfqHk39wa19WyWkdp0pR+i/f4wo=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=IcH1Vq4J4rSeqgJQnoLEJb9hwun7XOw2WYaxyxKQCbrYuDvOmT3ZgXFheM2V416Rh
	 WP7IdahP6zQOcF8JdvhBxSGWZarcrCtB7aaD2wGupWDCn/X0E2w+wleEJqI/H5e/fQ
	 KO9gQ8wsvS/LxO8nIYgGV6SCU2oVfApi6rX20zQ1LvM4+h32eoA4D080vrE3YldHHA
	 sVbXiYHGuzjA9VzRFIveZQ2RbpRqVOl0qtqoezcP+6qCvCeNctnNNJKNzw7nq0Sxok
	 28HP4HmU45/XGzLeg5wSrw9fl4PCItC/vDgrHuXyEGek48BFv418PbWAbFTCicny+7
	 9/EtLR0lLHaSQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 4/12/19 9:04 AM, Thomas Hellstrom wrote:
> Driver fault callbacks are allowed to drop the mmap_sem when expecting
> long hardware waits to avoid blocking other mm users. Allow the mkwrite
> callbacks to do the same by returning early on VM_FAULT_RETRY.
>=20
> In particular we want to be able to drop the mmap_sem when waiting for
> a reservation object lock on a GPU buffer object. These locks may be
> held while waiting for the GPU.
>=20
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Rik van Riel <riel@surriel.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Souptick Joarder <jrdr.linux@gmail.com>
> Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
>=20
> Signed-off-by: Thomas Hellstrom <thellstrom@vmware.com>

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
>   mm/memory.c | 10 ++++++----
>   1 file changed, 6 insertions(+), 4 deletions(-)
>=20
> diff --git a/mm/memory.c b/mm/memory.c
> index e11ca9dd823f..a95b4a3b1ae2 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2144,7 +2144,7 @@ static vm_fault_t do_page_mkwrite(struct vm_fault *=
vmf)
>   	ret =3D vmf->vma->vm_ops->page_mkwrite(vmf);
>   	/* Restore original flags so that caller is not surprised */
>   	vmf->flags =3D old_flags;
> -	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
> +	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_RETRY | VM_FAULT_NOPAGE))=
)

A very minor nit, for consistency elsewhere in mm/memory.c,
could you make this be:
	(VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)

>   		return ret;
>   	if (unlikely(!(ret & VM_FAULT_LOCKED))) {
>   		lock_page(page);
> @@ -2419,7 +2419,7 @@ static vm_fault_t wp_pfn_shared(struct vm_fault *vm=
f)
>   		pte_unmap_unlock(vmf->pte, vmf->ptl);
>   		vmf->flags |=3D FAULT_FLAG_MKWRITE;
>   		ret =3D vma->vm_ops->pfn_mkwrite(vmf);
> -		if (ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE))
> +		if (ret & (VM_FAULT_ERROR | VM_FAULT_RETRY | VM_FAULT_NOPAGE))
>   			return ret;
>   		return finish_mkwrite_fault(vmf);
>   	}
> @@ -2440,7 +2440,8 @@ static vm_fault_t wp_page_shared(struct vm_fault *v=
mf)
>   		pte_unmap_unlock(vmf->pte, vmf->ptl);
>   		tmp =3D do_page_mkwrite(vmf);
>   		if (unlikely(!tmp || (tmp &
> -				      (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
> +				      (VM_FAULT_ERROR | VM_FAULT_RETRY |
> +				       VM_FAULT_NOPAGE)))) {
>   			put_page(vmf->page);
>   			return tmp;
>   		}
> @@ -3494,7 +3495,8 @@ static vm_fault_t do_shared_fault(struct vm_fault *=
vmf)
>   		unlock_page(vmf->page);
>   		tmp =3D do_page_mkwrite(vmf);
>   		if (unlikely(!tmp ||
> -				(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
> +				(tmp & (VM_FAULT_ERROR | VM_FAULT_RETRY |
> +					VM_FAULT_NOPAGE)))) {
>   			put_page(vmf->page);
>   			return tmp;
>   		}
>=20

