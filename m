Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81AD6C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 04:21:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3538B20B1F
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 04:21:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="vH8xcYc+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3538B20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE1BB8E0005; Tue, 18 Jun 2019 00:21:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6B568E0001; Tue, 18 Jun 2019 00:21:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A33258E0005; Tue, 18 Jun 2019 00:21:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9608E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 00:21:33 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id v15so12898996ybe.13
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 21:21:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HEtE1A+FVeBvQxYd033P9YUeuxrZ3GsjmhLPdyrBUok=;
        b=S5zZt40sx4tFZQ8/NIUU6zgfhJFlF/o7chVzX3doFMsF+HG4ofRQElLSfc/65ziBDQ
         tLYGiqvqvvHenhSbq4SJnTNHGQyAQxoZVldJqYN2jL/fK/4LBb/daNvMZZ3nJ8jjYKma
         AyB6mINCZIy0IZ/mmpbWgHZ2rZ7xo9mYDkxRk3IGWkK7EM3WzzeatGB5cjg4hen9K3wx
         iUEf8BVJUE1R8D1eTI8fmBUWNkIlu4KdSbRsioI9dV+FXYwhprRKsAXVGpurEKY/ryjJ
         OK0+qbHXxFD8ZGgnIPAZvR5ouBN2nJUV8iumNzLCXQuAx+G9qlEzEy4bMKuUBW26ht7O
         ZFIg==
X-Gm-Message-State: APjAAAWoBUb7X3mHqsUm/hwKTTrYmj/J09NxFl1n6bFJZj2yeAh0jhH2
	J6KWFA8IEH4tBKNj3Msf7RQEZLEiEWm66YfWhEWzjh5QBRdeqAu7L34vN7veHsaE2VifoUfiJ/S
	tcfxTk/d39LmIZ7qjJ7E0l9ivf8tPN76x4DYwYT/sgxmr95iZMDQ57Ttvm9RW5LkrGw==
X-Received: by 2002:a25:3206:: with SMTP id y6mr8346140yby.148.1560831693227;
        Mon, 17 Jun 2019 21:21:33 -0700 (PDT)
X-Received: by 2002:a25:3206:: with SMTP id y6mr8346131yby.148.1560831692594;
        Mon, 17 Jun 2019 21:21:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560831692; cv=none;
        d=google.com; s=arc-20160816;
        b=gRDWgpmVzAliX1xEw2xvk8gcW5cNd3WHMhqrhRFxa9sNUmyn93fcR3MuUyAKmnLW63
         FfXAImWVhXSqKlN8l4jVn81JUzaSGVMO2uW+k/V/RjCuSE6C/ZAuQl4UhiAwA1b3ds/H
         UVYH0aj+ziqM+7Z+6umXEjsJeTfq+kxDvHt+QAnwesYuRZR8M5rz9Gtqhyo7dSjEBeaa
         3x42/zFUeiiqicaMH2ARoEccvcfNUUuA/MLiqxEFQVHRNXHjEPSVwfA9gx6ip7Iz0fHm
         HDaN65H0A3O20gzugswc9+RxK9+Q6JIQjL4sgNz+voj2yodrRmDhf2GiRH3/LRkZnQ/h
         VMLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HEtE1A+FVeBvQxYd033P9YUeuxrZ3GsjmhLPdyrBUok=;
        b=FOvFQ4XemnSP7Wq/i3FFXlZy/zCJu4Sk2YCYnUeN5awsBB4UrUpOl/YPFOWqWvyRJX
         US7BUJbDmEmTYE/2iyxGyfnyb/BcrwMafTjzAzWUcQBlvjfuw90fzywssaRjjS1y0+jp
         Wint3orL2XdbfbdbhgOjpyGN9kql56Z/huVky+JbgANqROD3yNHLZQRTTauiTOz4VxCJ
         djVdH8IaUrJQGdKu10hj+DInIQXor3rK0UWijsK73cI/QiMjkI4AzypAb2d5D+jD2sfN
         Q75U1xoY66tbaxOk7X8RUPPGcj1ON5WRe01qTRIp3K3zPTEqP/cJJAR5ex7KdGS9iaZJ
         Ty5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vH8xcYc+;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i5sor6605992ybp.18.2019.06.17.21.21.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 21:21:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vH8xcYc+;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HEtE1A+FVeBvQxYd033P9YUeuxrZ3GsjmhLPdyrBUok=;
        b=vH8xcYc+TFxAr+CXKS81Vrul2KssbSwKqLNG4diKj8FJlkSAa/EV2jaJv0QAyBTBxY
         nPtg2iBRJiGkXVvK/+RVRTcjv/tNo9SiLpDQBdM1aqNN8+sr/hbfeQnrjN5HR4C9Wqe9
         2+nM2Y3SYAdu3/+zqgc4vBLaYUJW8IRHb3MV/45vVvEDTj+hliI5lUmZ7SOrEcdnpR3Z
         tI1BJeQ5hIALLU9Ggkgky49E2+8cQuxNbIoqs7ktczzPz1Z9I5b1xFKhEg4dIB/xDJPT
         LDTpuzFl5x7rc3Tvaeu3+sH7cu+58zb4+gaysdbhzXfgGpC2rdcRIlPo+hS0bMtbL0in
         2khg==
