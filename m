Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 062466B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 16:22:37 -0500 (EST)
Received: by mail-lb0-f173.google.com with SMTP id n10so5855232lbv.4
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 13:22:36 -0800 (PST)
Received: from mail-lb0-x230.google.com (mail-lb0-x230.google.com. [2a00:1450:4010:c04::230])
        by mx.google.com with ESMTPS id la5si1525000lac.113.2015.02.11.13.22.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 13:22:35 -0800 (PST)
Received: by mail-lb0-f176.google.com with SMTP id u10so5818447lbd.7
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 13:22:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150211203359.GF21356@htj.duckdns.org>
References: <xr93zj8ti6ca.fsf@gthelen.mtv.corp.google.com>
	<20150205131514.GD25736@htj.dyndns.org>
	<xr93siekt3p3.fsf@gthelen.mtv.corp.google.com>
	<20150205222522.GA10580@htj.dyndns.org>
	<xr93pp9nucrt.fsf@gthelen.mtv.corp.google.com>
	<20150206141746.GB10580@htj.dyndns.org>
	<CAHH2K0bxvc34u1PugVQsSfxXhmN8qU6KRpiCWwOVBa6BPqMDOg@mail.gmail.com>
	<20150207143839.GA9926@htj.dyndns.org>
	<20150211021906.GA21356@htj.duckdns.org>
	<CAHH2K0aHM=jmzbgkSCdFX0NxWbHBcVXqi3EAr0MS-gE3Txk93w@mail.gmail.com>
	<20150211203359.GF21356@htj.duckdns.org>
Date: Thu, 12 Feb 2015 00:22:34 +0300
Message-ID: <CALYGNiMm2VajBx0Y+XtLJ8860JS-GHfuSXQrBt32Wt0K7QpH0A@mail.gmail.com>
Subject: Re: [RFC] Making memcg track ownership per address_space or anon_vma
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Greg Thelen <gthelen@google.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, Li Zefan <lizefan@huawei.com>, Hugh Dickins <hughd@google.com>

On Wed, Feb 11, 2015 at 11:33 PM, Tejun Heo <tj@kernel.org> wrote:
> Hello, Greg.
>
> On Wed, Feb 11, 2015 at 10:28:44AM -0800, Greg Thelen wrote:
>> This seems good.  I assume that blkcg writeback would query
>> corresponding memcg for dirty page count to determine if over
>> background limit.  And balance_dirty_pages() would query memcg's dirty
>
> Yeah, available memory to the matching memcg and the number of dirty
> pages in it.  It's gonna work the same way as the global case just
> scoped to the cgroup.

That might be a problem: all dirty pages accounted to cgroup must be
reachable for its own personal writeback or balanace-drity-pages will be
unable to satisfy memcg dirty memory thresholds. I've done accounting
for per-inode owner, but there is another option: shared inodes might be
handled differently and will be available for all (or related) cgroup
writebacks.

Another side is that reclaimer now (mosly?) never trigger pageout.
Memcg reclaimer should do something if it finds shared dirty page:
either move it into right cgroup or make that inode reachable for
memcg writeback. I've send patch which marks shared dirty inodes
with flag I_DIRTY_SHARED or so.

>
>> page count to throttle based on blkcg's bandwidth.  Note: memcg
>> doesn't yet have dirty page counts, but several of us have made
>> attempts at adding the counters.  And it shouldn't be hard to get them
>> merged.
>
> Can you please post those?
>
> So, cool, we're in agreement.  Working on it.  It shouldn't take too
> long, hopefully.

Good. As I see this design is almost equal to my proposal,
maybe except that dumb first-owns-all-until-the-end rule.

>
> Thanks.
>
> --
> tejun
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
