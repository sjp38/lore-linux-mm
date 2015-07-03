Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id E8E32280260
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 13:02:14 -0400 (EDT)
Received: by ykdr198 with SMTP id r198so99997324ykd.3
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 10:02:14 -0700 (PDT)
Received: from mail-yk0-x230.google.com (mail-yk0-x230.google.com. [2607:f8b0:4002:c07::230])
        by mx.google.com with ESMTPS id e126si6637254ywb.47.2015.07.03.10.02.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jul 2015 10:02:13 -0700 (PDT)
Received: by ykdy1 with SMTP id y1so100322073ykd.2
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 10:02:13 -0700 (PDT)
Date: Fri, 3 Jul 2015 13:02:10 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 44/51] writeback: implement bdi_wait_for_completion()
Message-ID: <20150703170210.GD5273@mtj.duckdns.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-45-git-send-email-tj@kernel.org>
 <20150701160437.GG7252@quack.suse.cz>
 <20150702030624.GM26440@mtj.duckdns.org>
 <20150703123642.GL23329@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150703123642.GL23329@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

Hello,

On Fri, Jul 03, 2015 at 02:36:42PM +0200, Jan Kara wrote:
> Let me phrase my objection this differently: Instead of implementing custom
> synchronization mechanism, you could as well do:
> 
> int count_submitted;	/* Number of submitted works we want to wait for */
> struct completion done;
> ...
> submit works with 'done' as completion.
> ...
> while (count_submitted--)
> 	wait_for_completion(&done);
> 
> And we could also easily optimize that loop and put it in
> kernel/sched/completion.c. The less synchronization mechanisms we have the
> better I'd think...

And what I'm trying to say is that we most likely don't want to build
it around completions.  We really don't want to roll "event count" and
"wakeup count" into the same mechanism.  There's nothing completion
provides that such event counting mechanism needs or wants.  It isn't
that attractive from the completion side either.  The main reason we
have completions is for stupid simple synchronizations and we wanna
keep it simple.

I do agree that we might want a generic "event count" mechanism but at
the same time combining a counter and wait_event is usually pretty
trivial.  Maybe atomic_t + waitqueue is a useful enough abstraction
but then we would eventually end up having to deal with all the
different types of waits and timeouts.  We might end up with a lot of
thin wrappers which really don't do much of anything.

If you can think of a good way to abstract this, please go head.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
