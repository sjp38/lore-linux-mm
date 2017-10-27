Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id E589A6B0253
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 05:48:02 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id b186so10941857iof.21
        for <linux-mm@kvack.org>; Fri, 27 Oct 2017 02:48:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r187sor771768ith.57.2017.10.27.02.48.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 27 Oct 2017 02:48:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+Y=NCy20_k4YcrCF2Q0f16UPDZBVAF=RkkZ0uSxZq5XaA@mail.gmail.com>
References: <089e0825eec8955c1f055c83d476@google.com> <20171027093418.om5e566srz2ztsrk@dhcp22.suse.cz>
 <CACT4Y+Y=NCy20_k4YcrCF2Q0f16UPDZBVAF=RkkZ0uSxZq5XaA@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 27 Oct 2017 11:47:40 +0200
Message-ID: <CACT4Y+ZTE70hJ5u=G4KbKFTVPowOf=uf2BZnB33=5+etEpG8NA@mail.gmail.com>
Subject: Re: possible deadlock in lru_add_drain_all
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: syzbot <bot+e7353c7141ff7cbb718e4c888a14fa92de41ebaa@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, jglisse@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, shli@fb.com, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com

On Fri, Oct 27, 2017 at 11:44 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Fri, Oct 27, 2017 at 11:34 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> On Fri 27-10-17 02:22:40, syzbot wrote:
>>> Hello,
>>>
>>> syzkaller hit the following crash on
>>> a31cc455c512f3f1dd5f79cac8e29a7c8a617af8
>>> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
>>> compiler: gcc (GCC) 7.1.1 20170620
>>> .config is attached
>>> Raw console output is attached.
>>
>> I do not see such a commit. My linux-next top is next-20171018

As far as I understand linux-next constantly recreates tree, so that
all commits hashes are destroyed.
Somebody mentioned some time ago about linux-next-something tree which
keeps all of the history (but I don't remember it off the top of my
head).


>> [...]
>>> Chain exists of:
>>>   cpu_hotplug_lock.rw_sem --> &pipe->mutex/1 --> &sb->s_type->i_mutex_key#9
>>>
>>>  Possible unsafe locking scenario:
>>>
>>>        CPU0                    CPU1
>>>        ----                    ----
>>>   lock(&sb->s_type->i_mutex_key#9);
>>>                                lock(&pipe->mutex/1);
>>>                                lock(&sb->s_type->i_mutex_key#9);
>>>   lock(cpu_hotplug_lock.rw_sem);
>>
>> I am quite confused about this report. Where exactly is the deadlock?
>> I do not see where we would get pipe mutex from inside of the hotplug
>> lock. Is it possible this is just a false possitive due to cross release
>> feature?
>
>
> As far as I understand this CPU0/CPU1 scheme works only for simple
> cases with 2 mutexes. This seem to have larger cycle as denoted by
> "the existing dependency chain (in reverse order) is:" section.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
