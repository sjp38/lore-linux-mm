Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 370DB280257
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 08:36:50 -0400 (EDT)
Received: by wgqq4 with SMTP id q4so87480092wgq.1
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 05:36:49 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l2si15007679wic.16.2015.07.03.05.36.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 03 Jul 2015 05:36:48 -0700 (PDT)
Date: Fri, 3 Jul 2015 14:36:42 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 44/51] writeback: implement bdi_wait_for_completion()
Message-ID: <20150703123642.GL23329@quack.suse.cz>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
 <1432329245-5844-45-git-send-email-tj@kernel.org>
 <20150701160437.GG7252@quack.suse.cz>
 <20150702030624.GM26440@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150702030624.GM26440@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>, axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru

On Wed 01-07-15 23:06:24, Tejun Heo wrote:
> Hello, Jan.
> 
> On Wed, Jul 01, 2015 at 06:04:37PM +0200, Jan Kara wrote:
> > I'd find it better to extend completions to allow doing what you need. It
> > isn't that special. It seems it would be enough to implement
> > 
> > void wait_for_completions(struct completion *x, int n);
> > 
> > where @n is the number of completions to wait for. And the implementation
> > can stay as is, only in do_wait_for_common() we change checks for x->done ==
> > 0 to "x->done < n". That's about it...
> 
> I don't know.  While I agree that it'd be nice to have a generic event
> count & trigger mechanism in the kernel, I don't think extending
> completion is a good idea - the count then works both ways as the
> event counter && listener counter and effectively becomes a semaphore
> which usually doesn't end well.  There are very few cases where we
> want the counter works both ways and I personally think we'd be far
> better served if those rare cases implement something custom rather
> than generic mechanism becoming cryptic trying to cover everything.

Let me phrase my objection this differently: Instead of implementing custom
synchronization mechanism, you could as well do:

int count_submitted;	/* Number of submitted works we want to wait for */
struct completion done;
...
submit works with 'done' as completion.
...
while (count_submitted--)
	wait_for_completion(&done);

And we could also easily optimize that loop and put it in
kernel/sched/completion.c. The less synchronization mechanisms we have the
better I'd think...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
