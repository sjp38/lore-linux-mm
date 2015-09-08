Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 461BA6B025C
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 12:59:58 -0400 (EDT)
Received: by ykcf206 with SMTP id f206so128328167ykc.3
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 09:59:58 -0700 (PDT)
Received: from mail-yk0-x235.google.com (mail-yk0-x235.google.com. [2607:f8b0:4002:c07::235])
        by mx.google.com with ESMTPS id b82si2509500ykc.78.2015.09.08.09.59.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Sep 2015 09:59:57 -0700 (PDT)
Received: by ykcf206 with SMTP id f206so128327429ykc.3
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 09:59:57 -0700 (PDT)
Date: Tue, 8 Sep 2015 12:59:53 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 3/2] memcg: punt high overage reclaim to
 return-to-userland path
Message-ID: <20150908165953.GG13749@mtj.duckdns.org>
References: <20150828220158.GD11089@htj.dyndns.org>
 <20150828220237.GE11089@htj.dyndns.org>
 <20150904210011.GH25329@mtj.duckdns.org>
 <20150907092346.GC6022@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150907092346.GC6022@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, cgroups@vger.kernel.org, linux-mm@kvack.org, vdavydov@parallels.com, kernel-team@fb.com

Hello, Michal.

On Mon, Sep 07, 2015 at 11:23:46AM +0200, Michal Hocko wrote:
> > As long as kernel doesn't have a run-away allocation spree, this
> > should provide enough protection while making kmemcg behave more
> > consistently.
> 
> I would also point out that this approach allows for a better reclaim
> opportunities for GFP_NOFS charges which are quite common with kmem
> enabled.

Will update the description.

> > v2: - Switched to reclaiming only the overage caused by current rather
> >       than the difference between usage and high as suggested by
> >       Michal.
> >     - Don't record the memcg which went over high limit.  This makes
> >       exit path handling unnecessary.  Dropped.
> 
> Hmm, this allows to leave a memcg in a high limit excess. I guess
> you are right that this is not that likely to lose sleep over
> it. Nevertheless, a nasty user could move away from within signal
> handler context which runs before. This looks like a potential runaway
> but the migration outside of the restricted hierarchy is a problem in
> itself so I wouldn't consider this a problem.

Yeah, it's difficult to say that there isn't an exploitable sequence
which allows userland to breach high limit from an exiting task.  That
said, I think it'd be pretty difficult to make it large enough to
matter given that the exiting task is losing whatever it's pinning
anyway and the overage it can leave behind is confined by what it
allocates in the kernel execution leading to the exit.  The only
reason I added the exit handling is to put the memcg ref in the first
place.

> > +void mem_cgroup_handle_over_high(void)
> > +{
> > +	unsigned int nr_pages = current->memcg_nr_pages_over_high;
> > +	struct mem_cgroup *memcg, *pos;
> > +
> > +	if (likely(!nr_pages))
> > +		return;
> 
> This is hooking into a hot path so I guess it would be better to make
> this part inline and the rest can go via function call.

Thought about that but it's already guarded by TIF_NOTIFY_RESUME.  It
shouldn't be a hot path.

> > @@ -2082,17 +2108,22 @@ done_restock:
> 
> JFYI you can get rid of labels in the patch format by
> [diff "default"]
>         xfuncname = "^[[:alpha:]$_].*[^:]$"

Heh, I had that in my config but apparently lost it while migrating to
a new machine.  Reinstating...

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
