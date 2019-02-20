Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A573CC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 21:08:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B8E52146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 21:08:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="MBrn/36B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B8E52146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9B168E0033; Wed, 20 Feb 2019 16:08:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D49228E0002; Wed, 20 Feb 2019 16:08:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C117F8E0033; Wed, 20 Feb 2019 16:08:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8A8B58E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 16:08:49 -0500 (EST)
Received: by mail-vs1-f71.google.com with SMTP id o22so4743663vsp.18
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 13:08:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HBCAGUhW5l+Ooty8Gq4PTf9TssSWAHH8S8cAfD5Y1DA=;
        b=W9ul6MqmWVLgbT9DBubQwpy7j1Lnje55Try9pR9Zh6+KbHD/E5SLRNWJfZMFb852FZ
         c/hK+roPsjSu7v4GrTHacIJ2nVGegu1xZ46iDs2Jqu+zE5Ydx6SH0ocarxRUzzUvbDvQ
         gYAucyr3plSIC5Ls/ifQhNxhh2sG8216qM6kMrEjQbGpRvbjQ7xyPyeen8/7lXhw2V98
         8Up90lanN/KnKVx0lxmHVFFE+nIkfGe0XMtuwWScQ+vw0M9CuZs0trp1LWDmKfEooy27
         U8/yf9NDNNr4/NbG4/puwMSdBZ92IzYRni8+S4XlfcNGY7WJqYuzt8VHeI0dzbdrElEM
         hPVw==
X-Gm-Message-State: AHQUAuY8GjN5SGJ0cQvM1KTXGrC/46RvvSR4DF7sE526fMDFzqJdCgTt
	VjhNwTksL5TpRLeSlrEPYRFkkfPMayVaCJPy9aqJrPc/qCiOb63idVwNOiWs6Kne6iossXTabAq
	HpX5JlZLjK7OMdyl/J9e94amBkjfz0ShBnSx8yJ925oX54gPSBrRryWXn5PPKG/+vKzheVT/vV8
	h7mPffvMH64Pd4WybmGPespc7FFwMOr/5B3snfoEg4jC8x0euqG2Xl9bMYnmoltYqMjWrc9htAu
	oOC7PQRxNqLCtdFpnvjIH0FvGkNqi7KsqwznHz+FxQMoqMlZ+SOtIQWpdleWxftoZ5JaVeh5ICc
	t96EPihqOnzK6E21wnGVoDXMA8ypgxiLo12a/Oz9u4wRgBEjc2nqXXpuCKRo7X3g9n5SRVpjUuJ
	m
X-Received: by 2002:ab0:6486:: with SMTP id p6mr17933830uam.64.1550696929223;
        Wed, 20 Feb 2019 13:08:49 -0800 (PST)
X-Received: by 2002:ab0:6486:: with SMTP id p6mr17933798uam.64.1550696928648;
        Wed, 20 Feb 2019 13:08:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550696928; cv=none;
        d=google.com; s=arc-20160816;
        b=CUa2LJ2rLQkc7TN/vTOOkZm+tO8VsIt+QIThvM/obQ9eFGEmZQcv18TwC6odYzyBX/
         ECSGt5JsP3ebCnAEelFnmb1Y8iSyWZteo4Z9qqjy2Mset+yZgzLq6vvS0Bx/6A5m79n0
         8rxzi6YRDNvVdEDT4tGN0O7G2CWrsiyAd3vKQsiUwpNvB5gsVHSZN+vlIIqvb10C2W9Y
         jb9TllzzzjfJv3tmI5Rvus1yMpTOkJXDaliuwth5bQyBsG1jlKx3MAo15vvRwOQZbXsx
         yPxCSpAD4m+gh4JLsZCymVs/mHBnoqkTj/i8WBTb/3Gc2n0pr9U6ojK5dpNWDuoZ7PI6
         +2EA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HBCAGUhW5l+Ooty8Gq4PTf9TssSWAHH8S8cAfD5Y1DA=;
        b=VSeFhAySq0EPQLCuTJHQ98MOQ31FKZh4jpNrQ6jvwrsbjRvjIPjtI/GPW7HtnWk3/T
         6IrkC5/BVYjsn9kDlGB3TB8qSCozc8tf3le2ha9jisrzT8S53TKMrGSMdK5ob42/a/iB
         FbVOC3dkjoA942RFEffjvutBUchy0kLz6TRG1JePgSKv4DJq4Tuw5t/kAbRiLqVhMGQ7
         8zkImikHObaInodnKbRPcFUg9SnFMYPhhr1MQWpE8hrd6NkuKxxUdhgscdWjPtDZ9nq/
         NEhAlJJmEmhbriXBgFgf6Fgm5b8grbuu3A7R7iPY6WTC1XRzcydDrXz6eztEBdQy9Ti8
         B6LA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="MBrn/36B";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d8sor3284146uap.40.2019.02.20.13.08.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Feb 2019 13:08:48 -0800 (PST)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="MBrn/36B";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HBCAGUhW5l+Ooty8Gq4PTf9TssSWAHH8S8cAfD5Y1DA=;
        b=MBrn/36BK1xIIwh4TJOoq3MNs4GkFfMGTjKPgG6uJCZ59bPws2nF0RSuEpNjICqudR
         W+/8lf6tP+Emi7gUmqenhTj3MK2xIpG7Lg1zIj2r4FazklGZOCQslm5cw3mT84s+WnYx
         8jxtb3PmNDzF/pjCiunl6UitouFRe5tOaJ2BQ=
