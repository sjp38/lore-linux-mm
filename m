Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04D7FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 18:03:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B95C320811
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 18:03:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qZ9LzxuX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B95C320811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 429306B0008; Tue, 19 Mar 2019 14:03:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D8C06B000A; Tue, 19 Mar 2019 14:03:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A1A56B000C; Tue, 19 Mar 2019 14:03:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id CE8976B0008
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 14:03:16 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id l20so6056661wrf.23
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 11:03:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=DjQYlcDfI2yco5kK76SVjFJd0JAsA9gIL0FN2AFEY0c=;
        b=GjQA6x+QPZ5leQa+8WC/oDHIMg+Av8CmgEDOyk50Mq4oIkliIJaMCZf8tauqAcW4Xx
         k/IQcfSBrr+4sdfA0sIHbGBkL7cra6M2fOxYMUhRj/YRjyza14RxhTlSvfSJ1GWD76jD
         ILH4gjxZ9uU/JZaT6wQ61eh5AMrY0FVIg1h8OiLvOhNeRVZREkeVC1nTR6rTHCz+2uwZ
         b4jEj1lrg9K4xMdGa6PfwBEOZvwYnZjIgqQaNqVIfcXAst1jgrHdBc+bjO3mcvHYDwcI
         Rg1s7KpuThmnfCOT7juX0EVJnHJdbUaMRXFih8SzYbMrpLFPFl9g8A29cniGVBn2B0wq
         IKmw==
X-Gm-Message-State: APjAAAWviDVXuDfZWsyMvsv7HuHVfGkYU4xFbTw+HxaXwja7UAGwpY3p
	e3yKDEjIeL9N46p0yTx0fU4zwV2Le7ISf3ol3/3MIbu88vikrLadQcNZSNvvoQyc/96T6R3pw9R
	MR5SArjvdSh0FIfgRN2cCUbZFjIAraBurT0lYstBFxm77cCoMnOMH2UlL3QG2vw8/7Q==
X-Received: by 2002:a1c:4d12:: with SMTP id o18mr5017889wmh.74.1553018596268;
        Tue, 19 Mar 2019 11:03:16 -0700 (PDT)
