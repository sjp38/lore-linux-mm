Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4559C3A59D
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 07:15:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 68269214DA
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 07:15:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68269214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00D086B02D5; Thu, 22 Aug 2019 03:15:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F006E6B02D6; Thu, 22 Aug 2019 03:15:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E15576B02D7; Thu, 22 Aug 2019 03:15:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0156.hostedemail.com [216.40.44.156])
	by kanga.kvack.org (Postfix) with ESMTP id C06626B02D5
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 03:15:47 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 2F4B2180AD832
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 07:15:47 +0000 (UTC)
X-FDA: 75849203934.08.wave77_15568554e7609
X-HE-Tag: wave77_15568554e7609
X-Filterd-Recvd-Size: 6076
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 07:15:46 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 54151AE00;
	Thu, 22 Aug 2019 07:15:45 +0000 (UTC)
Date: Thu, 22 Aug 2019 09:15:44 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Edward Chron <echron@arista.com>
Cc: David Rientjes <rientjes@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Ivan Delalande <colona@arista.com>
Subject: Re: [PATCH] mm/oom: Add oom_score_adj value to oom Killed process
 message
Message-ID: <20190822071544.GC12785@dhcp22.suse.cz>
References: <20190821001445.32114-1-echron@arista.com>
 <alpine.DEB.2.21.1908202024300.141379@chino.kir.corp.google.com>
 <20190821064732.GW3111@dhcp22.suse.cz>
 <alpine.DEB.2.21.1908210017320.177871@chino.kir.corp.google.com>
 <CAM3twVQ4Z7dOx+bFn3O6ERstQ4wm3ojhM624NVzc=CAZw1OUUA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAM3twVQ4Z7dOx+bFn3O6ERstQ4wm3ojhM624NVzc=CAZw1OUUA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 21-08-19 15:22:07, Edward Chron wrote:
> On Wed, Aug 21, 2019 at 12:19 AM David Rientjes <rientjes@google.com> wrote:
> >
> > On Wed, 21 Aug 2019, Michal Hocko wrote:
> >
> > > > vm.oom_dump_tasks is pretty useful, however, so it's curious why you
> > > > haven't left it enabled :/
> > >
> > > Because it generates a lot of output potentially. Think of a workload
> > > with too many tasks which is not uncommon.
> >
> > Probably better to always print all the info for the victim so we don't
> > need to duplicate everything between dump_tasks() and dump_oom_summary().
> >
> > Edward, how about this?
> >
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -420,11 +420,17 @@ static int dump_task(struct task_struct *p, void *arg)
> >   * State information includes task's pid, uid, tgid, vm size, rss,
> >   * pgtables_bytes, swapents, oom_score_adj value, and name.
> >   */
> > -static void dump_tasks(struct oom_control *oc)
> > +static void dump_tasks(struct oom_control *oc, struct task_struct *victim)
> >  {
> >         pr_info("Tasks state (memory values in pages):\n");
> >         pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
> >
> > +       /* If vm.oom_dump_tasks is disabled, only show the victim */
> > +       if (!sysctl_oom_dump_tasks) {
> > +               dump_task(victim, oc);
> > +               return;
> > +       }
> > +
> >         if (is_memcg_oom(oc))
> >                 mem_cgroup_scan_tasks(oc->memcg, dump_task, oc);
> >         else {
> > @@ -465,8 +471,8 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
> >                 if (is_dump_unreclaim_slabs())
> >                         dump_unreclaimable_slab();
> >         }
> > -       if (sysctl_oom_dump_tasks)
> > -               dump_tasks(oc);
> > +       if (p || sysctl_oom_dump_tasks)
> > +               dump_tasks(oc, p);
> >         if (p)
> >                 dump_oom_summary(oc, p);
> >  }
> 
> I would be willing to accept this, though as Michal mentions in his
> post, it would be very helpful to have the oom_score_adj on the Killed
> process message.
> 
> One reason for that is that the Killed process message is the one
> message that is printed with error priority (pr_err)
> and so that message can be filtered out and sent to notify support
> that an OOM event occurred.
> Putting any information that can be shared in that message is useful
> from my experience as it the initial point of triage for an OOM event.
> Even if the full log with per user process is available it the
> starting point for triage for an OOM event.
> 
> So from my perspective I would be happy having both, with David's
> proposal providing a bit of extra information as shown here:
> 
> Jul 21 20:07:48 linuxserver kernel: [  pid  ]   uid  tgid total_vm
>  rss pgtables_bytes swapents oom_score_adj name
> Jul 21 20:07:48 linuxserver kernel: [    547]     0   547    31664
> 615             299008              0                       0
> systemd-journal
> 
> The OOM Killed process message will print as:
> 
> Jul 21 20:07:48 linuxserver kernel: Out of memory: Killed process 2826
> (oomprocs) total-vm:1056800kB, anon-rss:1052784kB, file-rss:4kB,
> shmem-rss:0kB oom_score_adj:1000
> 
> But if only one one output change is allowed I'd favor the Killed
> process message since that can be singled due to it's print priority
> and forwarded.
> 
> By the way, right now there is redundancy in that the Killed process
> message is printing vm, rss even if vm.oom_dump_tasks is enabled.
> I don't see why that is a big deal.

There will always be redundancy there because dump_tasks part is there
mostly to check the oom victim decision for potential wrong/unexpected
selection. While "killed..." message is there to inform who has been
killed. Most people really do care about that part only.

> It is very useful to have all the information that is there.
> Wouldn't mind also having pgtables too but we would be able to get
> that from the output of dump_task if that is enabled.

I am not against adding pgrable information there. That memory is going
to be released when the task dies.
 
> If it is acceptable to also add the dump_task for the killed process
> for !sysctl_oom_dump_tasks I can repost the patch including that as
> well.

Well, I would rather focus on adding the missing pieces to the killed
task message instead.

-- 
Michal Hocko
SUSE Labs

