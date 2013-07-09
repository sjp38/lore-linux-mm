Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id C63FE6B0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 13:43:01 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id eb20so5064280lab.15
        for <linux-mm@kvack.org>; Tue, 09 Jul 2013 10:42:59 -0700 (PDT)
Message-ID: <51DC4BA1.3000403@openvz.org>
Date: Tue, 09 Jul 2013 21:42:57 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] fsio: filesystem io accounting cgroup
References: <20130708175201.GB9094@redhat.com> <20130708175607.GB18600@mtj.dyndns.org> <51DBC99F.4030301@openvz.org> <20130709125734.GA2478@htj.dyndns.org> <51DC0CE2.2050906@openvz.org> <20130709131605.GB2478@htj.dyndns.org> <20130709131646.GC2478@htj.dyndns.org> <51DC136E.6020901@openvz.org> <20130709134558.GD2478@htj.dyndns.org> <51DC1FCA.3060904@openvz.org> <20130709150605.GC2237@redhat.com>
In-Reply-To: <20130709150605.GC2237@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sha Zhengju <handai.szj@gmail.com>, devel@openvz.org, Jens Axboe <axboe@kernel.dk>

Vivek Goyal wrote:
> On Tue, Jul 09, 2013 at 06:35:54PM +0400, Konstantin Khlebnikov wrote:
>
> [..]
>> I'm not interested in QoS or proportional control. Let schedulers do it.
>> I want just bandwidth control. I don't want to write a new scheduler
>> or extend some of existing one. I want implement simple and lightweight
>> accounting and add couple of throttlers on top of that.
>> It can be easily done without violation of that hierarchical design.
>>
>> The same problem already has happened with cpu scheduler. It has really
>> complicated rate limiter which is actually useless in the real world because
>> it triggers all possible priority inversions since it puts bunch of tasks into
>> deep sleep while some of them may hold kernel locks. Perfect.
>>
>> QoS and scheduling policy are good thing, but rate-limiting must be separated
>> and done only in places where it doesn't leads to these problems.
>
> So what kind of priority inversion you are facing with blkcg and how would
> you avoid it with your implementation?
>
> I know that serialization can happen at filesystem level while trying
> to commit journal. But I think same thing will happen with your
> implementation too.

Yes, metadata changes are serialized and and they depends on data commits,
thus block layer cannot delay write requests without introducing nasty priority
inversions. Cached read requests cannot be delayed at all. All solutions either
breaks throttling or adds PI. So block layer is just wrong place for this.

>
> One simple way of avoiding that will be to throttle IO even earlier
> but that means we do not take advantage of writeback cache and buffered
> writes will slow down.

If we want to control writeback speed we also must control size of dirty set.
There are several possibilities: we either can start writeback earlier,
or when dirty set exceeds some threshold we will start charging that dirty
memory into throttler and slow down all tasks who generates this dirty memory.
Because dirty memory is charged and accounted we can write it without delays.

>
> So I am curious how would you take care of these serialization issue.
>
> Also the throttlers you are planning to implement, what kind of throttling
> do they provide. Is it throttling rate per cgroup or per file per cgroup
> or rules will be per bdi per cgroup or something else.

Currently I'm thinking about per-cgroup X per-tier. Each bdi will be assigned
to some tier. It's flexible enough and solves chicken-and-egg problem:
when disk appears it will be assigned to default tier and can be reassigned.

>
> Thanks
> Vivek
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
