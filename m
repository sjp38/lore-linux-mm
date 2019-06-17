Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03A52C31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 13:23:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9F2C206B7
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 13:23:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="HD59OuSs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9F2C206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44B028E0003; Mon, 17 Jun 2019 09:23:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FAE58E0001; Mon, 17 Jun 2019 09:23:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E9588E0003; Mon, 17 Jun 2019 09:23:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0B8DF8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 09:23:20 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id t203so12159460ywe.7
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 06:23:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=02kfRFeWEhd6YUuolIO/Uq6FrIlQTeHIsl8qg/L1ER0=;
        b=Uk5PLOHtTYpX7uQwhjYNM2AlhL2g/qLQV/qQ4+hzXAOgkOsuttSRFRyc66O8Pbx8lU
         PSpQhhCqtEa+RsExarJq74ime8n5t4KTNrmojIqaOFUMUffHTQBICvpV880DTctJ0SuD
         QwgScGdsKYR83PwEInEcBTPWvfRYX9YdcjMRp7BPEC7lJxEmPIZiaLgnXWXFGMfyaS7J
         YFrelTxp8uGLOJio9aNGonrHkoryyac7El2PLzk8JHIryvg/VopHE+YD/KC0rN8qdbzC
         ys1r/rBOk7sPHAD4xSEIsa8ThojOMYC2cOr6U5n9QcNqIsgkeoTPRGGnPcmxTU7152vQ
         UBVQ==
X-Gm-Message-State: APjAAAVOOtnEW8g6+5JshRWj+923IafhlgI2NbuOKpKVJm/HCtlErQeu
	POkTl+sfTYgWu/aeZZ7yZ+c6u8NYcNlZtMqGNLezHftcnkcBJIXjk2Y4MZKNUD7nEQOYRPXq+cc
	YRF8SwwUhPBwEZOq1M+xpmp0VXi2ihNcKdcJ/VQMiRfTTG8BfzGYv4G+3mw4cue/QpA==
X-Received: by 2002:a25:d055:: with SMTP id h82mr55737649ybg.418.1560777799719;
        Mon, 17 Jun 2019 06:23:19 -0700 (PDT)
X-Received: by 2002:a25:d055:: with SMTP id h82mr55737617ybg.418.1560777798983;
        Mon, 17 Jun 2019 06:23:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560777798; cv=none;
        d=google.com; s=arc-20160816;
        b=BXe2SPrDZSx8aKNwLInaIrzJGd3Jmlg/HUd4ZYcFjgxEXfJZWUGd7EsHAxF0yCAnp6
         pZouVbCYrD5Fq5xiMjHpAMILtEVqST0xP3CJR2E14U7zumLkp7QU7M5xJpAsR1Wo/9v3
         6Poqaaa9dbS+/22eW4ZG+64xunMIgi3u5bv2Yb7cuvxn5lPmkGjBLmBArwmcthpqh++/
         9BusX//dWjAykvb/30y10qbmM3fwWwLxCAaeGfl1feHJ0s/ClPybQfK3iUMR0r1N/U3+
         6e6e4Ys0ppCnuSWFYA3EiT4ey0MW/L6OTTs4yVW1ohI023Ougo79gZYZSx0F8hdn94VK
         /OEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=02kfRFeWEhd6YUuolIO/Uq6FrIlQTeHIsl8qg/L1ER0=;
        b=BcoBd5/Dv3PqnPrsQ+brcbkWvJSU6SucJ5DDGJvMcS11xJazgBIrN4olgyBnVTU3jt
         bkbrBiHXnP1zLJf75i8vofVeBzcHeLo8+81RINg3haRCTjww8DqoBaHAgnPVQUjRa0Ri
         ugIZYEZ1+Tm486j3e6fT3+pUZ3CLWCpRT6RnkgSlFsMf2poLkfq10Id2NY/70aV0bg9O
         5wRJs1KZbuBHNIres/5RjxmvPaibJmksxwxNAJD244BSYfg63YbcmHX47TuLl2xy/6XG
         6ow9LtYlYL8zdwUkbS4ZqF/reJz1Fg/dQeY0GLiBVrcq7ZysPZlRg51+FUX2yYgemGaW
         yGDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HD59OuSs;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v19sor5940038ywg.82.2019.06.17.06.23.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 06:23:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HD59OuSs;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=02kfRFeWEhd6YUuolIO/Uq6FrIlQTeHIsl8qg/L1ER0=;
        b=HD59OuSscHam75mFRRnjZG318f3rXqPeH28hTUkTCnl8Zbf0lQQGqF7txgk45Jfgce
         XBQp0tW2lslW1/q1mO7UMQy2vwZiPy7vpkDBxAcpia968Wps6xitEr5J1cmto1PTUsd9
         DLmsoveYNkQbu8qdvYofsxqK7UkdpJ3vvLNkhkU35lWS4B63vxPlG34dmxhhZtIheioc
         nQJt+aSBDggXAmDQHAaZnVket7jrdU1dZxVPQy6VQOCbL7Yg3VwswJrPtGn1ik7Zjeha
         djsZ2u7tP7ezZMTuJjlkVUZ3CMhlvPcy2fb6JDf0mjXLQfvscWo5hJHujSBncsJfVOFZ
         FmMg==
X-Google-Smtp-Source: APXvYqw07r8abFG4Ma8KQ5Kz56AyMcZLucz+Hht8aCZ1QixFnZRmEgnh4WLKFu8cyZ///tczttEEVjWPXvUKdgmUqPE=
X-Received: by 2002:a81:90e:: with SMTP id 14mr18617403ywj.4.1560777798456;
 Mon, 17 Jun 2019 06:23:18 -0700 (PDT)
