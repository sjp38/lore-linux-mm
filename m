Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A5C3C282E1
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 14:55:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC6E720874
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 14:55:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC6E720874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B97D6B0003; Mon, 22 Apr 2019 10:55:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76A7F6B0006; Mon, 22 Apr 2019 10:55:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 681226B0007; Mon, 22 Apr 2019 10:55:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 476E06B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 10:55:53 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id y11so11893670qtb.6
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 07:55:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=YBrjvnQnYPYeAwmo0xvknuKZqa8tuoNbw4Ef9y3Vo5U=;
        b=Y+10RUVLUuVIiqoD15FyDjl5FGofYA9hecTr734CTyt9jrXASO+HR2Ss1a5VZueZ8G
         6E3H15iLMjFtvN1d1gKoGY/Ii/dC/HWYch8qcsUTu1atHcx9DhOgDxqG0rBLu58TRrJE
         jP0LZ+cp/xQo/boN4PCs4AEBPMxV450JXYFnGbcOjas2gfYVzc1viYGpBu6AipMqDgvz
         2qgPDLaXksDDRJhP939TL41EUTcvK5CqCglKxo2Psq1yQsilz9lp9fks5jBDj2sj8na9
         nIO6/1lqzuY1XBG/cSPckL6g4igltAlra+JkGAfrDYtrGXYGAoCUUYEM9RYIJQxrnJOT
         ad7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVR3f7+44fSSWuXy1vDh9rWA7mWoswuTeUA5A5F61q5lWnh7pKN
	q27B6gfcTKnJ1GCUdf/OWtWoM8iXMn/CwwNlkzAQr4rVSoR6yA+k5drcr1ojJBt7h1DRDR43ULq
	jvNg4O8FstsMN45BnRqkuruZP/Bkfg3XMFGqQKh4L/inGa6W+HsfVmENPZ6UK+caWgQ==
X-Received: by 2002:ac8:45c1:: with SMTP id e1mr10629659qto.191.1555944953018;
        Mon, 22 Apr 2019 07:55:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz910U6lIMgBlemz0BMmNpcedaVhJQ+u2SooMpGjBq5VatqP2IsCJtKnu89BpiYEwLDg9FB
X-Received: by 2002:ac8:45c1:: with SMTP id e1mr10629618qto.191.1555944952394;
        Mon, 22 Apr 2019 07:55:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555944952; cv=none;
        d=google.com; s=arc-20160816;
        b=iWxNLsgPUTlegpF42+sa3eovVII3iEb18A3lgEth4cD77KhSVvxQD62bQfUqkVJMAX
         xPHz/fY+MtPKCxiLJ4X6vk485FZ8twt2Mp3hGL19Gi06ep/JDE2OydwMb+5nMAaPzT1U
         jWT2Pm13iY6lNQAAEXHC7vImtiHq5FGDV7s6HKw6Kblzx3LSGy8s4OzjLn8ipgnBsgps
         EZEctgNtC7xRXT8sOwa+t1Reu5pJi0eEcx0RM8pNjJFb/94nxIMK0YM6q8iduTHmPeO7
         HERQ5sEunzlPszNKHLLg5iFa7mRHI/L31ktgSCgtCjh4gFD7Net2B0zzOyiEe3K0hA0e
         zHRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=YBrjvnQnYPYeAwmo0xvknuKZqa8tuoNbw4Ef9y3Vo5U=;
        b=HNhIfQBOEq6rhsekq6H15n5jAvOjxItQWd5NLVr80w+5ctg8YWXGplQNq5GjXnkPDL
         Pk7ByviOpcpALEEVZ5gtygfUXTplTm1oNzR5M9t2clsJcA/wR4iODnaghm8SqaDi8Ekz
         TB3yoeFNf6YfZvUsMTDXRhKEhTZ0Zj8+s6RP/hvmK2dXBCytY+mzJIJoVBJVag6lJlv1
         tPJXPg1KLd8jmj4kmYynKIDBsAVUfe2qeBR/JpH72Ec7GGLN0exMLH+lKs1ZBxVeN/I2
         k2Q5ilTgSPIEB6znOvIC/qjmHoWxIQNfPPy3kc3DmYh7MqO0+r0RpRYci1i0iYjmzMZb
         fVnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u13si6474199qve.103.2019.04.22.07.55.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 07:55:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 704A881F0F;
	Mon, 22 Apr 2019 14:55:51 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 401B7608E4;
	Mon, 22 Apr 2019 14:55:50 +0000 (UTC)
Date: Mon, 22 Apr 2019 10:55:48 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: rcampbell@nvidia.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Ira Weiny <ira.weiny@intel.com>, John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND PATCH] mm/hmm: Fix initial PFN for hugetlbfs pages
Message-ID: <20190422145548.GC3450@redhat.com>
References: <20190419233536.8080-1-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190419233536.8080-1-rcampbell@nvidia.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Mon, 22 Apr 2019 14:55:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 19, 2019 at 04:35:36PM -0700, rcampbell@nvidia.com wrote:
> From: Ralph Campbell <rcampbell@nvidia.com>
> 
> The mmotm patch [1] adds hugetlbfs support for HMM but the initial
> PFN used to fill the HMM range->pfns[] array doesn't properly
> compute the starting PFN offset.
> This can be tested by running test-hugetlbfs-read from [2].
> 
> Fix the PFN offset by adjusting the page offset by the device's
> page size.
> 
> Andrew, this should probably be squashed into Jerome's patch.
> 
> [1] https://marc.info/?l=linux-mm&m=155432003506068&w=2
> ("mm/hmm: mirror hugetlbfs (snapshoting, faulting and DMA mapping)")
> [2] https://gitlab.freedesktop.org/glisse/svm-cl-tests
> 
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>

Good catch.

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> Cc: Jérôme Glisse <jglisse@redhat.com>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Balbir Singh <bsingharora@gmail.com>
> Cc: Dan Carpenter <dan.carpenter@oracle.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Souptick Joarder <jrdr.linux@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  mm/hmm.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index def451a56c3e..fcf8e4fb5770 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -868,7 +868,7 @@ static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsigned long hmask,
>  		goto unlock;
>  	}
>  
> -	pfn = pte_pfn(entry) + (start & mask);
> +	pfn = pte_pfn(entry) + ((start & mask) >> range->page_shift);
>  	for (; addr < end; addr += size, i++, pfn += pfn_inc)
>  		range->pfns[i] = hmm_device_entry_from_pfn(range, pfn) |
>  				 cpu_flags;
> -- 
> 2.20.1
> 

