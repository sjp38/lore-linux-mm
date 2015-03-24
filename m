Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 09A806B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 14:15:35 -0400 (EDT)
Received: by lbcmq2 with SMTP id mq2so831691lbc.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 11:15:34 -0700 (PDT)
Received: from mail-lb0-x22c.google.com (mail-lb0-x22c.google.com. [2a00:1450:4010:c04::22c])
        by mx.google.com with ESMTPS id rt5si3509930lac.158.2015.03.24.11.15.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 11:15:33 -0700 (PDT)
Received: by lbbug6 with SMTP id ug6so707672lbb.3
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 11:15:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150324181016.GA9678@redhat.com>
References: <20150320144715.24899.24547.stgit@buzz>
	<1427134273.2412.12.camel@stgolabs.net>
	<20150323191055.GA10212@redhat.com>
	<55119B3B.5020403@yandex-team.ru>
	<20150324181016.GA9678@redhat.com>
Date: Tue, 24 Mar 2015 21:15:32 +0300
Message-ID: <CALYGNiP15BLtxMmMnpEu94jZBtce7tCtJnavrguqFr1d2XxH_A@mail.gmail.com>
Subject: Re: [PATCH] mm: fix lockdep build in rcu-protected get_mm_exe_file()
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Davidlohr Bueso <dave@stgolabs.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Mar 24, 2015 at 9:10 PM, Oleg Nesterov <oleg@redhat.com> wrote:
> On 03/24, Konstantin Khlebnikov wrote:
>>
>> On 23.03.2015 22:10, Oleg Nesterov wrote:
>>> On 03/23, Davidlohr Bueso wrote:
>>>>
>>>>   void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
>>>>   {
>>>>     struct file *old_exe_file = rcu_dereference_protected(mm->exe_file,
>>>> -                   !atomic_read(&mm->mm_users) || current->in_execve ||
>>>> -                   lock_is_held(&mm->mmap_sem));
>>>> +                   !atomic_read(&mm->mm_users) || current->in_execve);
>>>
>>> Thanks, looks correct at first glance...
>>>
>>> But can't we remove the ->in_execve check above? and check
>>>
>>>                      atomic_read(&mm->mm_users) <= 1
>>>
>>> instead. OK, this is subjective, I won't insist. Just current->in_execve
>>> looks a bit confusing, it means "I swear, the caller is flush_old_exec()
>>> and this mm is actualy bprm->mm".
>>>
>>> "atomic_read(&mm->mm_users) <= 1" looks a bit more "safe". But again,
>>> I won't insist.
>>
>> Not so safe: this will race with get_task_mm().
>
> How?

I mean rcu/lockdep debug migh race with get_task_mm() and generate
false-positive warning about non-protected rcu_dereference.

>
> If set_mm_exe_file() can race with get_task_mm() then we have a bug.
> And it will be reported ;)
>
>> A lot of proc files grab temporary reference to task mm.
>> But this just a debug -- we can place here "true".
>
> Yeees, probably rcu_dereference_raw() would be even better. set_mm_exe_file()
> must be called only if nobody but us can access this mm.

Yep.

>
> Oleg.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
