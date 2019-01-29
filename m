Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 851D4C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:47:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3BB3120882
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:47:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ieee.org header.i=@ieee.org header.b="OsEJ4n8z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BB3120882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=ieee.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E7D408E0005; Tue, 29 Jan 2019 14:47:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2D158E0001; Tue, 29 Jan 2019 14:47:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF51B8E0005; Tue, 29 Jan 2019 14:47:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id A2A4F8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:47:07 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id r65so17361251iod.12
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:47:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=XG7u523a/0f6kyGjbZgxsWPAk334VvfCv1Jk6fCTIsA=;
        b=jsgPVWpQoK3joJpg9OdavdyS7D4spcE3nCEF/p7pd7w4kril6O5YHMeKChhQ1UXWgt
         GktPX8tnWUsGmaRjzb4qYOxuC6BvMCBQ6mvL9mJdm6exw+26N2MT1CsR6eOUyMKA1GTs
         hh2RA2/+WorGA6i6e8rH0PWxz1dMSzib7wneYplao7xjpNIl+WHJBfwINwnIzSooXe3k
         FbMFiDBNr7YCiwIp+QxxYBohp+0oPR/jpQhPPkYt9ArG/3gb/sEBb/nW71FVElzbcPJk
         H/UBInxB4z5RHBGop4OFU6krbZpHeqkh6yeI5ZRLaBe99ZmcEKWuDV8j9ecvMCEwEBCH
         /S6Q==
X-Gm-Message-State: AJcUukf2HwjsB0a4fyZ65i6Jo99TsKQjzN4wxZ3ey4i8ZhhtBJ1lkRQs
	tWzNEzLNpYZ9a+Ph0kC3CwJHzDanD0P2mgEfx1ZhVdCpEgjnHzW5ENm/0U7MFOoMjShn8zlCRKs
	dY4UHiI7Vr70rgoRKjYAeL7uSUFNjGId/tkRquJwqWw4DuZwUOLBf4m6dnkgHHIXbTNuIE7fyMf
	Vx8rcsbn10qv+HUyL9YKu+Unkeay5xl5l/LVNehIraINNPerQKl+K6GxPGesdWZNaQPQHDN1BjF
	U61qyzOBGdzXmFCWT7gUybheyycgkR3fbICt3ScBJQltY8YKixOF6Rmpt3uyAXDQsphRnTHNi90
	b1fNyt7VLQPmEdyRaUVvm+2+VnwrH8WSWlX7URFfpk8YCPmrSeT3/Gzv6hWjFLOnb+PTkvfvsNp
	O
X-Received: by 2002:a05:660c:684:: with SMTP id n4mr11757540itk.64.1548791227469;
        Tue, 29 Jan 2019 11:47:07 -0800 (PST)
