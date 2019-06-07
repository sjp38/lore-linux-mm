Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86356C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 23:00:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DECA206E0
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 23:00:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DECA206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D589B6B0276; Fri,  7 Jun 2019 19:00:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE3156B0278; Fri,  7 Jun 2019 19:00:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B82786B0279; Fri,  7 Jun 2019 19:00:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7CA036B0276
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 19:00:25 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y7so2484733pfy.9
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 16:00:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=YSAivd3bLUAYg13fwhhXcywSQNA5yynTwV28CEy07yw=;
        b=EMD7/VKxf0V0O1+WeonYOieZBhQwNtxBNHRdGxbWMA/WF6BCqYgZJjVDxMrOwHtQNZ
         +rHsbw3ozeiK0mvSL2jcaggG0y4GzNQbwOdfdIClQ5sFOLleGAY0c3PQSGJiixuueiLH
         PfmbfcbnrYEvP5QWnHbZ1LRTXPX8bE+GZk8NQVJt+4uobTt4O3qWWm/I8Bu+lgNlU8G0
         irh0u1ePI0VUrtQzmgtwZKYUZZlQKwHpFt1u7vSgE5DrQC0R4pgTNOoPn55Q4YdOQFwK
         y7hjSRBCAImDACNVrJbHbQ7Kz/CZKGXJbUnhwZ0uG157kQjXp223pjADYEI0Vcs718ZL
         vegA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW+kvi8AK7bxr9XI7sJZeSQrloAQ4PmOcmuNpIYdEP+gqWrF4+l
	QE08RTENkcL1/EX4rEUoHDA5PL9NBz5cFsS140lyEhZa7kG/pLAndD3NrhqdGiAWGpoiPUvnbsD
	3UkH2U2nf5pGj0Dwe+NUdAhE+RUfXNHuwIxmlsDv6ihRtZ0w+5nAVTV5LvbjvPst1rA==
X-Received: by 2002:a17:90a:cb12:: with SMTP id z18mr7927970pjt.82.1559948425182;
        Fri, 07 Jun 2019 16:00:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyEfiKuqgT4XGXggB8qgrAFbdCMxJRy/KX6lf1ZjjcbUeJoF7h97nbmQh1wHvurxyTOn2Co
X-Received: by 2002:a17:90a:cb12:: with SMTP id z18mr7927924pjt.82.1559948424571;
        Fri, 07 Jun 2019 16:00:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559948424; cv=none;
        d=google.com; s=arc-20160816;
        b=GZosTICQcUOTJyGM5oKDma4ZMis6NpBa9DWRZGd2WDcw6xRkMhTCpOCpaR23su96HI
         uxJYjtnI/w0r6uCqj6rlrC53qK2WsNpokmGoeHvurI9SFXK4nAKieDozf0sPRoyyLHyR
         Iluy6f6Dti4F5iEdhGb+5UqvCKhwXzfIdpFraEhvRMhkeQti+uo+DNSsglf+mm92S885
         FRTKZTcrX5ElszaxGkubc1IzxT3Fq88C0oBWmAw4kMg+zvopryvGWoH9Sf154nhDgdVA
         aU1QPHEqUQUDhQ6Dtc8pF8ePIzBNl5rC6MvgF1O0RdUBXlx5HRW2Q6kvpVb3vRngtc+q
         wGSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=YSAivd3bLUAYg13fwhhXcywSQNA5yynTwV28CEy07yw=;
        b=dXB++/b2Dg1N6Qjl8rpOC47Slx46Lope8+41frWPBUYQhyjBLL+CZX6hdMB8sHQadk
         fB/jt0xyVi9Q1UUeSNdVBGqMzVNRC2/RMYlzIUYHIcbhLXc270wvel4lYUDiMB8b1i4D
         7uEwGwhLf9mETjMmSEgsOD2t6N4pXE1ywRIsOJdmcc5jIucLrkiKM1xFpwYmSXqKHo5j
         eLrN0F8oNe0kZw7ZSebyGRGzUV8hY/UlOPqOUjIQMG7FZY3EhTS3Uc6SL6Ue7PQc5xFX
         na/UsEuZzvmvzFv9SraCipsAklgZTKw8AVQrDFQsp9OIriUZvS6xMSi4E9dSr3oexhYV
         x4iw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id b6si3294288pgq.465.2019.06.07.16.00.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 16:00:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Jun 2019 16:00:24 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 07 Jun 2019 16:00:23 -0700
Date: Fri, 7 Jun 2019 16:01:37 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [PATCH v2 hmm 09/11] mm/hmm: Poison hmm_range during unregister
Message-ID: <20190607230136.GH14559@iweiny-DESK2.sc.intel.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-10-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190606184438.31646-10-jgg@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 03:44:36PM -0300, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> Trying to misuse a range outside its lifetime is a kernel bug. Use WARN_ON
> and poison bytes to detect this condition.
> 
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> ---
> v2
> - Keep range start/end valid after unregistration (Jerome)
> ---
>  mm/hmm.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 6802de7080d172..c2fecb3ecb11e1 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -937,7 +937,7 @@ void hmm_range_unregister(struct hmm_range *range)
>  	struct hmm *hmm = range->hmm;
>  
>  	/* Sanity check this really should not happen. */
> -	if (hmm == NULL || range->end <= range->start)
> +	if (WARN_ON(range->end <= range->start))
>  		return;
>  
>  	mutex_lock(&hmm->lock);
> @@ -948,7 +948,10 @@ void hmm_range_unregister(struct hmm_range *range)
>  	range->valid = false;
>  	mmput(hmm->mm);
>  	hmm_put(hmm);
> -	range->hmm = NULL;
> +
> +	/* The range is now invalid, leave it poisoned. */
> +	range->valid = false;

No need to set valid false again as you just did this 5 lines above.

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> +	memset(&range->hmm, POISON_INUSE, sizeof(range->hmm));
>  }
>  EXPORT_SYMBOL(hmm_range_unregister);
>  
> -- 
> 2.21.0
> 

