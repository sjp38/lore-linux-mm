Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA06D6B0069
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 12:23:32 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id e70so1490270wmc.6
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 09:23:32 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x127sor722241wmb.90.2017.12.19.09.23.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 09:23:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171219152444.GP3919388@devbig577.frc2.facebook.com>
References: <20171219000131.149170-1-shakeelb@google.com> <20171219124908.GS2787@dhcp22.suse.cz>
 <CALvZod5jU9vPoJaf44TVT0_HQpEESiELJU5MD_DDRbcOkPNQbg@mail.gmail.com> <20171219152444.GP3919388@devbig577.frc2.facebook.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 19 Dec 2017 09:23:29 -0800
Message-ID: <CALvZod5sWWBX69QovOeLBSx9vij7=5cmoSocdTUvh2Uq8=noyQ@mail.gmail.com>
Subject: Re: [RFC PATCH] mm: memcontrol: memory+swap accounting for cgroup-v2
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Li Zefan <lizefan@huawei.com>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org

On Tue, Dec 19, 2017 at 7:24 AM, Tejun Heo <tj@kernel.org> wrote:
> Hello,
>
> On Tue, Dec 19, 2017 at 07:12:19AM -0800, Shakeel Butt wrote:
>> Yes, there are pros & cons, therefore we should give users the option
>> to select the API that is better suited for their use-cases and
>
> Heh, that's not how API decisions should be made.  The long term
> outcome would be really really bad.
>
>> environment. Both approaches are not interchangeable. We use memsw
>> internally for use-cases I mentioned in commit message. This is one of
>> the main blockers for us to even consider cgroup-v2 for memory
>> controller.
>
> Let's concentrate on the use case.  I couldn't quite understand what
> was missing from your description.  You said that it'd make things
> easier for the centralized monitoring system which isn't really a
> description of a use case.  Can you please go into more details
> focusing on the eventual goals (rather than what's currently
> implemented)?
>

The goal is to provide an interface that provides:

1. Consistent memory usage history
2. Consistent memory limit enforcement behavior

By consistent I mean, the environment should not affect the usage
history. For example, the presence or absence of swap or memory
pressure on the system should not affect the memory usage history i.e.
making environment an invariant. Similarly, the environment should not
affect the memcg OOM or memcg memory reclaim behavior.

To provide consistent memory usage history using the current
cgroup-v2's 'swap' interface, an additional metric expressing the
intersection of memory and swap has to be exposed. Basically memsw is
the union of memory and swap. So, if that additional metric can be
used to find the union. However for consistent memory limit
enforcement, I don't think there is an easy way to use current 'swap'
interface.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
