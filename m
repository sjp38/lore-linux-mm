Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8BF3B8E005B
	for <linux-mm@kvack.org>; Sat, 29 Dec 2018 14:39:18 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id r191so16985584ybr.12
        for <linux-mm@kvack.org>; Sat, 29 Dec 2018 11:39:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f2sor6088168ywa.0.2018.12.29.11.39.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 29 Dec 2018 11:39:17 -0800 (PST)
MIME-Version: 1.0
References: <20181229015524.222741-1-shakeelb@google.com> <20181229073325.GZ16738@dhcp22.suse.cz>
 <7c0fa75f-df2f-668e-ebc2-3d3e9831030f@virtuozzo.com>
In-Reply-To: <7c0fa75f-df2f-668e-ebc2-3d3e9831030f@virtuozzo.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Sat, 29 Dec 2018 11:39:06 -0800
Message-ID: <CALvZod5FxsHk9UFvDewoVftWU0AB=1JJCEgd6B-5np1CrXwRvA@mail.gmail.com>
Subject: Re: Re: [PATCH] netfilter: account ebt_table_info to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Michal Hocko <mhocko@kernel.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Roopa Prabhu <roopa@cumulusnetworks.com>, Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, bridge@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com

Hi Kirill,

On Sat, Dec 29, 2018 at 1:52 AM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>
> Hi, Michal!
>
> On 29.12.2018 10:33, Michal Hocko wrote:
> > On Fri 28-12-18 17:55:24, Shakeel Butt wrote:
> >> The [ip,ip6,arp]_tables use x_tables_info internally and the underlying
> >> memory is already accounted to kmemcg. Do the same for ebtables. The
> >> syzbot, by using setsockopt(EBT_SO_SET_ENTRIES), was able to OOM the
> >> whole system from a restricted memcg, a potential DoS.
> >
> > What is the lifetime of these objects? Are they bound to any process?
>
> These are list of ebtables rules, which may be displayed with $ebtables-save command.
> In case of we do not account them, a low priority container may eat all the memory
> and OOM killer in berserk mode will kill all the processes on machine. They are not bound
> to any process, but they are bound to network namespace.
>
> OOM killer does not analyze such the memory cgroup-related allocations, since it
> is task-aware only. Maybe we should do it namespace-aware too...

This is a good idea. I am already brainstorming on a somewhat similar
idea to make shmem/tmpfs files oom-killable. I will share once I have
something more concrete and will think on namespace angle too.

thanks,
Shakeel
