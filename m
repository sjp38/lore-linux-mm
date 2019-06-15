Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD6FCC31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 18:50:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E54C2184B
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 18:50:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="DAZVeS1q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E54C2184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1FDB6B0003; Sat, 15 Jun 2019 14:50:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED1146B0005; Sat, 15 Jun 2019 14:50:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC0948E0001; Sat, 15 Jun 2019 14:50:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id BDB2C6B0003
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 14:50:44 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id v15so6560774ybe.13
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 11:50:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=hsw6F/JD0JWJFl9lCNc3fmoZkyiWfJZZGwD/Q8JM96E=;
        b=eawnHJDbQoFUpGYdfK3ZHENSm4OCbi5Tv3FUgrt2RnGfrfIM7aH5/XFjz1RD68uMZD
         UwvJtAIvMRVpaJ7ZQ4VVJu4roJDz18XQUZXJ8TItEZiHzdMH8v3j8qZrYgKzD/TkS8GJ
         yN2QISKwmErXyMHXEQnJSeAo4ZqJ1Hg2M7ED8WI3Za+UfKMxkdL7tsxvTwEu4ustw4wk
         YqQHxBsyQvNwdEaTPQKaIk8m2Ik4mO1hxFX3fw3Gl7coCFTlQSRsyABbT9MusPdsIHmj
         RKheVKia6MXvjYBbRfV+vANU/rviHGIB9/e4kw1fLftV6LCNQNmoiAhGmYttL2kBhvn8
         gQZA==
X-Gm-Message-State: APjAAAUlG1N2I3hMitBsvm4fL1hDIG0SYKn8XcZsdzlK5httChhJ06IF
	pkw004C3bh2iaiStmk5AC4XxVMTqRZV7e6brBtRxw3aCQa1+RlIe+Xrbe+E8WOOfyMBbUHE4YDQ
	TxII20yyBzuSKauccP3c+ndMZ+kZN9OKg/aAbLJmXs0hH4qpUUhDUnudr3j4GIvfW/Q==
X-Received: by 2002:a25:ca8c:: with SMTP id a134mr44201629ybg.68.1560624644407;
        Sat, 15 Jun 2019 11:50:44 -0700 (PDT)
X-Received: by 2002:a25:ca8c:: with SMTP id a134mr44201618ybg.68.1560624643742;
        Sat, 15 Jun 2019 11:50:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560624643; cv=none;
        d=google.com; s=arc-20160816;
        b=ctYUAwyt5zrO3D+D9ZQDf/24rDGUu2D8DsOyHcEcJ418EL//ZJawvqlDOpCH6fAQYu
         lV5xwmA+i+4JTt6HWPCxZAmvWzwP8aYjdeTm6BtOmFHq7UVsncAfNVCjNzzQQ/8UJDUu
         fN8iPgLPCz8IrRa8d/CocT/NbyTdfhbuIj6w+IHfLaMzvRbB6CeRSXlbsyfuzVSQhPu9
         lVVx6rwdrFxQF+y36vbeEhS6SH2Z9I6iI4OBm6riIKHFynLXMjRQcxB1scaM6vqaYAnC
         ptMlhMoApy2dw5GITkNfbvVSn1IMZECDEW6EQKA5R3EJ68fGwDnlWbgi43myjsO+hknD
         VKkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=hsw6F/JD0JWJFl9lCNc3fmoZkyiWfJZZGwD/Q8JM96E=;
        b=pHiA4nktBvsVUKYFliD6VaIapKk6icfKz6hA1IwSLITcQ3v1FNAgfsivmLtNvf0dCj
         K4FTPBk/8+X8E2685T68QGZY2nQRSJbfDRobL+kAPH9hU8wOt31A0tfMIkk+pBY/ogrr
         zeqBk3EGEZWLBirnoimxRMX/SKvGvVXed/rJH5Ydq90XVJeqOuNmxUalnBa+3zJ6fixv
         P/Ms3iXTULJv5JqnpWmEMBFb/I98bRBb0wLWQqeogpvAKr5S445TKMMMaxtdUCau/qzz
         ogVyvlAf6tO+l3lRypgx676f0Lh6LI7Ql6bzzycI0vmZZMd7zGQqfvyeDp9lRzCW2x0I
         J3/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DAZVeS1q;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o5sor3791780ywe.207.2019.06.15.11.50.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 15 Jun 2019 11:50:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DAZVeS1q;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=hsw6F/JD0JWJFl9lCNc3fmoZkyiWfJZZGwD/Q8JM96E=;
        b=DAZVeS1q+rG3Nj2CWnwq7DHcMWuAHnWUfvQj4jBHVPsTl5nhWKrgVhJUUzuaF0ESvk
         9eZvFxBsHqnD/OxOhv8KPKD7qenAUU9QH6cyxZ8OswyYoUAg0VAY/YeSsBUHNUyHuJR5
         cTtHZLZJeL3xDglL9EloZvp6FX+pnNYiVLAmZRhrm1DLObhvU9lqguPMwTtsaC+IJAQd
         bh8Z4kq7Sn3K9OphUToOxMdmVxkx+d1IYhPE/ifulxO3wRLtFK3aPQIEx7qhXPgBFKVx
         gBmTgFFfTemmMa9Zgtk+McMQFRqyf86pW/q2zkP6H4vhzPb472GPRtkEjLLVoAusqZBJ
         3KQw==
