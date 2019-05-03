Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A2A7C004C9
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 17:03:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 084FF2087F
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 17:03:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 084FF2087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A618B6B0005; Fri,  3 May 2019 13:03:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A12836B0006; Fri,  3 May 2019 13:03:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B5A26B0007; Fri,  3 May 2019 13:03:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3D1106B0005
	for <linux-mm@kvack.org>; Fri,  3 May 2019 13:03:22 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r8so4366687edd.21
        for <linux-mm@kvack.org>; Fri, 03 May 2019 10:03:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=56SWskVylMIZ8+l9qzqvj7MnMyRLG6uAYTXItWUnOLc=;
        b=YKmYyy3NyfQZ/cX8oyRNWZN41cjKMsAbg5dfRptnZBHzgmwr1RckShzga7U4rB9P+L
         xEF7q3WRkXTALeSUiKBzVlINW5/W+R9ivTZbDMiDUZj9mx9NXFCVcYjpCuZH7Lwpni7l
         cS+V7uDjLUHYzMm7nDak0LhGQxUDcHiMpcRLPfv4GmzZf4zrekPJ3Jwi2z/47jXFG0tG
         sgAzLxRZXpwcbeXFBz267Zk5kHUXywKIc57oA/OkK3zJcszdfUSruUG0b/ruODgRNukw
         pUDpz5tL2EpiS76I9gQhO4SX7dT+0j/9+jie70AmmU5Exz/B+eKaCN6cOjBY1YiQsnI3
         ro6Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUYL6uImeBYW8sJIN6N33kz8Nm9abkISy2aB4mHL8Whq+AgidFx
	uQq2rZbOMWeMLH7MR0BbnjhkKxTGnBNPeUATa8+nkBe8EskXpymqcyyxusq8V0PKbGDb1Cn9MFw
	y6C2IfBC6rBKbSagdqczKRUYkvwmPevCJHNjfys+doOrmv9giFTL3B7It1uiaBWug/Q==
X-Received: by 2002:a50:9016:: with SMTP id b22mr9324479eda.99.1556903001817;
        Fri, 03 May 2019 10:03:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYc4FPRqmr/4NcGE1yzhcK4KvfLKKbkjliee31ZssWOv3Dx6EplOsKlMrD0KOevfEHouDf
X-Received: by 2002:a50:9016:: with SMTP id b22mr9324394eda.99.1556903001058;
        Fri, 03 May 2019 10:03:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556903001; cv=none;
        d=google.com; s=arc-20160816;
        b=hUyQYndaI2gvoTrervzoXqrM3sH0MY8av+AcD6wacCs2K1Tbw77qhJ8AyP9D3x6xk/
         sN/+zOMREidjdCdVx8cMIna411SGvNQOcbF2aG5ewIRoxrhCwIeWJbDFhYoIj7Av2w4O
         3w0iKEg7KBT96jMMrUQCNZWt8Hiq5ax5Xe9L/o70RqcXH8RJx7Lzjt8njPaWqJFshBhW
         YkNH00wCGtJ102iuicklEQsga2pw7ITbyGS7wzPV86XBD8W0DHqUzA7D4DoA+pFx4TdM
         9tS6/T+FDHM7NnJswk2iraTXZQmNOdyBYaQUYbTLmnEOz1LFCDsQO9d22TL1iP16Wcgi
         JxgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=56SWskVylMIZ8+l9qzqvj7MnMyRLG6uAYTXItWUnOLc=;
        b=X37JUqjfkVt4OIZA7gef3YMdDDrENN830h/k6dmaqFQ9lKv94nHQPa69qw8YbplyOF
         S1gmJEmgRjpuq1QHSs1dHf8Kt7LXH2RZ/Z8094eHiWnBOYyxrCsLEIRjs90mUvQDVWGG
         QOGpbLa6mxGt4oNrnqSWB+WPKNj+MoF3k/bDnI4UdR/SO2sFtcSvIVGjh+bJBwGG/FXW
         gSISt8jZi+kFnGbppu2n41k0EXoZia9WdyeqYkPq4DLcTrFgQKY1TebIUYJ33ozP5xFf
         CsV/IISTRPuHQUVnu7arn8Yedbcis/SJSUtjqwx3PQV47kKFipDYfNHj+F7VVBUxGAdm
         cXeg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k15si1732919ejz.108.2019.05.03.10.03.20
        for <linux-mm@kvack.org>;
        Fri, 03 May 2019 10:03:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B389915A2;
	Fri,  3 May 2019 10:03:19 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2A5D43F557;
	Fri,  3 May 2019 10:03:13 -0700 (PDT)
Date: Fri, 3 May 2019 18:03:10 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>, Kuehling@google.com,
	Felix <Felix.Kuehling@amd.com>, Deucher@google.com,
	Alexander <Alexander.Deucher@amd.com>, Koenig@google.com,
	Christian <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Leon Romanovsky <leonro@mellanox.com>
Subject: Re: [PATCH v14 13/17] IB/mlx4, arm64: untag user pointers in
 mlx4_get_umem_mr
Message-ID: <20190503170310.GL55449@arrakis.emea.arm.com>
References: <cover.1556630205.git.andreyknvl@google.com>
 <05c0c078b8b5984af4cc3b105a58c711dcd83342.1556630205.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <05c0c078b8b5984af4cc3b105a58c711dcd83342.1556630205.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 30, 2019 at 03:25:09PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> mlx4_get_umem_mr() uses provided user pointers for vma lookups, which can
> only by done with untagged pointers.
> 
> Untag user pointers in this function.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> Reviewed-by: Leon Romanovsky <leonro@mellanox.com>
> ---
>  drivers/infiniband/hw/mlx4/mr.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/infiniband/hw/mlx4/mr.c b/drivers/infiniband/hw/mlx4/mr.c
> index 395379a480cb..9a35ed2c6a6f 100644
> --- a/drivers/infiniband/hw/mlx4/mr.c
> +++ b/drivers/infiniband/hw/mlx4/mr.c
> @@ -378,6 +378,7 @@ static struct ib_umem *mlx4_get_umem_mr(struct ib_udata *udata, u64 start,
>  	 * again
>  	 */
>  	if (!ib_access_writable(access_flags)) {
> +		unsigned long untagged_start = untagged_addr(start);
>  		struct vm_area_struct *vma;
>  
>  		down_read(&current->mm->mmap_sem);
> @@ -386,9 +387,9 @@ static struct ib_umem *mlx4_get_umem_mr(struct ib_udata *udata, u64 start,
>  		 * cover the memory, but for now it requires a single vma to
>  		 * entirely cover the MR to support RO mappings.
>  		 */
> -		vma = find_vma(current->mm, start);
> -		if (vma && vma->vm_end >= start + length &&
> -		    vma->vm_start <= start) {
> +		vma = find_vma(current->mm, untagged_start);
> +		if (vma && vma->vm_end >= untagged_start + length &&
> +		    vma->vm_start <= untagged_start) {
>  			if (vma->vm_flags & VM_WRITE)
>  				access_flags |= IB_ACCESS_LOCAL_WRITE;
>  		} else {

Discussion ongoing on the previous version of the patch but I'm more
inclined to do this in ib_uverbs_(re)reg_mr() on cmd.start.

-- 
Catalin

