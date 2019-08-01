Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88A51C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:43:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24786206A2
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:43:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24786206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC89F8E0005; Thu,  1 Aug 2019 02:43:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A78D18E0001; Thu,  1 Aug 2019 02:43:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 968048E0005; Thu,  1 Aug 2019 02:43:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7641E8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 02:43:40 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x1so63922605qts.9
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 23:43:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=a7uMtE+WKeMUwjpB1BJNmYTh2xrcyNJ4ICGUh31j624=;
        b=gfuAWAOMUy6ndI3F2zCAH5cP3+jaGrVBG6HqE/uI8R5ykrV3hyC1vNhvUTAFjrU2lG
         uDlf+556Zhju7tKYz4uW4Ml8YlOfyrxEooA6H4ZM9Utp4IH4xQli3Hu5pNYbtpNrVL+C
         5iQ+SQZgVW/oJQyci9Jy7PU9h399iksYYaWXFBi1gpDAwjq20sBpCy390a76O0lz2bPA
         DVRRry5DZRp6r4sdabPORxXVxpIF8yH4r6mcMC1tSM3TNwoSZJjKdLp4omiicBBVftQE
         B+zj+P2DmEGOSpFC2mCAcVlu3hBS4juwT1jnROcF1vtjH/6CdbcWL02itmEhZLboAW7p
         kT2w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of pagupta@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pagupta@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW2YW0kLlMYJ4tnw4b5NnJP2r2Dkt8uUF6UGffYjN25DzkDogvO
	daYkT+pQhfSp1EUDLin9ul4L6lOJ8XC0Bs6UhwHgy0Qyn1I1Ej77IscNMhhrOr/csWBtxqP4jru
	C5gKPe2IdplS2BZdGQeZ9p02xKz3B9SqS/1wGiy3DVlbstx5++f/mENKLgkwz0YnrKA==
X-Received: by 2002:a37:7844:: with SMTP id t65mr85995320qkc.166.1564641820283;
        Wed, 31 Jul 2019 23:43:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBTQ9FVBBvuxfcvKIqtscqhdBdu+57zPMLaL/M2bZH8hmbWxRjD2ypNJa3bzoigKBgVaz3
X-Received: by 2002:a37:7844:: with SMTP id t65mr85995298qkc.166.1564641819774;
        Wed, 31 Jul 2019 23:43:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564641819; cv=none;
        d=google.com; s=arc-20160816;
        b=b5KFN9DlHpjhb5rv6gj4m/2bHcoDlKxZs8oI6MnMSvObU41BjLqg4MNRSDKSO0/Iqz
         jJecnwz8FQNyJepKsEO1RsbXZcVjN/e7d790NdQTm92xghtIZmX6abANFAKo/K42C+kg
         EP3CrY+Ovreujrr2eFkUyNQ0p3BD0JnUlta7dfz87Pd3EdQsGRpzNgVnqfBHpSt0xVnA
         X3FCNLkJ7VI1Zc1crmB5l4bupoVDSEI/6TRXFCYgeqT6Bin6HwvXZBq2ynJFxIaKebjN
         bKtNzCFl/2duxCBEAgjCZFKVc3ORcYoRsJaufiY70iR6ihp/8KOZZyNmgkS8+P7VbnsB
         j5oA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date;
        bh=a7uMtE+WKeMUwjpB1BJNmYTh2xrcyNJ4ICGUh31j624=;
        b=xukvgOXmtH1DYnoMNnDYDzAcbDtCug5mQJ2RxT/knKEPfqNqP3dvF6ilPCvTmhGBg0
         s/kvJw92VI4MYkXu0LoGusD8bPf3XNamxgB9YH5vTzS28HzOH+NHwrrX0+RlKm6JFfx9
         ZU8rlGICCARa0PmNUn+h97FQGH/CeQWwGsv+p152ABOjUflQg+T7YHEPC/9kGnZENFg4
         oSfCpcBoSHD4MuEpJqc/U1cVdCl59toArbkU/fRFBSmX53ZpSDyiTnOKRM7zDxSNpppS
         8Oak7bThD5qdWXRFk9zwDOdtHHah+kBz6OicXaBTwJ4sPakTZWhC+dWatNI06HRetQnG
         5lSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of pagupta@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pagupta@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w23si40481472qtw.202.2019.07.31.23.43.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 23:43:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of pagupta@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of pagupta@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pagupta@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0872530833A5;
	Thu,  1 Aug 2019 06:43:39 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.20])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id F202860BE0;
	Thu,  1 Aug 2019 06:43:38 +0000 (UTC)