X-Received: by 2002:a1c:4d12:: with SMTP id o18mr5017842wmh.74.1553018595339;
        Tue, 19 Mar 2019 11:03:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553018595; cv=none;
        d=google.com; s=arc-20160816;
        b=GDRGw20njDou6ti6aaBfZfYoFoB3sxOYROAVpbd3Bt+rWf2wEFsKHi55KRXpUA/Nig
         5xlN4beYoJIL2K5GhHiwKB20v1R4FBVGCrawBorSpfizzNurX2Tz4bWEdO7WUVD8itBH
         cU26C+6C9IZALyLwd93H3Imv2gcdC0gqt4SOVZhZbnq8Z+Amg4oav7cb5TU7lEcixjrc
         aJMOH9Pikb0s6hK8pCC1j93pix2Rq+7vxD6zJ5pzoC2+L2/EFMSOGgMTbqeORx2vJk61
         xaIUIw8110BE3AyWesPyD8eAljyU9u9IUxlAY6f+IwXqovNezFzzvVBOMx/y613iUiAh
         bY6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=DjQYlcDfI2yco5kK76SVjFJd0JAsA9gIL0FN2AFEY0c=;
        b=ZEE6zK6tFxCHvVLwTNZ84TLRoDbSRe/t6rm+YlYcMwMOdos0hJzlu3I8n15/rYlYTg
         YlbYdJlbU3ROLphHHnRTOVh2u41q/9OiB2GSRQSSo1QZJsw7lvokB3dRdCo1B+Cdc8kA
         aop3QOex1GpmsV0nQD1pZADzbV+EZmvfS+ggLINakFXdzf8OzkkawmyQJNLmxLn3cbfP
         T+43erXoSXywxZXxSzsB8fPF8J+EXCDpEi+0wQe0KCc+DwsTzEuwbNpEZobyT0bf7cX+
         mCCoSlq40t0Sd7lDUptB8m7PDqJ94MIRH/tFSUgajXGZtSCQuagEnsyN4XqzW2wHpCyQ
         F0yw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qZ9LzxuX;
       spf=pass (google.com: domain of lucien.xin@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=lucien.xin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f15sor6184728wrm.24.2019.03.19.11.03.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 11:03:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of lucien.xin@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qZ9LzxuX;
       spf=pass (google.com: domain of lucien.xin@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=lucien.xin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DjQYlcDfI2yco5kK76SVjFJd0JAsA9gIL0FN2AFEY0c=;
        b=qZ9LzxuXQvPGopSwPJwE8FrP4+RUr7dwnIw4CMOoP3vrdES4eCRZN0qsKsmEohIFql
         1M5iMT99wvZg+pGeJCDc1tJ+vefdqsuXZ5ZFRAz2JzF1Ix5o2CKHWEmX4WSVmldE6lot
         Zbh+Hdlgft4t+Pk7NORG2PV2ktc/swjMTc34GCOVG9DSGuemlxRZtuLGuw09+VpGYvw+
         KXOyH/SDwD3pFeE5at5whcZCPpCspZKxPUvaNrxWeb1RhPxqIeipxd7hStH/ZJolOFdO
         SOfPW3UW+QeCh0gBPszxXcyuF7AZkmBMsTB34x1n/4neVfj7FxhdiLke9LJTk9Xth+rS
         2n5Q==
X-Google-Smtp-Source: APXvYqwxA+cja8P0Uolv1lvIcuMWr+xMbFnYg7BW0m+L5QJB8Jf0Q/+sVz5h/+znN3FpJIUNhQ72kkWZ2miVK/JxlGM=
X-Received: by 2002:adf:eb0a:: with SMTP id s10mr16412401wrn.242.1553018595039;
 Tue, 19 Mar 2019 11:03:15 -0700 (PDT)
MIME-Version: 1.0
References: <000000000000b05d0c057e492e33@google.com> <000000000000db3d130584506672@google.com>
In-Reply-To: <000000000000db3d130584506672@google.com>
From: Xin Long <lucien.xin@gmail.com>
Date: Wed, 20 Mar 2019 02:03:03 +0800
Message-ID: <CADvbK_f6cDsJzXa3fzj3EFq+-hRD9EYXqbhkXq8gHqMEpqp8bA@mail.gmail.com>
Subject: Re: kernel panic: corrupted stack end in wb_workfn
To: syzbot <syzbot+ec1b7575afef85a0e5ca@syzkaller.appspotmail.com>
Cc: akpm@linux-foundation.org, aryabinin@virtuozzo.com, cai@lca.pw, 
	davem <davem@davemloft.net>, Dmitry Vyukov <dvyukov@google.com>, guro@fb.com, 
	hannes@cmpxchg.org, jbacik@fb.com, Kirill Tkhai <ktkhai@virtuozzo.com>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 
	linux-sctp@vger.kernel.org, mgorman@techsingularity.net, mhocko@suse.com, 
	network dev <netdev@vger.kernel.org>, Neil Horman <nhorman@tuxdriver.com>, shakeelb@google.com, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, viro@zeniv.linux.org.uk, 
	Vlad Yasevich <vyasevich@gmail.com>, willy@infradead.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 18, 2019 at 4:49 AM syzbot
<syzbot+ec1b7575afef85a0e5ca@syzkaller.appspotmail.com> wrote:
>
> syzbot has bisected this bug to:
>
> commit c981f254cc82f50f8cb864ce6432097b23195b9c
> Author: Al Viro <viro@zeniv.linux.org.uk>
> Date:   Sun Jan 7 18:19:09 2018 +0000
>
>      sctp: use vmemdup_user() rather than badly open-coding memdup_user()
'addrs_size' is passed from users, we actually used GFP_USER to
put some more restrictions on it in this commit:

commit cacc06215271104b40773c99547c506095db6ad4
Author: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date:   Mon Nov 30 14:32:54 2015 -0200

    sctp: use GFP_USER for user-controlled kmalloc

However, vmemdup_user() will 'ignore' this flag when going to vmalloc_*(),
So we probably should fix it by using memdup_user() to avoid that
open-coding part instead:

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index ea95cd4..e5bcade 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -999,7 +999,7 @@ static int sctp_setsockopt_bindx(struct sock *sk,
        if (unlikely(addrs_size <= 0))
                return -EINVAL;

-       kaddrs = vmemdup_user(addrs, addrs_size);
+       kaddrs = memdup_user(addrs, addrs_size);

>
> bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=137bcecf200000
> start commit:   c981f254 sctp: use vmemdup_user() rather than badly open-c..
> git tree:       upstream
> final crash:    https://syzkaller.appspot.com/x/report.txt?x=10fbcecf200000
> console output: https://syzkaller.appspot.com/x/log.txt?x=177bcecf200000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=5e7dc790609552d7
> dashboard link: https://syzkaller.appspot.com/bug?extid=ec1b7575afef85a0e5ca
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=16a9a84b400000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=17199bb3400000
>
> Reported-by: syzbot+ec1b7575afef85a0e5ca@syzkaller.appspotmail.com
> Fixes: c981f254 ("sctp: use vmemdup_user() rather than badly open-coding
> memdup_user()")

