Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 76F0B6B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 05:10:00 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l1so912080wrc.6
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 02:10:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s3si10534007wmb.174.2017.10.11.02.09.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Oct 2017 02:09:59 -0700 (PDT)
Date: Wed, 11 Oct 2017 11:09:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171011090957.i6z7e7akv3uuzti3@dhcp22.suse.cz>
References: <20171005222144.123797-1-shakeelb@google.com>
 <20171006075900.icqjx5rr7hctn3zd@dhcp22.suse.cz>
 <CALvZod7YN4JCG7Anm2FViyZ0-APYy+nxEd3nyxe5LT_P0FC9wg@mail.gmail.com>
 <20171009062426.hmqedtqz5hkmhnff@dhcp22.suse.cz>
 <xr93a810xl77.fsf@gthelen.svl.corp.google.com>
 <20171009180409.z3mpk3m7m75hjyfv@dhcp22.suse.cz>
 <20171009181754.37svpqljub2goojr@dhcp22.suse.cz>
 <20171010091042.eokqlrqec33w3qzt@dhcp22.suse.cz>
 <CALvZod5VzPRRbhxLSn5GkgPbJEVJ9X5SfA=rjzRtTqLbCAe+eA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod5VzPRRbhxLSn5GkgPbJEVJ9X5SfA=rjzRtTqLbCAe+eA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Greg Thelen <gthelen@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

On Tue 10-10-17 15:21:53, Shakeel Butt wrote:
[...]
> On Tue, Oct 10, 2017 at 2:10 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Mon 09-10-17 20:17:54, Michal Hocko wrote:
> >> the primary concern for this patch was whether we really need/want to
> >> charge short therm objects which do not outlive a single syscall.
> >
> > Let me expand on this some more. What is the benefit of kmem accounting
> > of such an object? It cannot stop any runaway as a syscall lifetime
> > allocations are bound to number of processes which we kind of contain by
> > other means.
> 
> We can contain by limited the number of processes or thread but for us
> applications having thousands of threads is very common. So, limiting
> the number of threads/processes will not work.

Well, the number of tasks is already contained in a way because we do
account each task (kernel) stack AFAIR.

> > If we do account then we put a memory pressure due to
> > something that cannot be reclaimed by no means. Even the memcg OOM
> > killer would simply kick a single path while there might be others
> > to consume the same type of memory.
> >
> > So what is the actual point in accounting these? Does it help to contain
> > any workload better? What kind of workload?
> >
> 
> I think the benefits will be isolation and more accurate billing. As I
> have said before we have observed 100s of MiBs in names_cache on many
> machines and cumulative amount is not something we can ignore as just
> memory overhead.

I do agree with Al arguing this is rather dubious and it can add an
overhead without a good reason.

> > Or am I completely wrong and name objects can outlive a syscall
> > considerably?
> >
> 
> No, I didn't find any instance of the name objects outliving the syscall.
> 
> Anyways, we can discuss more on names_cache, do you have any objection
> regarding charging filp?

I think filep makes more sense. But let's drop the names for now. I am
not really convinced this is a good idea.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
