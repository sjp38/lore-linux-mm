Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2A8956B006C
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 16:57:07 -0500 (EST)
Received: by labhs14 with SMTP id hs14so5930186lab.1
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 13:57:06 -0800 (PST)
Received: from mail-lb0-x229.google.com (mail-lb0-x229.google.com. [2a00:1450:4010:c04::229])
        by mx.google.com with ESMTPS id g7si1405830lae.46.2015.02.11.13.57.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 13:57:05 -0800 (PST)
Received: by mail-lb0-f169.google.com with SMTP id p9so5986420lbv.0
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 13:57:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150211214650.GA11920@htj.duckdns.org>
References: <xr93siekt3p3.fsf@gthelen.mtv.corp.google.com>
	<20150205222522.GA10580@htj.dyndns.org>
	<xr93pp9nucrt.fsf@gthelen.mtv.corp.google.com>
	<20150206141746.GB10580@htj.dyndns.org>
	<CAHH2K0bxvc34u1PugVQsSfxXhmN8qU6KRpiCWwOVBa6BPqMDOg@mail.gmail.com>
	<20150207143839.GA9926@htj.dyndns.org>
	<20150211021906.GA21356@htj.duckdns.org>
	<CAHH2K0aHM=jmzbgkSCdFX0NxWbHBcVXqi3EAr0MS-gE3Txk93w@mail.gmail.com>
	<20150211203359.GF21356@htj.duckdns.org>
	<CALYGNiMm2VajBx0Y+XtLJ8860JS-GHfuSXQrBt32Wt0K7QpH0A@mail.gmail.com>
	<20150211214650.GA11920@htj.duckdns.org>
Date: Thu, 12 Feb 2015 01:57:04 +0400
Message-ID: <CALYGNiPX89HsgUS8BrJvL_jW-EU95xezc7uPf=0Pm72qiUwp7A@mail.gmail.com>
Subject: Re: [RFC] Making memcg track ownership per address_space or anon_vma
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Greg Thelen <gthelen@google.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, Li Zefan <lizefan@huawei.com>, Hugh Dickins <hughd@google.com>

On Thu, Feb 12, 2015 at 12:46 AM, Tejun Heo <tj@kernel.org> wrote:
> Hello,
>
> On Thu, Feb 12, 2015 at 12:22:34AM +0300, Konstantin Khlebnikov wrote:
>> > Yeah, available memory to the matching memcg and the number of dirty
>> > pages in it.  It's gonna work the same way as the global case just
>> > scoped to the cgroup.
>>
>> That might be a problem: all dirty pages accounted to cgroup must be
>> reachable for its own personal writeback or balanace-drity-pages will be
>> unable to satisfy memcg dirty memory thresholds. I've done accounting
>
> Yeah, it would.  Why wouldn't it?

How do you plan to do per-memcg/blkcg writeback for balance-dirty-pages?
Or you're thinking only about separating writeback flow into blkio cgroups
without actual inode filtering? I mean delaying inode writeback and keeping
dirty pages as long as possible if their cgroups are far from threshold.

>
>> for per-inode owner, but there is another option: shared inodes might be
>> handled differently and will be available for all (or related) cgroup
>> writebacks.
>
> I'm not following you at all.  The only reason this scheme can work is
> because we exclude persistent shared write cases.  As the whole thing
> is based on that assumption, special casing shared inodes doesn't make
> any sense.  Doing things like allowing all cgroups to write shared
> inodes without getting memcg on-board almost immediately breaks
> pressure propagation while making shared writes a lot more attractive
> and increasing implementation complexity substantially.  Am I missing
> something?
>
>> Another side is that reclaimer now (mosly?) never trigger pageout.
>> Memcg reclaimer should do something if it finds shared dirty page:
>> either move it into right cgroup or make that inode reachable for
>> memcg writeback. I've send patch which marks shared dirty inodes
>> with flag I_DIRTY_SHARED or so.
>
> It *might* make sense for memcg to drop pages being dirtied which
> don't match the currently associated blkcg of the inode; however,
> again, as we're basically declaring that shared writes aren't
> supported, I'm skeptical about the usefulness.
>
> Thanks.
>
> --
> tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
