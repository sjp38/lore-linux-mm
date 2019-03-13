Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A37B3C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 14:35:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5907A2087C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 14:35:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5907A2087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEF1F8E0003; Wed, 13 Mar 2019 10:35:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9EEF8E0001; Wed, 13 Mar 2019 10:35:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8F868E0003; Wed, 13 Mar 2019 10:35:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5DB988E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 10:35:06 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id t4so884833eds.1
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 07:35:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Idx8wXXBwQOOPMKRuc2dDME3eVRzsLZqZiisX++3jMY=;
        b=Umm1AtYUmcR9SBBhEzHldfvAmO6XKbSMC/LgD0aiiEMupw1ART5uBsmELtpz/A8Frv
         9N9mAPMj/j04o1e59sA+n+vkg9whJr0N8dsYsKCXb6ggtEWhaGST6cKUuIP4HUSatuw1
         n40Jyx9JJfFiaBFBLvN5b1cWAnwh+7bYic4oihDZD4SlZNF60Fpgu48NHUGhUDcpLSaY
         s4vULV6ykaUxulJ5Mpuu1c2quIU+O8VvX9Sg6n5a3afIKRy3RLU7UBUUbLeu4H8DApJ9
         21YFxq1jo8i+NNYez9f09/oFWSIvhrFrL7OXXnHomdQ1Gbs89FuHEdkG64pmAlg7xL32
         Gv+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAXZjX4kqUJfYUhYOxofSSOGHEzVX3Tf1wAAyPo8vHoVlID/JZ/C
	bv9SALmujPESoLu/P2GpkMFtgnb7hERYET7W5Ct4sNoVQK9z8sOHq+fPB3jsVT3u8axyhctXNTR
	tGJIXshtFA0/8DD2YNLVoPlEZQZwle0+TzpLzfXDqu2h3+g+uwdT4S75g+PL6UsgI4w==
X-Received: by 2002:a05:6402:1699:: with SMTP id a25mr7739547edv.59.1552487705954;
        Wed, 13 Mar 2019 07:35:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzg6anmUDwhj2fczbLI+IGIaSiszlKOvQxqu2BIS4pQv3vAFUMoKDb1stdE8fHgUculY8BH
X-Received: by 2002:a05:6402:1699:: with SMTP id a25mr7739504edv.59.1552487705081;
        Wed, 13 Mar 2019 07:35:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552487705; cv=none;
        d=google.com; s=arc-20160816;
        b=i6rE7ibFspVIr5SQ4CK5ds9AG8Cuq9CUKSEB2+uErq9F8h/ZtMRZZkxymlZzNA6B9N
         zhI9EsSDj4VM6M1McgXzw97/G4G0TNI4CqZcHqX5mrD8tbrkoaydIf4aVLLDGoQa+ptt
         Y/IrE3mH8xPfSKxu/auFwIHDUEsJb+Vtp3m66w9WCSjpSirG8uSVuBCcFw5Yt+3lXWyv
         EWH0FPW6uGjKRvsTPrSdrQizV5Vdy4Uhce6HANx53ta1+N0ohmEWiO19E3zivVRgf9l4
         FjEQRYcpf3BTBWoFx20lhDGiOv4M7yGp37Qm5GcFNL/U6md2JWTCY5w+kBCkoFt6eCQ4
         FdpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Idx8wXXBwQOOPMKRuc2dDME3eVRzsLZqZiisX++3jMY=;
        b=MtjWSvn/8DStnjadXBrugaUsIkcbCGofULSNci+zWbkEZMlwgG85Fr3aScUcey3pxN
         w+gGPjyoQTTPUbOygdIUeOh3pXTeZfTQqRCnMaxWVF4QbCmtjubj8YlMx1yWz4NaxWBs
         aN17CeMLfC6Vtwl3Ibd9HKkUWCR7h/r9igm/y5nCthGKLhtPNh/QjxmpgxBXGOa1mogA
         d+doiL/R65Hu3Bo67yaXxDyp/xWs6rga3K+uAn+OVRQiTilsOfADkdHgMj67bWREANVQ
         wZ6fGc6o6SqjFatNYAC4oi347OtLJN8pX78KEHHxvCu1yOg/cBO40Gw2CsMWN2BJb6fH
         ESNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h10si760571ejb.37.2019.03.13.07.35.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 07:35:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3427DAD55;
	Wed, 13 Mar 2019 14:35:04 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 8490A1E3FE8; Wed, 13 Mar 2019 15:35:03 +0100 (CET)
