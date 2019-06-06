Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4F5BC28EB4
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 15:18:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90D7C20673
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 15:18:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="g9cYwVye"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90D7C20673
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1127C6B027D; Thu,  6 Jun 2019 11:18:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09CBA6B027E; Thu,  6 Jun 2019 11:18:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA5326B027F; Thu,  6 Jun 2019 11:18:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id CABDD6B027D
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 11:18:31 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id z19so369428ioi.15
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 08:18:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+Czz2YJ7892NSsTQIUl/eIZo5zHlJk+9baf2OTNB6U0=;
        b=YvEFh3Xt4vb8pQPJkD+/iYWzwEYTUb/NHS61e5GTM4UsMNVxUkBWWo353YMdpem4Wu
         DacTYJaj6qc7c6JZiPhFGLeTv50kzYWFV6oL86VUpaNhIaaTEXfZc6Zk6zWVqKwYen/s
         El2L74omrV3B1C9tzHhl50aSTuVBMvpGU6077r5MdNfp87D1L4Dzf/qNHRrnkKwAX1aR
         vMu9mWqfAKxRczQtu1nAEIjIMYzJAiEAU7JImc5TOjLpeM4EU9mkG01pvLIwFvVrRzWG
         0dKkd+v5fUiuJim7567On8laG8k5reSWNyQ1feQnk0aDRhk5xtR/HOKG4m+MA/uYvcQK
         Oniw==
X-Gm-Message-State: APjAAAWWwUfEfcoCpjZ2OghY58usvi+UDXzQc2lTcwOZtQ717N2AaCrR
	6eTK+UhHF3KllTecrQVqkfazqEDdF8kMDOFblIzvdld+69ssgX6bEN8M8r5l5fAVgmgxRbf8CX5
	XrX6Gps8dgaLm8YA4UyxtZ/O/Yh8q54BADZNHguj8EkjScIO12UqiX8AEujUxeGvrjA==
X-Received: by 2002:a02:862b:: with SMTP id e40mr2299426jai.7.1559834311545;
        Thu, 06 Jun 2019 08:18:31 -0700 (PDT)
X-Received: by 2002:a02:862b:: with SMTP id e40mr2299377jai.7.1559834310891;
        Thu, 06 Jun 2019 08:18:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559834310; cv=none;
        d=google.com; s=arc-20160816;
        b=GnnozTL4/BxolvJ5s0P0O5W7QLcqCvMsbpYS7qVvYfS0BxLoyhhOG1oNKL/OoLb2a+
         9jt44xHCHRNTZtJcMZwluYgMogrJe+9MkiaOx3UoNgiM1o59WNw6XUL3UpUK/PLfivHo
         yqYp831UIHLH58ER+ju0zGwwd+GRMJ/+WmiaUO0fKlxdsX6W56PbBjn1pbrsWXiqiKIf
         uNkHBqXmCegHJzdFej6qxOeQkeKjHbe/DEJ3C/yEhUtwehxyp5+VOd7eR+0/nToP6nzG
         F0v3jUSVQR7Xio+ULw0FgFAPyAi1ztbAn/spkmEPq7K3zCllhzmLWKek62QdyWGM7C2D
         zfsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+Czz2YJ7892NSsTQIUl/eIZo5zHlJk+9baf2OTNB6U0=;
        b=ikoyKUkbS5vC96N4AW7yn1fJ6GlZHNb7o7Ss9LjyPH3ZITy9+V9XN37n7HIObSHMZy
         T9iDDIZfvUayFEUVebL2lgtQ1QG5+LbZeLoDOUy32LXYgFZu6rjvz8BVqgeWu78PhmEB
         Rb+4IC+EAp3j4LhtjQ5/wblhpRrMRjXrlqliY3LThUGBYTd39GvhXYQ3HlwxWtlhFiVq
         ScqeMJ6ZcEO2rBXmybeZJuWcaqdgHbTCeA+b3dJPbvL2BYWbxhZ1bINo9Qz7RchFe3mQ
         ZbpoVzQHUF+lsygnFiYDevBTfuhOQcqQbfmVamIk5lIbDQGCuw6A1tavfnxmUa8aZckH
         19DA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=g9cYwVye;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v129sor3163907itb.4.2019.06.06.08.18.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 08:18:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=g9cYwVye;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+Czz2YJ7892NSsTQIUl/eIZo5zHlJk+9baf2OTNB6U0=;
        b=g9cYwVyeaSTJ4J3DPXQfg7qNzmOZHt86bELF+Z9EwhydQbsHg68LqzYVRluTpmW4hn
         lcSV0N7uV+jNQm0/Cbc12coiRdBCPFmmwPh9MUw7M5DX/C37GJ9bF7olW7lMtzvQ7MqD
         4DnOx8YLETBZePvU2bW7nAHhb6VeAuQz7Som64e2OWsA/heLTuuxzjH0l3PweWblnAUo
         1u4mts1yPfrl9NdEsx6qEa5iohK0qPO3/9k+s0VtMNXX0lhHer5/LtJwmJcs1OtBhyly
         lCta6YwqJnjE/LxvVBHppNI3SnOAQhi5EyKs0SyY7tQPnKFhC+pXb5/YsGwzmEjDrcmM
         qc1w==
