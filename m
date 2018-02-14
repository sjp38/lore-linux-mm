Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id BE4B46B0003
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 04:00:18 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id n70so25416991ywd.20
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 01:00:18 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d83sor1378919ywe.389.2018.02.14.01.00.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Feb 2018 01:00:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALvZod7FTNzoGfGnaorqjk4KEsxJFdz1pApHi04P1cF10ejxpQ@mail.gmail.com>
References: <20171030124358.GF23278@quack2.suse.cz> <76a4d544-833a-5f42-a898-115640b6783b@alibaba-inc.com>
 <20171031101238.GD8989@quack2.suse.cz> <20171109135444.znaksm4fucmpuylf@dhcp22.suse.cz>
 <10924085-6275-125f-d56b-547d734b6f4e@alibaba-inc.com> <20171114093909.dbhlm26qnrrb2ww4@dhcp22.suse.cz>
 <afa2dc80-16a3-d3d1-5090-9430eaafc841@alibaba-inc.com> <20171115093131.GA17359@quack2.suse.cz>
 <CALvZod6HJO73GUfLemuAXJfr4vZ8xMOmVQpFO3vJRog-s2T-OQ@mail.gmail.com>
 <CAOQ4uxg-mTgQfTv-qO6EVwfttyOy+oFyAHyFDKTQsDOkQPyyfA@mail.gmail.com>
 <20180124103454.ibuqt3njaqbjnrfr@quack2.suse.cz> <CAOQ4uxhDpBBUrr0JWRBaNQTTaUeJ4=gnM0iij2KivaGgp1ggtg@mail.gmail.com>
 <CALvZod4PyqfaqgEswegF5uOjNwVwbY1C4ptJB0Ouvgchv2aVFg@mail.gmail.com>
 <CAOQ4uxhyZNghjQU5atNv5xtgdHzA75UayphCyQDzxjM8GDTv3Q@mail.gmail.com>
 <CALvZod5H4eL=YtZ3zkGG3p8gD+3=qnC3siUw1zpKL+128KufAA@mail.gmail.com>
 <CAOQ4uxgJqn0CJaf=LMH-iv2g1MJZwPM97K6iCtzrcY3eoN6KjA@mail.gmail.com>
 <CAOQ4uxjgKUFJ_uhyrQdcTs1FzcN6JrR_JpPc9QBrGJEU+cf65w@mail.gmail.com>
 <CALvZod45r7oW=HWH7KJyvFhJWB=6+Si54JK7E0Mx_2gLTZd1Pg@mail.gmail.com>
 <CAOQ4uxghwNg9Ni23EQA-971-qAaTNceSZS2MSvK06uEjoXG_yg@mail.gmail.com> <CALvZod7FTNzoGfGnaorqjk4KEsxJFdz1pApHi04P1cF10ejxpQ@mail.gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 14 Feb 2018 11:00:15 +0200
Message-ID: <CAOQ4uxhRW=AN5UUHiWYaQp=Nw29ys_1Ak6ADCAvCLTUOqaYn6g@mail.gmail.com>
Subject: Re: [PATCH v2] fs: fsnotify: account fsnotify metadata to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Jan Kara <jack@suse.cz>, Yang Shi <yang.s@alibaba-inc.com>, Michal Hocko <mhocko@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

On Wed, Feb 14, 2018 at 12:20 AM, Shakeel Butt <shakeelb@google.com> wrote:
> On Tue, Feb 13, 2018 at 1:54 PM, Amir Goldstein <amir73il@gmail.com> wrote:
>> On Tue, Feb 13, 2018 at 11:10 PM, Shakeel Butt <shakeelb@google.com> wrote:
[...]
>>>> The question is, do we need the user to also explicitly opt-in for
>>>> Q_OVERFLOW on ENOMEM with FAN_Q_ERR mark mask?
>>>> Should these 2 new APIs be coupled or independent?
>>>>
>>>
>>> Are there any error which are not related to queue overflows? I see
>>> the mention of ENODEV and EOVERFLOW in the discussion. If there are
>>> such errors and might be interesting to the listener then we should
>>> have 2 independent APIs.
>>>
>>
>> These are indeed 2 different use cases.
>> A Q_OVERFLOW event is only expected one of ENOMEM or
>> EOVERFLOW in event->fd, but other events (like open of special device
>> file) can have ENODEV in event->fd.
>>
>> But I am not convinced that those require 2 independent APIs.
>> Specifying FAN_Q_ERR means that the user expects to reads errors
>> from event->fd.
>>
>
> Can you please explain what you mean by 2 independent APIs? I thought
> "no independent APIs" means FAN_Q_ERR can only be used with
> FAN_Q_OVERFLOW and without FAN_Q_OVERFLOW, FAN_Q_ERR is ignored. Is
> that right or I misunderstood?
>

What I initially meant to say was, we actually consider several
behavior changes:
1. Charge event allocations to memcg of listener
2. Queue a Q_OVERFLOW event on ENOMEM of event allocation
3. Report the error to user on metadata->fd (instead of FAN_NOFD)
4. Allow non Q_OVERFLOW event to have negative metadata->fd.

#3 is applicable both to Q_OVERFLOW event and other events that
can't provide and open file descriptor for some reason (i.e. ENODEV).

#1 and #2 could be independent, but they both make sense together.
When enabling #1 user increases the chance of ENOMEM and therefore
#2 is desired. So if we are going to let distro/admin/programmer to
opt-in for what we believe to be a "change of behavior for the best", then
we could consider that opting-in  for #1 will also imply opting-in for #2
and #3 (as the means to report Q_OVERFLOW due to ENOMEM).

I guess we will need to allow user to opt-in to #4 and #3 by FAN_Q_ERR
mask flag to cover the ENODEV case independently from opting-in to
charging memcg.

How was I doing in the balance of adding clarity vs. adding confusion?

Thanks,
Amir.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
