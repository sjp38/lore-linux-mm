Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 873338E005B
	for <linux-mm@kvack.org>; Sat, 29 Dec 2018 14:34:42 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id d72so17607132ywe.9
        for <linux-mm@kvack.org>; Sat, 29 Dec 2018 11:34:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 66-v6sor20426052ybg.113.2018.12.29.11.34.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 29 Dec 2018 11:34:41 -0800 (PST)
MIME-Version: 1.0
References: <20181229015524.222741-1-shakeelb@google.com> <20181229073325.GZ16738@dhcp22.suse.cz>
 <20181229095215.nbcijqacw5b6aho7@breakpoint.cc> <20181229100615.GB16738@dhcp22.suse.cz>
In-Reply-To: <20181229100615.GB16738@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Sat, 29 Dec 2018 11:34:29 -0800
Message-ID: <CALvZod7v-CC1XipLAerFj1Zp_M=qXZq6MzDL4pubJMTRCsMFNw@mail.gmail.com>
Subject: Re: [PATCH] netfilter: account ebt_table_info to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Florian Westphal <fw@strlen.de>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Roopa Prabhu <roopa@cumulusnetworks.com>, Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, bridge@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com

On Sat, Dec 29, 2018 at 2:06 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Sat 29-12-18 10:52:15, Florian Westphal wrote:
> > Michal Hocko <mhocko@kernel.org> wrote:
> > > On Fri 28-12-18 17:55:24, Shakeel Butt wrote:
> > > > The [ip,ip6,arp]_tables use x_tables_info internally and the underlying
> > > > memory is already accounted to kmemcg. Do the same for ebtables. The
> > > > syzbot, by using setsockopt(EBT_SO_SET_ENTRIES), was able to OOM the
> > > > whole system from a restricted memcg, a potential DoS.
> > >
> > > What is the lifetime of these objects? Are they bound to any process?
> >
> > No, they are not.
> > They are free'd only when userspace requests it or the netns is
> > destroyed.
>
> Then this is problematic, because the oom killer is not able to
> guarantee the hard limit and so the excessive memory consumption cannot
> be really contained. As a result the memcg will be basically useless
> until somebody tears down the charged objects by other means. The memcg
> oom killer will surely kill all the existing tasks in the cgroup and
> this could somehow reduce the problem. Maybe this is sufficient for
> some usecases but that should be properly analyzed and described in the
> changelog.
>

Can you explain why you think the memcg hard limit will not be
enforced? From what I understand, the memcg oom-killer will kill the
allocating processes as you have mentioned. We do force charging for
very limited conditions but here the memcg oom-killer will take care
of

Anyways, the kernel is already charging the memory for
[ip,ip6,arp]_tables and this patch adds the charging for ebtables.
Without this patch, as Kirill has described and shown by syzbot, a low
priority memcg can force system OOM.

Shakeel
