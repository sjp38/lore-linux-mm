Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 741CD6B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 04:45:06 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id t5so1098220lfe.1
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 01:45:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u68si9407353wrc.234.2017.10.10.01.45.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 01:45:04 -0700 (PDT)
Date: Tue, 10 Oct 2017 10:45:01 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm/page-writeback.c: fix bug caused by disable periodic
 writeback
Message-ID: <20171010084501.GC775@quack2.suse.cz>
References: <1507330684-2205-1-git-send-email-laoar.shao@gmail.com>
 <20171009154212.bdf3645a2dce5d540657914b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171009154212.bdf3645a2dce5d540657914b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yafang Shao <laoar.shao@gmail.com>, jack@suse.cz, mhocko@suse.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, jlayton@redhat.com, nborisov@suse.com, tytso@mit.edu, mawilcox@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jens Axboe <axboe@kernel.dk>

On Mon 09-10-17 15:42:12, Andrew Morton wrote:
> On Sat,  7 Oct 2017 06:58:04 +0800 Yafang Shao <laoar.shao@gmail.com> wrote:
> 
> > After disable periodic writeback by writing 0 to
> > dirty_writeback_centisecs, the handler wb_workfn() will not be
> > entered again until the dirty background limit reaches or
> > sync syscall is executed or no enough free memory available or
> > vmscan is triggered.
> > So the periodic writeback can't be enabled by writing a non-zero
> > value to dirty_writeback_centisecs
> > As it can be disabled by sysctl, it should be able to enable by 
> > sysctl as well.
> > 
> > ...
> >
> > --- a/mm/page-writeback.c
> > +++ b/mm/page-writeback.c
> > @@ -1972,7 +1972,13 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
> >  int dirty_writeback_centisecs_handler(struct ctl_table *table, int write,
> >  	void __user *buffer, size_t *length, loff_t *ppos)
> >  {
> > -	proc_dointvec(table, write, buffer, length, ppos);
> > +	unsigned int old_interval = dirty_writeback_interval;
> > +	int ret;
> > +
> > +	ret = proc_dointvec(table, write, buffer, length, ppos);
> > +	if (!ret && !old_interval && dirty_writeback_interval)
> > +		wakeup_flusher_threads(0, WB_REASON_PERIODIC);
> > +
> >  	return 0;
> 
> We could do with a code comment here, explaining why this code exists.
> 
> And...  I'm not sure it works correctly?  For example, if a device
> doesn't presently have bdi_has_dirty_io() then wakeup_flusher_threads()
> will skip it and the periodic writeback still won't be started?

This works correctly. For this case __mark_inode_dirty() has:

      if (bdi_cap_writeback_dirty(wb->bdi) && wakeup_bdi)
              wb_wakeup_delayed(wb);

So periodic writeback gets automatically started once first dirty inode
appears on a bdi.

> (why does the dirty_writeback_interval==0 special case exist, btw? 
> Seems to be a strange thing to do).

I guess to prevent busylooping? But I'm not sure...
 
> (and what happens if the interval was set to 1 hour and the user
> rewrites that to 1 second?  Does that change take 1 hour to take
> effect?)

That's a good point I didn't think about. So probably we should do the
wakeup whenever dirty_writeback_interval changes. 

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