X-Google-Smtp-Source: APXvYqz2nxnNCsP6qANdViBc7IWFcaTmarfi4vuwMpaN6A94f2qkbKEUgRoo5uR3ibDCAImQ71Kc6IBCjTbDmmb7NJ0=
X-Received: by 2002:a5b:942:: with SMTP id x2mr54859299ybq.147.1560831692033;
 Mon, 17 Jun 2019 21:21:32 -0700 (PDT)
MIME-Version: 1.0
References: <0000000000004143a5058b526503@google.com> <CALvZod72=KuBZkSd0ey5orJFGFpwx462XY=cZvO3NOXC0MogFw@mail.gmail.com>
 <20190615134955.GA28441@dhcp22.suse.cz> <CALvZod4hT39PfGt9Ohj+g77om5=G0coHK=+G1=GKcm-PowkXsw@mail.gmail.com>
 <5bb1fe5d-f0e1-678b-4f64-82c8d5d81f61@i-love.sakura.ne.jp>
 <CALvZod4etSv9Hv4UD=E6D7U4vyjCqhxQgq61AoTUCd+VubofFg@mail.gmail.com>
 <791594c6-45a3-d78a-70b5-901aa580ed9f@i-love.sakura.ne.jp>
 <840fa9f1-07e2-e206-2fc0-725392f96baf@i-love.sakura.ne.jp>
 <c763afc8-f0ae-756a-56a7-395f625b95fc@i-love.sakura.ne.jp>
 <CALvZod5VPLVEwRzy83+wT=aA8vsrUkvoJJZvmQxyv4YbXvrQWw@mail.gmail.com> <20190617184547.5b81f7df81af46e86441ba8c@linux-foundation.org>
In-Reply-To: <20190617184547.5b81f7df81af46e86441ba8c@linux-foundation.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 17 Jun 2019 21:21:20 -0700
Message-ID: <CALvZod5L9VEAiGSk2JYY-e7RGLRn+tFcn-cePtw-epLGsxf2wg@mail.gmail.com>
Subject: Re: general protection fault in oom_unkillable_task
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Michal Hocko <mhocko@kernel.org>, 
	syzbot <syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com>, 
	"Eric W. Biederman" <ebiederm@xmission.com>, Roman Gushchin <guro@fb.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, yuzhoujian@didichuxing.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 6:45 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Mon, 17 Jun 2019 06:23:07 -0700 Shakeel Butt <shakeelb@google.com> wrote:
>
> > > Here is a patch to use CSS_TASK_ITER_PROCS.
> > >
> > > From 415e52cf55bc4ad931e4f005421b827f0b02693d Mon Sep 17 00:00:00 2001
> > > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > Date: Mon, 17 Jun 2019 00:09:38 +0900
> > > Subject: [PATCH] mm: memcontrol: Use CSS_TASK_ITER_PROCS at mem_cgroup_scan_tasks().
> > >
> > > Since commit c03cd7738a83b137 ("cgroup: Include dying leaders with live
> > > threads in PROCS iterations") corrected how CSS_TASK_ITER_PROCS works,
> > > mem_cgroup_scan_tasks() can use CSS_TASK_ITER_PROCS in order to check
> > > only one thread from each thread group.
> > >
> > > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> >
> > Reviewed-by: Shakeel Butt <shakeelb@google.com>
> >
> > Why not add the reproducer in the commit message?
>
> That would be nice.
>
> More nice would be, as always, a descriptoin of the user-visible impact
> of the patch.
>

This is just a cleanup and optimization where instead of traversing
all the threads in a memcg, we only traverse only one thread for each
thread group in a memcg. There is no user visible impact.

> As I understand it, it's just a bit of a cleanup against current
> mainline but without this patch in place, Shakeel's "mm, oom: refactor
> dump_tasks for memcg OOMs" will cause kernel crashes.  Correct?

No, the patch "mm, oom: refactor dump_tasks for memcg OOMs" is making
dump_stacks not depend on the memcg check within
oom_unkillable_task().

"mm, oom: fix oom_unkillable_task for memcg OOMs" is the actual fix
which is making oom_unkillable_task() correctly handle the memcg OOMs
code paths.

Shakeel

