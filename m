Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D056C00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 16:07:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 240DF2084D
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 16:07:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 240DF2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ADF588E0090; Thu, 21 Feb 2019 11:07:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8F018E0002; Thu, 21 Feb 2019 11:07:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9565A8E0090; Thu, 21 Feb 2019 11:07:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6C4ED8E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 11:07:11 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id k37so27046616qtb.20
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 08:07:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=+lEt++79LSLnEqubkMvDdNhACmy8isPOksvi2/UaRhA=;
        b=SCwFAEZxTZEGN8BMsynH01MqsWqceXq0GFYC8KD4kfpB8vmwRgC+rBHxHBOYM1D7+Z
         lysJooX1UAGY8rtb05SqbNk0nKofXYY5vCHrv5w2l1+QvP/As7owRR4smSKPiXLlaEDi
         s02NFng8B2oT3+KQcGHAe+p0UnBf/ARHFSp28cQMASxbpSIxQ1NxKSGH5bDVRydRGUSB
         bmDsHbfzk5eYbs12db1ZxfMDHjrymtubeOurgQDYXtfmfqA/QzesEn19yXhFywpNMd6F
         OkYkAnCqOdgI2XwQB5jCXoxg+HTVP5DVQnZ/xVWa7DXMewOFEwK4s+/CK+HD1+PqiMyO
         oBpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuY6oPAoshunwAl2U79xoYHoWKERyyf9y4Vcdj1U8VsYpRBrq9y6
	f0skpgNnLnd7Xh2QZHBMc9FiF5619jHP6iOhJjzZBAyNNnT8O0NU0imcEY5ACNBZdQokfGN86VN
	Y4VOwQkCM8KPAZw83FxUd05hQDMK/wyhR0MOOHFw0Y30EDxE3smR6dH+OBjI1gC8zfQ==
X-Received: by 2002:aed:314b:: with SMTP id 69mr438072qtg.247.1550765231117;
        Thu, 21 Feb 2019 08:07:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYbs5nna6i+xvaALRCHShBnbxHKL7EIYcjTayiZLtmuU05wPWFgRcU4u5qsLR4gXAd3fHAH
X-Received: by 2002:aed:314b:: with SMTP id 69mr438021qtg.247.1550765230402;
        Thu, 21 Feb 2019 08:07:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550765230; cv=none;
        d=google.com; s=arc-20160816;
        b=zwOpacHZENzwOvb8AXYKe+G5BB7KlAIyMk8dZBHZNeju9ypr2vfSyCIkjI+7Fi6Gve
         VJM/W6CjKi4fS+Xlbm5TOTLSd71qtxj0fjsbHES2ejFG9ZCk3q6Qxgf8Bpeez88bfO9B
         laeEDxLw/PHCVMB1I+taUp0CAb1UfuhAcsiCIosgzeSoywjcb6nkrdf5ADLxZjGBE0yM
         7upyp8lwA22HmoQV8bwCHP8mwhI8IUhAB4vp7VsK8wj48WgmX4KmPPglHvs5vfXx2ACc
         YmiT6VyFpEHSUL0WB2Gd+hIpjD/EKQo1Slo3bBA9Gqhjmhn9jQGicHWgGe8KfNI4yECf
         mJaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=+lEt++79LSLnEqubkMvDdNhACmy8isPOksvi2/UaRhA=;
        b=CC8y1Elqd0Yz0bacl5QrkElD0OZYqvfUKt68RZtAdsvEyoEPQNPlNPbtM/nalfNQwW
         iRepIoz7AfUj9PFFX50G+ZZwsIKft+yAQQ5rOvdne1WO9QarPrRAI/fYuqBOugC7zdga
         H+RhNChyv4ElLMdtQ2BOlvrHClCt5ujMctcfTW2oQ/6epkpYpJuY90QJh194phg5UW4Z
         9BFpjYLUeIbxBGa+Q0osQtYIX6YU++QIxDiNoWyU+az7mHw2ngzbK9qCddYopakC3J7G
         jlLGkWQgDeiLnmyhwA2dkyw3dPqQUouEt88ToiFrorRCRF0fCaxRI7nOIqPImvWLPLKj
         G2BQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g11si869873qtc.86.2019.02.21.08.07.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 08:07:10 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5B3D537F46;
	Thu, 21 Feb 2019 16:07:09 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id DBE9A1001DD8;
	Thu, 21 Feb 2019 16:06:57 +0000 (UTC)
Date: Thu, 21 Feb 2019 11:06:55 -0500
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
Subject: Re: [PATCH v2 05/26] mm: gup: allow VM_FAULT_RETRY for multiple times
Message-ID: <20190221160612.GE2813@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-6-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190212025632.28946-6-peterx@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 21 Feb 2019 16:07:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:11AM +0800, Peter Xu wrote:
> This is the gup counterpart of the change that allows the VM_FAULT_RETRY
> to happen for more than once.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  mm/gup.c | 17 +++++++++++++----
>  1 file changed, 13 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index fa75a03204c1..ba387aec0d80 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -528,7 +528,10 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
>  	if (*flags & FOLL_NOWAIT)
>  		fault_flags |= FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT;
>  	if (*flags & FOLL_TRIED) {
> -		VM_WARN_ON_ONCE(fault_flags & FAULT_FLAG_ALLOW_RETRY);
> +		/*
> +		 * Note: FAULT_FLAG_ALLOW_RETRY and FAULT_FLAG_TRIED
> +		 * can co-exist
> +		 */
>  		fault_flags |= FAULT_FLAG_TRIED;
>  	}
>  
> @@ -943,17 +946,23 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
>  		/* VM_FAULT_RETRY triggered, so seek to the faulting offset */
>  		pages += ret;
>  		start += ret << PAGE_SHIFT;
> +		lock_dropped = true;
>  
> +retry:
>  		/*
>  		 * Repeat on the address that fired VM_FAULT_RETRY
> -		 * without FAULT_FLAG_ALLOW_RETRY but with
> +		 * with both FAULT_FLAG_ALLOW_RETRY and
>  		 * FAULT_FLAG_TRIED.
>  		 */
>  		*locked = 1;
> -		lock_dropped = true;
>  		down_read(&mm->mmap_sem);
>  		ret = __get_user_pages(tsk, mm, start, 1, flags | FOLL_TRIED,
> -				       pages, NULL, NULL);
> +				       pages, NULL, locked);
> +		if (!*locked) {
> +			/* Continue to retry until we succeeded */
> +			BUG_ON(ret != 0);
> +			goto retry;
> +		}
>  		if (ret != 1) {
>  			BUG_ON(ret > 1);
>  			if (!pages_done)
> -- 
> 2.17.1
> 

