Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C5BCC6B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 04:48:20 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u78so32872425wmd.4
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 01:48:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 137si8425845wmm.33.2017.10.10.01.48.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 01:48:19 -0700 (PDT)
Date: Tue, 10 Oct 2017 10:48:17 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm/page-writeback.c: fix bug caused by disable periodic
 writeback
Message-ID: <20171010084817.GD775@quack2.suse.cz>
References: <1507330684-2205-1-git-send-email-laoar.shao@gmail.com>
 <20171009154212.bdf3645a2dce5d540657914b@linux-foundation.org>
 <CALOAHbBRxYqhoeqzDiCNcpA6PG9ysAknaRBseCEYLoV1M9MyHA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbBRxYqhoeqzDiCNcpA6PG9ysAknaRBseCEYLoV1M9MyHA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, mhocko@suse.com, Johannes Weiner <hannes@cmpxchg.org>, vdavydov.dev@gmail.com, jlayton@redhat.com, nborisov@suse.com, Theodore Ts'o <tytso@mit.edu>, mawilcox@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jens Axboe <axboe@kernel.dk>

On Tue 10-10-17 16:00:29, Yafang Shao wrote:
> 2017-10-10 6:42 GMT+08:00 Andrew Morton <akpm@linux-foundation.org>:
> > On Sat,  7 Oct 2017 06:58:04 +0800 Yafang Shao <laoar.shao@gmail.com> wrote:
> >
> >> After disable periodic writeback by writing 0 to
> >> dirty_writeback_centisecs, the handler wb_workfn() will not be
> >> entered again until the dirty background limit reaches or
> >> sync syscall is executed or no enough free memory available or
> >> vmscan is triggered.
> >> So the periodic writeback can't be enabled by writing a non-zero
> >> value to dirty_writeback_centisecs
> >> As it can be disabled by sysctl, it should be able to enable by
> >> sysctl as well.
> >>
> >> ...
> >>
> >> --- a/mm/page-writeback.c
> >> +++ b/mm/page-writeback.c
> >> @@ -1972,7 +1972,13 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
> >>  int dirty_writeback_centisecs_handler(struct ctl_table *table, int write,
> >>       void __user *buffer, size_t *length, loff_t *ppos)
> >>  {
> >> -     proc_dointvec(table, write, buffer, length, ppos);
> >> +     unsigned int old_interval = dirty_writeback_interval;
> >> +     int ret;
> >> +
> >> +     ret = proc_dointvec(table, write, buffer, length, ppos);
> >> +     if (!ret && !old_interval && dirty_writeback_interval)
> >> +             wakeup_flusher_threads(0, WB_REASON_PERIODIC);
> >> +
> >>       return 0;
> >
> > We could do with a code comment here, explaining why this code exists.
> >
> 
> OK. I will comment here.
> 
> > And...  I'm not sure it works correctly?  For example, if a device
> > doesn't presently have bdi_has_dirty_io() then wakeup_flusher_threads()
> > will skip it and the periodic writeback still won't be started?
> >
> 
> That's an issue.
> The periodic writeback won't be started.
> 
> Maybe we'd better call  wb_wakeup_delayed(wb) here to bypass the
> bdi_has_dirty_io() check ?

Well, wb_wakeup_delayed() would be more appropriate but you'd then have to
iterate over all bdis and wbs to be able to call it which IMO isn't worth
the pain for a special case like this. But the decision is worth mentioning
in the comment. Also wakeup_flusher_threads() does in principle what you
need - see my reply to Andrew for details.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
