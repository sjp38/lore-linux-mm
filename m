Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id A1DB66B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 02:50:28 -0400 (EDT)
Received: by wibhm6 with SMTP id hm6so4889401wib.8
        for <linux-mm@kvack.org>; Mon, 24 Sep 2012 23:50:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120924222306.GC30997@quack.suse.cz>
References: <1347798342-2830-1-git-send-email-linkinjeon@gmail.com>
	<20120920084422.GA5697@localhost>
	<20120924222306.GC30997@quack.suse.cz>
Date: Tue, 25 Sep 2012 15:50:26 +0900
Message-ID: <CAKYAXd8FB-BZNomePAr0MyzNCqz7ND+J+DurKD6KdvkCFf+3jA@mail.gmail.com>
Subject: Re: [PATCH v3 1/2] writeback: add dirty_background_centisecs per bdi variable
From: Namjae Jeon <linkinjeon@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Fengguang Wu <fengguang.wu@intel.com>
Cc: Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, Namjae Jeon <namjae.jeon@samsung.com>, Vivek Trivedi <t.vivek@samsung.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org

2012/9/25, Jan Kara <jack@suse.cz>:
> On Thu 20-09-12 16:44:22, Wu Fengguang wrote:
>> On Sun, Sep 16, 2012 at 08:25:42AM -0400, Namjae Jeon wrote:
>> > From: Namjae Jeon <namjae.jeon@samsung.com>
>> >
>> > This patch is based on suggestion by Wu Fengguang:
>> > https://lkml.org/lkml/2011/8/19/19
>> >
>> > kernel has mechanism to do writeback as per dirty_ratio and
>> > dirty_background
>> > ratio. It also maintains per task dirty rate limit to keep balance of
>> > dirty pages at any given instance by doing bdi bandwidth estimation.
>> >
>> > Kernel also has max_ratio/min_ratio tunables to specify percentage of
>> > writecache to control per bdi dirty limits and task throttling.
>> >
>> > However, there might be a usecase where user wants a per bdi writeback
>> > tuning
>> > parameter to flush dirty data once per bdi dirty data reach a threshold
>> > especially at NFS server.
>> >
>> > dirty_background_centisecs provides an interface where user can tune
>> > background writeback start threshold using
>> > /sys/block/sda/bdi/dirty_background_centisecs
>> >
>> > dirty_background_centisecs is used alongwith average bdi write
>> > bandwidth
>> > estimation to start background writeback.
>   The functionality you describe, i.e. start flushing bdi when there's
> reasonable amount of dirty data on it, looks sensible and useful. However
> I'm not so sure whether the interface you propose is the right one.
> Traditionally, we allow user to set amount of dirty data (either in bytes
> or percentage of memory) when background writeback should start. You
> propose setting the amount of data in centisecs-to-write. Why that
> difference? Also this interface ties our throughput estimation code (which
> is an implementation detail of current dirty throttling) with the userspace
> API. So we'd have to maintain the estimation code forever, possibly also
> face problems when we change the estimation code (and thus estimates in
> some cases) and users will complain that the values they set originally no
> longer work as they used to.
>
> Also, as with each knob, there's a problem how to properly set its value?
> Most admins won't know about the knob and so won't touch it. Others might
> know about the knob but will have hard time figuring out what value should
> they set. So if there's a new knob, it should have a sensible initial
> value. And since this feature looks like a useful one, it shouldn't be
> zero.
>
> So my personal preference would be to have bdi->dirty_background_ratio and
> bdi->dirty_background_bytes and start background writeback whenever
> one of global background limit and per-bdi background limit is exceeded. I
> think this interface will do the job as well and it's easier to maintain in
> future.
Hi Jan.
Thanks for review and your opinion.

Hi. Wu.
How about adding per-bdi - bdi->dirty_background_ratio and
bdi->dirty_background_bytes interface as suggested by Jan?

Thanks.
>
> 								Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
