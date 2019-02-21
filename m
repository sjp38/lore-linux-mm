Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34F06C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 16:08:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE6E12083E
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 16:08:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE6E12083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BC178E0092; Thu, 21 Feb 2019 11:08:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86B2D8E0002; Thu, 21 Feb 2019 11:08:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 781CF8E0092; Thu, 21 Feb 2019 11:08:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4BCB18E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 11:08:10 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id k1so27050099qta.2
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 08:08:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=HMjCfQFzQ6fnd4OCrw+qWPIQWummTH7x+ymeNcIMDbo=;
        b=jCIbQ7eNQkH17mzpDILJVBQImYlWFCNdlF5YiypWrrwu7oLes0OOVbGzlMp4dzzZw+
         Hhy0TxTBitJSUSm6Bef0PQ5gCQh00zLtPQTJPptdGfUdSdbifI1y3IYBhPuXePrq6SNA
         kXIiTyrvWAmP1EyqsohYsZ6xU3WuDk9uYTpoPUQgs4N9QyeXMYbJbgZ1sSNhIEe7RzNO
         4IcaSHWE+ueYD+KF1fMIoW6D3o5GI+6jSK8GxfOeOMV0bnar0ZhJtCYaFKwGoBbvgz0W
         72wS28ZkffYxIEJMLfTiAzPsYANfI6LNEpujzH/Z5ED5pJctmZW/RONkDXDUOgjcWmPR
         3Viw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaVyQxQQ4vKGEbR1CIMKnvY/FBIjEOlxpNfLMTYfFnqaCn7UsLw
	H662XHlHrvwa80434bvokd2LSMhNiKcAoHXjyHeX1KdooLadpQ7U63dNuif0/YU5gttAdQbb1FK
	u4g+hclZBaOM/XxgPTU9UWAtimNw0Dqy9dbrxDoWBhFOfmJewV/C/0FDga258p+NOuA==
X-Received: by 2002:a37:d409:: with SMTP id l9mr30147554qki.211.1550765290058;
        Thu, 21 Feb 2019 08:08:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbtysctfuaA1Vb00LGxUNfYoio3yqwhaPavzedHOwDY+KSWeL6KiXLh5OQrqsFyMpfThYU2
X-Received: by 2002:a37:d409:: with SMTP id l9mr30147493qki.211.1550765289541;
        Thu, 21 Feb 2019 08:08:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550765289; cv=none;
        d=google.com; s=arc-20160816;
        b=qACkePsgUqqszpfCyyx8rkjVl33syzMKARvDpRy7gzfRYDY7Ne05b09e7dGD34/8kD
         ntlrT0aQ2TiLIEgyP0OMYrSJZy4/y4wckzQfJBCZMBLk4vXUJti+DAtvo1IA7D+vzzyt
         80Y+Z2uSmRDD8xJjOh/j/mdQVp+QdzoDvVO8SC+1f7IhrF0WDL610uMd6JFyirqtg8EJ
         nWBY/kIXb6bDUFt3RJFgxoIb3iMewt8NWVcRxP9lxwGfIc8Ho1OS7C2bZb5fscaXvpqQ
         4e6/5Lry8T3VoOKDhz5rXL8FbJjNZ1xQVVIMjnows/4flvblWVQtOC55wA8B4NGWn4JB
         1T9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=HMjCfQFzQ6fnd4OCrw+qWPIQWummTH7x+ymeNcIMDbo=;
        b=RUuGv9TI5eCCOo5psmK33KrsZ2UpCqRR9ay3Y90WAUApyX7b07mF3466+eMSHiSQwz
         NBLtGRNCViN+fcoxwoURIRu/Dh9QpgDxdQMOEClV2l/QgwmD82gn3YVaVnyvSEI++Q+I
         gzE/VIS8ZFLuYAsm3JIjwI9VdrJerSk4t2ck6DdQnxHsq7hPnvs6ZjDnO4UkkDpVaC3F
         4R/EMwqETw0C4QsuyFjN3Z2HtND0+dH9wikpKGh7taT0/Bx44/AlZc4FqLhA05vlKpKD
         N39Q/b6uj5GnWo9IEtbUMsFjsvdNkD4yvA39Ub7YzUHrsjR+UwF0WFa/5j584BJbUD+7
         CK3w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f2si2871519qve.19.2019.02.21.08.08.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 08:08:09 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8E50F3001D5F;
	Thu, 21 Feb 2019 16:08:08 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1988260C18;
	Thu, 21 Feb 2019 16:07:59 +0000 (UTC)
Date: Thu, 21 Feb 2019 11:07:58 -0500
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
Subject: Re: [PATCH v2 06/26] userfaultfd: wp: add helper for writeprotect
 check
Message-ID: <20190221160757.GF2813@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-7-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190212025632.28946-7-peterx@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Thu, 21 Feb 2019 16:08:08 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:12AM +0800, Peter Xu wrote:
> From: Shaohua Li <shli@fb.com>
> 
> add helper for writeprotect check. Will use it later.
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

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  include/linux/userfaultfd_k.h | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
> index 37c9eba75c98..38f748e7186e 100644
> --- a/include/linux/userfaultfd_k.h
> +++ b/include/linux/userfaultfd_k.h
> @@ -50,6 +50,11 @@ static inline bool userfaultfd_missing(struct vm_area_struct *vma)
>  	return vma->vm_flags & VM_UFFD_MISSING;
>  }
>  
> +static inline bool userfaultfd_wp(struct vm_area_struct *vma)
> +{
> +	return vma->vm_flags & VM_UFFD_WP;
> +}
> +
>  static inline bool userfaultfd_armed(struct vm_area_struct *vma)
>  {
>  	return vma->vm_flags & (VM_UFFD_MISSING | VM_UFFD_WP);
> @@ -94,6 +99,11 @@ static inline bool userfaultfd_missing(struct vm_area_struct *vma)
>  	return false;
>  }
>  
> +static inline bool userfaultfd_wp(struct vm_area_struct *vma)
> +{
> +	return false;
> +}
> +
>  static inline bool userfaultfd_armed(struct vm_area_struct *vma)
>  {
>  	return false;
> -- 
> 2.17.1
> 

