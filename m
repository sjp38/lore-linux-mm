Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40388C00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:28:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0815A20818
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 18:28:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0815A20818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 82C4F8E00A7; Thu, 21 Feb 2019 13:28:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DB4A8E00A5; Thu, 21 Feb 2019 13:28:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CB138E00A7; Thu, 21 Feb 2019 13:28:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 41B178E00A5
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 13:28:35 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id p5so27431300qtp.3
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 10:28:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=BwwjM13bvkzDkzIha8/+5iNh/bZZ+kObCZSJEZOW+Rk=;
        b=BOKQyMPyy4lg7OlklDRjpn9KmfgHjXlvaYqnD3k5dTiC1N9MaFfS4uFxwH75mtm2zL
         6RhAFSb6IoDnXJ3MjSsY26SLhpE1cjkvP13/4HHGovNEbpu48GRDUrJlCcfM0s/wwbH8
         x03iTCP++65Wi1cKnOTTEdq8fqJ1YqhbXSx52I/M9Q4l4S6vnWFJ9Tb/2WiFxNqZ7yyE
         1++WizhVdsTxAjhhLzrp9Dm6FXRL7O+GhbIj7+7+QllMuhoFk6YavI2yx2VfbRmG6sW5
         1SM+1evZs178oWLze49fKUJbkpw7OSPLEVe1w2NMukPpmRSTj/qtzXPpxU+N/BwH3Z6m
         o4Rw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZeDV/lGVwqawFLoX05ltqgNx3dkCasYftJFnsIMvN2alcttK9U
	UOLCfR2cCM2+pBLvJx1+CHZhquUYW5tbLAiuTGD0bEtR78x74ksN6+awRL6fXz/AizXon0+3Oy6
	pCSm/AH/SfEU3cYtneaYLENgdFa+l3eOEREPpAhOL23EpT8+2G1LblJcV7Tggazmo9Q==
X-Received: by 2002:a0c:a9d7:: with SMTP id c23mr8680765qvb.24.1550773715017;
        Thu, 21 Feb 2019 10:28:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaZB4aZQ0REDY8x78JnYe5a+Ph2cgg1DLgggN+d5xB9L31sYoLkq4x1+Bqtx+sbhoIOpLVI
X-Received: by 2002:a0c:a9d7:: with SMTP id c23mr8680735qvb.24.1550773714476;
        Thu, 21 Feb 2019 10:28:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550773714; cv=none;
        d=google.com; s=arc-20160816;
        b=NXCb40rrsrYnIOqqYHVeM1IILaHn/dQm7yePYqybfJG+VJjcPkmdly3bQDvD/EVcXw
         76cerfUDcFAwvjJ+jUHFXHpY5puPgwUuKNR3/maurKoq0sI7BHBYvH89H+BtAtT4EonE
         KzvnuWfCe5XZd51vUj1nx57gq36kbqb7eJ+12uusLpdRSF0NKv1ZmGrnm3zGmytyvt6A
         kC/8pBTfMsEHQBV5IE0+iYyoJY0oCsXKBRnZCJIw5NrkyyPi38t+KhXDimxMCWcsdamd
         0G1VqddEKhLpSWeHFGm8mobnbxVrBO/+Uqhp+LfAktKNYUTCA+34Q4AA4okNOKY62A7T
         CL2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=BwwjM13bvkzDkzIha8/+5iNh/bZZ+kObCZSJEZOW+Rk=;
        b=Sd4K3F1RPlh4koyWp4+/5S7PkvUQ20zPSDV09z/xDObj2ksJEKMgiz2DHnBcRptj1s
         Ir76hn32vzJibsmYOZ/jS97lhvnuIwuC6mgvXA7kp1An7+8N+TpVW6sLjkbuctl+62vi
         CCXG1EuQnq0m9qKcU5VxsKIffYIONnSv8odwBAz6KXzBTCWioX3TLp1mvtPVFJ3oOUUN
         2V9K3uSU1+HfAzGascQScPbOllKlgh3fDTjVvNGi5CaQCRiT1Pq7LS+pypTQW0/xDvmC
         VQoUBJUeTUQc4WyYQ9QNN4//5kOWtyXYF8N4cCIhq9LPoRLbqcbxpX9belZ5x3/mAKBL
         ILkA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i14si1428qkg.219.2019.02.21.10.28.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 10:28:34 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9EE1B5AFE3;
	Thu, 21 Feb 2019 18:28:33 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 590065D704;
	Thu, 21 Feb 2019 18:28:27 +0000 (UTC)
Date: Thu, 21 Feb 2019 13:28:25 -0500
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
Subject: Re: [PATCH v2 21/26] userfaultfd: wp: add the writeprotect API to
 userfaultfd ioctl
Message-ID: <20190221182825.GA4198@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-22-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190212025632.28946-22-peterx@redhat.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 21 Feb 2019 18:28:33 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:27AM +0800, Peter Xu wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> v1: From: Shaohua Li <shli@fb.com>
> 
> v2: cleanups, remove a branch.
> 
> [peterx writes up the commit message, as below...]
> 
> This patch introduces the new uffd-wp APIs for userspace.
> 
> Firstly, we'll allow to do UFFDIO_REGISTER with write protection
> tracking using the new UFFDIO_REGISTER_MODE_WP flag.  Note that this
> flag can co-exist with the existing UFFDIO_REGISTER_MODE_MISSING, in
> which case the userspace program can not only resolve missing page
> faults, and at the same time tracking page data changes along the way.
> 
> Secondly, we introduced the new UFFDIO_WRITEPROTECT API to do page
> level write protection tracking.  Note that we will need to register
> the memory region with UFFDIO_REGISTER_MODE_WP before that.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> [peterx: remove useless block, write commit message, check against
>  VM_MAYWRITE rather than VM_WRITE when register]
> Signed-off-by: Peter Xu <peterx@redhat.com>

I am not an expert with userfaultfd code but it looks good to me so:

Also see my question down below, just a minor one.

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  fs/userfaultfd.c                 | 82 +++++++++++++++++++++++++-------
>  include/uapi/linux/userfaultfd.h | 11 +++++
>  2 files changed, 77 insertions(+), 16 deletions(-)
> 

[...]

> diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
> index 297cb044c03f..1b977a7a4435 100644
> --- a/include/uapi/linux/userfaultfd.h
> +++ b/include/uapi/linux/userfaultfd.h
> @@ -52,6 +52,7 @@
>  #define _UFFDIO_WAKE			(0x02)
>  #define _UFFDIO_COPY			(0x03)
>  #define _UFFDIO_ZEROPAGE		(0x04)
> +#define _UFFDIO_WRITEPROTECT		(0x06)
>  #define _UFFDIO_API			(0x3F)

What did happen to ioctl 0x05 ? :)

