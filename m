Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 542E06B0044
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 12:20:04 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so3154259bkw.14
        for <linux-mm@kvack.org>; Mon, 02 Apr 2012 09:20:02 -0700 (PDT)
Message-ID: <4F79D1AF.7080100@openvz.org>
Date: Mon, 02 Apr 2012 20:19:59 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 6/7] mm: kill vma flag VM_EXECUTABLE
References: <20120331091049.19373.28994.stgit@zurg> <20120331092929.19920.54540.stgit@zurg> <20120331201324.GA17565@redhat.com> <20120331203912.GB687@moon> <4F79755B.3030703@openvz.org> <20120402144821.GA3334@redhat.com>
In-Reply-To: <20120402144821.GA3334@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric Paris <eparis@redhat.com>

Oleg Nesterov wrote:
> On 04/02, Konstantin Khlebnikov wrote:
>>
>> In this patch I leave mm->exe_file lockless.
>> After exec/fork we can change it only for current task and only if mm->mm_users == 1.
>>
>> something like this:
>>
>> task_lock(current);
>
> OK, this protects against the race with get_task_mm()
>
>> if (atomic_read(&current->mm->mm_users) == 1)
>
> this means PR_SET_MM_EXE_FILE can fail simply because someone did
> get_task_mm(). Or the caller is multithreaded.

This is sad, seems like we should keep mm->exe_file protection by mm->mmap_sem.
So, I'll rework this patch...

>
>> 	set_mm_exe_file(current->mm, new_file);
>
> No, fput() can sleep.

Yep

>
> Oleg.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
