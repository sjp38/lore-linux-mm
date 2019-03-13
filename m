Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CD82C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 06:26:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4529217F5
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 06:26:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="QdHnZTm7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4529217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D93D8E0003; Wed, 13 Mar 2019 02:26:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 388278E0002; Wed, 13 Mar 2019 02:26:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 250058E0003; Wed, 13 Mar 2019 02:26:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id E96898E0002
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 02:26:38 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id t20so178307vsq.4
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 23:26:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=p7xzeYD4smScVaFve0D/PWcSiHc+2ECvkTqKkXhqffA=;
        b=rMKw7GY3LBe9hbTTNk8n740VBB5bYiSmzugNxiYNXU2sesPXxQzwB64KX1clATXCVx
         qmgbathUdTzhqld+cI49Lrh3EHBMfay+LU9R+sxiF4W2m+DvKgG0iXeg2xfHp6Raprh+
         9SKRNTTsSb+vM/zFckFvyJfo3hffW7AWfhDuDuKyWt1gbub+QhLbniuBskVLxBST2mby
         Fu1auObQO0oiIEex3qp7lejj21hHwybGqHtnaOvGUtjQcqewbHRW71Nfmu9ANOKUdrRw
         TQ42GrhueWlz+Q1MF6CBkAp9rLaUJgQczULGSJwq6v4zGh+jmeVJzGZLjU2InN3wWCIo
         igpQ==
X-Gm-Message-State: APjAAAUCUFb7ENVVr/6ERy8PGN+b8euWk6gzcMcuaYCzxU0C8giHxdjW
	kkrrsRq/wZh79bv2oEe3xEcT17MY6PoWfIgFWXcmwtgvnJbAQ0e88mTGWFoyL1PYXigFkga2KT1
	MZ05LB/HfEXDw6oivGq4YyHIPX8WxE93/WAUtQlNzp+J6o7TwAlb1NKT4wdZOBN5dbgzKwmBBxx
	y7FduXmP8uhy947VpzLSgoDauJPc0D2OWNQC+hRfYdaiNOqQAMOcfHEHGryJfPtumcr8a0KYDz9
	s9vpjgOHHcm45LCwkWowazak58ewMJKi5J9ojTa70QNebjlWFK0PEDO5MRibqyRbdhgvfFSh06O
	kyfv8+vdclTsqt3eKTpbYH3sZ/mEiyJJcg94JP6C7Rd0PeHl+jyVoweQKk4+9ZjJ7Chzgm2fzMe
	W
X-Received: by 2002:a1f:8948:: with SMTP id l69mr21795339vkd.32.1552458398561;
        Tue, 12 Mar 2019 23:26:38 -0700 (PDT)
X-Received: by 2002:a1f:8948:: with SMTP id l69mr21795316vkd.32.1552458397585;
        Tue, 12 Mar 2019 23:26:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552458397; cv=none;
        d=google.com; s=arc-20160816;
        b=cpHrEXOoTbc1nO7UI2SEGHuqwqWvRtpPpPXVaLN72FpoxpOMKm/xZ7KybhYSnUz8vx
         bB39HzSvOSN7nNSjoAuX7TOUYb1h/NtzNcGT7TjB/zWJIhvKe1/7eIV9vVTUvylfDrRo
         CmAxD09gL8rMDPyB45iCFvC+8vSaPzVUKdlOWjSlbR7hHfcU5ZUHPY1UEy4A2/rSoz8C
         pgpds0W8axnNQGapnPw9fGg5M9KAC9IakWN7eV+unBv7VoUhH6+J7xBFR1QDcYwLEMI3
         pQK6Oz9U5JSsZP+ZABQDsyZoC3jFqwemeZ/Xpy/G4AYs/W302y1YTT6KV3fDSABdGwEV
         Hl3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=p7xzeYD4smScVaFve0D/PWcSiHc+2ECvkTqKkXhqffA=;
        b=0lZdw21XkLMR99a4d+YCrM4WKkuWUSVt+7SnDIkzc9uiHHm4qN+vNEsiUiOiBC7M7F
         mYWpAE9L2rorploVyNwCuQ2J8rVFrXYKwjaKl6UixALAa4mpItmFtgNBsQcvHnqoV7ED
         mNGxUDWTy+D4Ld5HDP9wugOXx3ncHhn1sASCN5jU29T+zZ/m31bMwdVGXa9bSvqBQ5op
         E5BC4TvaVDG6EEQ+8LvQfVGTj2gkklmMWI+boJna+z/DlIl6l6u9uCrtZ+pX/x4++1hU
         rlExK/LmtJSPVztWWgjxrgXAsfsbN7y8mHX2N0c5hA6msPqvmrDv4/eCRCSUvKfRXnCc
         cGwg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=QdHnZTm7;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a123sor6451365vsd.78.2019.03.12.23.26.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 23:26:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=QdHnZTm7;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=p7xzeYD4smScVaFve0D/PWcSiHc+2ECvkTqKkXhqffA=;
        b=QdHnZTm7n3nsNFJWb4IeZSOYwii5BQ8mCPxL6xhnYymT5xzssWA70KJSDMEXd6GRCS
         h1mLXtGsKHF+1ijdtX9DLZ72skvXtCxwNY3+l1SmaUb4/GXJMx0phlmLEan3J8L0AYZt
         C/TMggSFhA5PVQYB/vTNvJFV/3tdmOxNUT8Ms=
