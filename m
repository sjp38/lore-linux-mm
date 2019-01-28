Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C920C282CB
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 06:31:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F44E20882
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 06:31:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ATzekJRR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F44E20882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA65B8E0002; Mon, 28 Jan 2019 01:31:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A55648E0001; Mon, 28 Jan 2019 01:31:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 96EF08E0002; Mon, 28 Jan 2019 01:31:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B8A38E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 01:31:27 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id u23so1307572lfi.5
        for <linux-mm@kvack.org>; Sun, 27 Jan 2019 22:31:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=o//iVq3hBTHa9XD8DZInYP3EOrEMWQQBv8sSLizNJeg=;
        b=H5RiP3AwkO0GgD2FZEyFVNtwcJOlnUp8jdPKa2rbHTD2Q7sr2up21C8R7YNoEhbMyC
         94SRK92iByfiWtMWjArMOV5zkftM9ExzT4WtHd64VJvrH32Dpa6Z5K1rUJstubrpJvsM
         zWXwWC0MCzJqC4sqQMYQa08QurZKET28l7TuQsDa+jbF1yZ/kfP1xTjb/qP8d02Lt2Nr
         GreWJ9uaf6RueWtPI5k4hQz4n0ogVzBngGKf9r7EJDbKLP7LJH6NMuZTgVU4d7YtR1C0
         FabPvS2P4SknLix2KVeCp/6XOLRU+9+lsdyfYRLoQt3FEzNgjkWR7lMJAtueuMRUIqxD
         BJYg==
X-Gm-Message-State: AJcUukfdJKcnDXixPxcohPe2k6zdF2Sn/dmxF8i/ruQqzOrRKa/b+CTt
	iohIklTJU8dUzA+Mcfx2AuN/3qbJ/bcp5podbotn/Fc63cjczphoB1bJ09fKsI3xCNSc6wnh2ES
	Q5enicSiTnQXoD0FbARRHOKxOZTzDSszHAJH1MlCy/AQxA6yHmTHYtJ8l2xovqDK/bkS12BhRs1
	k6xQDvlHi66CoEG4qe5rtR0b8Wo+7R5WrywrbYsoycIq/Itq/aM3IZ6kCz10dID5QTce+vbKnuR
	wjPvY4HKnEvCf9BGqVB9yyW/zFOcZbNZmWCQgKZpAYEjl+JWKlmvepQv90T95oj9rW1atuAEu30
	1ijcNn/CzMfJmKJ8IfXZZW2ZS7ngM+QKID5ycdD+5b4NsXOIRNekJ9dOyZiDVnLVAOtBXxkbJzV
	6
X-Received: by 2002:a19:db54:: with SMTP id s81mr16266372lfg.102.1548657086219;
        Sun, 27 Jan 2019 22:31:26 -0800 (PST)
X-Received: by 2002:a19:db54:: with SMTP id s81mr16266329lfg.102.1548657085070;
        Sun, 27 Jan 2019 22:31:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548657085; cv=none;
        d=google.com; s=arc-20160816;
        b=rC2QSJuBXiSP0GmUw+Ke3C91eEwT8MJzMKm1+vaBcjZw+srIDWlXygJ/Uzh1m+eNTy
         Kp5wgniIvThcqNl0PJyCfYQcULDPm9SUsps9vMKWbeg/faTszfEd1xxDwsXtmXkLCgiW
         MsIA8Mfe50UGLF4QMOMwX17IJFuMQOYChbBCs2OJ4aOQtw7xkwTZmkJkReGZGW5oF7B3
         eU4ApnzB8CeR9MoU00huEgpaDNQJ4lIADQq3otcHB+9KF4NhNoKnMyKux43NsTnX9M5B
         2dCsAEATi69tXbkQ64qHiPulPvoAI+lcfVnD2LaNs0AhaF2Ka/9eDHOS3jirr7tvF2Ez
         15LA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=o//iVq3hBTHa9XD8DZInYP3EOrEMWQQBv8sSLizNJeg=;
        b=SvAtqzmJSwrUIhXRJOdJUrnb806eBvPeYktHELG+UbJojBRu3gZ4k28nrQN3BiV9sU
         Q1tS03xntLpS8wmXDsUdeqg9W6fSFNz7hfrTHgMB2FmEelEy+uigzfTjiNsZIysjrcFB
         YJ5bsAqhsC5Riruu2lkHQqriTgo0vpvKfowvLeiOO37E8FUsQyTBernbx/oLYaLyX/bD
         q2kY76ABMR+NEJU7X+PLaadW0YJz0cCKxeVT8OHX1VAH0UP5AnIki0zpQywTBJqtGt/6
         p7tXvR92FdQ+ovwtM5x8Vy9QL+QRZWn1CmTY5WLryO/SciM9O2NnuD2/NzXLIfZhEz8h
         4nJg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ATzekJRR;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y86-v6sor9959770lje.18.2019.01.27.22.31.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 27 Jan 2019 22:31:25 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ATzekJRR;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=o//iVq3hBTHa9XD8DZInYP3EOrEMWQQBv8sSLizNJeg=;
        b=ATzekJRRvtQGucujNrDFXsV130pA0J7dxJD3Z4UK26nneQ0dIukUNKx6fW2rYIh1S9
         OI7tn4VuC/2xTJjr74eh9f8zZ3WKdMrF0NkG7xH/VwsTPaFKAjVK4Iy6eymY9yz+tTqp
         wPJKJcMtN+1Ih7jQsPN1/4jcZwL+CaCvZGfq97ezVCBPFi6vkjj+HVyy67HvPHfl4+pz
         1cEexzurgJie7Dvbj2YEg4VCl/HGnCyxuE4gHnsSTdLaV+sLCY16cvZgQVhnzAgdr6gI
         TLiTTKA89ErBtmCJeLFhXPkDppx2Zh4Hu4sP57CvbL6xZUsSGbqyDpl4CYRwc0Kupb+x
         csSw==
