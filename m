Return-Path: <SRS0=zbpI=QK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35AEDC169C4
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 12:11:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E24892083B
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 12:11:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pJsGlez9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E24892083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7401B8E0020; Sun,  3 Feb 2019 07:11:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E9EF8E001C; Sun,  3 Feb 2019 07:11:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58C2C8E0020; Sun,  3 Feb 2019 07:11:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id D9F6E8E001C
	for <linux-mm@kvack.org>; Sun,  3 Feb 2019 07:11:02 -0500 (EST)
Received: by mail-lf1-f70.google.com with SMTP id y12so1385252lfl.2
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 04:11:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=8SrF1ldydTiBZNiCjzZif0i3Yfeug4ftFhfixRtZHpw=;
        b=InfWKq5V5sYmmrUSChxYXgeo0mJXKS/sQLH8JTfEcvVC34kRjrmuEkz5xuxuSu2XYS
         rJAf0m+TPQCWqcydYcLYa+DWEmRN0NmLVkfIzftIByJ5gfrsOtsdkNTD3KAsULFGVQQA
         ZjrDACzxm1rucJH2QpuRXfEyMZ2hX2/KhAmaoyclqfsaXHEhXsWmGQLBRCre2WUvMH1H
         nk+kdNkSvY7JJX153nyI3/b8+2I9nD6w3BBrE+jB6MifgTh2XCQ2koTu69PXBYbgl2O/
         uBlVX9IHDX5L1CN/7iKavZ+UlOrgOZizLyd24bsG7WVmRga1NGpIvOSEWGNYAhvmHg/a
         S8EQ==
X-Gm-Message-State: AHQUAuZ6n49J/ECZzEbrGc0r++Vw0mDPwmKaaZ+SwW2hbSaqAeX0CE/s
	oJP7b7v4Y1eBtwswiOdtqO4GHYfSMkG9BtJtmNuomd1wRhCvmh1YlvCYLKIRdh/TNRhO0VZRgXF
	4l44B3W7kk3VGKvZE0jiN0wsqNbRlAvzkCByi3T6/5NgCR+pYDvdPE4cKCKpkltjkhD4CXiVthU
	ObexeNLZaBkqXFBcdOoF08a5c+JRAguDauEegH8XlXUGnKicA3VLvIhnPrU4EkiInuWPCOpKw3T
	8d0Lg/5QrIPh3jwYzNBxKih70TYnnGkDgKJYSi3uFXwnvi2JMJOUlq3k0tUax1C1Ttc8COIA/MS
	4lHEV6uXdau3oH15EqKaH8RnoyLriim/2VUmHtE/AZcUE+CKsWgwlL3go1g6yk473dvVBikUXHo
	M
X-Received: by 2002:a19:520b:: with SMTP id m11mr3282370lfb.2.1549195861979;
        Sun, 03 Feb 2019 04:11:01 -0800 (PST)
X-Received: by 2002:a19:520b:: with SMTP id m11mr3282336lfb.2.1549195860841;
        Sun, 03 Feb 2019 04:11:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549195860; cv=none;
        d=google.com; s=arc-20160816;
        b=LjafjlvqrwrJsRXDOayfVhl9TeTuxVZA+6sW/qBdAaMPwYR0ac6nyuaD/zD2ad9kX3
         16rXC1Mai591zjQ3QD8bCWtP/q4ufs95ROTvVni5ZWayho1/FMEQU9o5oHs6AgghDytB
         2I++barYdQ8pfXhda8opWcr0wMJ5kjGEeWADDizmFQlzTtHQI3zV7N2uWXbU73solaDw
         QxNqzB8+kxilkY1vmUkXx7ya+P67/8II294bR/zslvDgEaZ119uZpbepB9LE63MGgjpk
         260lFI7fThzzLMYO6GAlFZaDGGiNfaYzBH4keJFuZgcMQl9BDODD7r/gFC5QEL1yIk0l
         +sEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=8SrF1ldydTiBZNiCjzZif0i3Yfeug4ftFhfixRtZHpw=;
        b=rvdpqerr3K58ybhrjgNd+X6iINqGdVd+TVZpITWbBlyfVPA2Z3NTf0dlAI9C8JqttV
         oUx361sP54z0bHa5I5QYDH8hsYj/ZEjYzhS98M8zBu7vve2XJdcTTeb4qPUH393fJvLf
         gI9DacCtOmuaPJm3wvbvmsBeQDGyB7kQHCfdHBgzafXDjcfD8MAQdQoPaCujw3t8fEnE
         nNZo9OHpTsArWSQJ/onAmnvnLq3rPL0rmBv27ZaVDLAmWsukX0dsucAnC7n/B4C+48/f
         4KdPxopnqo1i6r+IJaGQrbUKdzZENitmbzYVqpYWgH/wtJwaCmAKEun+02bEUICTB+cy
         M1Dw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pJsGlez9;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q23-v6sor7517918lji.14.2019.02.03.04.11.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 03 Feb 2019 04:11:00 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pJsGlez9;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8SrF1ldydTiBZNiCjzZif0i3Yfeug4ftFhfixRtZHpw=;
        b=pJsGlez92rrWhCVjLzcirAg32UfgdzZmz3h7IHlwSMeHDraTB7Az+ntFTMkWHQT8N2
         vhuMi+jS1XIhIbR3VzbVgsxBQJI1didJosDf31B6hngRyB8PS53CxxYR/Rc5tc/g+EYC
         zJW8XqZe9g+X3OJiIUGV76zTpSaLQ3B+WeQIaHaQcNJHwOIq5HAbUnaog2y1NXfRrOlb
         btsjOSK1MNVgF/sYbuPDBRUk7whc5WI3p+6ho8cI6vTN0WddJ0eogXaxBMwINDFHl6pM
         pkS10Z9mC82aOkfkX6hczwBIxYVrdI8c+OqCSfWf1Gfh4lE8hHKYtOqfYbtQNFaJkPbA
         jflw==
