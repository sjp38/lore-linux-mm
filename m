Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 1CDE96B0068
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 21:59:46 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id ds1so66438wgb.2
        for <linux-mm@kvack.org>; Thu, 27 Sep 2012 18:59:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120927115219.GB28126@quack.suse.cz>
References: <1347798342-2830-1-git-send-email-linkinjeon@gmail.com>
	<20120920084422.GA5697@localhost>
	<20120924222306.GC30997@quack.suse.cz>
	<20120926165602.GA24672@localhost>
	<20120926202247.GA20920@quack.suse.cz>
	<CAKYAXd_=TkHM4s8hyyEZpkJCv3N7HOeXKxoEOpwigFYfR9+ReA@mail.gmail.com>
	<20120927115219.GB28126@quack.suse.cz>
Date: Fri, 28 Sep 2012 10:59:44 +0900
Message-ID: <CAKYAXd-1di4QioqvaAEoshqX9068id4BBBdWz7pJRZH60Gny1Q@mail.gmail.com>
Subject: Re: [PATCH v3 1/2] writeback: add dirty_background_centisecs per bdi variable
From: Namjae Jeon <linkinjeon@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Fengguang Wu <fengguang.wu@intel.com>
Cc: Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, Namjae Jeon <namjae.jeon@samsung.com>, Vivek Trivedi <t.vivek@samsung.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org

