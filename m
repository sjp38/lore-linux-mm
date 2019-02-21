Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 345A1C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:29:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F12B32083E
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:29:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F12B32083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A4378E00A8; Thu, 21 Feb 2019 13:29:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 653A58E00A5; Thu, 21 Feb 2019 13:29:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56BAD8E00A8; Thu, 21 Feb 2019 13:29:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2F07B8E00A5
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 13:29:40 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id d13so27238239qth.6
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 10:29:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=1H6Rv1X9pgsYLGV/z2nAyr1+qh7EbRJs7xV5+BVpmmI=;
        b=lQZVecnl3duzTQnt56TH5DhBmLWJ9v2JFyrErnJnJmLsv8i+A84/urvSO2VG1tp5Yy
         7evEsw2xxyeLW/06Vw0Y+D/HN9V0g36/8InLv3PELj8zduUYdHuZOBz/4ARcSGUMCAb9
         zUhv/vEePtGrTVVLTXQfRjw1yMN1nZrSlfIaZ5msr41Sb9C6lcimPaNlWVq9huwy8GEv
         TyL0CEzGB/EwOrC9Q5O56/jluq5z6J7Lg1A0M66FxvA7XWlIwr0czy96oqUy+53F2AfX
         MECl6XETumwkIFGACrdu3P7RehT8hLkZsHqD/lRFaldES6+dyVR0q7rTXoKa7sn07fIG
         385A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubg1PhcYWitMRJ08t93s3YxWGhCxwLi1o24WmdHqaTI2t8P4v2B
	z5scdZK6Upm8wkaRjt+6X5IeAAbhBVANU4RYprKzMO75e9mlejNsVWJhH5qUA5Rv8GGajRvMspW
	g7d6ZVukjefKsqBWUAgrXj3hoACgmsRmdsSB2godIAEy4eCATq3hC09RQIqokzj48VA==
X-Received: by 2002:ac8:263d:: with SMTP id u58mr32323232qtu.295.1550773779960;
        Thu, 21 Feb 2019 10:29:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaNMtjGBuO6Hse8k6FT3Gcjs7zyYRzYFvh1dq1T2OEarrQ3Ra3S1hzWxFrB4I+AfNfgphzv
X-Received: by 2002:ac8:263d:: with SMTP id u58mr32323208qtu.295.1550773779471;
        Thu, 21 Feb 2019 10:29:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550773779; cv=none;
        d=google.com; s=arc-20160816;
        b=euXhX/iV2F6XwB4KZOO/UaCs3e69XnEU8PbcnT4NL5cHWN3cnOD9vL5kAgFArAXtAu
         mdYDLRp4adcp3z38clv5BVtAMkLBa+yMWyPHoYdcETnGIaJoXugIMsTK0LGJSRB3KpY1
         i2MTTEZgRUD2FmhK9ta86UAQpQIVdzWBINW3uTMRjN0QJWVM3VZIrs1alN3yFT3uiX1z
         9RFY/cA1Md57wNMuIhNvIPa9AMvotOVJvH/i7OpRZVsdy0SOucSgYlPcVpCAYNlwdfjX
         HjkCoEC+UrmTXlKrxVxi5nLPIQmtNfcxED2SKiX7K32tsfc8NSl/dSrxr1bAke5U0yej
         balA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=1H6Rv1X9pgsYLGV/z2nAyr1+qh7EbRJs7xV5+BVpmmI=;
        b=u/DvFJOCuXGRDjCfmQ7MvKyx8Pj047mcKewbYHLzaBxUEqJst8NdqjGOhb3ahgWM29
         H/x5RuHMfCG9Li0WIEm8HNY0IxtoHgHNf7kXM6xt/riY3FTl7hhQHJF6HelelbZHkii0
         Deuon8N3w0ALXbF5qJFfiwAz8J49Ew9IVhldJjvf+VY/+QVwLbtzv3gIXf7aaUMnBB+X
         /AKNd6PCOp5vj6a4EkVH6Y63v5gSzNJhY2cdXBiGy+knZ24JzBAM3FXASJ4qHU48k52r
         f7eR8eVp/ehpVG6SOpGrL24E0BUjMNd1HNchkGtYbjBEVHcirpBWa9qKu3kouHFrEWLL
         9KTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n11si1486335qvg.219.2019.02.21.10.29.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 10:29:39 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9471637E74;
	Thu, 21 Feb 2019 18:29:38 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 0B4035D9E1;
	Thu, 21 Feb 2019 18:29:27 +0000 (UTC)
Date: Thu, 21 Feb 2019 13:29:26 -0500
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
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH v2 22/26] userfaultfd: wp: enabled write protection in
 userfaultfd API
Message-ID: <20190221182926.GU2813@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-23-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190212025632.28946-23-peterx@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 21 Feb 2019 18:29:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:28AM +0800, Peter Xu wrote:
> From: Shaohua Li <shli@fb.com>
> 
> Now it's safe to enable write protection in userfaultfd API
> 
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Shaohua Li <shli@fb.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Peter Xu <peterx@redhat.com>

Maybe fold that patch with the previous one ? In any case:

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  include/uapi/linux/userfaultfd.h | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
> index 1b977a7a4435..a50f1ed24d23 100644
> --- a/include/uapi/linux/userfaultfd.h
> +++ b/include/uapi/linux/userfaultfd.h
> @@ -19,7 +19,8 @@
>   * means the userland is reading).
>   */
>  #define UFFD_API ((__u64)0xAA)
> -#define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK |		\
> +#define UFFD_API_FEATURES (UFFD_FEATURE_PAGEFAULT_FLAG_WP |	\
> +			   UFFD_FEATURE_EVENT_FORK |		\
>  			   UFFD_FEATURE_EVENT_REMAP |		\
>  			   UFFD_FEATURE_EVENT_REMOVE |	\
>  			   UFFD_FEATURE_EVENT_UNMAP |		\
> @@ -34,7 +35,8 @@
>  #define UFFD_API_RANGE_IOCTLS			\
>  	((__u64)1 << _UFFDIO_WAKE |		\
>  	 (__u64)1 << _UFFDIO_COPY |		\
> -	 (__u64)1 << _UFFDIO_ZEROPAGE)
> +	 (__u64)1 << _UFFDIO_ZEROPAGE |		\
> +	 (__u64)1 << _UFFDIO_WRITEPROTECT)
>  #define UFFD_API_RANGE_IOCTLS_BASIC		\
>  	((__u64)1 << _UFFDIO_WAKE |		\
>  	 (__u64)1 << _UFFDIO_COPY)
> -- 
> 2.17.1
> 