X-Google-Smtp-Source: AHgI3IbCzFQD/+Uqz0DfjLSsX4iVK4fMId5Z87LLJDmoXHAA42wXu6RBQ0/v6b3cLh38pZaQBHcIfOlK/fsOvmLRX+E=
X-Received: by 2002:a2e:5703:: with SMTP id l3-v6mr24761848ljb.106.1549195860175;
 Sun, 03 Feb 2019 04:11:00 -0800 (PST)
MIME-Version: 1.0
References: <20190131030940.GA2305@jordon-HP-15-Notebook-PC>
In-Reply-To: <20190131030940.GA2305@jordon-HP-15-Notebook-PC>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sun, 3 Feb 2019 17:40:51 +0530
Message-ID: <CAFqt6zaN-AJuhVf8_=z3KDCjcuu+zTN_GorxDzcpAUqcM04m2w@mail.gmail.com>
Subject: Re: [PATCHv2 3/9] drivers/firewire/core-iso.c: Convert to use vm_insert_range_buggy
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, 
	Michal Hocko <mhocko@suse.com>, stefanr@s5r6.in-berlin.de, 
	Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com
Cc: linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, 
	linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Stefanr,

On Thu, Jan 31, 2019 at 8:35 AM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>
> Convert to use vm_insert_range_buggy to map range of kernel memory
> to user vma.
>
> This driver has ignored vm_pgoff and mapped the entire pages. We
> could later "fix" these drivers to behave according to the normal
> vm_pgoff offsetting simply by removing the _buggy suffix on the
> function name and if that causes regressions, it gives us an easy
> way to revert.
>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>

Can you please help to review this patch ?

> ---
>  drivers/firewire/core-iso.c | 15 ++-------------
>  1 file changed, 2 insertions(+), 13 deletions(-)
>
> diff --git a/drivers/firewire/core-iso.c b/drivers/firewire/core-iso.c
> index 35e784c..99a6582 100644
> --- a/drivers/firewire/core-iso.c
> +++ b/drivers/firewire/core-iso.c
> @@ -107,19 +107,8 @@ int fw_iso_buffer_init(struct fw_iso_buffer *buffer, struct fw_card *card,
>  int fw_iso_buffer_map_vma(struct fw_iso_buffer *buffer,
>                           struct vm_area_struct *vma)
>  {
> -       unsigned long uaddr;
> -       int i, err;
> -
> -       uaddr = vma->vm_start;
> -       for (i = 0; i < buffer->page_count; i++) {
> -               err = vm_insert_page(vma, uaddr, buffer->pages[i]);
> -               if (err)
> -                       return err;
> -
> -               uaddr += PAGE_SIZE;
> -       }
> -
> -       return 0;
> +       return vm_insert_range_buggy(vma, buffer->pages,
> +                                       buffer->page_count);
>  }
>
>  void fw_iso_buffer_destroy(struct fw_iso_buffer *buffer,
> --
> 1.9.1
>

