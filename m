Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0D0D58E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 11:18:22 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id e68so20766396ybb.4
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 08:18:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a9sor9675709ybq.187.2019.01.03.08.18.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 08:18:20 -0800 (PST)
MIME-Version: 1.0
References: <20190103031431.247970-1-shakeelb@google.com> <313C6566-289D-4973-BB15-857EED858DA3@oracle.com>
In-Reply-To: <313C6566-289D-4973-BB15-857EED858DA3@oracle.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 3 Jan 2019 08:18:09 -0800
Message-ID: <CALvZod5YSKZvWq13ptbfignECxLVH5H_1YbdvoghrmicuDwuSA@mail.gmail.com>
Subject: Re: [PATCH v2] netfilter: account ebt_table_info to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Florian Westphal <fw@strlen.de>, Kirill Tkhai <ktkhai@virtuozzo.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Roopa Prabhu <roopa@cumulusnetworks.com>, Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, bridge@lists.linux-foundation.org

On Thu, Jan 3, 2019 at 2:15 AM William Kucharski
<william.kucharski@oracle.com> wrote:
>
>
>
> > On Jan 2, 2019, at 8:14 PM, Shakeel Butt <shakeelb@google.com> wrote:
> >
> >       countersize = COUNTER_OFFSET(tmp.nentries) * nr_cpu_ids;
> > -     newinfo = vmalloc(sizeof(*newinfo) + countersize);
> > +     newinfo = __vmalloc(sizeof(*newinfo) + countersize, GFP_KERNEL_ACCOUNT,
> > +                         PAGE_KERNEL);
> >       if (!newinfo)
> >               return -ENOMEM;
> >
> >       if (countersize)
> >               memset(newinfo->counters, 0, countersize);
> >
> > -     newinfo->entries = vmalloc(tmp.entries_size);
> > +     newinfo->entries = __vmalloc(tmp.entries_size, GFP_KERNEL_ACCOUNT,
> > +                                  PAGE_KERNEL);
> >       if (!newinfo->entries) {
> >               ret = -ENOMEM;
> >               goto free_newinfo;
> > --
>
> Just out of curiosity, what are the actual sizes of these areas in typical use
> given __vmalloc() will be allocating by the page?
>

We don't really use this in production, so, I don't have a good idea
of the size in the typical case. The size depends on the workload. The
motivation behind this patch was the system OOM triggered by a syzbot
running in a restricted memcg.

Shakeel
