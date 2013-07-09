Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id B2C886B0031
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 04:28:21 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id z5so4419422lbh.21
        for <linux-mm@kvack.org>; Tue, 09 Jul 2013 01:28:19 -0700 (PDT)
Message-ID: <51DBC99F.4030301@openvz.org>
Date: Tue, 09 Jul 2013 12:28:15 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] fsio: filesystem io accounting cgroup
References: <20130708100046.14417.12932.stgit@zurg> <20130708170047.GA18600@mtj.dyndns.org> <20130708175201.GB9094@redhat.com> <20130708175607.GB18600@mtj.dyndns.org>
In-Reply-To: <20130708175607.GB18600@mtj.dyndns.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Vivek Goyal <vgoyal@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sha Zhengju <handai.szj@gmail.com>, devel@openvz.org, Jens Axboe <axboe@kernel.dk>

Tejun Heo wrote:
> Hello, Vivek.
>
> On Mon, Jul 08, 2013 at 01:52:01PM -0400, Vivek Goyal wrote:
>>> Again, a problem to be fixed in the stack rather than patching up from
>>> up above.  The right thing to do is to propagate pressure through bdi
>>> properly and let whatever is backing the bdi generate appropriate
>>> amount of pressure, be that disk or network.
>>
>> Ok, so use network controller for controlling IO rate on NFS? I had
>> tried it once and it did not work. I think it had problems related
>> to losing the context info as IO propagated through the stack. So
>> we will have to fix that too.
>
> But that's a similar problem we have with blkcg anyway - losing the
> dirtier information by the time writeback comes down through bdi.  It
> might not be exactly the same and might need some impedance matching
> on the network side but I don't see any fundamental differences.
>
> Thanks.
>

Yep, blkio has plenty problems and flaws and I don't get how it's related
to vfs layer, dirty set control and non-disk or network backed filesystems.
Any problem can be fixed by introducing new abstract layer, except too many
abstraction levels. Cgroup is pluggable subsystem, blkio has it's own plugins
and it's build on top of io scheduler plugin. All this stuff always have worked
with block devices. Now you suggest to handle all filesystems in this stack.
I think binding them to unrealated cgroup is rough leveling violation.

NFS cannot be controlled only by network throttlers because we cannot slow down
writeback process when it happens, we must slow down tasks who generates dirty memory.
Plus it's close to impossible to separate several workloads if they share one NFS sb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
