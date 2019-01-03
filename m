Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B6AC8E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 12:04:11 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id v6so9840587ybm.11
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 09:04:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o192sor7627144ywo.136.2019.01.03.09.04.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 09:04:10 -0800 (PST)
MIME-Version: 1.0
References: <1546459533-36247-1-git-send-email-yang.shi@linux.alibaba.com>
 <1546459533-36247-3-git-send-email-yang.shi@linux.alibaba.com>
 <CALvZod7X6FOMnZT48Q9Joh_nha6NMXntL3XqMDqRYFZ1ULgh=w@mail.gmail.com> <763b97f5-ea9c-e3e6-7fd9-0ab42cf09ca8@linux.alibaba.com>
In-Reply-To: <763b97f5-ea9c-e3e6-7fd9-0ab42cf09ca8@linux.alibaba.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 3 Jan 2019 09:03:58 -0800
Message-ID: <CALvZod5cZ60VkrxuO8o9dnSOhGmNt21o+NoS5Qy1Mh3-k6suyw@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm: memcontrol: do not try to do swap when force empty
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jan 3, 2019 at 8:57 AM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
>
>
> On 1/2/19 1:45 PM, Shakeel Butt wrote:
> > On Wed, Jan 2, 2019 at 12:06 PM Yang Shi <yang.shi@linux.alibaba.com> wrote:
> >> The typical usecase of force empty is to try to reclaim as much as
> >> possible memory before offlining a memcg.  Since there should be no
> >> attached tasks to offlining memcg, the tasks anonymous pages would have
> >> already been freed or uncharged.
> > Anon pages can come from tmpfs files as well.
>
> Yes, but they are charged to swap space as regular anon pages.
>

The point was the lifetime of tmpfs anon pages are not tied to any
task. Even though there aren't any task attached to a memcg, the tmpfs
anon pages will remain charged. Other than that, the old anon pages of
a task which have migrated away might still be charged to the old
memcg (if move_charge_at_immigrate is not set).

> >
> >> Even though anonymous pages get
> >> swapped out, but they still get charged to swap space.  So, it sounds
> >> pointless to do swap for force empty.
> >>
> > I understand that force_empty is typically used before rmdir'ing a
> > memcg but it might be used differently by some users. We use this
> > interface to test memory reclaim behavior (anon and file).
>
> Thanks for sharing your usecase. So, you uses this for test only?
>

Yes.

Shakeel
