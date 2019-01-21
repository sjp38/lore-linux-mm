Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B29558E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 05:27:11 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id v4so7367132edm.18
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 02:27:11 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i21si3847280edg.324.2019.01.21.02.27.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 02:27:10 -0800 (PST)
Date: Mon, 21 Jan 2019 11:27:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: memory cgroup pagecache and inode problem
Message-ID: <20190121102708.GQ4087@dhcp22.suse.cz>
References: <CAHbLzkoRGk9nE6URO9xJKaAQ+8HDPJQosJuPyR1iYuaUBroDMg@mail.gmail.com>
 <20190120231551.213847-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190120231551.213847-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Yang Shi <shy828301@gmail.com>, Fam Zheng <zhengfeiran@bytedance.com>, cgroups@vger.kernel.org, Linux MM <linux-mm@kvack.org>, tj@kernel.org, Johannes Weiner <hannes@cmpxchg.org>, lizefan@huawei.com, Vladimir Davydov <vdavydov.dev@gmail.com>, duanxiongchun@bytedance.com, =?utf-8?B?5byg5rC46IKD?= <zhangyongsu@bytedance.com>, liuxiaozhou@bytedance.com

On Sun 20-01-19 15:15:51, Shakeel Butt wrote:
> On Wed, Jan 16, 2019 at 9:07 PM Yang Shi <shy828301@gmail.com> wrote:
> ...
> > > > You mean it solves the problem by retrying more times?  Actually, I'm
> > > > not sure if you have swap setup in your test, but force_empty does do
> > > > swap if swap is on. This may cause it can't reclaim all the page cache
> > > > in 5 retries.  I have a patch within that series to skip swap.
> > >
> > > Basically yes, retrying solves the problem. But compared to immediate retries, a scheduled retry in a few seconds is much more effective.
> >
> > This may suggest doing force_empty in a worker is more effective in
> > fact. Not sure if this is good enough to convince Johannes or not.
> >
> 
> >From what I understand what we actually want is to force_empty an
> offlined memcg. How about we change the semantics of force_empty on
> root_mem_cgroup? Currently force_empty on root_mem_cgroup returns
> -EINVAL. Rather than that, let's do force_empty on all offlined memcgs
> if user does force_empty on root_mem_cgroup. Something like following.

No, I do not thing we want to make root memcg somehow special here. I do
recognize two things here
1) people seem to want to have a control over when a specific cgroup
gets reclaimed (basically force_empty)
2) people would like the above to happen when a memcg is offlined

The first part is not present in v2 and we should discuss whether we
want to expose it because it hasn't been added due to lack of usecases.
The later is discussed [1] already so let's continue there.

[1] http://lkml.kernel.org/r/1547061285-100329-1-git-send-email-yang.shi@linux.alibaba.com
-- 
Michal Hocko
SUSE Labs
