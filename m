Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id CE5D18E005B
	for <linux-mm@kvack.org>; Sun, 30 Dec 2018 02:45:21 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c53so28443719edc.9
        for <linux-mm@kvack.org>; Sat, 29 Dec 2018 23:45:21 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f14-v6si7593346ejx.312.2018.12.29.23.45.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Dec 2018 23:45:20 -0800 (PST)
Date: Sun, 30 Dec 2018 08:45:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] netfilter: account ebt_table_info to kmemcg
Message-ID: <20181230074513.GA22445@dhcp22.suse.cz>
References: <20181229015524.222741-1-shakeelb@google.com>
 <20181229073325.GZ16738@dhcp22.suse.cz>
 <20181229095215.nbcijqacw5b6aho7@breakpoint.cc>
 <20181229100615.GB16738@dhcp22.suse.cz>
 <CALvZod7v-CC1XipLAerFj1Zp_M=qXZq6MzDL4pubJMTRCsMFNw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod7v-CC1XipLAerFj1Zp_M=qXZq6MzDL4pubJMTRCsMFNw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Florian Westphal <fw@strlen.de>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Roopa Prabhu <roopa@cumulusnetworks.com>, Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, bridge@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com

On Sat 29-12-18 11:34:29, Shakeel Butt wrote:
> On Sat, Dec 29, 2018 at 2:06 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Sat 29-12-18 10:52:15, Florian Westphal wrote:
> > > Michal Hocko <mhocko@kernel.org> wrote:
> > > > On Fri 28-12-18 17:55:24, Shakeel Butt wrote:
> > > > > The [ip,ip6,arp]_tables use x_tables_info internally and the underlying
> > > > > memory is already accounted to kmemcg. Do the same for ebtables. The
> > > > > syzbot, by using setsockopt(EBT_SO_SET_ENTRIES), was able to OOM the
> > > > > whole system from a restricted memcg, a potential DoS.
> > > >
> > > > What is the lifetime of these objects? Are they bound to any process?
> > >
> > > No, they are not.
> > > They are free'd only when userspace requests it or the netns is
> > > destroyed.
> >
> > Then this is problematic, because the oom killer is not able to
> > guarantee the hard limit and so the excessive memory consumption cannot
> > be really contained. As a result the memcg will be basically useless
> > until somebody tears down the charged objects by other means. The memcg
> > oom killer will surely kill all the existing tasks in the cgroup and
> > this could somehow reduce the problem. Maybe this is sufficient for
> > some usecases but that should be properly analyzed and described in the
> > changelog.
> >
> 
> Can you explain why you think the memcg hard limit will not be
> enforced? From what I understand, the memcg oom-killer will kill the
> allocating processes as you have mentioned. We do force charging for
> very limited conditions but here the memcg oom-killer will take care
> of

I was talking about the force charge part. Depending on a specific
allocation and its life time this can gradually get us over hard limit
without any bound theoretically.

> Anyways, the kernel is already charging the memory for
> [ip,ip6,arp]_tables and this patch adds the charging for ebtables.
> Without this patch, as Kirill has described and shown by syzbot, a low
> priority memcg can force system OOM.

I am not opposing the patch per-se. I would just like the changelog to
be more descriptive about the life time and consequences.
-- 
Michal Hocko
SUSE Labs