X-Google-Smtp-Source: APXvYqwD2/luGyw6rZrr4tRLwqYRE9SKSMYafHefhObPoppO7e8fH0bBzADF2n3XhHPwe3aohkyZGQ4yMO925zAA7W0=
X-Received: by 2002:a02:1384:: with SMTP id 126mr29101248jaz.72.1559834310297;
 Thu, 06 Jun 2019 08:18:30 -0700 (PDT)
MIME-Version: 1.0
References: <0000000000005a4b99058a97f42e@google.com> <b67a0f5d-c508-48a7-7643-b4251c749985@virtuozzo.com>
 <20190606131334.GA24822@fieldses.org> <275f77ad-1962-6a60-e60b-6b8845f12c34@virtuozzo.com>
 <CACT4Y+aJQ6J5WdviD+cOmDoHt2Dj=Q4uZ4vHbCfHe+_TCEY6-Q@mail.gmail.com> <00ec828a-0dcb-ca70-e938-ca26a6a8b675@virtuozzo.com>
In-Reply-To: <00ec828a-0dcb-ca70-e938-ca26a6a8b675@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 6 Jun 2019 17:18:19 +0200
Message-ID: <CACT4Y+aZNxZyhJEjZjxYqh34BKz+VnfZPpZO9rDn0B_9Z_gZcw@mail.gmail.com>
Subject: Re: KASAN: use-after-free Read in unregister_shrinker
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, 
	syzbot <syzbot+83a43746cebef3508b49@syzkaller.appspotmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, bfields@redhat.com, 
	Chris Down <chris@chrisdown.name>, Daniel Jordan <daniel.m.jordan@oracle.com>, guro@fb.com, 
	Johannes Weiner <hannes@cmpxchg.org>, Jeff Layton <jlayton@kernel.org>, laoar.shao@gmail.com, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	linux-nfs@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, 
	Michal Hocko <mhocko@suse.com>, Stephen Rothwell <sfr@canb.auug.org.au>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, yang.shi@linux.alibaba.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 6, 2019 at 4:54 PM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>
> On 06.06.2019 17:40, Dmitry Vyukov wrote:
> > On Thu, Jun 6, 2019 at 3:43 PM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
> >>
> >> On 06.06.2019 16:13, J. Bruce Fields wrote:
> >>> On Thu, Jun 06, 2019 at 10:47:43AM +0300, Kirill Tkhai wrote:
> >>>> This may be connected with that shrinker unregistering is forgotten on error path.
> >>>
> >>> I was wondering about that too.  Seems like it would be hard to hit
> >>> reproduceably though: one of the later allocations would have to fail,
> >>> then later you'd have to create another namespace and this time have a
> >>> later module's init fail.
> >>
> >> Yes, it's had to bump into this in real life.
> >>
> >> AFAIU, syzbot triggers such the problem by using fault-injections
> >> on allocation places should_failslab()->should_fail(). It's possible
> >> to configure a specific slab, so the allocations will fail with
> >> requested probability.
> >
> > No fault injection was involved in triggering of this bug.
> > Fault injection is clearly visible in console log as "INJECTING
> > FAILURE at this stack track" splats and also for bugs with repros it
> > would be noted in the syzkaller repro as "fault_call": N. So somehow
> > this bug was triggered as is.
> >
> > But overall syzkaller can do better then the old probabilistic
> > injection. The probabilistic injection tend to both under-test what we
> > want to test and also crash some system services. syzkaller uses the
> > new "systematic fault injection" that allows to test specifically each
> > failure site separately in each syscall separately.
>
> Oho! Interesting.

If you are interested. You write N into /proc/thread-self/fail-nth
(say, 5) then it will cause failure of the N-th (5-th) failure site in
the next syscall in this task only. And by reading it back after the
syscall you can figure out if the failure was indeed injected or not
(or the syscall had less than 5 failure sites).
Then, for each syscall in a test (or only for one syscall of
interest), we start by writing "1" into /proc/thread-self/fail-nth; if
the failure was injected, write "2" and restart the test; if the
failure was injected, write "3" and restart the test; and so on, until
the failure wasn't injected (tested all failure sites).
This guarantees systematic testing of each error path with minimal
number of runs. This has obvious extensions to "each pair of failure
sites" (to test failures on error paths), but it's not supported atm.

