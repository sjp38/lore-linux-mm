Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 99DE46B089B
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 03:55:29 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id s50so2699285edd.11
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 00:55:29 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h22-v6si2580154ejl.15.2018.11.16.00.55.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 00:55:28 -0800 (PST)
Date: Fri, 16 Nov 2018 09:55:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH AUTOSEL 3.18 8/9] mm/vmstat.c: assert that vmstat_text is
 in sync with stat_items_size
Message-ID: <20181116085525.GC14706@dhcp22.suse.cz>
References: <20181113055252.79406-1-sashal@kernel.org>
 <20181113055252.79406-8-sashal@kernel.org>
 <20181115140810.e3292c83467544f6a1d82686@linux-foundation.org>
 <20181115223718.GB1706@sasha-vm>
 <20181115144719.d26dc7a2d47fade8d41a83d5@linux-foundation.org>
 <20181115230118.GC1706@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115230118.GC1706@sasha-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sashal@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, linux-kernel@vger.kernel.org, Jann Horn <jannh@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Christoph Lameter <clameter@sgi.com>, Kemi Wang <kemi.wang@intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Thu 15-11-18 18:01:18, Sasha Levin wrote:
> On Thu, Nov 15, 2018 at 02:47:19PM -0800, Andrew Morton wrote:
> > On Thu, 15 Nov 2018 17:37:18 -0500 Sasha Levin <sashal@kernel.org> wrote:
> > 
> > > On Thu, Nov 15, 2018 at 02:08:10PM -0800, Andrew Morton wrote:
> > > >On Tue, 13 Nov 2018 00:52:51 -0500 Sasha Levin <sashal@kernel.org> wrote:
> > > >
> > > >> From: Jann Horn <jannh@google.com>
> > > >>
> > > >> [ Upstream commit f0ecf25a093fc0589f0a6bc4c1ea068bbb67d220 ]
> > > >>
> > > >> Having two gigantic arrays that must manually be kept in sync, including
> > > >> ifdefs, isn't exactly robust.  To make it easier to catch such issues in
> > > >> the future, add a BUILD_BUG_ON().
> > > >>
> > > >> ...
> > > >>
> > > >> --- a/mm/vmstat.c
> > > >> +++ b/mm/vmstat.c
> > > >> @@ -1189,6 +1189,8 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
> > > >>  	stat_items_size += sizeof(struct vm_event_state);
> > > >>  #endif
> > > >>
> > > >> +	BUILD_BUG_ON(stat_items_size !=
> > > >> +		     ARRAY_SIZE(vmstat_text) * sizeof(unsigned long));
> > > >>  	v = kmalloc(stat_items_size, GFP_KERNEL);
> > > >>  	m->private = v;
> > > >>  	if (!v)
> > > >
> > > >I don't think there's any way in which this can make a -stable kernel
> > > >more stable!
> > > >
> > > >
> > > >Generally, I consider -stable in every patch I merge, so for each patch
> > > >which doesn't have cc:stable, that tag is missing for a reason.
> > > >
> > > >In other words, your criteria for -stable addition are different from
> > > >mine.
> > > >
> > > >And I think your criteria differ from those described in
> > > >Documentation/process/stable-kernel-rules.rst.
> > > >
> > > >So... what is your overall thinking on patch selection?
> > > 
> > > Indeed, this doesn't fix anything.
> > > 
> > > My concern is that in the future, we will pull a patch that will cause
> > > the issue described here, and that issue will only be relevant on
> > > stable. It is very hard to debug this, and I suspect that stable kernels
> > > will still pass all their tests with flying colors.
> > > 
> > > As an example, consider the case where commit 28e2c4bb99aa ("mm/vmstat.c:
> > > fix outdated vmstat_text") is backported to a kernel that doesn't have
> > > commit 7a9cdebdcc17 ("mm: get rid of vmacache_flush_all() entirely").
> > > 
> > > I also felt safe with this patch since it adds a single BUILD_BUG_ON()
> > > which does nothing during runtime, so the chances it introduces anything
> > > beyond a build regression seemed to be slim to none.
> > 
> > Well OK.  But my question was general and covers basically every
> > autosel patch which originated in -mm.
> 
> Sure. I picked 3 patches that show up on top when I google for AUTOSEL
> in linux-mm, maybe they'll be a good example to help me understand why
> they were not selected.
> 
> This one fixes a case where too few struct pages are allocated when
> using mirrorred memory:
> 
> 	https://marc.info/?l=linux-mm&m=154211933211147&w=2

Let me quote "I found this bug by reading the code." I do not think
anybody has ever seen this in practice.

> Race condition with memory hotplug due to missing locks:
> 
> 	https://marc.info/?l=linux-mm&m=154211934011188&w=2

Memory hotplug locking is dubious at best and this patch doesn't really
fix it. It fixes a theoretical problem. I am not aware anybody would be
hitting in practice. We need to rework the locking quite extensively.

> Raising an OOM event that causes issues in userspace when no OOM has
> actually occured:
> 
> 	https://marc.info/?l=linux-mm&m=154211939811582&w=2

The patch makes sense I just do not think this is a stable material. The
semantic of the event was and still is suboptimal.

> I think that all 3 cases represent a "real" bug users can hit, and I
> honestly don't know why they were not tagged for stable.

It would be much better to ask in the respective email thread rather
than spamming mailing with AUTOSEL patches which rarely get any
attention.

We have been through this discussion several times already and I thought
we have agreed that those subsystems which are seriously considering stable
are opted out from the AUTOSEL automagic. Has anything changed in that
regards.
-- 
Michal Hocko
SUSE Labs
