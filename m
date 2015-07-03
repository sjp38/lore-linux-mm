Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9B663280260
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 12:33:15 -0400 (EDT)
Received: by ykdr198 with SMTP id r198so99442780ykd.3
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 09:33:15 -0700 (PDT)
Received: from mail-yk0-x233.google.com (mail-yk0-x233.google.com. [2607:f8b0:4002:c07::233])
        by mx.google.com with ESMTPS id i189si6595473ywc.10.2015.07.03.09.33.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jul 2015 09:33:13 -0700 (PDT)
Received: by ykdv136 with SMTP id v136so99830121ykd.0
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 09:33:12 -0700 (PDT)
Date: Fri, 3 Jul 2015 12:33:09 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 41/51] writeback: make wakeup_flusher_threads() handle
 multiple bdi_writeback's
Message-ID: <20150703163309.GC5273@mtj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-42-git-send-email-tj@kernel.org>
 <20150701081528.GB7252@quack.suse.cz>
 <20150702023706.GK26440@mtj.duckdns.org>
 <20150703130213.GM23329@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150703130213.GM23329@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

Hello,

On Fri, Jul 03, 2015 at 03:02:13PM +0200, Jan Kara wrote:
...
> OK, I agree with your device vs logical construct argument. However when
> splitting pages based on avg throughput each cgroup generates, we know
> nothing about actual amount of dirty pages in each cgroup so we may end up
> writing much fewer pages than we originally wanted since a cgroup which was
> assigned a big chunk needn't have many pages available. So your algorithm
> is basically bound to undershoot the requested number of pages in some
> cases...

Sure, but the nr_to_write has never been a strict thing except when
we're writing out everything.  We don't overshoot them but writing out
less than requested is not unusual.  Also, note that write bandwidth
is the primary measure that we base the distribution of dirty pages
on.  Sure, there can be cases where the two deviate but this is the
better measure to use than, say, number of currently dirty pages.

> Another concern is that if we have two cgroups with same amount of dirty
> pages but cgroup A has them randomly scattered (and thus have much lower
> bandwidth) and cgroup B has them in a sequential fashion (thus with higher
> bandwidth), you end up cleaning (and subsequently reclaiming) more from
> cgroup B. That may be good for immediate memory pressure but could be
> considered unfair by the cgroup owner.
> 
> Maybe it would be better to split number of pages to write based on
> fraction of dirty pages each cgroup has in the bdi?

The dirty pages are already distributed according to write bandwidth.
Write bandwidth is the de-facto currency of dirty page distribution.
If it can be shown that some other measure is better for this purpose,
sure, but I don't see why we'd deviate just based on a vague feeling
that something else might be better and given how these mechanisms are
used I don't think going either way would matter a bit.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
