Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0F72C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:05:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55BE420838
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:05:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="UB3Pt/TA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55BE420838
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E88698E00BD; Thu, 21 Feb 2019 18:05:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E38638E00B5; Thu, 21 Feb 2019 18:05:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D014A8E00BD; Thu, 21 Feb 2019 18:05:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id A58128E00B5
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:05:29 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id q141so256799itc.2
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:05:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=M18y1j6N0BCPC6Qvm+oCd9cTgbTHzAhsGLH6qTZCOZg=;
        b=kSTk0e6AfhenqyBIZTf6esXQGwSicww4nfeNiO+vxjdwU2JIre5BfHNsPj0uEHz3GF
         3lj+VuZMAfG83bsJGLnYlgQadQvnq0+DrFZwNURCQIAdcNdbS2i/DI5tpFReQruZIJoD
         vpRXyKgQnnOTyNL86y6LgsDKZWck5ilSvfme3zXCWpe6eptfXyuE9vRL1fGDTaw1PXyS
         UEAIXB68K9yhdZODjeYG/6ge0PeBk4ChxwbGUBtwQWiKIl5Q/PeII8To/4OBRbe3+9Il
         EZOJ250dEMRiebc9X0ZNkVbe1ciPMX8bX5ovyeFHPpwvfh5SYpP4kFWuSB2zj23q0x9Y
         YsSQ==
X-Gm-Message-State: AHQUAub4PPew9ozFY7k5hOf2GjWO4RMNjuSlF4C3mpYMu08kDN1VhvIA
	3lQySeLRsleIzogP4JKQqyOPudK3y1SbK1zIYMfP+knIUjbWbaQfx7zKhYwp0cTu53UsrhkXaWZ
	sXe5fI59YXmGznDzjteMTMXanri0Vq4IQK1E96QcQI19PRx5e7neF6soo0QSwDkR71S5gm1J/Vf
	E3Ye66XSki+lkYBB6oLp13CmPOyN9Yioyqpomj2o8cVz+YUD9nQYwtvGBh4CO5zpEDoSGB1v21R
	NlBcZZ7YttA1v6CHWP/OyvY2+ESBJV0v0NToaFhIawsJ1X3HN6LzZe+HqxsLxSNeuPUYKFhZTC5
	XYFzbIJ56bMB/JqDj+VJAHfbP8kK6UgKnTaykMPlcptzafEOFcSZgGLng87AfSW5StV0pyL7Oo8
	R
X-Received: by 2002:a6b:f70a:: with SMTP id k10mr716405iog.68.1550790329414;
        Thu, 21 Feb 2019 15:05:29 -0800 (PST)