Date: Wed, 13 Mar 2019 15:35:03 +0100
From: Jan Kara <jack@suse.cz>
To: Kees Cook <keescook@chromium.org>
Cc: syzbot <syzbot+2c49971e251e36216d1f@syzkaller.appspotmail.com>,
	Amir Goldstein <amir73il@gmail.com>, Jan Kara <jack@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>, cai@lca.pw,
	Chris von Recklinghausen <crecklin@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>
Subject: Re: WARNING: bad usercopy in fanotify_read
Message-ID: <20190313143503.GD9108@quack2.suse.cz>
References: <00000000000016f7d40583d79bd9@google.com>
 <CAGXu5jKjWwYk5N3mOH1A8fXX_0BT3r1At_3MzN9M+Ckg5irKXg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jKjWwYk5N3mOH1A8fXX_0BT3r1At_3MzN9M+Ckg5irKXg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 12-03-19 23:26:22, Kees Cook wrote:
> On Mon, Mar 11, 2019 at 1:42 PM syzbot
> <syzbot+2c49971e251e36216d1f@syzkaller.appspotmail.com> wrote:
> > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=17ee410b200000
> > [...]
> > ------------[ cut here ]------------
> > Bad or missing usercopy whitelist? Kernel memory exposure attempt detected
> > from SLAB object 'fanotify_event' (offset 40, size 8)!
> > [...]
> >   copy_to_user include/linux/uaccess.h:151 [inline]
> >   copy_fid_to_user fs/notify/fanotify/fanotify_user.c:236 [inline]
> >   copy_event_to_user fs/notify/fanotify/fanotify_user.c:294 [inline]
> 
> Looks like this is the fh/ext_fh union in struct fanotify_fid, field
> "fid" in struct fanotify_event. Given that "fid" is itself in a union
> against a struct path, I think instead of a whitelist using
> KMEM_CACHE_USERCOPY(), this should just use a bounce buffer to avoid
> leaving a whitelist open for path or ext_fh exposure.

Do you mean to protect it from a situation when some other code (i.e. not
copy_fid_to_user()) would be tricked into copying ext_fh containing slab
pointer to userspace?

								Honza

> 
> Maybe something like this (untested):
> 
> diff --git a/fs/notify/fanotify/fanotify_user.c
> b/fs/notify/fanotify/fanotify_user.c
> index 56992b32c6bb..b87da9580b3c 100644
> --- a/fs/notify/fanotify/fanotify_user.c
> +++ b/fs/notify/fanotify/fanotify_user.c
> @@ -207,6 +207,7 @@ static int process_access_response(struct
> fsnotify_group *group,
>  static int copy_fid_to_user(struct fanotify_event *event, char __user *buf)
>  {
>         struct fanotify_event_info_fid info = { };
> +       unsigned char bounce[FANOTIFY_INLINE_FH_LEN], *fh;
>         struct file_handle handle = { };
>         size_t fh_len = event->fh_len;
>         size_t len = fanotify_event_info_len(event);
> @@ -233,7 +234,18 @@ static int copy_fid_to_user(struct fanotify_event
> *event, char __user *buf)
> 
>         buf += sizeof(handle);
>         len -= sizeof(handle);
> -       if (copy_to_user(buf, fanotify_event_fh(event), fh_len))
> +
> +       /*
> +        * For an inline fh, copy through stack to exclude the copy from
> +        * usercopy hardening protections.
> +        */
> +       fh = fanotify_event_fh(event);
> +       if (fh_len <= sizeof(bounce)) {
> +               memcpy(bounce, fh, fh_len);
> +               fh = bounce;
> +       }
> +
> +       if (copy_to_user(buf, fh, fh_len))
>                 return -EFAULT;
> 
>         /* Pad with 0's */
> 
> 
> -- 
> Kees Cook
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

