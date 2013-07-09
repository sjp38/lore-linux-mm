Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 3403C6B0031
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 09:46:02 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md12so5496400pbc.30
        for <linux-mm@kvack.org>; Tue, 09 Jul 2013 06:46:01 -0700 (PDT)
Date: Tue, 9 Jul 2013 06:45:58 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH RFC] fsio: filesystem io accounting cgroup
Message-ID: <20130709134558.GD2478@htj.dyndns.org>
References: <20130708100046.14417.12932.stgit@zurg>
 <20130708170047.GA18600@mtj.dyndns.org>
 <20130708175201.GB9094@redhat.com>
 <20130708175607.GB18600@mtj.dyndns.org>
 <51DBC99F.4030301@openvz.org>
 <20130709125734.GA2478@htj.dyndns.org>
 <51DC0CE2.2050906@openvz.org>
 <20130709131605.GB2478@htj.dyndns.org>
 <20130709131646.GC2478@htj.dyndns.org>
 <51DC136E.6020901@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51DC136E.6020901@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Vivek Goyal <vgoyal@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sha Zhengju <handai.szj@gmail.com>, devel@openvz.org, Jens Axboe <axboe@kernel.dk>

On Tue, Jul 09, 2013 at 05:43:10PM +0400, Konstantin Khlebnikov wrote:
> My concept it cgroup which would control io operation on vfs layer
> for all filesystems.  It will account and manage IO operations. I've
> found really lightweight technique for accounting and throttling
> which don't introduce new locks or priority inversions (which is
> major problem in all existing throttlers, including cpu cgroup rate
> limiter) So, I've tried to keep code smaller, cleaner and saner as
> possible while you guys are trying to push me into the block layer
> =)

You're trying to implement QoS in the place where you don't have
control of the queue itself.  You aren't even managing the right type
of resource for disks which is time slice rather than iops or
bandwidth and by the time you implemented proper hierarchy support and
proportional control, yours isn't gonna be that simple either.  The
root problem is bdi failing to propagate pressure from the actual
queue upwards.  Fix that.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
