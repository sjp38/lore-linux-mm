Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id BA39B6B0003
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 15:30:27 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id n136-v6so8295898ybf.20
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 12:30:27 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k193sor1066928ywe.388.2018.02.20.12.30.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Feb 2018 12:30:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180220124354.6awua447q55lfduf@quack2.suse.cz>
References: <CALvZod5H4eL=YtZ3zkGG3p8gD+3=qnC3siUw1zpKL+128KufAA@mail.gmail.com>
 <CAOQ4uxgJqn0CJaf=LMH-iv2g1MJZwPM97K6iCtzrcY3eoN6KjA@mail.gmail.com>
 <CAOQ4uxjgKUFJ_uhyrQdcTs1FzcN6JrR_JpPc9QBrGJEU+cf65w@mail.gmail.com>
 <CALvZod45r7oW=HWH7KJyvFhJWB=6+Si54JK7E0Mx_2gLTZd1Pg@mail.gmail.com>
 <CAOQ4uxghwNg9Ni23EQA-971-qAaTNceSZS2MSvK06uEjoXG_yg@mail.gmail.com>
 <CALvZod7FTNzoGfGnaorqjk4KEsxJFdz1pApHi04P1cF10ejxpQ@mail.gmail.com>
 <CALvZod4SNwWHYZQsphB90cY-wc8WSLurKsA2kNxfVKV-upwy9A@mail.gmail.com>
 <CAOQ4uxifddquri4BNqBSKv6O_b13=C08kKYinTo9+m56z1n+aQ@mail.gmail.com>
 <20180219135027.fd6doess7satenxk@quack2.suse.cz> <CAOQ4uxjkfTTJ7nxrtj8ZsKcsWfBz=J0RPv3N=u3JaskRgG9aWw@mail.gmail.com>
 <20180220124354.6awua447q55lfduf@quack2.suse.cz>
From: Amir Goldstein <amir73il@gmail.com>
Date: Tue, 20 Feb 2018 22:30:25 +0200
Message-ID: <CAOQ4uxjAaRXPEwbqEMqL9Jr4-JhAscYcFtc01EMQbm5yEafq2Q@mail.gmail.com>
Subject: Re: [PATCH v2] fs: fsnotify: account fsnotify metadata to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Shakeel Butt <shakeelb@google.com>, Yang Shi <yang.s@alibaba-inc.com>, Michal Hocko <mhocko@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

On Tue, Feb 20, 2018 at 2:43 PM, Jan Kara <jack@suse.cz> wrote:
> On Mon 19-02-18 21:07:28, Amir Goldstein wrote:
[...]
>>
>> I just feel sorry about passing an opportunity to improve functionality.
>> The fact that fanotify does not have a way for defining the events queue
>> size is a deficiency IMO, one which I had to work around in the past.
>> I find that assigning group to memgc and configure memcg to desired
>> memory limit and getting Q_OVERFLOW on failure to allocate event
>> is going to be a proper way of addressing this deficiency.
>
> So if you don't pass FAN_Q_UNLIMITED, you will get queue with a fixed size
> and will get Q_OVERFLOW if that is exceeded. So is your concern that you'd
> like some other fixed limit? Larger one or smaller one and for what
> reason?
>

My use case was that with the default queue size, I would get Q_OVERFLOW
on bursty fs workloads, but using  FAN_Q_UNLIMITED and allowing to
consume entire system memory with events was not a desired alternative.
The actual queue size was not important, only allowing admin to tune the
system to bursty workloads without overflowing the event queue.

Something like FAN_Q_BESTEFFORT (i.e. Q_OVERFLOW on ENOMEM)
+ allowing to restrict event allocation to memcg, would allow admin to tune
the system to bursty workloads.

>> But if you don't think we should bind these 2 things together,
>> I'll let Shakeel decide if he want to pursue the Q_OVERFLOW change
>> or not.
>
> So if there is still some uncovered use case for finer tuning of event
> queue length than setting or not setting FAN_Q_UNLIMITED (+ possibly
> putting the task to memcg to limit memory usage), we can talk about how to
> address that but at this point I don't see a strong reason to bind this to
> whether / how events are accounted to memcg...

Agreed.

>
> And we still need to make sure we properly do ENOMEM -> Q_OVERFLOW
> translation and use GFP_NOFAIL for FAN_Q_UNLIMITED groups before merging

Good. it wasn't clear to me from your summary if were going to require
ENOEM -> Q_OVERFLOW before merging this work. If you put it this way,
I think it makes sense to let user to choose between GFP_NOFAIL and
Q_OVERFLOW behavior when queue is not limited, for example by using new
fanotify_init flag FAN_Q_BESTEFFORT (or better name), but I have no problem
with postponing that for later.

Thanks,
Amir.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