X-Received: by 2002:a6b:f70a:: with SMTP id k10mr716351iog.68.1550790328638;
        Thu, 21 Feb 2019 15:05:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550790328; cv=none;
        d=google.com; s=arc-20160816;
        b=oOUFVJyPkNYrvj+cw3YX8FCOeeJ+tsu1PDbzHl3WZRrt7gSS6pkOkTTag89M7E7kky
         dETti5pD0m/PnvmKGTiggi51lwguMZ/wqRuIEbIV90gVyVwe+9tWHsUpTbslrtIRN13K
         p9/dwXQrRyqi6wWIQxRmG+KSAzzqjhWK02G5eehSLW98Gf/O61kZU5TtqJKnfwWTg+oC
         50/65dyu2emtA/gguWscDXPgfABc3KIKCSX3NPrx0K1Uqs7bkZ5VLK6j2p5NnaC93Jpj
         VSNCvpv8A8ZE21OHKWGUlVqrQkIRKLYImi+rnZUdlZSC0F72RdJDfGTS+eQ+CCC6fP70
         cgog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=M18y1j6N0BCPC6Qvm+oCd9cTgbTHzAhsGLH6qTZCOZg=;
        b=MGE0l2zPxofSE2v3b+Igru9giX9Vhiba3pTesT89Adg6OnOIJAyBwe815JlgeGnXHe
         1ccLXqu08pi/JZw/0l0nDgup9qYSpFZFI/k2eYomHyp8wx0wxs8F8VVk5YiiulBeU8By
         n6eSPaoGiDHvndIk85CcDnP47/6z5TOIb+/giz6gcLXr5m2Mal3nb8cVpnNmr+Wf8WsN
         x58urh3bwOWV2FfmNR3/yB0goIOU7Be9ZWte/DFxChUWh92O8JrqCCqr1qrgh9SCuTZj
         tyO4f9UIykgKrYb4cqfhCQssR8BdsyJ39er0dDPkwWPYjZifrIfRJXnKRz8tKjF8LMtS
         M32g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="UB3Pt/TA";
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b62sor305515itb.21.2019.02.21.15.05.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Feb 2019 15:05:28 -0800 (PST)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="UB3Pt/TA";
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=M18y1j6N0BCPC6Qvm+oCd9cTgbTHzAhsGLH6qTZCOZg=;
        b=UB3Pt/TAhv5IjOxRvaiLS/aDHOu0BHqJAaVmztbR3nDBwQMq68zY37bNnLJk5cpjAB
         iu8TAGjqmYJIfj38mb/ku00WfoC93c+VgT8uJQj/x00JD7K0ssTVyNK5UuR0CHPIk+0H
         kezIq4fbNbZgHihpQAvGp5Q0s3N7D5gskOGd8xCaqoI/byLj11Zt7v+dlCHPr5szjucw
         MA0hqIUv+SEGGAop89a+I9fQMRbx4WSL0d+AgoeABwVuu92wu6NxTqswkAFcHvV21zXf
         2H3I6QmWyznNZx5eJuWCSKJAqBev3Auc0bRFN5Nld84Vsg+CkrftiMbGKsI5J5B3YU+B
         PqAQ==
X-Google-Smtp-Source: AHgI3IbosYKaCWed927UbZANAkfOS+LE0FELNMJEJrToVmfVRIFOE2T7F4QzFVFavvoelT2LUgzH5iMTCu9TzmoXe+E=
X-Received: by 2002:a24:2ec2:: with SMTP id i185mr637247ita.62.1550790327967;
 Thu, 21 Feb 2019 15:05:27 -0800 (PST)
MIME-Version: 1.0
References: <20190221222123.GC6474@magnolia>
In-Reply-To: <20190221222123.GC6474@magnolia>
From: Hugh Dickins <hughd@google.com>
Date: Thu, 21 Feb 2019 15:05:01 -0800
Message-ID: <CANsGZ6Zb0hLWZH3Tnx83hrgnSchsr06HNT9ZE4F0Z=kt3PRS3Q@mail.gmail.com>
Subject: Re: [PATCH] tmpfs: fix uninitialized return value in shmem_link
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matej Kupljen <matej.kupljen@gmail.com>, 
	linux-kernel <linux-kernel@vger.kernel.org>, 
	Linux-FSDevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	David Rientjes <rientjes@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 2:21 PM Darrick J. Wong <darrick.wong@oracle.com> wrote:
>
> From: Darrick J. Wong <darrick.wong@oracle.com>
>
> When we made the shmem_reserve_inode call in shmem_link conditional, we
> forgot to update the declaration for ret so that it always has a known
> value.  Dan Carpenter pointed out this deficiency in the original patch.
>
> Fixes: "tmpfs: fix link accounting when a tmpfile is linked in"
> Reported-by: dan.carpenter@oracle.com
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>

Gosh, yes indeed: thanks Dan and Darrick, I'm very sorry for not noticing that.
Acked-by: Hugh Dickins <hughd@google.com>
(and sorry if this mail is garbled: it's from gmail, I cannot use
alpine at the moment).

> ---
>  mm/shmem.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 0905215fb016..2c012eee133d 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -2848,7 +2848,7 @@ static int shmem_create(struct inode *dir, struct dentry *dentry, umode_t mode,
>  static int shmem_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
>  {
>         struct inode *inode = d_inode(old_dentry);
> -       int ret;
> +       int ret = 0;
>
>         /*
>          * No ordinary (disk based) filesystem counts links as inodes;

