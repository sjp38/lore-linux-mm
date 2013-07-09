Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id ABD426B0031
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 10:35:59 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id gw10so4765217lab.2
        for <linux-mm@kvack.org>; Tue, 09 Jul 2013 07:35:57 -0700 (PDT)
Message-ID: <51DC1FCA.3060904@openvz.org>
Date: Tue, 09 Jul 2013 18:35:54 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] fsio: filesystem io accounting cgroup
References: <20130708100046.14417.12932.stgit@zurg> <20130708170047.GA18600@mtj.dyndns.org> <20130708175201.GB9094@redhat.com> <20130708175607.GB18600@mtj.dyndns.org> <51DBC99F.4030301@openvz.org> <20130709125734.GA2478@htj.dyndns.org> <51DC0CE2.2050906@openvz.org> <20130709131605.GB2478@htj.dyndns.org> <20130709131646.GC2478@htj.dyndns.org> <51DC136E.6020901@openvz.org> <20130709134558.GD2478@htj.dyndns.org>
In-Reply-To: <20130709134558.GD2478@htj.dyndns.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Vivek Goyal <vgoyal@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sha Zhengju <handai.szj@gmail.com>, devel@openvz.org, Jens Axboe <axboe@kernel.dk>

Tejun Heo wrote:
> On Tue, Jul 09, 2013 at 05:43:10PM +0400, Konstantin Khlebnikov wrote:
>> My concept it cgroup which would control io operation on vfs layer
>> for all filesystems.  It will account and manage IO operations. I've
>> found really lightweight technique for accounting and throttling
>> which don't introduce new locks or priority inversions (which is
>> major problem in all existing throttlers, including cpu cgroup rate
>> limiter) So, I've tried to keep code smaller, cleaner and saner as
>> possible while you guys are trying to push me into the block layer
>> =)
>
> You're trying to implement QoS in the place where you don't have
> control of the queue itself.  You aren't even managing the right type
> of resource for disks which is time slice rather than iops or
> bandwidth and by the time you implemented proper hierarchy support and
> proportional control, yours isn't gonna be that simple either.  The
> root problem is bdi failing to propagate pressure from the actual
> queue upwards.  Fix that.
>

I'm not interested in QoS or proportional control. Let schedulers do it.
I want just bandwidth control. I don't want to write a new scheduler
or extend some of existing one. I want implement simple and lightweight
accounting and add couple of throttlers on top of that.
It can be easily done without violation of that hierarchical design.

The same problem already has happened with cpu scheduler. It has really
complicated rate limiter which is actually useless in the real world because
it triggers all possible priority inversions since it puts bunch of tasks into
deep sleep while some of them may hold kernel locks. Perfect.

QoS and scheduling policy are good thing, but rate-limiting must be separated
and done only in places where it doesn't leads to these problems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
