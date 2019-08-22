Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41495C3A59D
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 07:09:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F15E20644
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 07:09:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F15E20644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B351E6B02D3; Thu, 22 Aug 2019 03:09:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE6366B02D4; Thu, 22 Aug 2019 03:09:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FCC26B02D5; Thu, 22 Aug 2019 03:09:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0200.hostedemail.com [216.40.44.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7FB4F6B02D3
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 03:09:22 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 34CB08248AB2
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 07:09:22 +0000 (UTC)
X-FDA: 75849187764.06.dirt26_6ed8bc992050e
X-HE-Tag: dirt26_6ed8bc992050e
X-Filterd-Recvd-Size: 5279
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 07:09:21 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 27E53AE00;
	Thu, 22 Aug 2019 07:09:20 +0000 (UTC)
Date: Thu, 22 Aug 2019 09:09:19 +0200
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
Message-ID: <20190822070919.GB12785@dhcp22.suse.cz>
References: <20190821001445.32114-1-echron@arista.com>
 <alpine.DEB.2.21.1908202024300.141379@chino.kir.corp.google.com>
 <CAM3twVSfO7Z-fgHxy0CDgnJ33X6OgRzbrF+210QSGfPF4mxEuQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAM3twVSfO7Z-fgHxy0CDgnJ33X6OgRzbrF+210QSGfPF4mxEuQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 21-08-19 15:25:13, Edward Chron wrote:
> On Tue, Aug 20, 2019 at 8:25 PM David Rientjes <rientjes@google.com> wrote:
> >
> > On Tue, 20 Aug 2019, Edward Chron wrote:
> >
> > > For an OOM event: print oom_score_adj value for the OOM Killed process to
> > > document what the oom score adjust value was at the time the process was
> > > OOM Killed. The adjustment value can be set by user code and it affects
> > > the resulting oom_score so it is used to influence kill process selection.
> > >
> > > When eligible tasks are not printed (sysctl oom_dump_tasks = 0) printing
> > > this value is the only documentation of the value for the process being
> > > killed. Having this value on the Killed process message documents if a
> > > miscconfiguration occurred or it can confirm that the oom_score_adj
> > > value applies as expected.
> > >
> > > An example which illustates both misconfiguration and validation that
> > > the oom_score_adj was applied as expected is:
> > >
> > > Aug 14 23:00:02 testserver kernel: Out of memory: Killed process 2692
> > >  (systemd-udevd) total-vm:1056800kB, anon-rss:1052760kB, file-rss:4kB,
> > >  shmem-rss:0kB oom_score_adj:1000
> > >
> > > The systemd-udevd is a critical system application that should have an
> > > oom_score_adj of -1000. Here it was misconfigured to have a adjustment
> > > of 1000 making it a highly favored OOM kill target process. The output
> > > documents both the misconfiguration and the fact that the process
> > > was correctly targeted by OOM due to the miconfiguration. Having
> > > the oom_score_adj on the Killed message ensures that it is documented.
> > >
> > > Signed-off-by: Edward Chron <echron@arista.com>
> > > Acked-by: Michal Hocko <mhocko@suse.com>
> >
> > Acked-by: David Rientjes <rientjes@google.com>
> >
> > vm.oom_dump_tasks is pretty useful, however, so it's curious why you
> > haven't left it enabled :/
> >
> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > index eda2e2a0bdc6..c781f73b6cd6 100644
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -884,12 +884,13 @@ static void __oom_kill_process(struct task_struct *victim, const char *message)
> > >        */
> > >       do_send_sig_info(SIGKILL, SEND_SIG_PRIV, victim, PIDTYPE_TGID);
> > >       mark_oom_victim(victim);
> > > -     pr_err("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
> > > +     pr_err("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB oom_score_adj:%ld\n",
> > >               message, task_pid_nr(victim), victim->comm,
> > >               K(victim->mm->total_vm),
> > >               K(get_mm_counter(victim->mm, MM_ANONPAGES)),
> > >               K(get_mm_counter(victim->mm, MM_FILEPAGES)),
> > > -             K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
> > > +             K(get_mm_counter(victim->mm, MM_SHMEMPAGES)),
> > > +             (long)victim->signal->oom_score_adj);
> > >       task_unlock(victim);
> > >
> > >       /*
> >
> > Nit: why not just use %hd and avoid the cast to long?
> 
> Sorry I may have accidently top posted my response to this. Here is
> where my response should go:
> -----------------------------------------------------------------------------------------------------------------------------------
> 
> Good point, I can post this with your correction.
> 
> I will add your Acked-by: David Rientjes <rientjes@google.com>
> 
> I am adding your Acked-by to the revised patch as this is what Michal
> asked me to do (so I assume that is what I should do).
> 
> Should I post as a separate fix again or simply post here?

Andrew usually folds these small fixups automagically. If that doesn't
happen here for some reason then just repost with acks and the fixup.

Thanks!

-- 
Michal Hocko
SUSE Labs

