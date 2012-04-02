Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 98C276B007E
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 10:48:33 -0400 (EDT)
Date: Mon, 2 Apr 2012 16:48:21 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 6/7] mm: kill vma flag VM_EXECUTABLE
Message-ID: <20120402144821.GA3334@redhat.com>
References: <20120331091049.19373.28994.stgit@zurg> <20120331092929.19920.54540.stgit@zurg> <20120331201324.GA17565@redhat.com> <20120331203912.GB687@moon> <4F79755B.3030703@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F79755B.3030703@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric Paris <eparis@redhat.com>, "linux-security-module@vger.kernel.org"@jasper.es

On 04/02, Konstantin Khlebnikov wrote:
>
> In this patch I leave mm->exe_file lockless.
> After exec/fork we can change it only for current task and only if mm->mm_users == 1.
>
> something like this:
>
> task_lock(current);

OK, this protects against the race with get_task_mm()

> if (atomic_read(&current->mm->mm_users) == 1)

this means PR_SET_MM_EXE_FILE can fail simply because someone did
get_task_mm(). Or the caller is multithreaded.

> 	set_mm_exe_file(current->mm, new_file);

No, fput() can sleep.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