X-Received: by 2002:a05:660c:684:: with SMTP id n4mr11757523itk.64.1548791226820;
        Tue, 29 Jan 2019 11:47:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548791226; cv=none;
        d=google.com; s=arc-20160816;
        b=QlJTURbtVgjYCHUG5G2mKghqX9P0O06RQxpJggQTRSmRyjhGFrlF0QbUWDrEPRAy7d
         x8KLGNkAAP9an2xQnzjhIWP8r70qkQCnEJmgW3BhiYZVS10oUxAllg30YARPkCKa7h/F
         1J5bXfwPerfQIEB6RVSUKIph6IdXN2OEENGSkUKW1DrCdBmntzBlLFUGNbf6gg+9q+M6
         YmY8s0cwbFVpMoix2BbpZzFaKnMZNHRbX37/WAzCyp/caOpiA+8p0eW55Rbklw+eFv6p
         8HwF3u8IPoJeldWfOlNbV8wY+lR1E2IhvsJxOfgWKdjM7hzocMVro7JNIDWPr13pAIo4
         xKqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=XG7u523a/0f6kyGjbZgxsWPAk334VvfCv1Jk6fCTIsA=;
        b=EXMYLt0SLCkpUUaecfq02/rUMCHJ2q66ZzmZBYXJdPMf3WESP0/oMp+sR7p6BLY8NQ
         p1MZzsOkDRhv8CgRe+t17Hh+WZtYSfdzb4ymAGy/sNa0OlV30wmbV3h1z/c2ZEZHFQKN
         lbFfqiZYETo0AkWbr/xet1NrgX0SmqdbriLjHypSxAdxR+mPhixjMAN1j4KaB9tkG2DB
         Y3Olw6IMl5h7TDd681yf8+J9YEd9wXBl5d/Y6mKE7TbLDUcKWI7OVyPlSCtook3e4y1i
         QlKvAvU3Tnc7M4DbzRfic4zuIysJhNmTXxV5MSLwFgQr+hYT8Z2wZALJmdyIYfRiJ4vA
         dpkg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ieee.org header.s=google header.b=OsEJ4n8z;
       spf=pass (google.com: domain of ddstreet@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ddstreet@gmail.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ieee.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n143sor6013742itn.34.2019.01.29.11.47.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 11:47:06 -0800 (PST)
Received-SPF: pass (google.com: domain of ddstreet@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ieee.org header.s=google header.b=OsEJ4n8z;
       spf=pass (google.com: domain of ddstreet@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ddstreet@gmail.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ieee.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ieee.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=XG7u523a/0f6kyGjbZgxsWPAk334VvfCv1Jk6fCTIsA=;
        b=OsEJ4n8zUxkYU4PMZvePLOWqNzRY0561eKlemyXivyWwEbnIbIFlNqXpffGsDVmwUn
         GSDW9+4KKPB8YJaEmsXPMpZCtbv0FuBQdMhXS6mah7p0plnwDMbamslfsEB3SqedOk8n
         zYGxz9LCJ42C5+n8tZDEAhRSg2JOFcScsrrwM=
X-Google-Smtp-Source: ALg8bN5DGzla/QKZwis6cRJIQyg2Ju8Fk2fSxgIH3vLcT9upMZn+e+YH48qNUy050rPyOgC45tKsBG55kMHkrJmcYhg=
X-Received: by 2002:a24:9dce:: with SMTP id f197mr14154001itd.13.1548791226353;
 Tue, 29 Jan 2019 11:47:06 -0800 (PST)
MIME-Version: 1.0
References: <20190122152151.16139-9-gregkh@linuxfoundation.org>
In-Reply-To: <20190122152151.16139-9-gregkh@linuxfoundation.org>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 29 Jan 2019 14:46:30 -0500
Message-ID: <CALZtONCjGashJkkDSxjP-E8-p67+WeAjDaYn5dQi=FomByh8Qg@mail.gmail.com>
Subject: Re: [PATCH] zswap: ignore debugfs_create_dir() return value
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Seth Jennings <sjenning@redhat.com>, 
	Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 22, 2019 at 10:23 AM Greg Kroah-Hartman
<gregkh@linuxfoundation.org> wrote:
>
> When calling debugfs functions, there is no need to ever check the
> return value.  The function can work or not, but the code logic should
> never do something different based on this.
>
> Cc: Seth Jennings <sjenning@redhat.com>
> Cc: Dan Streetman <ddstreet@ieee.org>
> Cc: linux-mm@kvack.org
> Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> ---
>  mm/zswap.c | 2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/mm/zswap.c b/mm/zswap.c
> index a4e4d36ec085..f583d08f6e24 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -1262,8 +1262,6 @@ static int __init zswap_debugfs_init(void)
>                 return -ENODEV;
>
>         zswap_debugfs_root = debugfs_create_dir("zswap", NULL);
> -       if (!zswap_debugfs_root)
> -               return -ENOMEM;
>
>         debugfs_create_u64("pool_limit_hit", 0444,
>                            zswap_debugfs_root, &zswap_pool_limit_hit);

wait, so if i'm reading the code right, in the case where
debugfs_create_dir() returns NULL, that will then be passed along to
debugfs_create_u64() as its parent directory - and the debugfs nodes
will then get created in the root debugfs directory.  That's not what
we want to happen...

> --
> 2.20.1
>

