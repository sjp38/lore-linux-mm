Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4ABF06B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 12:16:03 -0400 (EDT)
Received: by lamx15 with SMTP id x15so44410193lam.3
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 09:16:02 -0700 (PDT)
Received: from forward-corp1g.mail.yandex.net (forward-corp1g.mail.yandex.net. [2a02:6b8:0:1402::10])
        by mx.google.com with ESMTPS id y10si8478108lal.143.2015.03.16.09.16.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 09:16:01 -0700 (PDT)
Message-ID: <550701BE.40100@yandex-team.ru>
Date: Mon, 16 Mar 2015 19:15:58 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: rcu-protected get_mm_exe_file()
References: <20150316131257.32340.36600.stgit@buzz> <20150316140720.GA1859@redhat.com>
In-Reply-To: <20150316140720.GA1859@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>, Al Viro <viro@zeniv.linux.org.uk>

On 16.03.2015 17:07, Oleg Nesterov wrote:
> On 03/16, Konstantin Khlebnikov wrote:
>>
>> +/**
>> + * set_mm_exe_file - change a reference to the mm's executable file
>> + *
>> + * This changes mm's executale file (shown as symlink /proc/[pid]/exe).
>> + *
>> + * Main users are mmput(), sys_execve() and sys_prctl(PR_SET_MM_MAP/EXE_FILE).
>> + * Callers prevent concurrent invocations: in mmput() nobody alive left,
>> + * in execve task is single-threaded, prctl holds mmap_sem exclusively.
>> + */
>>   void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
>>   {
>> +	struct file *old_exe_file = rcu_dereference_protected(mm->exe_file,
>> +			!atomic_read(&mm->mm_users) || current->in_execve ||
>> +			lock_is_held(&mm->mmap_sem));
>> +
>>   	if (new_exe_file)
>>   		get_file(new_exe_file);
>> -	if (mm->exe_file)
>> -		fput(mm->exe_file);
>> -	mm->exe_file = new_exe_file;
>> +	rcu_assign_pointer(mm->exe_file, new_exe_file);
>> +	if (old_exe_file)
>> +		fput(old_exe_file);
>>   }
>
> Yes, I think this is correct, __fput() does call_rcu(file_free_rcu). And
> much better than the new lock ;)
>
> Acked-by: Oleg Nesterov <oleg@redhat.com>
>
>
>
> So I think the patch is fine, but personally I dislike the "prctl holds
> mmap_sem exclusively" and rcu_dereference_protected().
>
> I mean, I think we can do another cleanup on top of this change.
>
> 	1. set_mm_exe_file() should be called by exit/exec only, so
> 	   it should use
>
> 		rcu_dereference_protected(mm->exe_file,
> 					atomic_read(&mm->mm_users) <= 1);
>
> 	2. prctl() should not use it, it can do
>
> 	   get_file(new_exe);
> 	   old_exe = xchg(&mm->exe_file);
> 	   if (old_exe)
> 	   	fput(old_exe);

I think smp_mb() is required before xchg() or
probably this stuff should be hidden inside yet another magic RCU macro
( with two screens of comments =)

>
> 	3. and we can remove down_write(mmap_sem) from prctl paths.
>
> 	   Actually we can do this even without xchg() above, but we might
> 	   want to kill MMF_EXE_FILE_CHANGED and test_and_set_bit() check.
>
> What do you think?
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
