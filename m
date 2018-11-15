Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 58D526B063D
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 17:47:24 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id a2so13971666pgt.11
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 14:47:24 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 32-v6si6224512plb.282.2018.11.15.14.47.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 14:47:22 -0800 (PST)
Date: Thu, 15 Nov 2018 14:47:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH AUTOSEL 3.18 8/9] mm/vmstat.c: assert that vmstat_text
 is in sync with stat_items_size
Message-Id: <20181115144719.d26dc7a2d47fade8d41a83d5@linux-foundation.org>
In-Reply-To: <20181115223718.GB1706@sasha-vm>
References: <20181113055252.79406-1-sashal@kernel.org>
	<20181113055252.79406-8-sashal@kernel.org>
	<20181115140810.e3292c83467544f6a1d82686@linux-foundation.org>
	<20181115223718.GB1706@sasha-vm>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sashal@kernel.org>
Cc: stable@vger.kernel.org, linux-kernel@vger.kernel.org, Jann Horn <jannh@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Christoph Lameter <clameter@sgi.com>, Kemi Wang <kemi.wang@intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Thu, 15 Nov 2018 17:37:18 -0500 Sasha Levin <sashal@kernel.org> wrote:

> On Thu, Nov 15, 2018 at 02:08:10PM -0800, Andrew Morton wrote:
> >On Tue, 13 Nov 2018 00:52:51 -0500 Sasha Levin <sashal@kernel.org> wrote:
> >
> >> From: Jann Horn <jannh@google.com>
> >>
> >> [ Upstream commit f0ecf25a093fc0589f0a6bc4c1ea068bbb67d220 ]
> >>
> >> Having two gigantic arrays that must manually be kept in sync, including
> >> ifdefs, isn't exactly robust.  To make it easier to catch such issues in
> >> the future, add a BUILD_BUG_ON().
> >>
> >> ...
> >>
> >> --- a/mm/vmstat.c
> >> +++ b/mm/vmstat.c
> >> @@ -1189,6 +1189,8 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
> >>  	stat_items_size += sizeof(struct vm_event_state);
> >>  #endif
> >>
> >> +	BUILD_BUG_ON(stat_items_size !=
> >> +		     ARRAY_SIZE(vmstat_text) * sizeof(unsigned long));
> >>  	v = kmalloc(stat_items_size, GFP_KERNEL);
> >>  	m->private = v;
> >>  	if (!v)
> >
> >I don't think there's any way in which this can make a -stable kernel
> >more stable!
> >
> >
> >Generally, I consider -stable in every patch I merge, so for each patch
> >which doesn't have cc:stable, that tag is missing for a reason.
> >
> >In other words, your criteria for -stable addition are different from
> >mine.
> >
> >And I think your criteria differ from those described in
> >Documentation/process/stable-kernel-rules.rst.
> >
> >So... what is your overall thinking on patch selection?
> 
> Indeed, this doesn't fix anything.
> 
> My concern is that in the future, we will pull a patch that will cause
> the issue described here, and that issue will only be relevant on
> stable. It is very hard to debug this, and I suspect that stable kernels
> will still pass all their tests with flying colors.
> 
> As an example, consider the case where commit 28e2c4bb99aa ("mm/vmstat.c:
> fix outdated vmstat_text") is backported to a kernel that doesn't have
> commit 7a9cdebdcc17 ("mm: get rid of vmacache_flush_all() entirely").
> 
> I also felt safe with this patch since it adds a single BUILD_BUG_ON()
> which does nothing during runtime, so the chances it introduces anything
> beyond a build regression seemed to be slim to none.

Well OK.  But my question was general and covers basically every
autosel patch which originated in -mm.
