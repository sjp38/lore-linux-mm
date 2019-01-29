Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DC96C4151A
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 08:09:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1585E217F5
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 08:09:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="Yfe/lYWx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1585E217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 89B048E0002; Tue, 29 Jan 2019 03:09:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84B138E0001; Tue, 29 Jan 2019 03:09:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7137E8E0002; Tue, 29 Jan 2019 03:09:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3966C8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 03:09:45 -0500 (EST)
Received: by mail-vs1-f71.google.com with SMTP id g5so962969vsi.2
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 00:09:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HskzooTvMqAmijkoLembaa8q/EUEh+gg5JDbqI0lirU=;
        b=IpCPuYcCxU7G6MLZ+5hyvIiQmJ5z2dwqZgJhCMPF5Mm8ShwjMEOvMZDnxE5wLmNDHs
         LQUWDYa75k00J02N4nuhN2maH1agcsIxcZi1YYSlSUyCJJfwF4mex+sZ36Ejuh8qh1Vg
         IZnXUQ44Py8+dworejzLA+BUYfDSVQghPwKF4toLXtgGeOUxMs2ffEHFjQl95uZbwduy
         QKewCG2cAQxDqy2ybDb1ggL5lpYqIoHQHgh18SfhkN3bHG++9ZAAacT3HA3iGuCUTdBI
         U+unuT4T7XJIoMCqzpj5OuBR+qvl23+DLfDTOPoq8ZwurlIrqTUqEm1GBNnPI1iwyfWi
         XbZQ==
X-Gm-Message-State: AJcUukcWXnoce7OXj3WscnpCF8grlYo2r2RAKRLkJ8ck8e3yGxhVfhCO
	cvzsBW5ZJNRg4Rp9jiTKTuyeQUd61clTi5aIcQtspjEsbh/8/RDaa0vgLSTQJKOsPxXT6kcG+sZ
	lAqVWYM7lQOJ8TphzC0irV/DIGxAytADsAianakcumLOavFIK5QM7j8s7O5/Hvx2JidKc2Dn2S1
	qSpIGecCzRsWT6ZL5MeDJDeU4r7oJnSFVytHHVoAmBXixeD8MoFhtIDX/RQWxijoFF13L4ESiK2
	o34mjwt5gZoN61GfTWgqiQMzJKRUeF3vjCd7GOHj/OlbknWyzxvMXCyEe300jbG7Kzt5HcMM2S+
	XHnQUsVCOMlkRbFnxH4cpoPEob4TtrW2T9aRTJwt0luaPaEx6X6QC6p0yW/SBm8+A4/QF9xd36m
	6
X-Received: by 2002:a67:edd8:: with SMTP id e24mr10986676vsp.169.1548749384853;
        Tue, 29 Jan 2019 00:09:44 -0800 (PST)