MIME-Version: 1.0
References: <0000000000004143a5058b526503@google.com> <CALvZod72=KuBZkSd0ey5orJFGFpwx462XY=cZvO3NOXC0MogFw@mail.gmail.com>
 <20190615134955.GA28441@dhcp22.suse.cz> <CALvZod4hT39PfGt9Ohj+g77om5=G0coHK=+G1=GKcm-PowkXsw@mail.gmail.com>
 <5bb1fe5d-f0e1-678b-4f64-82c8d5d81f61@i-love.sakura.ne.jp>
 <CALvZod4etSv9Hv4UD=E6D7U4vyjCqhxQgq61AoTUCd+VubofFg@mail.gmail.com>
 <791594c6-45a3-d78a-70b5-901aa580ed9f@i-love.sakura.ne.jp>
 <840fa9f1-07e2-e206-2fc0-725392f96baf@i-love.sakura.ne.jp> <c763afc8-f0ae-756a-56a7-395f625b95fc@i-love.sakura.ne.jp>
In-Reply-To: <c763afc8-f0ae-756a-56a7-395f625b95fc@i-love.sakura.ne.jp>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 17 Jun 2019 06:23:07 -0700
Message-ID: <CALvZod5VPLVEwRzy83+wT=aA8vsrUkvoJJZvmQxyv4YbXvrQWw@mail.gmail.com>
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

On Sun, Jun 16, 2019 at 8:14 AM Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
>
> On 2019/06/16 16:37, Tetsuo Handa wrote:
> > On 2019/06/16 6:33, Tetsuo Handa wrote:
> >> On 2019/06/16 3:50, Shakeel Butt wrote:
> >>>> While dump_tasks() traverses only each thread group, mem_cgroup_scan_tasks()
> >>>> traverses each thread.
> >>>
> >>> I think mem_cgroup_scan_tasks() traversing threads is not intentional
> >>> and css_task_iter_start in it should use CSS_TASK_ITER_PROCS as the
> >>> oom killer only cares about the processes or more specifically
> >>> mm_struct (though two different thread groups can have same mm_struct
> >>> but that is fine).
> >>
> >> We can't use CSS_TASK_ITER_PROCS from mem_cgroup_scan_tasks(). I've tried
> >> CSS_TASK_ITER_PROCS in an attempt to evaluate only one thread from each
> >> thread group, but I found that CSS_TASK_ITER_PROCS causes skipping whole
> >> threads in a thread group (and trivially allowing "Out of memory and no
> >> killable processes...\n" flood) if thread group leader has already exited.
> >
> > Seems that CSS_TASK_ITER_PROCS from mem_cgroup_scan_tasks() is now working.
>
>
> I found a reproducer and the commit.
>
> ----------------------------------------
> #define _GNU_SOURCE
> #include <stdio.h>
> #include <stdlib.h>
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <fcntl.h>
> #include <unistd.h>
> #include <sched.h>
> #include <sys/mman.h>
> #include <asm/unistd.h>
>
> static const unsigned long size = 1048576 * 200;
> static int thread(void *unused)
> {
>         int fd = open("/dev/zero", O_RDONLY);
>         char *buf = mmap(NULL, size, PROT_WRITE | PROT_READ,
>                          MAP_ANONYMOUS | MAP_SHARED, EOF, 0);
>         sleep(1);
>         read(fd, buf, size);
>         return syscall(__NR_exit, 0);
> }
> int main(int argc, char *argv[])
> {
>         FILE *fp;
>         mkdir("/sys/fs/cgroup/memory/test1", 0755);
>         fp = fopen("/sys/fs/cgroup/memory/test1/memory.limit_in_bytes", "w");
>         fprintf(fp, "%lu\n", size);
>         fclose(fp);
>         fp = fopen("/sys/fs/cgroup/memory/test1/tasks", "w");
>         fprintf(fp, "%u\n", getpid());
>         fclose(fp);
>         clone(thread, malloc(8192) + 4096, CLONE_SIGHAND | CLONE_THREAD | CLONE_VM, NULL);
>         return syscall(__NR_exit, 0);
> }
> ----------------------------------------
>
> Here is a patch to use CSS_TASK_ITER_PROCS.
>
> From 415e52cf55bc4ad931e4f005421b827f0b02693d Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Mon, 17 Jun 2019 00:09:38 +0900
> Subject: [PATCH] mm: memcontrol: Use CSS_TASK_ITER_PROCS at mem_cgroup_scan_tasks().
>
> Since commit c03cd7738a83b137 ("cgroup: Include dying leaders with live
> threads in PROCS iterations") corrected how CSS_TASK_ITER_PROCS works,
> mem_cgroup_scan_tasks() can use CSS_TASK_ITER_PROCS in order to check
> only one thread from each thread group.
>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

Why not add the reproducer in the commit message?

> ---
>  mm/memcontrol.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ba9138a..b09ff45 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1163,7 +1163,7 @@ int mem_cgroup_scan_tasks(struct mem_cgroup *memcg,
>                 struct css_task_iter it;
>                 struct task_struct *task;
>
> -               css_task_iter_start(&iter->css, 0, &it);
> +               css_task_iter_start(&iter->css, CSS_TASK_ITER_PROCS, &it);
>                 while (!ret && (task = css_task_iter_next(&it)))
>                         ret = fn(task, arg);
>                 css_task_iter_end(&it);
> --
> 1.8.3.1