X-Google-Smtp-Source: APXvYqxF93Zv7RM/vG5muLgCFR7l8abVBfZg9loqw5+gonEsrR4vX5i/9gEWNuseLjVXSacAq3q/fuV7TpoQYxUOrH0=
X-Received: by 2002:a81:3a0f:: with SMTP id h15mr56987138ywa.34.1560624643001;
 Sat, 15 Jun 2019 11:50:43 -0700 (PDT)
MIME-Version: 1.0
References: <0000000000004143a5058b526503@google.com> <CALvZod72=KuBZkSd0ey5orJFGFpwx462XY=cZvO3NOXC0MogFw@mail.gmail.com>
 <20190615134955.GA28441@dhcp22.suse.cz> <CALvZod4hT39PfGt9Ohj+g77om5=G0coHK=+G1=GKcm-PowkXsw@mail.gmail.com>
 <5bb1fe5d-f0e1-678b-4f64-82c8d5d81f61@i-love.sakura.ne.jp>
In-Reply-To: <5bb1fe5d-f0e1-678b-4f64-82c8d5d81f61@i-love.sakura.ne.jp>
From: Shakeel Butt <shakeelb@google.com>
Date: Sat, 15 Jun 2019 11:50:31 -0700
Message-ID: <CALvZod4etSv9Hv4UD=E6D7U4vyjCqhxQgq61AoTUCd+VubofFg@mail.gmail.com>
Subject: Re: general protection fault in oom_unkillable_task
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, 
	syzbot <syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, 
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, yuzhoujian@didichuxing.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 15, 2019 at 9:49 AM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> On 2019/06/16 1:11, Shakeel Butt wrote:
> > On Sat, Jun 15, 2019 at 6:50 AM Michal Hocko <mhocko@kernel.org> wrote:
> >> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> >> index 5a58778c91d4..43eb479a5dc7 100644
> >> --- a/mm/oom_kill.c
> >> +++ b/mm/oom_kill.c
> >> @@ -161,8 +161,8 @@ static bool oom_unkillable_task(struct task_struct *p,
> >>                 return true;
> >>
> >>         /* When mem_cgroup_out_of_memory() and p is not member of the group */
> >> -       if (memcg && !task_in_mem_cgroup(p, memcg))
> >> -               return true;
> >> +       if (memcg)
> >> +               return false;
> >
> > This will break the dump_tasks() usage of oom_unkillable_task(). We
> > can change dump_tasks() to traverse processes like
> > mem_cgroup_scan_tasks() for memcg OOMs.
>
> While dump_tasks() traverses only each thread group, mem_cgroup_scan_tasks()
> traverses each thread.

I think mem_cgroup_scan_tasks() traversing threads is not intentional
and css_task_iter_start in it should use CSS_TASK_ITER_PROCS as the
oom killer only cares about the processes or more specifically
mm_struct (though two different thread groups can have same mm_struct
but that is fine).

> To avoid printk()ing all threads in a thread group,
> moving that check to
>
>         if (memcg && !task_in_mem_cgroup(p, memcg))
>                 continue;
>
> in dump_tasks() is better?
>
> >
> >>
> >>         /* p may not have freeable memory in nodemask */
> >>         if (!has_intersects_mems_allowed(p, nodemask))
>

