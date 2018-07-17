Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B006B6B000A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 08:23:34 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12-v6so490314edi.12
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 05:23:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o92-v6si815321edd.195.2018.07.17.05.23.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 05:23:33 -0700 (PDT)
Date: Tue, 17 Jul 2018 14:23:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/10] psi: pressure stall information for CPU, memory,
 and IO v2
Message-ID: <20180717122327.GG7193@dhcp22.suse.cz>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180716155745.10368-1-drake@endlessm.com>
 <20180717112515.GE7193@dhcp22.suse.cz>
 <CAD8Lp45W00ga-P-nb6iytgSGW4xwSzmaTHA87DOvSotN0S2edw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAD8Lp45W00ga-P-nb6iytgSGW4xwSzmaTHA87DOvSotN0S2edw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Drake <drake@endlessm.com>
Cc: hannes@cmpxchg.org, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Linux Upstreaming Team <linux@endlessm.com>, linux-block@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On Tue 17-07-18 07:13:52, Daniel Drake wrote:
> On Tue, Jul 17, 2018 at 6:25 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > Yes this is really unfortunate. One thing that could help would be to
> > consider a trashing level during the reclaim (get_scan_count) to simply
> > forget about LRUs which are constantly refaulting pages back. We already
> > have the infrastructure for that. We just need to plumb it in.
> 
> Can you go into a bit more detail about that infrastructure and how we
> might detect which pages are being constantly refaulted? I'm
> interested in spending a few hours on this topic to see if I can come
> up with anything.

mm/workingset.c allows for tracking when an actual page got evicted.
workingset_refault tells us whether a give filemap fault is a recent
refault and activates the page if that is the case. So what you need is
to note how many refaulted pages we have on the active LRU list. If that
is a large part of the list and if the inactive list is really small
then we know we are trashing. This all sounds much easier than it will
eventually turn out to be of course but I didn't really get to play with
this much.

HTH even though it is not really thought through well.
-- 
Michal Hocko
SUSE Labs
