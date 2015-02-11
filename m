Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6BCA56B0038
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 17:15:32 -0500 (EST)
Received: by labgf13 with SMTP id gf13so6413264lab.9
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 14:15:31 -0800 (PST)
Received: from mail-lb0-x22f.google.com (mail-lb0-x22f.google.com. [2a00:1450:4010:c04::22f])
        by mx.google.com with ESMTPS id q4si1612485lag.103.2015.02.11.14.15.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 14:15:30 -0800 (PST)
Received: by mail-lb0-f175.google.com with SMTP id n10so6041800lbv.6
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 14:15:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150211220530.GA12728@htj.duckdns.org>
References: <xr93pp9nucrt.fsf@gthelen.mtv.corp.google.com>
	<20150206141746.GB10580@htj.dyndns.org>
	<CAHH2K0bxvc34u1PugVQsSfxXhmN8qU6KRpiCWwOVBa6BPqMDOg@mail.gmail.com>
	<20150207143839.GA9926@htj.dyndns.org>
	<20150211021906.GA21356@htj.duckdns.org>
	<CAHH2K0aHM=jmzbgkSCdFX0NxWbHBcVXqi3EAr0MS-gE3Txk93w@mail.gmail.com>
	<20150211203359.GF21356@htj.duckdns.org>
	<CALYGNiMm2VajBx0Y+XtLJ8860JS-GHfuSXQrBt32Wt0K7QpH0A@mail.gmail.com>
	<20150211214650.GA11920@htj.duckdns.org>
	<CALYGNiPX89HsgUS8BrJvL_jW-EU95xezc7uPf=0Pm72qiUwp7A@mail.gmail.com>
	<20150211220530.GA12728@htj.duckdns.org>
Date: Thu, 12 Feb 2015 02:15:29 +0400
Message-ID: <CALYGNiMgpU51vNr186x6h-uh_9NqaTqZ_a2L60XG0STozy=30g@mail.gmail.com>
Subject: Re: [RFC] Making memcg track ownership per address_space or anon_vma
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Greg Thelen <gthelen@google.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, Li Zefan <lizefan@huawei.com>, Hugh Dickins <hughd@google.com>

On Thu, Feb 12, 2015 at 1:05 AM, Tejun Heo <tj@kernel.org> wrote:
> On Thu, Feb 12, 2015 at 01:57:04AM +0400, Konstantin Khlebnikov wrote:
>> On Thu, Feb 12, 2015 at 12:46 AM, Tejun Heo <tj@kernel.org> wrote:
>> > Hello,
>> >
>> > On Thu, Feb 12, 2015 at 12:22:34AM +0300, Konstantin Khlebnikov wrote:
>> >> > Yeah, available memory to the matching memcg and the number of dirty
>> >> > pages in it.  It's gonna work the same way as the global case just
>> >> > scoped to the cgroup.
>> >>
>> >> That might be a problem: all dirty pages accounted to cgroup must be
>> >> reachable for its own personal writeback or balanace-drity-pages will be
>> >> unable to satisfy memcg dirty memory thresholds. I've done accounting
>> >
>> > Yeah, it would.  Why wouldn't it?
>>
>> How do you plan to do per-memcg/blkcg writeback for balance-dirty-pages?
>> Or you're thinking only about separating writeback flow into blkio cgroups
>> without actual inode filtering? I mean delaying inode writeback and keeping
>> dirty pages as long as possible if their cgroups are far from threshold.
>
> What?  The code was already in the previous patchset.  I'm just gonna
> rip out the code to handle inode being dirtied on multiple wb's.

Well, ok. Even if shared writes are rare whey should be handled somehow
without relying on kupdate-like writeback. If memcg has a lot of dirty pages
but their inodes are accidentially belong to wrong wb queues when tasks in
that memcg shouldn't stuck in balance-dirty-pages until somebody outside
acidentially writes this data. That's all what I wanted to say.

>
> --
> tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
