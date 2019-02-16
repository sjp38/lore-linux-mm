Return-Path: <SRS0=AfK9=QX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E078C43381
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 03:25:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E14D6222A1
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 03:25:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E14D6222A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4237A8E0002; Fri, 15 Feb 2019 22:25:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3ACBB8E0001; Fri, 15 Feb 2019 22:25:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 275768E0002; Fri, 15 Feb 2019 22:25:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id EBCFA8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 22:25:22 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id q17so10806480qta.17
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 19:25:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=B/BQUIknTyy/s4WMR9WaEytvAioBqctQ22DeQCXeT4c=;
        b=K2mj+hRw1TN3LTUt0ddC9Do9UJDoN+TUzz6bHY9ZJ4DE8VIfYzIkH/l2wsJXQYZSQw
         mtRLeuEEVlOb2BCoJAoWE9lURRn+JE6QFF+X5sNB8C+RiHGSOjJo/zhjteM7oGcw3POX
         c2hSSCxP+88EgZaC6YxW3XASzkfR3zVTrvzRVVSL8lTDhaJ9Sxyo3GnH0VO0vNmA+8RL
         vNDvJhQkXUWqDSsScA/AOrZ+OvASHKGT0uRWZNfeIzv9wva8UyQYAstxNyM/PPQD2MOD
         gWuXC8QYzFW7ngjRbOW5GvFsktEqQznE2x5nlQedXSdbzVjS5p9ITHQdmyyXZlOsynSb
         h9mQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYWjTNA4yIdHNySC2X+iQL2aZa5yEd/QW6eTneamQc1/BW6xXB5
	YuIDXHX/qQcotlKMTNC+s2KYfkpLJdNBqRcAbVwgcqpSub4X5IrNwY5Ey3HG3N9UzaA8UNBdaBi
	iURVSQCLUKp09SkV0O2Nraq1zefxCJ1VcM+yc9xakgGCNrszufq2l/FGJSmvYpz1ayA==
X-Received: by 2002:ae9:d8c5:: with SMTP id u188mr9436318qkf.356.1550287522678;
        Fri, 15 Feb 2019 19:25:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbJxUkOOYpH8mVUzU9avey+vPUH1zlAAZLpII+o3TN927yJDHoFuWcO5Ym4ZdQXhKBiBz0t
X-Received: by 2002:ae9:d8c5:: with SMTP id u188mr9436299qkf.356.1550287522069;
        Fri, 15 Feb 2019 19:25:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550287522; cv=none;
        d=google.com; s=arc-20160816;
        b=JqrbzFolUwnQ1UtComyMhMUXOLxsAAsGdl7f4swLMuJRjrUEGCohOJ1Bbkh1pCxi8h
         q/TcJyspj6M5fImoi80blcsG+fduI+EBUoJ/TJtYPN7EIMhevyDdO95UBEuaJXmXA0oC
         pDKRCVOKI1x5+dywpl9mAOxMlOWSmhk90ecqZP+i5+cQP3Oa3I1iPZh/8Zwgem4AAVov
         uc3/T2qbDA2T6fA39WB1NwoJpQnNv9EDZRJurjoj47oDSY6718AaTemf4AZJW6w/Bfp9
         8ji7LJYHqe7jEnLsJmDhqjw1q2dyVfq/bKepdLihw6MSj1IxwVVwWRsWp9EfHhuDTxik
         zRbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=B/BQUIknTyy/s4WMR9WaEytvAioBqctQ22DeQCXeT4c=;
        b=Im+1quNY8FwknpJoQ7QCpC8+MbNPYxb9j96lV+hJn7b0LphdhGnAPUbwdfJ7BmIsHA
         ObSZdvPoq1Bop1F/NC1UcMJ2jBIGACbTtGV8wV2pGzS0OOxaMyEemFCSNWTIFFaKyXTY
         koG77buakb961Fame57GJjoyG9fttlAoNFaWTrRrIs+hV9pcy2Vih1gTr0Ieaw0mPr96
         qbBDbWKD8KW7iNa87xUzrLSLeZhIa2Gl8DczdRl/tYjtTJ7LPeFllMqFK0jrd8kz46ax
         t/hE+l56ve04zGt0anYZP1o/WzzceU54jnCjficczLq+FPfBJbhG0ETZ/jEnSdDnjQe5
         eOqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 51si1574015qtu.326.2019.02.15.19.25.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 19:25:22 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 07886127931;
	Sat, 16 Feb 2019 03:25:21 +0000 (UTC)
Received: from redhat.com (ovpn-121-232.rdu2.redhat.com [10.10.121.232])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 269D3611C2;
	Sat, 16 Feb 2019 03:25:20 +0000 (UTC)
Date: Fri, 15 Feb 2019 22:25:18 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: rcampbell@nvidia.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH] mm/hmm: Fix struct hmm memory leak
Message-ID: <20190216032517.GB13561@redhat.com>
References: <20190215215922.29797-1-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190215215922.29797-1-rcampbell@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Sat, 16 Feb 2019 03:25:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 01:59:22PM -0800, rcampbell@nvidia.com wrote:
> From: Ralph Campbell <rcampbell@nvidia.com>
> 
> The patch [1] introduced reference counting on struct hmm and works
> fine when calling hmm_mirror_register() and hmm_mirror_unregister().
> However, when a process exits without explicitly unregistering,
> the MMU notifier callback hmm_release() doesn't release the mirror->hmm
> reference and thus leaks the struct hmm allocation.
> Fix this by releasing the reference in hmm_release().
> 
> [1] https://marc.info/?l=linux-mm&m=154878089214597&w=2
>     ("mm/hmm: use reference counting for HMM struct")

NAK we do not want to free stuff from underneath the driver that
was the whole point of the refcounting. Instead for driver that
want to free their mirror from the release call back can call the
hmm_mirror_unregister() function safely. Sorry if that was not
clear.

> 
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: "Jérôme Glisse" <jglisse@redhat.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> ---
>  mm/hmm.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 3c9781037918..50523df6ea0c 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -179,6 +179,8 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>  			mirror->ops->release(mirror);
>  			down_write(&hmm->mirrors_sem);
>  		}
> +		hmm_put(mirror->hmm);
> +		mirror->hmm = NULL;
>  		mirror = list_first_entry_or_null(&hmm->mirrors,
>  						  struct hmm_mirror, list);
>  	}
> -- 
> 2.17.2
> 

