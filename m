Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id D03326B0006
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 01:30:31 -0500 (EST)
Received: by mail-yw0-f200.google.com with SMTP id z193so21216294ywd.13
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 22:30:31 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l36sor2357637ybe.80.2018.02.12.22.30.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 12 Feb 2018 22:30:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAOQ4uxgJqn0CJaf=LMH-iv2g1MJZwPM97K6iCtzrcY3eoN6KjA@mail.gmail.com>
References: <20171030124358.GF23278@quack2.suse.cz> <76a4d544-833a-5f42-a898-115640b6783b@alibaba-inc.com>
 <20171031101238.GD8989@quack2.suse.cz> <20171109135444.znaksm4fucmpuylf@dhcp22.suse.cz>
 <10924085-6275-125f-d56b-547d734b6f4e@alibaba-inc.com> <20171114093909.dbhlm26qnrrb2ww4@dhcp22.suse.cz>
 <afa2dc80-16a3-d3d1-5090-9430eaafc841@alibaba-inc.com> <20171115093131.GA17359@quack2.suse.cz>
 <CALvZod6HJO73GUfLemuAXJfr4vZ8xMOmVQpFO3vJRog-s2T-OQ@mail.gmail.com>
 <CAOQ4uxg-mTgQfTv-qO6EVwfttyOy+oFyAHyFDKTQsDOkQPyyfA@mail.gmail.com>
 <20180124103454.ibuqt3njaqbjnrfr@quack2.suse.cz> <CAOQ4uxhDpBBUrr0JWRBaNQTTaUeJ4=gnM0iij2KivaGgp1ggtg@mail.gmail.com>
 <CALvZod4PyqfaqgEswegF5uOjNwVwbY1C4ptJB0Ouvgchv2aVFg@mail.gmail.com>
 <CAOQ4uxhyZNghjQU5atNv5xtgdHzA75UayphCyQDzxjM8GDTv3Q@mail.gmail.com>
 <CALvZod5H4eL=YtZ3zkGG3p8gD+3=qnC3siUw1zpKL+128KufAA@mail.gmail.com> <CAOQ4uxgJqn0CJaf=LMH-iv2g1MJZwPM97K6iCtzrcY3eoN6KjA@mail.gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Tue, 13 Feb 2018 08:30:27 +0200
Message-ID: <CAOQ4uxjgKUFJ_uhyrQdcTs1FzcN6JrR_JpPc9QBrGJEU+cf65w@mail.gmail.com>
Subject: Re: [PATCH v2] fs: fsnotify: account fsnotify metadata to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Jan Kara <jack@suse.cz>, Yang Shi <yang.s@alibaba-inc.com>, Michal Hocko <mhocko@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

On Thu, Jan 25, 2018 at 10:36 PM, Amir Goldstein <amir73il@gmail.com> wrote:
> On Thu, Jan 25, 2018 at 10:20 PM, Shakeel Butt <shakeelb@google.com> wrote:
>> On Wed, Jan 24, 2018 at 11:51 PM, Amir Goldstein <amir73il@gmail.com> wrote:
>>>
>>> There is a nicer alternative, instead of failing the file access,
>>> an overflow event can be queued. I sent a patch for that and Jan
>>> agreed to the concept, but thought we should let user opt-in for this
>>> change:
>>> https://marc.info/?l=linux-fsdevel&m=150944704716447&w=2
>>>
>>> So IMO, if user opts-in for OVERFLOW instead of ENOMEM,
>>> charging the listener memcg would be non controversial.
>>> Otherwise, I cannot say that starting to charge the listener memgc
>>> for events won't break any application.
>>>
>>

Shakeel, Jan,

Reviving this thread and adding linux-api, because I think it is important to
agree on the API before patches.

The last message on the thread you referenced suggest an API change
for opting in for Q_OVERFLOW on ENOMEM:
https://marc.info/?l=linux-api&m=150946878623441&w=2

However, the suggested API change in in fanotify_mark() syscall and
this is not the time when fsnotify_group is initialized.
I believe for opting-in to accounting events for listener, you
will need to add an opt-in flag for the fanotify_init() syscall.

Something like FAN_GROUP_QUEUE  (better name is welcome)
which is mutually exclusive (?) with FAN_UNLIMITED_QUEUE.

The question is, do we need the user to also explicitly opt-in for
Q_OVERFLOW on ENOMEM with FAN_Q_ERR mark mask?
Should these 2 new APIs be coupled or independent?

Another question is whether FAN_GROUP_QUEUE may require
less than CAP_SYS_ADMIN? Of course for now, this is only a
semantic change, because fanotify_init() requires CAP_SYS_ADMIN
but as the documentation suggests, this may be relaxed in the future.

Thought?

Amir.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
