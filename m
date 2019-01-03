Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0A4438E00AE
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 15:53:08 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id f10so22510745ywc.21
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 12:53:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d184sor2954256ybf.13.2019.01.03.12.53.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 12:53:06 -0800 (PST)
MIME-Version: 1.0
References: <20181229015524.222741-1-shakeelb@google.com> <20181229073325.GZ16738@dhcp22.suse.cz>
 <20181229095215.nbcijqacw5b6aho7@breakpoint.cc> <20181229100615.GB16738@dhcp22.suse.cz>
 <CALvZod7v-CC1XipLAerFj1Zp_M=qXZq6MzDL4pubJMTRCsMFNw@mail.gmail.com>
 <20181230074513.GA22445@dhcp22.suse.cz> <20181230080028.GB22445@dhcp22.suse.cz>
 <CALvZod6Ty30uQjJF8KZf=RS5djULaLVggYv_1WFrKJWaYa6EHw@mail.gmail.com> <20181231101158.GC22445@dhcp22.suse.cz>
In-Reply-To: <20181231101158.GC22445@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 3 Jan 2019 12:52:54 -0800
Message-ID: <CALvZod4sQ7ZEwfEefoNUeso2Va255x0jNgwOVZSU-b7+CevQuQ@mail.gmail.com>
Subject: Re: [PATCH] netfilter: account ebt_table_info to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Florian Westphal <fw@strlen.de>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Roopa Prabhu <roopa@cumulusnetworks.com>, Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, bridge@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com

On Mon, Dec 31, 2018 at 2:12 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Sun 30-12-18 19:59:53, Shakeel Butt wrote:
> > On Sun, Dec 30, 2018 at 12:00 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Sun 30-12-18 08:45:13, Michal Hocko wrote:
> > > > On Sat 29-12-18 11:34:29, Shakeel Butt wrote:
> > > > > On Sat, Dec 29, 2018 at 2:06 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > > > >
> > > > > > On Sat 29-12-18 10:52:15, Florian Westphal wrote:
> > > > > > > Michal Hocko <mhocko@kernel.org> wrote:
> > > > > > > > On Fri 28-12-18 17:55:24, Shakeel Butt wrote:
> > > > > > > > > The [ip,ip6,arp]_tables use x_tables_info internally and the underlying
> > > > > > > > > memory is already accounted to kmemcg. Do the same for ebtables. The
> > > > > > > > > syzbot, by using setsockopt(EBT_SO_SET_ENTRIES), was able to OOM the
> > > > > > > > > whole system from a restricted memcg, a potential DoS.
> > > > > > > >
> > > > > > > > What is the lifetime of these objects? Are they bound to any process?
> > > > > > >
> > > > > > > No, they are not.
> > > > > > > They are free'd only when userspace requests it or the netns is
> > > > > > > destroyed.
> > > > > >
> > > > > > Then this is problematic, because the oom killer is not able to
> > > > > > guarantee the hard limit and so the excessive memory consumption cannot
> > > > > > be really contained. As a result the memcg will be basically useless
> > > > > > until somebody tears down the charged objects by other means. The memcg
> > > > > > oom killer will surely kill all the existing tasks in the cgroup and
> > > > > > this could somehow reduce the problem. Maybe this is sufficient for
> > > > > > some usecases but that should be properly analyzed and described in the
> > > > > > changelog.
> > > > > >
> > > > >
> > > > > Can you explain why you think the memcg hard limit will not be
> > > > > enforced? From what I understand, the memcg oom-killer will kill the
> > > > > allocating processes as you have mentioned. We do force charging for
> > > > > very limited conditions but here the memcg oom-killer will take care
> > > > > of
> > > >
> > > > I was talking about the force charge part. Depending on a specific
> > > > allocation and its life time this can gradually get us over hard limit
> > > > without any bound theoretically.
> > >
> > > Forgot to mention. Since b8c8a338f75e ("Revert "vmalloc: back off when
> > > the current task is killed"") there is no way to bail out from the
> > > vmalloc allocation loop so if the request is really large then the memcg
> > > oom will not help. Is that a problem here?
> > >
> >
> > Yes, I think it will be an issue here.
> >
> > > Maybe it is time to revisit fatal_signal_pending check.
> >
> > Yes, we will need something to handle the memcg OOM. I will think more
> > on that front or if you have any ideas, please do propose.
>
> I can see three options here:
>         - do not force charge on memcg oom or introduce a limited charge
>           overflow (reserves basically).
>         - revert the revert and reintroduce the fatal_signal_pending
>           check into vmalloc
>         - be more specific and check tsk_is_oom_victim in vmalloc and
>           fail
>

I think for the long term solution we might need something similar to
memcg oom reserves (1) but for quick fix I think we can do the
combination of (2) and (3).

Shakeel
