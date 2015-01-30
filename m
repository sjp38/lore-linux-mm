Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 624256B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 21:08:59 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id r5so18501053qcx.11
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 18:08:59 -0800 (PST)
Received: from mail-qa0-x22c.google.com (mail-qa0-x22c.google.com. [2607:f8b0:400d:c00::22c])
        by mx.google.com with ESMTPS id y4si11895180qch.0.2015.01.29.18.08.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 18:08:58 -0800 (PST)
Received: by mail-qa0-f44.google.com with SMTP id w8so18132910qac.3
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 18:08:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CANcMJZALAz1WKjo+8VbUMWBpS117gaZht-b7jBLJWT9VVN83=g@mail.gmail.com>
References: <1421079554-30899-1-git-send-email-cpandya@codeaurora.org>
	<20150115170324.GD7008@dhcp22.suse.cz>
	<CANcMJZALAz1WKjo+8VbUMWBpS117gaZht-b7jBLJWT9VVN83=g@mail.gmail.com>
Date: Thu, 29 Jan 2015 18:08:58 -0800
Message-ID: <CAABpnA-hGh2iP866aB+U7y6SN4pU2izP1wPUCYpkc+F7TQcDvw@mail.gmail.com>
Subject: Re: [PATCH] lowmemorykiller: Avoid excessive/redundant calling of LMK
From: Rom Lemarchand <romlem@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Michal Hocko <mhocko@suse.cz>, Chintan Pandya <cpandya@codeaurora.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Weijie Yang <weijie.yang@samsung.com>, David Rientjes <rientjes@google.com>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Android Kernel Team <kernel-team@android.com>, Anton Vorontsov <anton@enomsg.org>

On Thu, Jan 29, 2015 at 4:44 PM, John Stultz <john.stultz@linaro.org> wrote:
> On Thu, Jan 15, 2015 at 9:03 AM, Michal Hocko <mhocko@suse.cz> wrote:
>> On Mon 12-01-15 21:49:14, Chintan Pandya wrote:
>>> The global shrinker will invoke lowmem_shrink in a loop.
>>> The loop will be run (total_scan_pages/batch_size) times.
>>> The default batch_size will be 128 which will make
>>> shrinker invoking 100s of times. LMK does meaningful
>>> work only during first 2-3 times and then rest of the
>>> invocations are just CPU cycle waste. Fix that by returning
>>> to the shrinker with SHRINK_STOP when LMK doesn't find any
>>> more work to do. The deciding factor here is, no process
>>> found in the selected LMK bucket or memory conditions are
>>> sane.
>>
>> lowmemory killer is broken by design and this one of the examples which
>> shows why. It simply doesn't fit into shrinkers concept.
>>
>> The count_object callback simply lies and tells the core that all
>> the reclaimable LRU pages are scanable and gives it this as a number
>> which the core uses for total_scan. scan_objects callback then happily
>> ignore nr_to_reclaim and does its one time job where it iterates over
>> _all_ tasks and picks up the victim and returns its rss as a return
>> value. This is just a subset of LRU pages of course so it continues
>> looping until total_scan goes down to 0 finally.
>>
>> If this really has to be a shrinker then, shouldn't it evaluate the OOM
>> situation in the count callback and return non zero only if OOM and then
>> the scan callback would kill and return nr_to_reclaim.
>>
>> Or even better wouldn't it be much better to use vmpressure to wake
>> up a kernel module which would simply check the situation and kill
>> something?
>>
>> Please do not put only cosmetic changes on top of broken concept and try
>> to think about a proper solution that is what staging is for AFAIU.
>>
>> The code is in this state for quite some time and I would really hate if
>> it got merged just because it is in staging for too long and it is used
>> out there.
>
> So the in-kernel low-memory-killer is hopefully on its way out.
>
> With Lollipop on some devices, Android is using the mempressure
> notifiers to kill processes from userland. However, not all devices
> have moved to this new model (and possibly some resulting performance
> issues are being worked out? Its not clear).  So hopefully we can drop
> it soon, but I'd like to make sure we don't get only a half-working
> solution upstream before we do remove it.
>
> thanks
> -john

We are still working on a user space replacement to LMK. We have
definitely had issues with LMKd and so stayed with the in kernel one
for all the lollipop devices we shipped. Issues were mostly related to
performance, timing of OOM notifications and when under intense memory
pressure we ran into issues where even opening a file would fail due
to no RAM being available.
As John said, it's WIP and hopefully we'll be able to drop the in
kernel one soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
