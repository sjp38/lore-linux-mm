Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 066C46B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 15:13:18 -0400 (EDT)
Received: by qgep97 with SMTP id p97so30612034qge.1
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 12:13:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 66si1581990qkx.102.2015.03.23.12.12.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Mar 2015 12:12:56 -0700 (PDT)
Date: Mon, 23 Mar 2015 20:10:55 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm: fix lockdep build in rcu-protected
	get_mm_exe_file()
Message-ID: <20150323191055.GA10212@redhat.com>
References: <20150320144715.24899.24547.stgit@buzz> <1427134273.2412.12.camel@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427134273.2412.12.camel@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On 03/23, Davidlohr Bueso wrote:
>
>  void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
>  {
>  	struct file *old_exe_file = rcu_dereference_protected(mm->exe_file,
> -			!atomic_read(&mm->mm_users) || current->in_execve ||
> -			lock_is_held(&mm->mmap_sem));
> +			!atomic_read(&mm->mm_users) || current->in_execve);

Thanks, looks correct at first glance...

But can't we remove the ->in_execve check above? and check

			atomic_read(&mm->mm_users) <= 1

instead. OK, this is subjective, I won't insist. Just current->in_execve
looks a bit confusing, it means "I swear, the caller is flush_old_exec()
and this mm is actualy bprm->mm".

"atomic_read(&mm->mm_users) <= 1" looks a bit more "safe". But again,
I won't insist.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
