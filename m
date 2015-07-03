Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5CA73280257
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 06:50:05 -0400 (EDT)
Received: by wiga1 with SMTP id a1so174795750wig.0
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 03:50:04 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l15si13886482wjq.63.2015.07.03.03.50.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 03 Jul 2015 03:50:03 -0700 (PDT)
Date: Fri, 3 Jul 2015 12:49:57 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 22/51] writeback: add {CONFIG|BDI_CAP|FS}_CGROUP_WRITEBACK
Message-ID: <20150703104957.GH23329@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-23-git-send-email-tj@kernel.org>
 <20150630093751.GH7252@quack.suse.cz>
 <20150702011056.GC26440@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150702011056.GC26440@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Wed 01-07-15 21:10:56, Tejun Heo wrote:
> Hello, Jan.
> 
> On Tue, Jun 30, 2015 at 11:37:51AM +0200, Jan Kara wrote:
> > Hum, you later changed this to use a per-sb flag instead of a per-fs-type
> > flag, right? We could do it as well here but OK.
> 
> The commits were already in stable branch at that point and landed in
> mainline during this merge window, so I'm afraid the review points
> will have to be addressed as additional patches.

Yeah, I know but I just didn't get to the series earlier. Anyway, I didn't
find fundamental issues so it's easy to change things in followup patches.

> > One more question - what does prevent us from supporting CGROUP_WRITEBACK
> > for all bdis capable of writeback? I guess the reason is that currently
> > blkcgs are bound to request_queue and we have to have blkcg(s) for
> > CGROUP_WRITEBACK to work, am I right? But in principle tracking writeback
> > state and doing writeback per memcg doesn't seem to be bound to any device
> > properties so we could do that right?
> 
> The main issue is that cgroup should somehow know how the processes
> are mapped to the underlying IO layer - the IO domain should somehow
> be defined.  We can introduce an intermediate abstraction which maps
> to blkcg and whatever other cgroup controllers which may define cgroup
> IO domains but given that such cases would be fairly niche, I think
> we'd be better off making those corner cases represent themselves
> using blkcg rather than introducing an additional layer.

Well, unless there is some specific mapping for the device, we could just
fall back to attributing everything to the root cgroup. We would still
account dirty pages in memcg, throttle writers in memcg when there are too
many dirty pages, issue writeback for inodes in memcg with enough dirty
pages etc. Just all IO from different memcgs would be equal so no
separation would be there. But it would still seem better that just
ignoring the split of dirty pages among memcgs as we do now... Thoughts?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