X-Google-Smtp-Source: AHgI3IbGK5mZK+NnSyULWRlsVeaByjiWok5/YaCNXkrpF86UzHAi5un5qi/64N4ZnNnHC4ujYwvgmDnnWjupdoAOptE=
X-Received: by 2002:a2e:5703:: with SMTP id l3-v6mr4691341ljb.106.1548657084389;
 Sun, 27 Jan 2019 22:31:24 -0800 (PST)
MIME-Version: 1.0
References: <20190111150933.GA2760@jordon-HP-15-Notebook-PC>
In-Reply-To: <20190111150933.GA2760@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Mon, 28 Jan 2019 12:01:12 +0530
Message-ID:
 <CAFqt6zYcd6XgFDz1vGcZpoeDPCpr5sODdUQ=3WF1z8ZKLxUBOQ@mail.gmail.com>
Subject: Re: [PATCH 4/9] drm/rockchip/rockchip_drm_gem.c: Convert to use vm_insert_range
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, 
	Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com
Cc: linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, 
	linux-arm-kernel@lists.infradead.org, dri-devel@lists.freedesktop.org, 
	linux-rockchip@lists.infradead.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190128063112.2_eiC-btcjmsCe0fuFLl6A9WJXun5uJP1GhZYtAbQ3o@z>

On Fri, Jan 11, 2019 at 8:35 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Convert to use vm_insert_range() to map range of kernel
> memory to user vma.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

Any comment on this patch ?

> ---
>  drivers/gpu/drm/rockchip/rockchip_drm_gem.c | 17 ++---------------
>  1 file changed, 2 insertions(+), 15 deletions(-)
>
> diff --git a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
> index a8db758..c9e207f 100644
> --- a/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
> +++ b/drivers/gpu/drm/rockchip/rockchip_drm_gem.c
> @@ -221,26 +221,13 @@ static int rockchip_drm_gem_object_mmap_iommu(struct drm_gem_object *obj,
>                                               struct vm_area_struct *vma)
>  {
>         struct rockchip_gem_object *rk_obj = to_rockchip_obj(obj);
> -       unsigned int i, count = obj->size >> PAGE_SHIFT;
> +       unsigned int count = obj->size >> PAGE_SHIFT;
>         unsigned long user_count = vma_pages(vma);
> -       unsigned long uaddr = vma->vm_start;
> -       unsigned long offset = vma->vm_pgoff;
> -       unsigned long end = user_count + offset;
> -       int ret;
>
>         if (user_count == 0)
>                 return -ENXIO;
> -       if (end > count)
> -               return -ENXIO;
>
> -       for (i = offset; i < end; i++) {
> -               ret = vm_insert_page(vma, uaddr, rk_obj->pages[i]);
> -               if (ret)
> -                       return ret;
> -               uaddr += PAGE_SIZE;
> -       }
> -
> -       return 0;
> +       return vm_insert_range(vma, rk_obj->pages, count);
>  }
>
>  static int rockchip_drm_gem_object_mmap_dma(struct drm_gem_object *obj,
> --
> 1.9.1
>