2012/9/27, Jan Kara <jack@suse.cz>:
> On Thu 27-09-12 15:00:18, Namjae Jeon wrote:
>> 2012/9/27, Jan Kara <jack@suse.cz>:
>> > On Thu 27-09-12 00:56:02, Wu Fengguang wrote:
>> >> On Tue, Sep 25, 2012 at 12:23:06AM +0200, Jan Kara wrote:
>> >> > On Thu 20-09-12 16:44:22, Wu Fengguang wrote:
>> >> > > On Sun, Sep 16, 2012 at 08:25:42AM -0400, Namjae Jeon wrote:
>> >> > > > From: Namjae Jeon <namjae.jeon@samsung.com>
>> >> > > >
>> >> > > > This patch is based on suggestion by Wu Fengguang:
>> >> > > > https://lkml.org/lkml/2011/8/19/19
>> >> > > >
>> >> > > > kernel has mechanism to do writeback as per dirty_ratio and
>> >> > > > dirty_background
>> >> > > > ratio. It also maintains per task dirty rate limit to keep
>> >> > > > balance
>> >> > > > of
>> >> > > > dirty pages at any given instance by doing bdi bandwidth
>> >> > > > estimation.
>> >> > > >
>> >> > > > Kernel also has max_ratio/min_ratio tunables to specify
>> >> > > > percentage
>> >> > > > of
>> >> > > > writecache to control per bdi dirty limits and task throttling.
>> >> > > >
>> >> > > > However, there might be a usecase where user wants a per bdi
>> >> > > > writeback tuning
>> >> > > > parameter to flush dirty data once per bdi dirty data reach a
>> >> > > > threshold
>> >> > > > especially at NFS server.
>> >> > > >
>> >> > > > dirty_background_centisecs provides an interface where user can
>> >> > > > tune
>> >> > > > background writeback start threshold using
>> >> > > > /sys/block/sda/bdi/dirty_background_centisecs
>> >> > > >
>> >> > > > dirty_background_centisecs is used alongwith average bdi write
>> >> > > > bandwidth
>> >> > > > estimation to start background writeback.
>> >> >   The functionality you describe, i.e. start flushing bdi when
>> >> > there's
>> >> > reasonable amount of dirty data on it, looks sensible and useful.
>> >> > However
>> >> > I'm not so sure whether the interface you propose is the right one.
>> >> > Traditionally, we allow user to set amount of dirty data (either in
>> >> > bytes
>> >> > or percentage of memory) when background writeback should start. You
>> >> > propose setting the amount of data in centisecs-to-write. Why that
>> >> > difference? Also this interface ties our throughput estimation code
>> >> > (which
>> >> > is an implementation detail of current dirty throttling) with the
>> >> > userspace
>> >> > API. So we'd have to maintain the estimation code forever, possibly
>> >> > also
>> >> > face problems when we change the estimation code (and thus estimates
>> >> > in
>> >> > some cases) and users will complain that the values they set
>> >> > originally
>> >> > no
>> >> > longer work as they used to.
>> >>
>> >> Yes, that bandwidth estimation is not all that (and in theory cannot
>> >> be made) reliable which may be a surprise to the user. Which make the
>> >> interface flaky.
>> >>
>> >> > Also, as with each knob, there's a problem how to properly set its
>> >> > value?
>> >> > Most admins won't know about the knob and so won't touch it. Others
>> >> > might
>> >> > know about the knob but will have hard time figuring out what value
>> >> > should
>> >> > they set. So if there's a new knob, it should have a sensible
>> >> > initial
>> >> > value. And since this feature looks like a useful one, it shouldn't
>> >> > be
>> >> > zero.
>> >>
>> >> Agreed in principle. There seems be no reasonable defaults for the
>> >> centisecs-to-write interface, mainly due to its inaccurate nature,
>> >> especially the initial value may be wildly wrong on fresh system
>> >> bootup. This is also true for your proposed interfaces, see below.
>> >>
>> >> > So my personal preference would be to have
>> >> > bdi->dirty_background_ratio
>> >> > and
>> >> > bdi->dirty_background_bytes and start background writeback whenever
>> >> > one of global background limit and per-bdi background limit is
>> >> > exceeded.
>> >> > I
>> >> > think this interface will do the job as well and it's easier to
>> >> > maintain
>> >> > in
>> >> > future.
>> >>
>> >> bdi->dirty_background_ratio, if I understand its semantics right, is
>> >> unfortunately flaky in the same principle as centisecs-to-write,
>> >> because it relies on the (implicitly estimation of) writeout
>> >> proportions. The writeout proportions for each bdi starts with 0,
>> >> which is even worse than the 100MB/s initial value for
>> >> bdi->write_bandwidth and will trigger background writeback on the
>> >> first write.
>> >   Well, I meant bdi->dirty_backround_ratio wouldn't use writeout
>> > proportion
>> > estimates at all. Limit would be
>> >   dirtiable_memory * bdi->dirty_backround_ratio.
>> >
>> > After all we want to start writeout to bdi when we have enough pages to
>> > reasonably load the device for a while which has nothing to do with how
>> > much is written to this device as compared to other devices.
>> >
>> > OTOH I'm not particularly attached to this interface. Especially since
>> > on a
>> > lot of today's machines, 1% is rather big so people might often end up
>> > using dirty_background_bytes anyway.
>> >
>> >> bdi->dirty_background_bytes is, however, reliable, and gives users
>> >> total control. If we export this interface alone, I'd imagine users
>> >> who want to control centisecs-to-write could run a simple script to
>> >> periodically get the write bandwith value out of the existing bdi
>> >> interface and echo it into bdi->dirty_background_bytes. Which makes
>> >> simple yet good enough centisecs-to-write controlling.
>> >>
>> >> So what do you think about exporting a really dumb
>> >> bdi->dirty_background_bytes, which will effectively give smart users
>> >> the freedom to do smart control over per-bdi background writeback
>> >> threshold? The users are offered the freedom to do his own bandwidth
>> >> estimation and choose not to rely on the kernel estimation, which will
>> >> free us from the burden of maintaining a flaky interface as well. :)
>> >   That's fine with me. Just it would be nice if we gave
>> > bdi->dirty_background_bytes some useful initial value. Maybe like
>> > dirtiable_memory * dirty_background_ratio?
>> Global dirty_background_bytes default value is zero that means
>> flushing is started based on dirty_background_ratio and dirtiable
>> memory.
>> Is it correct to set per bdi default dirty threshold
>> (bdi->dirty_background_bytes) equal to global dirty threshold  -
>> dirtiable_memory * dirty_background_ratio ?
>   Right, the default setting I proposed doesn't make a difference. And it's
> not obvious how to create one which is more meaningful. Pity.
>
>> In my opinion, default setting for per bdi-> dirty_background_bytes
>> should be zero to avoid any confusion and any change in default
>> writeback behaviour.
>   OK, fine with me.
Okay, I will make the patches as your opinion again.
Thanks Jan and Wu !
>
> 								Honza
> --
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
