Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B081F6B0B18
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 14:34:11 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id t2so9209362edb.22
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 11:34:11 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n1si2643346edq.35.2018.11.16.11.34.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 11:34:10 -0800 (PST)
Date: Fri, 16 Nov 2018 20:34:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH AUTOSEL 3.18 8/9] mm/vmstat.c: assert that vmstat_text is
 in sync with stat_items_size
Message-ID: <20181116193408.GO14706@dhcp22.suse.cz>
References: <20181113055252.79406-1-sashal@kernel.org>
 <20181113055252.79406-8-sashal@kernel.org>
 <20181115140810.e3292c83467544f6a1d82686@linux-foundation.org>
 <20181115223718.GB1706@sasha-vm>
 <20181115144719.d26dc7a2d47fade8d41a83d5@linux-foundation.org>
 <20181115230118.GC1706@sasha-vm>
 <20181116085525.GC14706@dhcp22.suse.cz>
 <20181116181904.GH1706@sasha-vm>
 <20181116184457.GA11906@dhcp22.suse.cz>
 <20181116191910.GJ1706@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181116191910.GJ1706@sasha-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sashal@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, linux-kernel@vger.kernel.org, Jann Horn <jannh@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Christoph Lameter <clameter@sgi.com>, Kemi Wang <kemi.wang@intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Fri 16-11-18 14:19:10, Sasha Levin wrote:
> On Fri, Nov 16, 2018 at 07:44:57PM +0100, Michal Hocko wrote:
> > On Fri 16-11-18 13:19:04, Sasha Levin wrote:
> > > On Fri, Nov 16, 2018 at 09:55:25AM +0100, Michal Hocko wrote:
> > [...]
> > > > > Race condition with memory hotplug due to missing locks:
> > > > >
> > > > > 	https://marc.info/?l=linux-mm&m=154211934011188&w=2
> > > >
> > > > Memory hotplug locking is dubious at best and this patch doesn't really
> > > > fix it. It fixes a theoretical problem. I am not aware anybody would be
> > > > hitting in practice. We need to rework the locking quite extensively.
> > > 
> > > The word "theoretical" used in the stable rules file does not mean
> > > that we need to have actual reports of users hitting bugs before we
> > > start backporting the relevant patch, it simply suggests that there
> > > needs to be a reasonable explanation of how this issue can be hit.
> > > 
> > > For this memory hotplug patch in particular, I use the hv_balloon driver
> > > at this very moment (running a linux guest on windows, with "dynamic
> > > memory" enabled). Should I wait for it to crash before I can fix it?
> > > 
> > > Is the upstream code perfect? No, but that doesn't mean that it's not
> > > working at all, and if there are users they expect to see fixes going in
> > > and not just sitting idly waiting for a big rewrite that will come in a
> > > few years.
> > > 
> > > Memory hotplug fixes are not something you think should go to stable?
> > > Andrew sent a few of them to stable, so that can't be the case.
> > 
> > I am not arguing about hotplug fixes in general. I was arguing that this
> > particular one is a theoretical one and hotplug locking is quite subtle.
> > E.g. 381eab4a6ee mm/memory_hotplug: fix online/offline_pages called w.o. mem_hotplug_lock
> > http://lkml.kernel.org/r/20181114070909.GB2653@MiWiFi-R3L-srv
> > So in general unless the issue is really triggered easily I am rather
> > conservative.
> 
> We have millions of machines running linux, everything is triggered
> "easily" at that scale.

yet a zero report...

> > > > > Raising an OOM event that causes issues in userspace when no OOM has
> > > > > actually occured:
> > > > >
> > > > > 	https://marc.info/?l=linux-mm&m=154211939811582&w=2
> > > >
> > > > The patch makes sense I just do not think this is a stable material. The
> > > > semantic of the event was and still is suboptimal.
> > > 
> > > I really fail to understand your reasoning about -stable here. This
> > > patch is something people actually hit in the field, spent time on
> > > triaging and analysing it, and submitting a fix which looks reasonably
> > > straightforward.
> > > 
> > > That fix was acked by quite a few folks (including yourself) and merged
> > > in. And as far as we can tell, it actually fixed the problem.
> > > 
> > > Why is it not stable material?
> > 
> > Because the semantic of the OOM event is quite tricky itself. We have
> > discussed this patch and concluded that the updated one is more
> > sensible. But it is not yet clear whether this is actually what other
> > users expect as well. That to me does sound quite risky for a stable
> > kernel.
> 
> So there's another patch following this one that fixes it? Sure - can I
> take both?

No. There is no known bug. I am arguing that such a change needs some
time to settle. I am quite skeptical that this will actually trigger
any bug.

I will not _object_ if this was merged if somebody explicitly asks for
it. I am saying that I am not convinced it is a stable material.

So I guess our views on what is stable material differ. As I have said
several times already, I think the volume of patches flowing to the
stable tree is really high. To the point that taking stable trees for
our SLES kernels become problematic. I have heard the similar from
others. More is not always better. But let's not repeat this discussion
again. If Andrew doesn't mind then keep sending AUTOSEL emails but
please let's not apply those patches automatically.

Thanks!
-- 
Michal Hocko
SUSE Labs
