Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 075656B0028
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 14:07:31 -0500 (EST)
Received: by mail-yw0-f197.google.com with SMTP id e125so8179361ywh.10
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 11:07:31 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q7sor4828755ybk.52.2018.02.19.11.07.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Feb 2018 11:07:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180219135027.fd6doess7satenxk@quack2.suse.cz>
References: <CALvZod4PyqfaqgEswegF5uOjNwVwbY1C4ptJB0Ouvgchv2aVFg@mail.gmail.com>
 <CAOQ4uxhyZNghjQU5atNv5xtgdHzA75UayphCyQDzxjM8GDTv3Q@mail.gmail.com>
 <CALvZod5H4eL=YtZ3zkGG3p8gD+3=qnC3siUw1zpKL+128KufAA@mail.gmail.com>
 <CAOQ4uxgJqn0CJaf=LMH-iv2g1MJZwPM97K6iCtzrcY3eoN6KjA@mail.gmail.com>
 <CAOQ4uxjgKUFJ_uhyrQdcTs1FzcN6JrR_JpPc9QBrGJEU+cf65w@mail.gmail.com>
 <CALvZod45r7oW=HWH7KJyvFhJWB=6+Si54JK7E0Mx_2gLTZd1Pg@mail.gmail.com>
 <CAOQ4uxghwNg9Ni23EQA-971-qAaTNceSZS2MSvK06uEjoXG_yg@mail.gmail.com>
 <CALvZod7FTNzoGfGnaorqjk4KEsxJFdz1pApHi04P1cF10ejxpQ@mail.gmail.com>
 <CALvZod4SNwWHYZQsphB90cY-wc8WSLurKsA2kNxfVKV-upwy9A@mail.gmail.com>
 <CAOQ4uxifddquri4BNqBSKv6O_b13=C08kKYinTo9+m56z1n+aQ@mail.gmail.com> <20180219135027.fd6doess7satenxk@quack2.suse.cz>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 19 Feb 2018 21:07:28 +0200
Message-ID: <CAOQ4uxjkfTTJ7nxrtj8ZsKcsWfBz=J0RPv3N=u3JaskRgG9aWw@mail.gmail.com>
Subject: Re: [PATCH v2] fs: fsnotify: account fsnotify metadata to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Shakeel Butt <shakeelb@google.com>, Yang Shi <yang.s@alibaba-inc.com>, Michal Hocko <mhocko@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

On Mon, Feb 19, 2018 at 3:50 PM, Jan Kara <jack@suse.cz> wrote:
[...]
> For fanotify without FAN_UNLIMITED_QUEUE the situation is similar as for
> inotify - IMO low practical impact, apps should generally handle queue
> overflow so I don't see a need for any opt in (more accurate memcg charging
> takes precedense over possibly broken apps).
>
> For fanotify with FAN_UNLIMITED_QUEUE the situation is somewhat different -
> firstly there is a practical impact (memory consumption is not limited by
> anything else) and secondly there are higher chances of the application
> breaking (no queue overflow expected) and also that this breakage won't be
> completely harmless (e.g., the application participates in securing the
> system). I've been thinking about this "conflict of interests" for some
> time and currently I think that the best handling of this is that by
> default events for FAN_UNLIMITED_QUEUE groups will get allocated with
> GFP_NOFAIL - such groups can be created only by global CAP_SYS_ADMIN anyway
> so it is reasonably safe against misuse (and since the allocations are
> small it is in fact equivalent to current status quo, just more explicit).
> That way application won't see unexpected queue overflow. The process
> generating event may be looping in the allocator but that is the case
> currently as well. Also the memcg with the consumer of events will have
> higher chances of triggering oom-kill if events consume too much memory but
> I don't see how this is not a good thing by default - and if such reaction
> is not desirable, there's memcg's oom_control to tune the OOM behavior
> which has capabilities far beyond of what we could invent for fanotify...
>
> What do you think Amir?
>

If I followed all your reasoning correctly, you propose to change behavior to
always account events to group memcg and never fail event allocation,
without any change of API and without opting-in for new behavior?
I think it makes sense. I can't point at any expected breakage,
so overall, this would be a good change.

I just feel sorry about passing an opportunity to improve functionality.
The fact that fanotify does not have a way for defining the events queue
size is a deficiency IMO, one which I had to work around in the past.
I find that assigning group to memgc and configure memcg to desired
memory limit and getting Q_OVERFLOW on failure to allocate event
is going to be a proper way of addressing this deficiency.

But if you don't think we should bind these 2 things together,
I'll let Shakeel decide if he want to pursue the Q_OVERFLOW change
or not.

Thanks,
Amir.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
