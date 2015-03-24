Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id F27776B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 14:12:22 -0400 (EDT)
Received: by weop45 with SMTP id p45so848678weo.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 11:12:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id bb4si719944wib.69.2015.03.24.11.12.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 11:12:21 -0700 (PDT)
Date: Tue, 24 Mar 2015 19:10:16 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm: fix lockdep build in rcu-protected
	get_mm_exe_file()
Message-ID: <20150324181016.GA9678@redhat.com>
References: <20150320144715.24899.24547.stgit@buzz> <1427134273.2412.12.camel@stgolabs.net> <20150323191055.GA10212@redhat.com> <55119B3B.5020403@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55119B3B.5020403@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On 03/24, Konstantin Khlebnikov wrote:
>
> On 23.03.2015 22:10, Oleg Nesterov wrote:
>> On 03/23, Davidlohr Bueso wrote:
>>>
>>>   void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
>>>   {
>>>   	struct file *old_exe_file = rcu_dereference_protected(mm->exe_file,
>>> -			!atomic_read(&mm->mm_users) || current->in_execve ||
>>> -			lock_is_held(&mm->mmap_sem));
>>> +			!atomic_read(&mm->mm_users) || current->in_execve);
>>
>> Thanks, looks correct at first glance...
>>
>> But can't we remove the ->in_execve check above? and check
>>
>> 			atomic_read(&mm->mm_users) <= 1
>>
>> instead. OK, this is subjective, I won't insist. Just current->in_execve
>> looks a bit confusing, it means "I swear, the caller is flush_old_exec()
>> and this mm is actualy bprm->mm".
>>
>> "atomic_read(&mm->mm_users) <= 1" looks a bit more "safe". But again,
>> I won't insist.
>
> Not so safe: this will race with get_task_mm().

How?

If set_mm_exe_file() can race with get_task_mm() then we have a bug.
And it will be reported ;)

> A lot of proc files grab temporary reference to task mm.
> But this just a debug -- we can place here "true".

Yeees, probably rcu_dereference_raw() would be even better. set_mm_exe_file()
must be called only if nobody but us can access this mm.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