Received: from zmail21.collab.prod.int.phx2.redhat.com (zmail21.collab.prod.int.phx2.redhat.com [10.5.83.24])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id E31C51800202;
	Thu,  1 Aug 2019 06:43:38 +0000 (UTC)
Date: Thu, 1 Aug 2019 02:43:38 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Message-ID: <1944499597.6210303.1564641818536.JavaMail.zimbra@redhat.com>
In-Reply-To: <1564640896-1210-1-git-send-email-rppt@linux.ibm.com>
References: <1564640896-1210-1-git-send-email-rppt@linux.ibm.com>
Subject: Re: [PATCH] mm/madvise: reduce code duplication in error handling
 paths
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.67.116.181, 10.4.195.4]
Thread-Topic: mm/madvise: reduce code duplication in error handling paths
Thread-Index: epQ2HTIRhoW+wkIZZblxwj+pESe04w==
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Thu, 01 Aug 2019 06:43:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


> 
> The madvise_behavior() function converts -ENOMEM to -EAGAIN in several
> places using identical code.
> 
> Move that code to a common error handling path.
> 
> No functional changes.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  mm/madvise.c | 52 ++++++++++++++++------------------------------------
>  1 file changed, 16 insertions(+), 36 deletions(-)
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 968df3a..55d78fd 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -105,28 +105,14 @@ static long madvise_behavior(struct vm_area_struct
> *vma,
>  	case MADV_MERGEABLE:
>  	case MADV_UNMERGEABLE:
>  		error = ksm_madvise(vma, start, end, behavior, &new_flags);
> -		if (error) {
> -			/*
> -			 * madvise() returns EAGAIN if kernel resources, such as
> -			 * slab, are temporarily unavailable.
> -			 */
> -			if (error == -ENOMEM)
> -				error = -EAGAIN;
> -			goto out;
> -		}
> +		if (error)
> +			goto out_convert_errno;
>  		break;
>  	case MADV_HUGEPAGE:
>  	case MADV_NOHUGEPAGE:
>  		error = hugepage_madvise(vma, &new_flags, behavior);
> -		if (error) {
> -			/*
> -			 * madvise() returns EAGAIN if kernel resources, such as
> -			 * slab, are temporarily unavailable.
> -			 */
> -			if (error == -ENOMEM)
> -				error = -EAGAIN;
> -			goto out;
> -		}
> +		if (error)
> +			goto out_convert_errno;
>  		break;
>  	}
>  
> @@ -152,15 +138,8 @@ static long madvise_behavior(struct vm_area_struct *vma,
>  			goto out;
>  		}
>  		error = __split_vma(mm, vma, start, 1);
> -		if (error) {
> -			/*
> -			 * madvise() returns EAGAIN if kernel resources, such as
> -			 * slab, are temporarily unavailable.
> -			 */
> -			if (error == -ENOMEM)
> -				error = -EAGAIN;
> -			goto out;
> -		}
> +		if (error)
> +			goto out_convert_errno;
>  	}
>  
>  	if (end != vma->vm_end) {
> @@ -169,15 +148,8 @@ static long madvise_behavior(struct vm_area_struct *vma,
>  			goto out;
>  		}
>  		error = __split_vma(mm, vma, end, 0);
> -		if (error) {
> -			/*
> -			 * madvise() returns EAGAIN if kernel resources, such as
> -			 * slab, are temporarily unavailable.
> -			 */
> -			if (error == -ENOMEM)
> -				error = -EAGAIN;
> -			goto out;
> -		}
> +		if (error)
> +			goto out_convert_errno;
>  	}
>  
>  success:
> @@ -185,6 +157,14 @@ static long madvise_behavior(struct vm_area_struct *vma,
>  	 * vm_flags is protected by the mmap_sem held in write mode.
>  	 */
>  	vma->vm_flags = new_flags;
> +
> +out_convert_errno:
> +	/*
> +	 * madvise() returns EAGAIN if kernel resources, such as
> +	 * slab, are temporarily unavailable.
> +	 */
> +	if (error == -ENOMEM)
> +		error = -EAGAIN;
>  out:
>  	return error;
>  }

looks good.

Acked-by: Pankaj Gupta <pagupta@redhat.com>

> --
> 2.7.4
> 
> 

