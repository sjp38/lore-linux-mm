Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 43CA46B0033
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 23:50:30 -0400 (EDT)
Received: by mail-qc0-f176.google.com with SMTP id z10so3424480qcx.35
        for <linux-mm@kvack.org>; Tue, 09 Jul 2013 20:50:29 -0700 (PDT)
Date: Tue, 9 Jul 2013 20:50:24 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH RFC] fsio: filesystem io accounting cgroup
Message-ID: <20130710035024.GA28461@htj.dyndns.org>
References: <51DC0CE2.2050906@openvz.org>
 <20130709131605.GB2478@htj.dyndns.org>
 <20130709131646.GC2478@htj.dyndns.org>
 <51DC136E.6020901@openvz.org>
 <20130709134558.GD2478@htj.dyndns.org>
 <20130709141833.GA2237@redhat.com>
 <20130709142908.GE2478@htj.dyndns.org>
 <20130709145430.GB2237@redhat.com>
 <20130709150815.GG2478@htj.dyndns.org>
 <20130710030955.GA3569@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130710030955.GA3569@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sha Zhengju <handai.szj@gmail.com>, devel@openvz.org, Jens Axboe <axboe@kernel.dk>

Hello,

On Tue, Jul 09, 2013 at 11:09:55PM -0400, Vivek Goyal wrote:
> Stacking drivers are pretty important ones and we expect throttling
> to work with them. By throttling bio, a single hook worked both for
> request based drivers and bio based drivers.

Oh yeah, sure, we have them working now, so there's no way to break
them but that doesn't mean it's a good overall design.  I don't have a
good answer for this one.  The root cause is having the distinction
between bio and rq based drivers.  With the right constructs, I
suspect we probably could have done away with bio based drivers, but,
well, that's all history now.

> So looks like for bio based drivers you want bio throttling and for
> request based drviers, request throttling and define a separate hook
> in blk_queue_bio(). A generic hook probably can check the type of request
> queue and not throttle bio if it is request based queue and ultimately
> request queue based hook will throttle it.
> 
> So in a cgroup we blkio.throttle.io_serviced will have stats for
> bio/request depending on type of device.
> 
> And we will need to modify throttling logic so that it can handle
> both bio and request throttling. Not sure how much of code can be
> shared for bio/request throttling.

I'm not sure how much (de)multiplexing and sharing we'd be doing but
I'm afraid there's gonna need to be some.  We really can't use the
same logic for SSDs and rotating rusts after all and it probably would
be best to avoid contaminating SSD paths with lots of guesstimating
logics necessary for rotating rusts.

> I am not sure about request based multipath driver and it might
> require some special handling.

If it's not supported now, I'll be happy with just leaving it alone
and telling mp users to configure the underlying queues.

> Is it roughly inline with what you have been thinking.

I'm hoping to keep it somewhat manageable at least.  I wouldn't mind
leaving stacking driver and cfq-iosched support as they are while only
supporting SSD devices with new code.  It's all pie in the sky at this
point and none of this matters before we fix the bdi and writeback
issue anyway.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
