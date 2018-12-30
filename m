Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 355A88E005B
	for <linux-mm@kvack.org>; Sun, 30 Dec 2018 03:00:32 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id i55so28380861ede.14
        for <linux-mm@kvack.org>; Sun, 30 Dec 2018 00:00:32 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a26-v6si2103172ejg.119.2018.12.30.00.00.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Dec 2018 00:00:30 -0800 (PST)
Date: Sun, 30 Dec 2018 09:00:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] netfilter: account ebt_table_info to kmemcg
Message-ID: <20181230080028.GB22445@dhcp22.suse.cz>
References: <20181229015524.222741-1-shakeelb@google.com>
 <20181229073325.GZ16738@dhcp22.suse.cz>
 <20181229095215.nbcijqacw5b6aho7@breakpoint.cc>
 <20181229100615.GB16738@dhcp22.suse.cz>
 <CALvZod7v-CC1XipLAerFj1Zp_M=qXZq6MzDL4pubJMTRCsMFNw@mail.gmail.com>
 <20181230074513.GA22445@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181230074513.GA22445@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Florian Westphal <fw@strlen.de>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Roopa Prabhu <roopa@cumulusnetworks.com>, Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, bridge@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com

On Sun 30-12-18 08:45:13, Michal Hocko wrote:
> On Sat 29-12-18 11:34:29, Shakeel Butt wrote:
> > On Sat, Dec 29, 2018 at 2:06 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Sat 29-12-18 10:52:15, Florian Westphal wrote:
> > > > Michal Hocko <mhocko@kernel.org> wrote:
> > > > > On Fri 28-12-18 17:55:24, Shakeel Butt wrote:
> > > > > > The [ip,ip6,arp]_tables use x_tables_info internally and the underlying
> > > > > > memory is already accounted to kmemcg. Do the same for ebtables. The
> > > > > > syzbot, by using setsockopt(EBT_SO_SET_ENTRIES), was able to OOM the
> > > > > > whole system from a restricted memcg, a potential DoS.
> > > > >
> > > > > What is the lifetime of these objects? Are they bound to any process?
> > > >
> > > > No, they are not.
> > > > They are free'd only when userspace requests it or the netns is
> > > > destroyed.
> > >
> > > Then this is problematic, because the oom killer is not able to
> > > guarantee the hard limit and so the excessive memory consumption cannot
> > > be really contained. As a result the memcg will be basically useless
> > > until somebody tears down the charged objects by other means. The memcg
> > > oom killer will surely kill all the existing tasks in the cgroup and
> > > this could somehow reduce the problem. Maybe this is sufficient for
> > > some usecases but that should be properly analyzed and described in the
> > > changelog.
> > >
> > 
> > Can you explain why you think the memcg hard limit will not be
> > enforced? From what I understand, the memcg oom-killer will kill the
> > allocating processes as you have mentioned. We do force charging for
> > very limited conditions but here the memcg oom-killer will take care
> > of
> 
> I was talking about the force charge part. Depending on a specific
> allocation and its life time this can gradually get us over hard limit
> without any bound theoretically.

Forgot to mention. Since b8c8a338f75e ("Revert "vmalloc: back off when
the current task is killed"") there is no way to bail out from the
vmalloc allocation loop so if the request is really large then the memcg
oom will not help. Is that a problem here?

Maybe it is time to revisit fatal_signal_pending check.
-- 
Michal Hocko
SUSE Labs