X-Received: by 2002:a67:edd8:: with SMTP id e24mr10986658vsp.169.1548749384357;
        Tue, 29 Jan 2019 00:09:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548749384; cv=none;
        d=google.com; s=arc-20160816;
        b=K2jNoH8TOwnTyyzvobhtqP9OiJ7o8CKDpYSbSbEihwztmhXOOlGFQ+TMpleHyXP6XS
         wQF6VwB5S2YqlFuznbRv4SxE0bJ5ga9nkB809DsM3SSqywV/gZW2FB6unh81uUZD71mB
         QzvMzGPwDyKw0tMN8niR9YftztU+NcPtKbY6sH3OgkQQI8Cki2n73BsaJP36T7ZXO3v3
         I6y/xq8apjBa8SR0tOnOeXiGiaWX/PBASa0Q6ok6FLIuJlpMQi6Z9cnTrNIbfcvYv5VA
         PINfwNmNAxvXXpxFB9mMF31HHgK3gns0H+yRSpVaIvcw1r70yCos2JuABhJ0wAOcmJtD
         /OGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HskzooTvMqAmijkoLembaa8q/EUEh+gg5JDbqI0lirU=;
        b=Db8j/jrtWkibixkgMGvDItRALCnqP5d36gAfk3lOewp4bTf3f7WbfVTQyBDSkSNg+f
         GYGHjSg/6vgXjt+XgdcdTzzzlqjv0yEF0XfIXnd6LwdMKDQFs6nt5CmUwniJnB9YhDSL
         vYkABbskYhktMN5JyXGr2DiCvBSokVALUjlwsD1cCAfK/hAlnUWFTsw1Y9yLTNHt02Vz
         gYYGrNp5ZRAgnX4VsRr0C5LdtaHdF3D331n0/AwP3dgmDc/L+iiZPhtKEIMjBAbTr6TI
         Rj+HiszST3IwTHqX+R6OEYR3mwEllDb4yzveY6S2BC9ICsrRy6lzvQnlS7ViCxGcebTd
         hhRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="Yfe/lYWx";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h75sor22625982vsg.0.2019.01.29.00.09.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 00:09:44 -0800 (PST)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="Yfe/lYWx";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HskzooTvMqAmijkoLembaa8q/EUEh+gg5JDbqI0lirU=;
        b=Yfe/lYWx+W08Wnk0LT/9pDOe33v6r/YJCX5FHNL8f7PXRPgQ1pULitx5UhzCxQozax
         sUmP0OKPSRBgz5/GAzgXWKinyALuD6Rusi8YhMCk2/sHGw9Yt1IqU4RuXsexPaHqYRN2
         vnrz1YDb7OGnn7mAzynSfkfNPRgP+5JqFpt78=
X-Google-Smtp-Source: ALg8bN7sVVE7ciRiR4XoigIHgE0fU2mMLar/zkbfwI4s6K2j4QCRS3h1Z5YKgKbfeV1pRchIgv93+A==
X-Received: by 2002:a67:334a:: with SMTP id z71mr10800052vsz.40.1548749383751;
        Tue, 29 Jan 2019 00:09:43 -0800 (PST)
Received: from mail-ua1-f46.google.com (mail-ua1-f46.google.com. [209.85.222.46])
        by smtp.gmail.com with ESMTPSA id y195sm72854468vkd.0.2019.01.29.00.09.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 00:09:42 -0800 (PST)
Received: by mail-ua1-f46.google.com with SMTP id c12so6545087uas.6
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 00:09:42 -0800 (PST)
X-Received: by 2002:ab0:470d:: with SMTP id h13mr10723029uac.122.1548749382268;
 Tue, 29 Jan 2019 00:09:42 -0800 (PST)
MIME-Version: 1.0
References: <20190129053830.3749-1-willy@infradead.org>
In-Reply-To: <20190129053830.3749-1-willy@infradead.org>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 29 Jan 2019 21:09:30 +1300
X-Gmail-Original-Message-ID: <CAGXu5jLbC1-T9JbYcDcXjA2G3jv3DLCWSUvJf3KiA8so2XC19g@mail.gmail.com>
Message-ID: <CAGXu5jLbC1-T9JbYcDcXjA2G3jv3DLCWSUvJf3KiA8so2XC19g@mail.gmail.com>
Subject: Re: [PATCH] mm: Prevent mapping typed pages to userspace
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Michael Ellerman <mpe@ellerman.id.au>, 
	Will Deacon <will.deacon@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 6:38 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> Pages which use page_type must never be mapped to userspace as it would
> destroy their page type.  Add an explicit check for this instead of
> assuming that kernel drivers always get this right.
>
> Signed-off-by: Matthew Wilcox <willy@infradead.org>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  mm/memory.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/memory.c b/mm/memory.c
> index ce8c90b752be..db3534bbd652 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1451,7 +1451,7 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
>         spinlock_t *ptl;
>
>         retval = -EINVAL;
> -       if (PageAnon(page) || PageSlab(page))
> +       if (PageAnon(page) || PageSlab(page) || page_has_type(page))
>                 goto out;
>         retval = -ENOMEM;
>         flush_dcache_page(page);
> --
> 2.20.1
>


-- 
Kees Cook

