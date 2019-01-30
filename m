Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16733C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 12:01:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD27020869
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 12:01:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD27020869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18F9C8E0002; Wed, 30 Jan 2019 07:01:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 140A48E0001; Wed, 30 Jan 2019 07:01:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 008258E0002; Wed, 30 Jan 2019 07:01:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id CA78D8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 07:01:32 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id p24so28541907qtl.2
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 04:01:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=a8TZOIdBH3LkSSC8s7VbvTzlKydlbwVIsYMGHLL2p5Y=;
        b=LbXjqs//JnUYvC87zQYkeJkcoR8/5VzdUUH186x1TcDxI5n7Az+jSYnmnnhBLSzlL2
         Hq0NVCNJjmmGf5YJ3WeATa6cNHERjPUOup69HLp/WXPlyjCUZtvNYLoXgNYHP0KOk/jE
         SA5enPKaUuglFKehdKhScM9dF3aCRBH30k1ESeN3f2letJynze/54TzW4F3GfyKdFeqM
         +Nlibbo8s+BUBXR4Dt9Ib75iqELtLvcJ1rZel05TJzaqrlmXD/RiMI0skmpaYkYXqnjc
         KpQHcn63JmpX9DaCwxYQZiHV7u0iH5yhztksvILnYrJElxkhOjDYASW/O7wfm+NuLUgg
         WkFw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukcKxTtZV4Fa76Ik5vLE1/MiPWCH9myEpDqmDnJsuKIB2fhY/cY0
	/fVJ+R2ptDRhfv699MCNkHT27DyMZC15hHIgcgHatPIIaurB+tpyAnKUsqbiHRX0cP/B6HP3oDv
	8Y3WNcNZCnGCc+yp+lbabzH5yihhT6Pz7PESKqOJHZTaoTzbA90E1pLl7cb9n+lOkDA==
X-Received: by 2002:aed:20ca:: with SMTP id 68mr29594662qtb.296.1548849692577;
        Wed, 30 Jan 2019 04:01:32 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7MFqPh1AXQAaO6YxVmHM3PCHeuu2VxDcp/emp+AAR24sr9eoGd/1UKkQCLiS6R85efcF70
X-Received: by 2002:aed:20ca:: with SMTP id 68mr29594622qtb.296.1548849692022;
        Wed, 30 Jan 2019 04:01:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548849692; cv=none;
        d=google.com; s=arc-20160816;
        b=bd3PkRVjCtwjCCZqeIkmv/VMM8OMRq7ng412vlEag8MXUFR9A39wH9Fr8+qXuAo81x
         bmwwnqnlz2FNpIAJJQRmcUO1LrzkttRJx8Kf/jVuX/KTS53xkRw5JpDzV2YlgHOtzBPk
         GhI0ElZWxl/uMvizTvpjC4tiiL5MH/q3w+/sQJeb2d5rjp5mrQGp0XwY7mSIW0jo4PG1
         cwhuA0gJDT/l9m0x+zP80drYiLPlrhylmUoqrNtysKvS1xW/uYNn5hjX3uHTBfSnC7KV
         v0YG+BP2fRp0JIzlBSBTCZsn0JzlFkzV5a1h0lvRb4PLUO2LiXO0dgl7ABULXBBXTH32
         rk3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=a8TZOIdBH3LkSSC8s7VbvTzlKydlbwVIsYMGHLL2p5Y=;
        b=Ib5gPxz8eeWQKhSwM6wy6UZ2e22ljoIYSH+zmLl1OB2ti8dCmkJy/5h/8XItoxIeUh
         9KIjGdKAwkGx2+hbVAmPNCB4BxwMRP3D1C5vpUkciMH2nGghRrRAM0MXQrsM5NxlxSqL
         JRoCj5msrAnn8r5t/d0NCu6+dy4/E2uIIZGruLFLjprTSZl1H9UUGLoaUa4hZ1OYAKFQ
         nY30Hq9va/XAnyZ8tchmEF92gudt3uMZUD7z46S3ZsL0KpCoh1oG3MPwkYDv1IXEJxlp
         FIPKi6cb1dv+Y5q1PtOnLpD7yEaGLMb0yznHSUL+Vdg24x0PXnlDsWa9dkOQaKhBscak
         94NQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e32si872331qvd.6.2019.01.30.04.01.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 04:01:32 -0800 (PST)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D8A99142C03;
	Wed, 30 Jan 2019 12:01:30 +0000 (UTC)
Received: from [10.36.117.149] (ovpn-117-149.ams2.redhat.com [10.36.117.149])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 103125C2EE;
	Wed, 30 Jan 2019 12:01:27 +0000 (UTC)
Subject: Re: [PATCH] mm: Prevent mapping typed pages to userspace
To: Matthew Wilcox <willy@infradead.org>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>,
 Michael Ellerman <mpe@ellerman.id.au>, Will Deacon <will.deacon@arm.com>
References: <20190129053830.3749-1-willy@infradead.org>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <44ea1fd9-f0ae-f031-0232-05afbd7aa7e5@redhat.com>
Date: Wed, 30 Jan 2019 13:01:23 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <20190129053830.3749-1-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Wed, 30 Jan 2019 12:01:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 29.01.19 06:38, Matthew Wilcox wrote:
> Pages which use page_type must never be mapped to userspace as it would
> destroy their page type.  Add an explicit check for this instead of
> assuming that kernel drivers always get this right.
> 
> Signed-off-by: Matthew Wilcox <willy@infradead.org>
> ---
>  mm/memory.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index ce8c90b752be..db3534bbd652 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1451,7 +1451,7 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
>  	spinlock_t *ptl;
>  
>  	retval = -EINVAL;
> -	if (PageAnon(page) || PageSlab(page))
> +	if (PageAnon(page) || PageSlab(page) || page_has_type(page))
>  		goto out;
>  	retval = -ENOMEM;
>  	flush_dcache_page(page);
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb

