Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF86BC3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 22:22:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72E56233A0
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 22:22:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arista.com header.i=@arista.com header.b="CYsF6BJG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72E56233A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0683A6B02B1; Wed, 21 Aug 2019 18:22:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01A066B02B2; Wed, 21 Aug 2019 18:22:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E49DC6B02B3; Wed, 21 Aug 2019 18:22:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0212.hostedemail.com [216.40.44.212])
	by kanga.kvack.org (Postfix) with ESMTP id BEF7E6B02B1
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:22:20 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 5B74A181AC9B4
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 22:22:20 +0000 (UTC)
X-FDA: 75847859640.22.range94_145b6fb3fe917
X-HE-Tag: range94_145b6fb3fe917
X-Filterd-Recvd-Size: 6920
Received: from mail-io1-f65.google.com (mail-io1-f65.google.com [209.85.166.65])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 22:22:19 +0000 (UTC)
Received: by mail-io1-f65.google.com with SMTP id t3so7809935ioj.12
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:22:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arista.com; s=googlenew;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=1n1EqLNQaVBykjrc6gwB/kJFS9Ls04rvVpImZ/x3es0=;
        b=CYsF6BJGJdSPA7AbVCKU7VpXyzx9FVJZzR3CqqYlqbawduDvrFSyZo6ah0QQ6MHy9A
         qAqzbTq6NujyUK4lznGOC3JS0N/DJegldMLMpihJ7TPdki7dqCRPgxGMCcuwqBuFIbgv
         1bcaZPiwfAjo7aaoIbJ8Sn/udLpisl62i8aXL//XnSpvoIg3VuQIIaeymrcwdBeQxr7D
         7OskJ2JihhelcLKVLvUbePycluFv3HcEY2T6yWj9JSJveiM9fDr8/7woLK+QlNdeqf2J
         QEjpkA2taXlg+ai+QRi51Q4S0I1VImxTfSdYxmBKxA6UXk7PKKIMCjS9e4HuhGQzwFSq
         a0Jw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=1n1EqLNQaVBykjrc6gwB/kJFS9Ls04rvVpImZ/x3es0=;
        b=BKGJhqPPCKuehAUAtOZdw2Q0Y1HYOCwJshvNxgdgJ9yJ9pFIJ65+DUyxCiLvgjqAV/
         UH1wYgtD4lbETRtkKgJhrgktVWszo2jUz3BNsjIqptJlIljP0AwAEe5riF+iG6JVUJbv
         vT3QydvfuEmyBMfPGKrOkt2HR17rSg8G2R9xVt6d0++QYqwMkudVet5zEQfY/ota5Ywt
         aYyJ1eUWDQ/vOaEAizrttW+gFWR+xOEvS/TFnWOOuI25VfTqKtpzxf9yCNsLNmhSy2/b
         vDQ8xyfc1y/3/qfLJRCjA9eJ/pwOYRxCd6UQ8Rli84vALim/hrFEj8ISywzH4QSZfdU2
         LXNA==
X-Gm-Message-State: APjAAAWyKEi7zmp8tRNWoUNuG/tjZz7xFr+tZgL8NXXa18IxMsOhF4OZ
	ohz60JgrvaEtZqjKJw0eTAd34MV988dXd4zevVgoZ/O8DWU=
X-Google-Smtp-Source: APXvYqzvag+OaQujSvk5p6H9EQ7CwvYSnMX/0Cx6iGEf7IytGcg/9JK5V/Tm+mb8GzPjJP8pE0g5ezJKByyL9zPUvY8=
X-Received: by 2002:a5d:8484:: with SMTP id t4mr7355672iom.5.1566426138770;
 Wed, 21 Aug 2019 15:22:18 -0700 (PDT)
MIME-Version: 1.0
References: <20190821001445.32114-1-echron@arista.com> <alpine.DEB.2.21.1908202024300.141379@chino.kir.corp.google.com>
 <20190821064732.GW3111@dhcp22.suse.cz> <alpine.DEB.2.21.1908210017320.177871@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.21.1908210017320.177871@chino.kir.corp.google.com>
