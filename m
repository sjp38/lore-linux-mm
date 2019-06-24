Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FB4CC48BE9
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 15:01:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFB3020674
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 15:01:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="MwA/LDiu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFB3020674
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A9D48E0005; Mon, 24 Jun 2019 11:01:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65A6F8E0002; Mon, 24 Jun 2019 11:01:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 571C28E0005; Mon, 24 Jun 2019 11:01:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5248E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 11:01:43 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id n1so7465771plk.11
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 08:01:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=BLg06i/VCl1+ARgBePt6UCtgCE6yMoeYz0XGu/hbFeo=;
        b=pXhCVbcKSYgovkdxET/M82kh/ThPOgS7rAkHu7Z1e+5ZZ5mp5akMZ2ac6YYh34QVoT
         7gnUriy3pFM7flQHEY6j//EdRA14c70d5fetpZJUBBPFYr+vIgXx9y7DnNgnUOzKLcEX
         KIfoVScDpT4KdpQKIS85l2Z1VUeTm77wbOCY7DrIf4WGGrunQZrHcdHetNxcYNhCoIsY
         +vHVAOydd3yXOZKI8bsYG/j1XUvnLdEhNIKfo5ZpysWM2fMD3xGYIABW7ILHJgsCOpRV
         HE2VlmMaTs/5wBpgqhDTa16HxKXyLDFnIADz+m5P83jdBWhAKtaU3WAlWTQQpicwwQcY
         zqZQ==
X-Gm-Message-State: APjAAAXuG4iovyJjH67//fewwOVrY/cGEEHHZXT+JPeJB3Bzd6NE6M2O
	ZI079saCevblOgb608KnQX51bGkpbwMa0K9+mLn0HtpwJ2QuhLsLKqZqbwySTNJoSzy+UH6pY6m
	NupAc/7kuIOB5slr+orzA+2kaFXp4G6l2/xt7IWv7qlaAZCyIGipmxzFtttgWgv0HJw==
X-Received: by 2002:a17:90a:9a95:: with SMTP id e21mr24671900pjp.98.1561388502236;
        Mon, 24 Jun 2019 08:01:42 -0700 (PDT)
X-Received: by 2002:a17:90a:9a95:: with SMTP id e21mr24671809pjp.98.1561388501449;
        Mon, 24 Jun 2019 08:01:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561388501; cv=none;
        d=google.com; s=arc-20160816;
        b=j0mBfsDsZSJ66e6ExDl91ZNo9FJjIaCwJZXy+kZ3EjUcowFMHvtO3dOAfEeFQ4KdK8
         KCyCRaDLU4/DcIYmZBlT//5SgCl98fbq+bmmrLVJOaPAt3Mmebs/ZFpvxoBSR0whBdRc
         PikAxlOslalW/8b6OS9T4OgUlmFGgS8CpZZ+Df2Eibv+J9PjZ9BDBj91vl9Xa0zHYt3z
         UEGdUZPhiYdTurzTOLB8ihKSv9v3UkjbCw66m6/qzbIafjdSiJjTkWMLGoeDfJKuUmj8
         qAJjV+ggvu9SQfxTl+NdJr3IzddVBRMp65hfbI0lIwpihEq6NsBZIXt6SV8OJJjGsWpK
         YN3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=BLg06i/VCl1+ARgBePt6UCtgCE6yMoeYz0XGu/hbFeo=;
        b=rRwCgL1kwt667jnppLTnQ4vYuI3ijCBLW5OT52HZLRhwLIv6OcFwEQfXWc2nQLIDam
         yZVIT1oyr55+oghf4U0rkLlevKW8mrfnFpg7hVlwoiB/UCik8YwJhHvn7l6YRDtmQS2G
         GoeflyJ7vi72ESNNGkDyZNCgNlvZj35C6frgal0yjNO2hJHQs/mKwmSWIC1/0lnEAsQA
         i/w5QOu9cQUZUmriDO6BHA8Rcn8YrDVoTKV3qrL7+sV1LoL2PjyHd1AKqbWE3FgLxbcM
         z1dVf72tf6FsUbU0UZjPnXTa3sYIHTy4ckS+ue6fsKVkRicI6yoKGosJnZ4x1JMoFqrU
         CbBA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="MwA/LDiu";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d34sor6745295pld.39.2019.06.24.08.01.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 08:01:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="MwA/LDiu";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=BLg06i/VCl1+ARgBePt6UCtgCE6yMoeYz0XGu/hbFeo=;
        b=MwA/LDiusqfNWsTB2DaatzITy3M650ma8hf3fWZJJgZo0sU5+WHRov34/AgR5khfdn
         43QWHZ5AnOHm74CPfDOEecH6k3NeL2D42ht4vodc0QKm4kkProj+2T//kWp6iTgN3F0V
         SMoSonCHMQtZbalEg27bzapOmKXhEcFOVUU3I=
X-Google-Smtp-Source: APXvYqxWnwPjr90pgAz811Ip1hR0DU+KY/u+1S7JOfCxDoc+41R5+q814qY7q3l7dWsEUazPv/NQog==
X-Received: by 2002:a17:902:ac88:: with SMTP id h8mr71103307plr.12.1561388501191;
        Mon, 24 Jun 2019 08:01:41 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id k2sm10325517pjl.23.2019.06.24.08.01.40
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Jun 2019 08:01:40 -0700 (PDT)
Date: Mon, 24 Jun 2019 08:01:39 -0700
From: Kees Cook <keescook@chromium.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Catalin Marinas <catalin.marinas@arm.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v18 11/15] IB/mlx4: untag user pointers in
 mlx4_get_umem_mr
Message-ID: <201906240801.BE42EB3AA@keescook>
References: <cover.1561386715.git.andreyknvl@google.com>
 <ea0ff94ef2b8af12ea6c222c5ebd970e0849b6dd.1561386715.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ea0ff94ef2b8af12ea6c222c5ebd970e0849b6dd.1561386715.git.andreyknvl@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 04:32:56PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends kernel ABI to allow to pass
> tagged user pointers (with the top byte set to something else other than
> 0x00) as syscall arguments.
> 
> mlx4_get_umem_mr() uses provided user pointers for vma lookups, which can
> only by done with untagged pointers.
> 
> Untag user pointers in this function.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  drivers/infiniband/hw/mlx4/mr.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/infiniband/hw/mlx4/mr.c b/drivers/infiniband/hw/mlx4/mr.c
> index 355205a28544..13d9f917f249 100644
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
> -- 
> 2.22.0.410.gd8fdbe21b5-goog
> 

-- 
Kees Cook