X-Google-Smtp-Source: AHgI3IbTQQMndzZXHqk8m/ADvpxi/3TcAIqqQPN1jC2YXu3owlc4ve0t/DM51tgJY2H3D73kWlNSRA==
X-Received: by 2002:ab0:3451:: with SMTP id a17mr11839003uaq.60.1550696927171;
        Wed, 20 Feb 2019 13:08:47 -0800 (PST)
Received: from mail-vs1-f43.google.com (mail-vs1-f43.google.com. [209.85.217.43])
        by smtp.gmail.com with ESMTPSA id v79sm4728003vkv.13.2019.02.20.13.08.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 13:08:45 -0800 (PST)
Received: by mail-vs1-f43.google.com with SMTP id n10so14854300vso.13
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 13:08:44 -0800 (PST)
X-Received: by 2002:a67:c00a:: with SMTP id v10mr20437112vsi.66.1550696924229;
 Wed, 20 Feb 2019 13:08:44 -0800 (PST)
MIME-Version: 1.0
References: <20190220204058.11676-1-daniel.vetter@ffwll.ch>
In-Reply-To: <20190220204058.11676-1-daniel.vetter@ffwll.ch>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 20 Feb 2019 13:08:30 -0800
X-Gmail-Original-Message-ID: <CAGXu5jLCyQYCrJDXB_jN7cSoEYEqK3PKLBXc64XHicnE48V0bQ@mail.gmail.com>
Message-ID: <CAGXu5jLCyQYCrJDXB_jN7cSoEYEqK3PKLBXc64XHicnE48V0bQ@mail.gmail.com>
Subject: Re: [PATCH] mm: Don't let userspace spam allocations warnings
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: DRI Development <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, 
	Daniel Vetter <daniel.vetter@intel.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Jan Stancek <jstancek@redhat.com>, 
	Andrey Ryabinin <aryabinin@virtuozzo.com>, "Michael S. Tsirkin" <mst@redhat.com>, 
	Huang Ying <ying.huang@intel.com>, Bartosz Golaszewski <brgl@bgdev.pl>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 12:41 PM Daniel Vetter <daniel.vetter@ffwll.ch> wrote:
>
> memdump_user usually gets fed unchecked userspace input. Blasting a
> full backtrace into dmesg every time is a bit excessive - I'm not sure
> on the kernel rule in general, but at least in drm we're trying not to
> let unpriviledge userspace spam the logs freely. Definitely not entire
> warning backtraces.
>
> It also means more filtering for our CI, because our testsuite
> exercises these corner cases and so hits these a lot.
>
> Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Jan Stancek <jstancek@redhat.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Bartosz Golaszewski <brgl@bgdev.pl>
> Cc: linux-mm@kvack.org
> ---
>  mm/util.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/util.c b/mm/util.c
> index 1ea055138043..379319b1bcfd 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -150,7 +150,7 @@ void *memdup_user(const void __user *src, size_t len)
>  {
>         void *p;
>
> -       p = kmalloc_track_caller(len, GFP_USER);
> +       p = kmalloc_track_caller(len, GFP_USER | __GFP_NOWARN);
>         if (!p)
>                 return ERR_PTR(-ENOMEM);
>
> --
> 2.20.1
>


-- 
Kees Cook