From: Edward Chron <echron@arista.com>
Date: Wed, 21 Aug 2019 15:22:07 -0700
Message-ID: <CAM3twVQ4Z7dOx+bFn3O6ERstQ4wm3ojhM624NVzc=CAZw1OUUA@mail.gmail.com>
Subject: Re: [PATCH] mm/oom: Add oom_score_adj value to oom Killed process message
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Shakeel Butt <shakeelb@google.com>, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Ivan Delalande <colona@arista.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 21, 2019 at 12:19 AM David Rientjes <rientjes@google.com> wrote:
>
> On Wed, 21 Aug 2019, Michal Hocko wrote:
>
> > > vm.oom_dump_tasks is pretty useful, however, so it's curious why you
> > > haven't left it enabled :/
> >
> > Because it generates a lot of output potentially. Think of a workload
> > with too many tasks which is not uncommon.
>
> Probably better to always print all the info for the victim so we don't
> need to duplicate everything between dump_tasks() and dump_oom_summary().
>
> Edward, how about this?
>
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -420,11 +420,17 @@ static int dump_task(struct task_struct *p, void *arg)
>   * State information includes task's pid, uid, tgid, vm size, rss,
>   * pgtables_bytes, swapents, oom_score_adj value, and name.
>   */
> -static void dump_tasks(struct oom_control *oc)
> +static void dump_tasks(struct oom_control *oc, struct task_struct *victim)
>  {
>         pr_info("Tasks state (memory values in pages):\n");
>         pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
>
> +       /* If vm.oom_dump_tasks is disabled, only show the victim */
> +       if (!sysctl_oom_dump_tasks) {
> +               dump_task(victim, oc);
> +               return;
> +       }
> +
>         if (is_memcg_oom(oc))
>                 mem_cgroup_scan_tasks(oc->memcg, dump_task, oc);
>         else {
> @@ -465,8 +471,8 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
>                 if (is_dump_unreclaim_slabs())
>                         dump_unreclaimable_slab();
>         }
> -       if (sysctl_oom_dump_tasks)
> -               dump_tasks(oc);
> +       if (p || sysctl_oom_dump_tasks)
> +               dump_tasks(oc, p);
>         if (p)
>                 dump_oom_summary(oc, p);
>  }

I would be willing to accept this, though as Michal mentions in his
post, it would be very helpful to have the oom_score_adj on the Killed
process message.

One reason for that is that the Killed process message is the one
message that is printed with error priority (pr_err)
and so that message can be filtered out and sent to notify support
that an OOM event occurred.
Putting any information that can be shared in that message is useful
from my experience as it the initial point of triage for an OOM event.
Even if the full log with per user process is available it the
starting point for triage for an OOM event.

So from my perspective I would be happy having both, with David's
proposal providing a bit of extra information as shown here:

Jul 21 20:07:48 linuxserver kernel: [  pid  ]   uid  tgid total_vm
 rss pgtables_bytes swapents oom_score_adj name
Jul 21 20:07:48 linuxserver kernel: [    547]     0   547    31664
615             299008              0                       0
systemd-journal

The OOM Killed process message will print as:

Jul 21 20:07:48 linuxserver kernel: Out of memory: Killed process 2826
(oomprocs) total-vm:1056800kB, anon-rss:1052784kB, file-rss:4kB,
shmem-rss:0kB oom_score_adj:1000

But if only one one output change is allowed I'd favor the Killed
process message since that can be singled due to it's print priority
and forwarded.

By the way, right now there is redundancy in that the Killed process
message is printing vm, rss even if vm.oom_dump_tasks is enabled.
I don't see why that is a big deal.
It is very useful to have all the information that is there.
Wouldn't mind also having pgtables too but we would be able to get
that from the output of dump_task if that is enabled.

If it is acceptable to also add the dump_task for the killed process
for !sysctl_oom_dump_tasks I can repost the patch including that as
well.

Thank-you,

Edward Chron
Arista Networks

