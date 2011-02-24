Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 652498D0039
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 21:01:53 -0500 (EST)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p1O21mPN025335
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 18:01:48 -0800
Received: from qwk3 (qwk3.prod.google.com [10.241.195.131])
	by kpbe17.cbf.corp.google.com with ESMTP id p1O21gd3022943
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 18:01:47 -0800
Received: by qwk3 with SMTP id 3so74803qwk.37
        for <linux-mm@kvack.org>; Wed, 23 Feb 2011 18:01:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110224094039.89c07bea.kamezawa.hiroyu@jp.fujitsu.com>
References: <1298394776-9957-1-git-send-email-arighi@develer.com>
 <20110222193403.GG28269@redhat.com> <20110222224141.GA23723@linux.develer.com>
 <20110223000358.GM28269@redhat.com> <20110223083206.GA2174@linux.develer.com>
 <20110223152354.GA2526@redhat.com> <20110223231410.GB1744@linux.develer.com>
 <20110224001033.GF2526@redhat.com> <20110224094039.89c07bea.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 23 Feb 2011 18:01:22 -0800
Message-ID: <AANLkTimka0euS_+Rp0Vrj4RrUx9CW_JJygNxYFdGsw2J@mail.gmail.com>
Subject: Re: [PATCH 0/5] blk-throttle: writeback and swap IO control
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Wu Fengguang <fengguang.wu@intel.com>, Gui Jianfeng <guijianfeng@cn.fujitsu.com>, Ryo Tsuruta <ryov@valinux.co.jp>, Hirokazu Takahashi <taka@valinux.co.jp>, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Wed, Feb 23, 2011 at 4:40 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 23 Feb 2011 19:10:33 -0500
> Vivek Goyal <vgoyal@redhat.com> wrote:
>
>> On Thu, Feb 24, 2011 at 12:14:11AM +0100, Andrea Righi wrote:
>> > On Wed, Feb 23, 2011 at 10:23:54AM -0500, Vivek Goyal wrote:
>> > > > > Agreed. Granularity of per inode level might be accetable in man=
y
>> > > > > cases. Again, I am worried faster group getting stuck behind slo=
wer
>> > > > > group.
>> > > > >
>> > > > > I am wondering if we are trying to solve the problem of ASYNC wr=
ite throttling
>> > > > > at wrong layer. Should ASYNC IO be throttled before we allow tas=
k to write to
>> > > > > page cache. The way we throttle the process based on dirty ratio=
, can we
>> > > > > just check for throttle limits also there or something like that=
.(I think
>> > > > > that's what you had done in your initial throttling controller i=
mplementation?)
>> > > >
>> > > > Right. This is exactly the same approach I've used in my old throt=
tling
>> > > > controller: throttle sync READs and WRITEs at the block layer and =
async
>> > > > WRITEs when the task is dirtying memory pages.
>> > > >
>> > > > This is probably the simplest way to resolve the problem of faster=
 group
>> > > > getting blocked by slower group, but the controller will be a litt=
le bit
>> > > > more leaky, because the writeback IO will be never throttled and w=
e'll
>> > > > see some limited IO spikes during the writeback.
>> > >
>> > > Yes writeback will not be throttled. Not sure how big a problem that=
 is.
>> > >
>> > > - We have controlled the input rate. So that should help a bit.
>> > > - May be one can put some high limit on root cgroup to in blkio thro=
ttle
>> > > =A0 controller to limit overall WRITE rate of the system.
>> > > - For SATA disks, try to use CFQ which can try to minimize the impac=
t of
>> > > =A0 WRITE.
>> > >
>> > > It will atleast provide consistent bandwindth experience to applicat=
ion.
>> >
>> > Right.
>> >
>> > >
>> > > >However, this is always
>> > > > a better solution IMHO respect to the current implementation that =
is
>> > > > affected by that kind of priority inversion problem.
>> > > >
>> > > > I can try to add this logic to the current blk-throttle controller=
 if
>> > > > you think it is worth to test it.
>> > >
>> > > At this point of time I have few concerns with this approach.
>> > >
>> > > - Configuration issues. Asking user to plan for SYNC ans ASYNC IO
>> > > =A0 separately is inconvenient. One has to know the nature of worklo=
ad.
>> > >
>> > > - Most likely we will come up with global limits (atleast to begin w=
ith),
>> > > =A0 and not per device limit. That can lead to contention on one sin=
gle
>> > > =A0 lock and scalability issues on big systems.
>> > >
>> > > Having said that, this approach should reduce the kernel complexity =
a lot.
>> > > So if we can do some intelligent locking to limit the overhead then =
it
>> > > will boil down to reduced complexity in kernel vs ease of use to use=
r. I
>> > > guess at this point of time I am inclined towards keeping it simple =
in
>> > > kernel.
>> > >
>> >
>> > BTW, with this approach probably we can even get rid of the page
>> > tracking stuff for now.
>>
>> Agreed.
>>
>> > If we don't consider the swap IO, any other IO
>> > operation from our point of view will happen directly from process
>> > context (writes in memory + sync reads from the block device).
>>
>> Why do we need to account for swap IO? Application never asked for swap
>> IO. It is kernel's decision to move soem pages to swap to free up some
>> memory. What's the point in charging those pages to application group
>> and throttle accordingly?
>>
>
> I think swap I/O should be controlled by memcg's dirty_ratio.
> But, IIRC, NEC guy had a requirement for this...
>
> I think some enterprise cusotmer may want to throttle the whole speed of
> swapout I/O (not swapin)...so, they may be glad if they can limit throttl=
e
> the I/O against a disk partition or all I/O tagged as 'swapio' rather tha=
n
> some cgroup name.
>
> But I'm afraid slow swapout may consume much dirty_ratio and make things
> worse ;)
>
>
>
>> >
>> > However, I'm sure we'll need the page tracking also for the blkio
>> > controller soon or later. This is an important information and also th=
e
>> > proportional bandwidth controller can take advantage of it.
>>
>> Yes page tracking will be needed for CFQ proportional bandwidth ASYNC
>> write support. But until and unless we implement memory cgroup dirty
>> ratio and figure a way out to make writeback logic cgroup aware, till
>> then I think page tracking stuff is not really useful.
>>
>
> I think Greg Thelen is now preparing patches for dirty_ratio.
>
> Thanks,
> -Kame
>
>

Correct.  I am working on the memcg dirty_ratio patches with latest
mmotm memcg.  I am running some test cases which should be complete
tomorrow.  Once testing is complete, I will sent  the patches for
review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