X-Google-Smtp-Source: APXvYqzvPCHW7FSKzSMvVH8XAjPXVqse3pAROMEvzXmLl7Rk+pSEC4Vx5GE5fmy+8UHfXUHc3JHe6w==
X-Received: by 2002:a67:c994:: with SMTP id y20mr185154vsk.160.1552458396915;
        Tue, 12 Mar 2019 23:26:36 -0700 (PDT)
Received: from mail-vs1-f53.google.com (mail-vs1-f53.google.com. [209.85.217.53])
        by smtp.gmail.com with ESMTPSA id q12sm4368055vkf.42.2019.03.12.23.26.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 23:26:35 -0700 (PDT)
Received: by mail-vs1-f53.google.com with SMTP id j12so343165vsd.3
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 23:26:35 -0700 (PDT)
X-Received: by 2002:a67:fa94:: with SMTP id f20mr5954737vsq.172.1552458395001;
 Tue, 12 Mar 2019 23:26:35 -0700 (PDT)
MIME-Version: 1.0
References: <00000000000016f7d40583d79bd9@google.com>
In-Reply-To: <00000000000016f7d40583d79bd9@google.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 12 Mar 2019 23:26:22 -0700
X-Gmail-Original-Message-ID: <CAGXu5jKjWwYk5N3mOH1A8fXX_0BT3r1At_3MzN9M+Ckg5irKXg@mail.gmail.com>
Message-ID: <CAGXu5jKjWwYk5N3mOH1A8fXX_0BT3r1At_3MzN9M+Ckg5irKXg@mail.gmail.com>
Subject: Re: WARNING: bad usercopy in fanotify_read
To: syzbot <syzbot+2c49971e251e36216d1f@syzkaller.appspotmail.com>, 
	Amir Goldstein <amir73il@gmail.com>, Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, cai@lca.pw, 
	Chris von Recklinghausen <crecklin@redhat.com>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 1:42 PM syzbot
<syzbot+2c49971e251e36216d1f@syzkaller.appspotmail.com> wrote:
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=17ee410b200000
> [...]
> ------------[ cut here ]------------
> Bad or missing usercopy whitelist? Kernel memory exposure attempt detected
> from SLAB object 'fanotify_event' (offset 40, size 8)!
> [...]
>   copy_to_user include/linux/uaccess.h:151 [inline]
>   copy_fid_to_user fs/notify/fanotify/fanotify_user.c:236 [inline]
>   copy_event_to_user fs/notify/fanotify/fanotify_user.c:294 [inline]

Looks like this is the fh/ext_fh union in struct fanotify_fid, field
"fid" in struct fanotify_event. Given that "fid" is itself in a union
against a struct path, I think instead of a whitelist using
KMEM_CACHE_USERCOPY(), this should just use a bounce buffer to avoid
leaving a whitelist open for path or ext_fh exposure.

Maybe something like this (untested):

diff --git a/fs/notify/fanotify/fanotify_user.c
b/fs/notify/fanotify/fanotify_user.c
index 56992b32c6bb..b87da9580b3c 100644
--- a/fs/notify/fanotify/fanotify_user.c
+++ b/fs/notify/fanotify/fanotify_user.c
@@ -207,6 +207,7 @@ static int process_access_response(struct
fsnotify_group *group,
 static int copy_fid_to_user(struct fanotify_event *event, char __user *buf)
 {
        struct fanotify_event_info_fid info = { };
+       unsigned char bounce[FANOTIFY_INLINE_FH_LEN], *fh;
        struct file_handle handle = { };
        size_t fh_len = event->fh_len;
        size_t len = fanotify_event_info_len(event);
@@ -233,7 +234,18 @@ static int copy_fid_to_user(struct fanotify_event
*event, char __user *buf)

        buf += sizeof(handle);
        len -= sizeof(handle);
-       if (copy_to_user(buf, fanotify_event_fh(event), fh_len))
+
+       /*
+        * For an inline fh, copy through stack to exclude the copy from
+        * usercopy hardening protections.
+        */
+       fh = fanotify_event_fh(event);
+       if (fh_len <= sizeof(bounce)) {
+               memcpy(bounce, fh, fh_len);
+               fh = bounce;
+       }
+
+       if (copy_to_user(buf, fh, fh_len))
                return -EFAULT;

        /* Pad with 0's */


-- 
Kees Cook

