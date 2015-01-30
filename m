Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id BC4F46B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 19:44:51 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id r10so14466632igi.3
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 16:44:51 -0800 (PST)
Received: from mail-ie0-x231.google.com (mail-ie0-x231.google.com. [2607:f8b0:4001:c03::231])
        by mx.google.com with ESMTPS id wj15si428460icb.1.2015.01.29.16.44.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 16:44:51 -0800 (PST)
Received: by mail-ie0-f177.google.com with SMTP id vy18so146389iec.8
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 16:44:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150115170324.GD7008@dhcp22.suse.cz>
References: <1421079554-30899-1-git-send-email-cpandya@codeaurora.org>
	<20150115170324.GD7008@dhcp22.suse.cz>
Date: Thu, 29 Jan 2015 16:44:51 -0800
Message-ID: <CANcMJZALAz1WKjo+8VbUMWBpS117gaZht-b7jBLJWT9VVN83=g@mail.gmail.com>
Subject: Re: [PATCH] lowmemorykiller: Avoid excessive/redundant calling of LMK
From: John Stultz <john.stultz@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Chintan Pandya <cpandya@codeaurora.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Weijie Yang <weijie.yang@samsung.com>, David Rientjes <rientjes@google.com>, devel@driverdev.osuosl.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Android Kernel Team <kernel-team@android.com>, Rom Lemarchand <romlem@google.com>, Anton Vorontsov <anton@enomsg.org>

On Thu, Jan 15, 2015 at 9:03 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Mon 12-01-15 21:49:14, Chintan Pandya wrote:
>> The global shrinker will invoke lowmem_shrink in a loop.
>> The loop will be run (total_scan_pages/batch_size) times.
>> The default batch_size will be 128 which will make
>> shrinker invoking 100s of times. LMK does meaningful
>> work only during first 2-3 times and then rest of the
>> invocations are just CPU cycle waste. Fix that by returning
>> to the shrinker with SHRINK_STOP when LMK doesn't find any
>> more work to do. The deciding factor here is, no process
>> found in the selected LMK bucket or memory conditions are
>> sane.
>
> lowmemory killer is broken by design and this one of the examples which
> shows why. It simply doesn't fit into shrinkers concept.
>
> The count_object callback simply lies and tells the core that all
> the reclaimable LRU pages are scanable and gives it this as a number
> which the core uses for total_scan. scan_objects callback then happily
> ignore nr_to_reclaim and does its one time job where it iterates over
> _all_ tasks and picks up the victim and returns its rss as a return
> value. This is just a subset of LRU pages of course so it continues
> looping until total_scan goes down to 0 finally.
>
> If this really has to be a shrinker then, shouldn't it evaluate the OOM
> situation in the count callback and return non zero only if OOM and then
> the scan callback would kill and return nr_to_reclaim.
>
> Or even better wouldn't it be much better to use vmpressure to wake
> up a kernel module which would simply check the situation and kill
> something?
>
> Please do not put only cosmetic changes on top of broken concept and try
> to think about a proper solution that is what staging is for AFAIU.
>
> The code is in this state for quite some time and I would really hate if
> it got merged just because it is in staging for too long and it is used
> out there.

So the in-kernel low-memory-killer is hopefully on its way out.

With Lollipop on some devices, Android is using the mempressure
notifiers to kill processes from userland. However, not all devices
have moved to this new model (and possibly some resulting performance
issues are being worked out? Its not clear).  So hopefully we can drop
it soon, but I'd like to make sure we don't get only a half-working
solution upstream before we do remove it.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
