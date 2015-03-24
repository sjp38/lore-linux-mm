Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1AF7A6B006C
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 13:13:36 -0400 (EDT)
Received: by lagg8 with SMTP id g8so164990138lag.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 10:13:35 -0700 (PDT)
Received: from forward-corp1f.mail.yandex.net (forward-corp1f.mail.yandex.net. [2a02:6b8:0:801::10])
        by mx.google.com with ESMTPS id jp2si3517320lab.7.2015.03.24.10.13.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 10:13:34 -0700 (PDT)
Message-ID: <55119B3B.5020403@yandex-team.ru>
Date: Tue, 24 Mar 2015 20:13:31 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix lockdep build in rcu-protected get_mm_exe_file()
References: <20150320144715.24899.24547.stgit@buzz> <1427134273.2412.12.camel@stgolabs.net> <20150323191055.GA10212@redhat.com>
In-Reply-To: <20150323191055.GA10212@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>, Davidlohr Bueso <dave@stgolabs.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On 23.03.2015 22:10, Oleg Nesterov wrote:
> On 03/23, Davidlohr Bueso wrote:
>>
>>   void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
>>   {
>>   	struct file *old_exe_file = rcu_dereference_protected(mm->exe_file,
>> -			!atomic_read(&mm->mm_users) || current->in_execve ||
>> -			lock_is_held(&mm->mmap_sem));
>> +			!atomic_read(&mm->mm_users) || current->in_execve);
>
> Thanks, looks correct at first glance...
>
> But can't we remove the ->in_execve check above? and check
>
> 			atomic_read(&mm->mm_users) <= 1
>
> instead. OK, this is subjective, I won't insist. Just current->in_execve
> looks a bit confusing, it means "I swear, the caller is flush_old_exec()
> and this mm is actualy bprm->mm".
>
> "atomic_read(&mm->mm_users) <= 1" looks a bit more "safe". But again,
> I won't insist.

Not so safe: this will race with get_task_mm().
A lot of proc files grab temporary reference to task mm.
But this just a debug -- we can place here "true".

>
> Oleg.
>

-- 
Konstantin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
