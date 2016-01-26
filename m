Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 589CB6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 16:44:21 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id r129so122564842wmr.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 13:44:21 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id qs3si4250041wjc.230.2016.01.26.13.44.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 13:44:20 -0800 (PST)
Date: Tue, 26 Jan 2016 16:43:34 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol: drop superfluous entry in the per-memcg
 stats array
Message-ID: <20160126214334.GA4016@cmpxchg.org>
References: <1453841729-29072-1-git-send-email-hannes@cmpxchg.org>
 <20160126133024.07f372dbf8935e03a3035269@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160126133024.07f372dbf8935e03a3035269@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Jan 26, 2016 at 01:30:24PM -0800, Andrew Morton wrote:
> On Tue, 26 Jan 2016 15:55:29 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > MEM_CGROUP_STAT_NSTATS is just a delimiter for cgroup1 statistics, not
> > an actual array entry. Reuse it for the first cgroup2 stat entry, like
> > in the event array.
> > 
> > ...
> >
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -51,7 +51,7 @@ enum mem_cgroup_stat_index {
> >  	MEM_CGROUP_STAT_SWAP,		/* # of pages, swapped out */
> >  	MEM_CGROUP_STAT_NSTATS,
> >  	/* default hierarchy stats */
> > -	MEMCG_SOCK,
> > +	MEMCG_SOCK = MEM_CGROUP_STAT_NSTATS,
> >  	MEMCG_NR_STAT,
> >  };
> 
> The code looks a bit odd.  How come mem_cgroup_stat_names[] ends with
> "swap"?  Should MEMCG_SOCK be in there at all?

It's cgroup1 vs. cgroup2 statistics. I'm using the same array in order
to use the original statistics infrastructure. It's a little weird, it
will be much cleaner once everything is converted to percpu_counter.

> And the naming is a bit sad.  "MEM_CGROUP_STAT_FILE_MAPPED" maps to
> "mapped_file", not "file_mapped".

MEM_CGROUP_STAT_FILE_MAPPED is named after NR_FILE_MAPPED because
they're both accounted from the same sites. Who knows why the
user-visible stat was then called mapped_file... :/

And in cgroup2 it's called file_mapped! At least there it'll be
consistent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
